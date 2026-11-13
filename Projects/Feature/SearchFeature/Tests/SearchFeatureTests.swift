import AppDetailFeature
import ComposableArchitecture
import Domain
import Foundation
import Testing
@testable import SearchFeature

/// TestStore로 검색 리듀서를 검증한다. (docs/feature-guide.md#search 의 "테스트 목록")
@MainActor
@Suite("SearchFeature")
struct SearchFeatureTests {
    /// id가 start..<start+count인 앱 목록
    static func apps(_ range: Range<Int>) -> [AppSummary] {
        range.map {
            AppSummary(id: $0, name: "앱 \($0)", sellerName: "개발사", iconURL: nil,
                       primaryGenre: "유틸리티", averageRating: 4, ratingCount: 10, formattedPrice: "무료")
        }
    }

    @Test("onAppear → 최근 검색어 구독")
    func observeRecentKeywords() async {
        let store = TestStore(initialState: SearchFeature.State()) {
            SearchFeature()
        } withDependencies: {
            $0.recentKeywordUseCase.observe = {
                AsyncThrowingStream {
                    $0.yield(RecentKeyword.mocks)
                    $0.finish()
                }
            }
        }

        await store.send(.onAppear)
        await store.receive(\.recentKeywordsUpdated) {
            $0.recentSearch = RecentKeyword.mocks
        }
    }

    @Test("입력 → 300ms 디바운스 후 자동 검색 (최근 검색어 저장 안 함), 연속 입력은 마지막만")
    func debouncedSearch() async {
        let clock = TestClock()
        let apps = Self.apps(0..<3)
        let store = TestStore(initialState: SearchFeature.State()) {
            SearchFeature()
        } withDependencies: {
            $0.continuousClock = clock
            $0.searchAppsUseCase.execute = { _, page in
                Page(items: apps, total: 3, offset: page.offset, limit: page.limit)
            }
        }

        await store.send(.inputKeyword("카")) { $0.searchText = "카" }
        await clock.advance(by: .milliseconds(200))
        await store.send(.inputKeyword("카카")) { $0.searchText = "카카" }
        await clock.advance(by: .milliseconds(300))

        await store.receive(\.debouncedSearch, "카카") {
            $0.searchedKeyword = "카카"
            $0.loadState = .loading
        }
        await store.receive(\.searchResponse.success) {
            $0.searchResults = IdentifiedArray(uniqueElements: apps)
            $0.total = 3
            $0.loadState = .loaded
        }
    }

    @Test("검색 버튼 → 최근 검색어 저장 + 즉시 검색")
    func searchButtonTapped() async {
        let saved = LockIsolated<[String]>([])
        var state = SearchFeature.State()
        state.searchText = "  토스 "

        let store = TestStore(initialState: state) {
            SearchFeature()
        } withDependencies: {
            $0.recentKeywordUseCase.save = { keyword in saved.withValue { $0.append(keyword) } }
            $0.searchAppsUseCase.execute = { _, page in .empty(page) }
        }

        await store.send(.searchButtonTapped) {
            $0.searchedKeyword = "토스"
            $0.loadState = .loading
        }
        await store.receive(\.searchResponse.success) {
            $0.loadState = .empty
        }
        #expect(saved.value == ["토스"])
    }

    @Test("입력을 모두 지우면 결과를 초기화하고 최근 검색어로 돌아간다")
    func clearInput() async {
        var state = SearchFeature.State()
        state.searchText = "카카오"
        state.searchedKeyword = "카카오"
        state.searchResults = IdentifiedArray(uniqueElements: Self.apps(0..<3))
        state.total = 3
        state.loadState = .loaded

        let store = TestStore(initialState: state) {
            SearchFeature()
        }

        await store.send(.inputKeyword("")) {
            $0.searchText = ""
            $0.searchedKeyword = ""
            $0.searchResults = []
            $0.total = 0
            $0.loadState = .idle
        }
    }

