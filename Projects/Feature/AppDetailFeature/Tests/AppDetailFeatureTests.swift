import ComposableArchitecture
import Domain
import Testing
@testable import AppDetailFeature

/// TestStore로 상세 리듀서를 검증한다. (docs/feature-guide.md#app-detail 의 "테스트 목록" 참고)
@MainActor
@Suite("AppDetailFeature")
struct AppDetailFeatureTests {
    @Test("TODO: onAppear 시나리오")
    func onAppear() async {
        let store = TestStore(initialState: AppDetailFeature.State(app: .mock)) {
            AppDetailFeature()
        }
        await store.send(.onAppear)
    }
}
