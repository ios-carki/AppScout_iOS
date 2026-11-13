import ComposableArchitecture
import Domain
import Testing
@testable import FavoritesFeature

/// TestStore로 즐겨찾기 리듀서를 검증한다. (docs/feature-guide.md#favorites 의 "테스트 목록")
@MainActor
@Suite("FavoritesFeature")
struct FavoritesFeatureTests {
    @Test("스트림 값 → 목록 반영, 다음 값이 오면 다시 반영")
    func observeFavorites() async {
        let (stream, continuation) = AsyncThrowingStream<[FavoriteApp], any Error>.makeStream()
        let store = TestStore(initialState: FavoritesFeature.State()) {
            FavoritesFeature()
        } withDependencies: {
            $0.favoriteUseCase.observeAll = { stream }
        }

        let task = await store.send(.onAppear)

        continuation.yield(FavoriteApp.mocks)
        await store.receive(\.favoritesUpdated) {
            $0.favorites = IdentifiedArray(uniqueElements: FavoriteApp.mocks)
            $0.loadState = .loaded
        }

        continuation.yield([])
        await store.receive(\.favoritesUpdated) {
            $0.favorites = []
        }

        await task.cancel()
    }

    @Test("스와이프 → remove(appID:) 호출, 목록은 스트림이 갱신하므로 직접 바꾸지 않음")
    func deleteSwiped() async {
        let removed = LockIsolated<[Int]>([])
        var state = FavoritesFeature.State()
        state.favorites = IdentifiedArray(uniqueElements: FavoriteApp.mocks)
        state.loadState = .loaded

        let store = TestStore(initialState: state) {
            FavoritesFeature()
        } withDependencies: {
            $0.favoriteUseCase.remove = { id in removed.withValue { $0.append(id) } }
        }

        let id = FavoriteApp.mocks[0].id
        await store.send(.deleteSwiped(id: id))
        #expect(removed.value == [id])
    }

    @Test("삭제 실패 → 알럿")
    func deleteFailed() async {
        let store = TestStore(initialState: FavoritesFeature.State()) {
            FavoritesFeature()
        } withDependencies: {
            $0.favoriteUseCase.remove = { _ in throw DomainError.storage }
        }

        await store.send(.deleteSwiped(id: 1))
        await store.receive(\.deleteFailed) {
            $0.alert = AlertState {
                TextState("삭제하지 못했어요")
            } actions: {
                ButtonState(role: .cancel) { TextState("확인") }
            } message: {
                TextState(DomainError.storage.message)
            }
        }
    }

    @Test("셀 탭 → 상세 push (평가 수 0, 가격 \"-\")")
    func cellTapped() async {
        let favorite = FavoriteApp.mocks[0]
        let store = TestStore(initialState: FavoritesFeature.State()) {
            FavoritesFeature()
        }

        await store.send(.cellTapped(favorite)) {
            $0.path[id: 0] = .detail(.init(app: AppSummary(favorite)))
        }
        #expect(store.state.path[id: 0]?.detail?.app.ratingCount == 0)
    }

    @Test("빈 상태 버튼 → delegate(.searchTabRequested)")
    func searchButtonTapped() async {
        let store = TestStore(initialState: FavoritesFeature.State()) {
            FavoritesFeature()
        }

        await store.send(.searchButtonTapped)
        await store.receive(\.delegate.searchTabRequested)
    }
}
