import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

/// 검색 화면 (뼈대). 와이어프레임 p.4~7
public struct SearchView: View {
    @Bindable var store: StoreOf<SearchFeature>

    public init(store: StoreOf<SearchFeature>) {
        self.store = store
    }

    public var body: some View {
        // TODO: NavigationStack(path: $store.scope(state: \.path, action: \.path)) { ... } destination: { ... }
        NavigationStack {
            EmptyStateView(
                systemImage: "hammer",
                title: "검색 구현 예정",
                message: "와이어프레임 p.4~7\ndocs/feature-guide.md"
            )
            .navigationTitle("검색")
            .toolbarTitleDisplayMode(.inlineLarge)
        }
        .task { store.send(.onAppear) }
    }
}

#Preview {
    SearchView(
        store: Store(initialState: SearchFeature.State()) {
            SearchFeature()
        }
    )
}
