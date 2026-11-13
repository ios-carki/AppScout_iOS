import AppDetailFeature
import ComposableArchitecture
import Domain
import Foundation

/// 검색 화면 리듀서
///
/// 와이어프레임: docs/wireframe/AppScout_Wireframe.pdf S1~S3
/// 요구사항·체크리스트: docs/feature-guide.md#search
@Reducer
public struct SearchFeature {
    /// 검색 탭 내비게이션 스택에 push되는 화면
    @Reducer
    public enum Path {
        case detail(AppDetailFeature)
    }

    @ObservableState
    public struct State: Equatable {
        var searchText: String = ""
        var recentSearch: [RecentKeyword] = []

        // 검색
        var searchedKeyword = ""
        var searchResults: IdentifiedArrayOf<AppSummary> = []
        var total = 0
        var nextPage: PageRequest?

        enum LoadState: Equatable {
            case idle  // 검색 전 -> 최근 검색어 표시
            case loading  // 첫 검색 중
            case loaded  // 결과 있음
            case empty  // 결과 0개
            case failed(String)  // 검색 실패(에러 메시지)
        }
        var loadState: LoadState = .idle
        var isLoadingNextPage = false
        var isNextPageFailed = false  // 다음 페이지 실패 → 하단 "다시 시도" (C5)

        var path = StackState<Path.State>()
        @Presents var alert: AlertState<Action.Alert>?

        public init() {}
    }

    public enum Action {
        case onAppear
        case recentKeywordsUpdated([RecentKeyword])
        case inputKeyword(String)
        case searchButtonTapped
        case cellTapped(RecentKeyword)
        case saveFail(String)
        case deleteAllRecentSearch
        case deleteRow(String)
        case deleteFail(String)

        // 검색
        case debouncedSearch(String)
        case searchResponse(Result<Page<AppSummary>, any Error>)
        case retryButtonTapped
        case rowAppeared(AppSummary.ID)
        case nextPageResponse(Result<Page<AppSummary>, any Error>)
        case nextPageRetryButtonTapped
        case resultTapped(AppSummary)

        case path(StackActionOf<Path>)
        case alert(PresentationAction<Alert>)

        public enum Alert: Equatable {}
    }

    /// 검색 API (페이지네이션)
    @Dependency(\.searchAppsUseCase) var searchAppsUseCase
    /// 최근 검색어 저장·구독·삭제
    @Dependency(\.recentKeywordUseCase) var recentKeywordUseCase
    /// 입력 디바운스(300ms)
    @Dependency(\.continuousClock) var continuousClock

    enum CancelID {
        case recentKeywords
        case search
        case nextPage
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    for try await keywords in recentKeywordUseCase.observe() {
                        await send(.recentKeywordsUpdated(keywords))
                    }
                }
                .cancellable(id: CancelID.recentKeywords, cancelInFlight: true)

            case .recentKeywordsUpdated(let recentKeywords):
                state.recentSearch = recentKeywords
                return .none

            case .inputKeyword(let text):
                state.searchText = text
                let keyword = text.trimmingCharacters(in: .whitespacesAndNewlines)

                guard !keyword.isEmpty else {
                    state.searchedKeyword = ""
                    state.searchResults = []
                    state.total = 0
                    state.nextPage = nil
                    state.isLoadingNextPage = false
                    state.isNextPageFailed = false
                    state.loadState = .idle

                    return .merge(
                        .cancel(id: CancelID.search),
                        .cancel(id: CancelID.nextPage)
                    )
                }

                return .run { send in
                    try await continuousClock.sleep(for: .milliseconds(300))
                    await send(.debouncedSearch(keyword))
                }
                .cancellable(id: CancelID.search, cancelInFlight: true)

            case .debouncedSearch(let keyword):
                // 자동 검색은 최근 검색어에 저장하지 않는다
                return startSearch(keyword, state: &state)

            case .searchButtonTapped:
                let keyword = state.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !keyword.isEmpty else { return .none }

                return .merge(
                    saveKeyword(keyword),
                    startSearch(keyword, state: &state)
                )

            case .cellTapped(let recent):
                state.searchText = recent.keyword