    @Test("검색 실패 → 에러, 다시 시도 → 마지막 검색어로 재검색")
    func failureThenRetry() async {
        let attempt = LockIsolated(0)
        let apps = Self.apps(0..<1)
        var state = SearchFeature.State()
        state.searchText = "지도"

        let store = TestStore(initialState: state) {
            SearchFeature()
        } withDependencies: {
            $0.recentKeywordUseCase.save = { _ in }
            $0.searchAppsUseCase.execute = { _, page in
                attempt.withValue { $0 += 1 }
                if attempt.value == 1 { throw DomainError.network }
                return Page(items: apps, total: 1, offset: page.offset, limit: page.limit)
            }
        }

        await store.send(.searchButtonTapped) {
            $0.searchedKeyword = "지도"
            $0.loadState = .loading
        }
        await store.receive(\.searchResponse.failure) {
            $0.loadState = .failed(DomainError.network.message)
        }

        await store.send(.retryButtonTapped) {
            $0.loadState = .loading
        }
        await store.receive(\.searchResponse.success) {
            $0.searchResults = IdentifiedArray(uniqueElements: apps)
            $0.total = 1
            $0.loadState = .loaded
        }
    }

    @Test("끝에서 5번째 셀이 보이면 다음 페이지를 이어 붙인다")
    func pagination() async {
        let first = Self.apps(0..<20)
        let second = Self.apps(20..<25)
        var state = SearchFeature.State()
        state.searchedKeyword = "게임"
        state.searchResults = IdentifiedArray(uniqueElements: first)
        state.total = 25
        state.nextPage = PageRequest(offset: 20)
        state.loadState = .loaded

        let store = TestStore(initialState: state) {
            SearchFeature()
        } withDependencies: {
            $0.searchAppsUseCase.execute = { term, page in
                #expect(term == "게임")
                #expect(page.offset == 20)
                return Page(items: second, total: 25, offset: 20, limit: 20)
            }
        }

        await store.send(.rowAppeared(10))   // 끝에서 5번째보다 위 → 무시
        await store.send(.rowAppeared(15)) {
            $0.isLoadingNextPage = true
        }
        await store.receive(\.nextPageResponse.success) {
            $0.isLoadingNextPage = false
            $0.searchResults.append(contentsOf: second)
            $0.nextPage = nil
        }
    }

    @Test("다음 페이지 실패 → 하단 다시 시도, 스크롤로는 자동 재시도하지 않음")
    func paginationFailure() async {
        var state = SearchFeature.State()
        state.searchedKeyword = "게임"
        state.searchResults = IdentifiedArray(uniqueElements: Self.apps(0..<20))
        state.total = 25
        state.nextPage = PageRequest(offset: 20)
        state.loadState = .loaded

        let store = TestStore(initialState: state) {
            SearchFeature()
        } withDependencies: {
            $0.searchAppsUseCase.execute = { _, _ in throw DomainError.network }
        }

        await store.send(.rowAppeared(19)) {
            $0.isLoadingNextPage = true
        }
        await store.receive(\.nextPageResponse.failure) {
            $0.isLoadingNextPage = false
            $0.isNextPageFailed = true
        }
        await store.send(.rowAppeared(19))   // 실패 후에는 무시
    }

    @Test("최근 검색어 삭제 실패 → 알럿")
    func deleteFailure() async {
        let store = TestStore(initialState: SearchFeature.State()) {
            SearchFeature()
        } withDependencies: {
            $0.recentKeywordUseCase.delete = { _ in throw DomainError.storage }
        }

        await store.send(.deleteRow("카카오"))
        await store.receive(\.deleteFail) {
            $0.alert = AlertState {
                TextState("삭제하지 못했어요")
            } actions: {
                ButtonState(role: .cancel) { TextState("확인") }
            } message: {
                TextState(DomainError.storage.message)
            }
        }
    }

    @Test("결과 셀 탭 → 상세 push")
    func resultTapped() async {
        let app = AppSummary.mock
        let store = TestStore(initialState: SearchFeature.State()) {
            SearchFeature()
        }

        await store.send(.resultTapped(app)) {
            $0.path[id: 0] = .detail(AppDetailFeature.State(app: app))
        }
    }
}
