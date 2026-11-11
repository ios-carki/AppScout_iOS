import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

/// 프로필 화면 (뼈대). 와이어프레임 S9~S12
public struct ProfileView: View {
    @Bindable var store: StoreOf<ProfileFeature>

    public init(store: StoreOf<ProfileFeature>) {
        self.store = store
    }

    public var body: some View {
        // TODO: NavigationStack(path: $store.scope(state: \.path, action: \.path)) { ... } destination: { ... }
        NavigationStack {
            EmptyStateView(
                systemImage: "hammer",
                title: "프로필 구현 예정",
                message: "와이어프레임 S9~S12\ndocs/feature-guide.md"
            )
            .navigationTitle("프로필")
            .toolbarTitleDisplayMode(.inlineLarge)
        }
        .task { await store.send(.onAppear).finish() }
    }
}

#Preview {
    ProfileView(
        store: Store(initialState: ProfileFeature.State()) {
            ProfileFeature()
        }
    )
}