                return .merge(
                    saveKeyword(recent.keyword),
                    startSearch(recent.keyword, state: &state)
                )

            case .saveFail:
                // 최근 검색어 저장은 부가 기능이라 실패해도 사용자에게 알리지 않는다 (검색은 계속 진행)
                return .none

            case .deleteAllRecentSearch:
                // 목록은 observe() 스트림이 갱신한다
                return .run { _ in
                    try await recentKeywordUseCase.deleteAll()
                } catch: { error, send in
                    await send(.deleteFail(error.userMessage))
                }

            case .deleteRow(let id):
                return .run { _ in
                    try await recentKeywordUseCase.delete(id: id)
                } catch: { error, send in
                    await send(.deleteFail(error.userMessage))
                }

            case .deleteFail(let message):
                state.alert = AlertState {
                    TextState("삭제하지 못했어요")
                } actions: {
                    ButtonState(role: .cancel) { TextState("확인") }
                } message: {
                    TextState(message)
                }
                return .none

            case .searchResponse(.success(let page)):
                state.searchResults = IdentifiedArray(uniqueElements: page.items)
                state.total = page.total
                state.nextPage = page.nextRequest
                state.loadState = page.items.isEmpty ? .empty : .loaded
                return .none

            case .searchResponse(.failure(let error)):
                state.loadState = .failed(error.userMessage)
                return .none

            case .retryButtonTapped:
                // 저장 없이 마지막 검색어로 다시 검색
                return startSearch(state.searchedKeyword, state: &state)

            case .rowAppeared(let id):
                guard
                    !state.isNextPageFailed,  // 실패 후에는 스크롤로 자동 재시도하지 않고 버튼으로만
                    let index = state.searchResults.index(id: id),
                    index >= state.searchResults.count - 5
                else { return .none }

                return loadNextPage(state: &state)

            case .nextPageRetryButtonTapped:
                state.isNextPageFailed = false
                return loadNextPage(state: &state)

            case .nextPageResponse(.success(let page)):
                state.isLoadingNextPage = false
                state.searchResults.append(contentsOf: page.items)
                state.nextPage = page.nextRequest
                return .none

            case .nextPageResponse(.failure):
                state.isLoadingNextPage = false
                state.isNextPageFailed = true
                return .none

            case .resultTapped(let app):
                state.path.append(.detail(AppDetailFeature.State(app: app)))
                return .none

            case .path, .alert:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
        .ifLet(\.$alert, action: \.alert)
    }

    /// 첫 페이지 검색 시작 — 상태 초기화 + 이전 요청 취소 + 검색 요청
    private func startSearch(_ keyword: String, state: inout State) -> Effect<Action> {
        state.searchedKeyword = keyword
        state.loadState = .loading
        state.nextPage = nil
        state.isLoadingNextPage = false
        state.isNextPageFailed = false

        return .merge(
            .cancel(id: CancelID.nextPage),
            .run { send in
                do {
                    let page = try await searchAppsUseCase.execute(term: keyword, page: .first)
                    await send(.searchResponse(.success(page)))
                } catch {
                    await send(.searchResponse(.failure(error)))
                }
            }
            .cancellable(id: CancelID.search, cancelInFlight: true)
        )
    }

    /// 다음 페이지 요청 — 다음 페이지가 있고, 요청 중이 아닐 때만
    private func loadNextPage(state: inout State) -> Effect<Action> {
        guard let nextPage = state.nextPage, !state.isLoadingNextPage else { return .none }

        state.isLoadingNextPage = true
        let keyword = state.searchedKeyword

        return .run { send in
            do {
                let page = try await searchAppsUseCase.execute(term: keyword, page: nextPage)
                await send(.nextPageResponse(.success(page)))
            } catch {
                await send(.nextPageResponse(.failure(error)))
            }
        }
        .cancellable(id: CancelID.nextPage)
    }

    /// 최근 검색어 저장 (실패해도 검색에는 영향 없음)
    private func saveKeyword(_ keyword: String) -> Effect<Action> {
        .run { _ in
            try await recentKeywordUseCase.save(keyword: keyword)
        } catch: { error, send in
            await send(.saveFail(error.userMessage))
        }
    }
}

extension SearchFeature.Path.State: Equatable {}
