import ComposableArchitecture
import Domain
import Testing
@testable import SettingsFeature

/// TestStore로 설정 리듀서를 검증한다. (docs/feature-guide.md#settings 의 "테스트 목록" 참고)
@MainActor
@Suite("SettingsFeature")
struct SettingsFeatureTests {
    @Test("TODO: onAppear 시나리오")
    func onAppear() async {
        let store = TestStore(initialState: SettingsFeature.State()) {
            SettingsFeature()
        }
        await store.send(.onAppear)
    }
}
