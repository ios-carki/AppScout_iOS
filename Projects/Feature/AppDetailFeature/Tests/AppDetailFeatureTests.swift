import ComposableArchitecture
import Domain
import Foundation
import Testing
@testable import AppDetailFeature

/// TestStore로 상세 리듀서를 검증한다.
@MainActor
@Suite("AppDetailFeature")
struct AppDetailFeatureTests {
    let app = AppSummary.mock

    @Test("onAppear → 상세 성공 → detail 반영, 즐겨찾기 스트림 → isFavorite 반영")
    func onAppearSuccess() async {
        let detail = AppDetail.mock(summary: app)
        let (favorites, continuation) = AsyncThrowingStream<Bool, any Error>.makeStream()

        let store = TestStore(initialState: AppDetailFeature.State(app: app)) {
            AppDetailFeature()
        } withDependencies: {
            $0.fetchAppDetailUseCase.execute = { _ in detail }
            $0.favoriteUseCase.observeIsFavorite = { _ in favorites }
        }

        let task = await store.send(.onAppear)
        await store.receive(\.detailResponse.success) {
            $0.detail = detail
            $0.loadState = .loaded
        }

        continuation.yield(true)
        await store.receive(\.favoriteUpdated) {
            $0.isFavorite = true
        }

        // 화면을 나가면(.task 취소) 구독도 끝난다
        await task.cancel()
    }

    @Test("이미 상세가 있으면 다시 들어와도 상세를 다시 요청하지 않는다")
    func onAppearAgainSkipsDetail() async {
        var state = AppDetailFeature.State(app: app)
        state.detail = .mock(summary: app)
        state.loadState = .loaded

        let store = TestStore(initialState: state) {
            AppDetailFeature()
        } withDependencies: {
            // execute를 정의하지 않음 → 호출되면 테스트 실패
            $0.favoriteUseCase.observeIsFavorite = { _ in AsyncThrowingStream { $0.finish() } }
        }

        await store.send(.onAppear)
    }

    @Test("상세 실패 → 다시 시도 가능한 에러, 다시 시도 → 스켈레톤 후 성공")
    func failureThenRetry() async {
        let detail = AppDetail.mock(summary: app)
        let attempt = LockIsolated(0)

        let store = TestStore(initialState: AppDetailFeature.State(app: app)) {
            AppDetailFeature()
        } withDependencies: {
            $0.fetchAppDetailUseCase.execute = { _ in
                attempt.withValue { $0 += 1 }
                if attempt.value == 1 { throw DomainError.network }
                return detail
            }
            $0.favoriteUseCase.observeIsFavorite = { _ in AsyncThrowingStream { $0.finish() } }
        }

        await store.send(.onAppear)
        await store.receive(\.detailResponse.failure) {
            $0.loadState = .failed(message: DomainError.network.message, canRetry: true)
        }

        await store.send(.retryButtonTapped) {
            $0.loadState = .loading
        }
        await store.receive(\.detailResponse.success) {
            $0.detail = detail
            $0.loadState = .loaded
        }
    }

    @Test("404 → 다시 시도 없는 에러")
    func notFound() async {
        let store = TestStore(initialState: AppDetailFeature.State(app: app)) {
            AppDetailFeature()
        } withDependencies: {
            $0.fetchAppDetailUseCase.execute = { _ in throw DomainError.notFound }
            $0.favoriteUseCase.observeIsFavorite = { _ in AsyncThrowingStream { $0.finish() } }
        }

        await store.send(.onAppear)
        await store.receive(\.detailResponse.failure) {
            $0.loadState = .failed(message: DomainError.notFound.message, canRetry: false)
        }
    }

    @Test("하트 탭 → toggle 호출, 하트 모양은 바꾸지 않음 (스트림이 바꿈)")
    func toggleFavorite() async {
        let toggled = LockIsolated<[Int]>([])

        let store = TestStore(initialState: AppDetailFeature.State(app: app)) {
            AppDetailFeature()
        } withDependencies: {
            $0.favoriteUseCase.toggle = { app in
                toggled.withValue { $0.append(app.id) }
                return true
            }
        }

        await store.send(.favoriteButtonTapped) {
            $0.isTogglingFavorite = true
        }
        await store.receive(\.toggleResponse.success) {
            $0.isTogglingFavorite = false
        }
        #expect(toggled.value == [app.id])
    }

    @Test("토글이 끝나기 전에 다시 탭하면 무시한다")
    func toggleTwiceQuickly() async {
        let toggleCount = LockIsolated(0)
        let clock = TestClock()

        let store = TestStore(initialState: AppDetailFeature.State(app: app)) {
            AppDetailFeature()
        } withDependencies: {
            $0.favoriteUseCase.toggle = { _ in
                toggleCount.withValue { $0 += 1 }
                try await clock.sleep(for: .seconds(1))
                return true
            }
        }

        await store.send(.favoriteButtonTapped) {
            $0.isTogglingFavorite = true
        }
        await store.send(.favoriteButtonTapped)   // 처리 중 → 상태 변화 없음

        await clock.advance(by: .seconds(1))
        await store.receive(\.toggleResponse.success) {
            $0.isTogglingFavorite = false
        }
        #expect(toggleCount.value == 1)
    }

    @Test("토글 실패 → 알럿")
    func toggleFailure() async {
        let store = TestStore(initialState: AppDetailFeature.State(app: app)) {
            AppDetailFeature()
        } withDependencies: {
            $0.favoriteUseCase.toggle = { _ in throw DomainError.storage }
        }

        await store.send(.favoriteButtonTapped) {
            $0.isTogglingFavorite = true
        }
        await store.receive(\.toggleResponse.failure) {
            $0.isTogglingFavorite = false
            $0.alert = AlertState {
                TextState("기기에 저장하지 못했어요")
            } actions: {
                ButtonState(role: .cancel) { TextState("확인") }
            } message: {
                TextState(DomainError.storage.message)
            }
        }
    }

    @Test("App Store 버튼 → openURL 호출")
    func openAppStore() async {
        let detail = AppDetail.mock(summary: app)
        let opened = LockIsolated<URL?>(nil)

        var state = AppDetailFeature.State(app: app)
        state.detail = detail
        state.loadState = .loaded

        let store = TestStore(initialState: state) {
            AppDetailFeature()
        } withDependencies: {
            $0.openURL = OpenURLEffect { url in
                opened.setValue(url)
                return true
            }
        }

        await store.send(.appStoreButtonTapped)
        #expect(opened.value == detail.appStoreURL)
    }

    @Test("더 보기 → 설명 펼침")
    func expandDescription() async {
        let store = TestStore(initialState: AppDetailFeature.State(app: app)) {
            AppDetailFeature()
        }

        await store.send(.descriptionMoreButtonTapped) {
            $0.isDescriptionExpanded = true
        }
    }
}
