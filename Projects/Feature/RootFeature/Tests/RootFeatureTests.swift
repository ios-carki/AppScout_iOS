import ComposableArchitecture
import Testing
@testable import RootFeature

@MainActor
@Suite("RootFeature")
struct RootFeatureTests {
    @Test("탭을 바꾸면 selectedTab이 바뀐다")
    func selectTab() async {
        let store = TestStore(initialState: RootFeature.State()) {
            RootFeature()
        }
        await store.send(.binding(.set(\.selectedTab, .profile))) {
            $0.selectedTab = .profile
        }
    }
}
