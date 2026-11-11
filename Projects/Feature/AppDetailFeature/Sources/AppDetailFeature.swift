import ComposableArchitecture
import Domain
import Foundation

/// 상세 화면 리듀서 (뼈대)
///
/// 와이어프레임: docs/wireframe/AppScout_Wireframe.pdf S4~S6
/// 요구사항·체크리스트: docs/feature-guide.md#app-detail
///
/// - [ ] State: 진입 시 받은 AppSummary(목록에서 이미 아는 정보로 상단을 먼저 그림), 상세 로딩 상태(로딩/성공/실패), 즐겨찾기 여부, 설명 펼침 여부
/// - [ ] onAppear(.task)에서 상세 요청 + 즐겨찾기 여부 구독을 함께 시작
/// - [ ] 즐겨찾기 토글 실패 시 알럿, 성공 시 상태는 구독 스트림이 갱신
/// - [ ] 에러 화면의 '다시 시도'는 같은 요청을 다시 보냄
@Reducer
public struct AppDetailFeature {
    @ObservableState
    public struct State: Equatable {
        public let app: AppSummary

        public init(app: AppSummary) {
            self.app = app
        }
    }

    public enum Action {
        case onAppear
        // TODO: 사용자 행동은 "무엇을 했는가"로 이름 짓기 (예: searchButtonTapped, cellTapped)
        // TODO: 부모에게 알릴 일은 case delegate(Delegate)로 분리
    }

    /// 상세 API
    @Dependency(\.fetchAppDetailUseCase) var fetchAppDetailUseCase
    /// 즐겨찾기 여부 구독·토글
    @Dependency(\.favoriteUseCase) var favoriteUseCase
    /// App Store에서 보기
    @Dependency(\.openURL) var openURL

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
