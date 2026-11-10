import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

/// 설정 화면 (뼈대). 와이어프레임 p.14
public struct SettingsView: View {
    @Bindable var store: StoreOf<SettingsFeature>

    public init(store: StoreOf<SettingsFeature>) {
        self.store = store
    }

    public var body: some View {
        EmptyStateView(
            systemImage: "hammer",
            title: "설정 구현 예정",
            message: "와이어프레임 p.14\ndocs/feature-guide.md"
        )
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.inline)
        .task { store.send(.onAppear) }
    }
}

#Preview {
    NavigationStack {
        SettingsView(
            store: Store(initialState: SettingsFeature.State()) {
                SettingsFeature()
            }
        )
    }
}
