import ComposableArchitecture
import Domain
import Testing
@testable import ProfileFeature

/// TestStore로 프로필 리듀서를 검증한다. (docs/feature-guide.md#profile 의 "테스트 목록" 참고)
@MainActor
@Suite("ProfileFeature")
struct ProfileFeatureTests {
    @Test("TODO: onAppear 시나리오")
    func onAppear() async {
        let store = TestStore(initialState: ProfileFeature.State()) {
            ProfileFeature()
        }
        await store.send(.onAppear)
    }
}
