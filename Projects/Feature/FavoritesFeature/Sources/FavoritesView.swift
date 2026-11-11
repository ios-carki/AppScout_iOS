import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

/// 즐겨찾기 화면 (뼈대). 와이어프레임 S7~S8
public struct FavoritesView: View {
    @Bindable var store: StoreOf<FavoritesFeature>

    public init(store: StoreOf<FavoritesFeature>) {
        self.store = store
    }

    public var body: some View {
        // TODO: NavigationStack(path: $store.scope(state: \.path, action: \.path)) { ... } destination: { ... }
        NavigationStack {
            EmptyStateView(
                systemImage: "hammer",
                title: "즐겨찾기 구현 예정",
                message: "와이어프레임 S7~S8\ndocs/feature-guide.md"
            )
            .navigationTitle("즐겨찾기")
            .toolbarTitleDisplayMode(.inlineLarge)
        }
        .task { await store.send(.onAppear).finish() }
    }
}

#Preview {
    FavoritesView(
        store: Store(initialState: FavoritesFeature.State()) {
            FavoritesFeature()
        }
    )
}
