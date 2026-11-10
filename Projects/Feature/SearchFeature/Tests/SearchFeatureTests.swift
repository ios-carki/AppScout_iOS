import ComposableArchitecture
import Domain
import Testing
@testable import SearchFeature

/// TestStore로 검색 리듀서를 검증한다. (docs/feature-guide.md#search 의 "테스트 목록" 참고)
@MainActor
@Suite("SearchFeature")
struct SearchFeatureTests {
    @Test("TODO: onAppear 시나리오")
    func onAppear() async {
        let store = TestStore(initialState: SearchFeature.State()) {
            SearchFeature()
        }
        await store.send(.onAppear)
    }
}
