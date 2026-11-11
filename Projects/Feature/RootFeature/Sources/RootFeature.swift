import ComposableArchitecture
import FavoritesFeature
import Foundation
import ProfileFeature
import SearchFeature

/// 탭 구성 (와이어프레임 05)
///
/// 탭 3개를 조립만 하는 리듀서라 미리 구현해 두었다. 각 탭의 기능은 하위 Feature에서 구현한다.
/// - [ ] (설정 구현 후) @Shared(.appStorage("appTheme"))를 읽어서 RootView에 테마 적용
/// - [ ] (선택) 즐겨찾기 탭을 다시 누르면 목록 맨 위로 / 내비게이션 루트로 돌아가기
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
    }
}
