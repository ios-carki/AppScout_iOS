import ComposableArchitecture
import Domain
import Foundation

/// 설정 화면 리듀서 (뼈대)
///
/// 와이어프레임: docs/wireframe/AppScout_Wireframe.pdf S13~S14
/// 요구사항·체크리스트: docs/feature-guide.md#settings
///
/// - [ ] State: @Shared(.appStorage("appTheme")) 테마(시스템/라이트/다크), 확인 다이얼로그, 앱 버전
/// - [ ] 테마는 RootView에서도 같은 @Shared 키로 읽어서 .preferredColorScheme 적용
/// - [ ] 최근 검색어 전체 삭제는 confirmationDialog로 한 번 더 확인
@Reducer
public struct SettingsFeature {
    @ObservableState
    public struct State: Equatable {
        // TODO: 화면 상태

        public init() {}
    }

    public enum Action {
        case onAppear
        // TODO: 사용자 행동은 "무엇을 했는가"로 이름 짓기 (예: searchButtonTapped, cellTapped)
        // TODO: 부모에게 알릴 일은 case delegate(Delegate)로 분리
    }

    /// 최근 검색어 전체 삭제
    @Dependency(\.recentKeywordUseCase) var recentKeywordUseCase

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            }
        }
    }
}
