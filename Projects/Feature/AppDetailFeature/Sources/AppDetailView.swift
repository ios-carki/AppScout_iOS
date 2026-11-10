import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

/// 상세 화면 (뼈대). 와이어프레임 p.8~9
public struct AppDetailView: View {
    @Bindable var store: StoreOf<AppDetailFeature>

    public init(store: StoreOf<AppDetailFeature>) {
        self.store = store
    }

    public var body: some View {
        EmptyStateView(
            systemImage: "hammer",
            title: "상세 구현 예정",
            message: "와이어프레임 p.8~9\ndocs/feature-guide.md"
        )
        .navigationTitle("상세")
        .navigationBarTitleDisplayMode(.inline)
        .task { await store.send(.onAppear).finish() }
    }
}

#Preview {
    NavigationStack {
        AppDetailView(
            store: Store(initialState: AppDetailFeature.State(app: .mock)) {
                AppDetailFeature()
            }
        )
    }
}
