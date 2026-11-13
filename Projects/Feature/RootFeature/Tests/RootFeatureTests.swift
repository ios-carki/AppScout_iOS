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

    @Test("즐겨찾기 빈 상태의 '앱 검색하러 가기' → 검색 탭으로 전환")
    func searchTabRequested() async {
        let store = TestStore(initialState: RootFeature.State(selectedTab: .favorites)) {
            RootFeature()
        }
        await store.send(.favorites(.searchButtonTapped))
        await store.receive(\.favorites.delegate.searchTabRequested) {
            $0.selectedTab = .search
        }
    }
}
