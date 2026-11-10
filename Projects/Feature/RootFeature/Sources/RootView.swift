import ComposableArchitecture
import DesignSystem
import FavoritesFeature
import ProfileFeature
import SearchFeature
import SwiftUI

/// 앱 루트 탭 화면 (와이어프레임 p.3)
public struct RootView: View {
    @Bindable var store: StoreOf<RootFeature>

    public init(store: StoreOf<RootFeature>) {
        self.store = store
    }

    public var body: some View {
        TabView(selection: $store.selectedTab) {
            SearchView(store: store.scope(state: \.search, action: \.search))
                .tabItem { Label("검색", systemImage: "magnifyingglass") }
                .tag(RootFeature.Tab.search)

            FavoritesView(store: store.scope(state: \.favorites, action: \.favorites))
                .tabItem { Label("즐겨찾기", systemImage: "heart") }
                .tag(RootFeature.Tab.favorites)

            ProfileView(store: store.scope(state: \.profile, action: \.profile))
                .tabItem { Label("프로필", systemImage: "person.crop.circle") }
                .tag(RootFeature.Tab.profile)
        }
        .tint(.dsBrandPrimary)
        // TODO: 설정의 테마 값으로 .preferredColorScheme(...) 적용
    }
}

#Preview {
    RootView(
        store: Store(initialState: RootFeature.State()) {
            RootFeature()
        }
    )
}
