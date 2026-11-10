import ComposableArchitecture
import Domain
import Testing
@testable import FavoritesFeature

/// TestStore로 즐겨찾기 리듀서를 검증한다. (docs/feature-guide.md#favorites 의 "테스트 목록" 참고)
@MainActor
@Suite("FavoritesFeature")
struct FavoritesFeatureTests {
    @Test("TODO: onAppear 시나리오")
    func onAppear() async {
        let store = TestStore(initialState: FavoritesFeature.State()) {
            FavoritesFeature()
        }
        await store.send(.onAppear)
    }
}
