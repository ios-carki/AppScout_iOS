import ComposableArchitecture
import FavoritesFeature
import Foundation
import ProfileFeature
import SearchFeature
import SettingsFeature

/// 탭 구성 (와이어프레임 05)
///
/// - 탭 3개를 조립하고, 자식의 delegate(탭 전환 요청)를 처리한다.
/// - 테마는 설정 화면과 같은 `@Shared(.appTheme)`를 읽어서 RootView에 적용한다.
@Reducer
public struct RootFeature {
    public enum Tab: Hashable, Sendable {
        case search
        case favorites
        case profile
    }

    @ObservableState
    public struct State: Equatable {
        public var selectedTab: Tab
        public var search: SearchFeature.State
        public var favorites: FavoritesFeature.State
        public var profile: ProfileFeature.State
        @Shared(.appTheme) public var theme

        public init(
            selectedTab: Tab = .search,
            search: SearchFeature.State = .init(),
            favorites: FavoritesFeature.State = .init(),
            profile: ProfileFeature.State = .init()
        ) {
            self.selectedTab = selectedTab
            self.search = search
            self.favorites = favorites
            self.profile = profile
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case search(SearchFeature.Action)
        case favorites(FavoritesFeature.Action)
        case profile(ProfileFeature.Action)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Scope(state: \.search, action: \.search) {
            SearchFeature()
        }
        Scope(state: \.favorites, action: \.favorites) {
            FavoritesFeature()
        }
        Scope(state: \.profile, action: \.profile) {
            ProfileFeature()
        }

        Reduce { state, action in
            switch action {
            case .favorites(.delegate(.searchTabRequested)):
                state.selectedTab = .search
                return .none

            case .binding, .search, .favorites, .profile:
                return .none
            }
        }
    }
}
