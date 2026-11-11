import ComposableArchitecture
import Domain
import Foundation
import SettingsFeature

/// 프로필 화면 리듀서 (뼈대)
///
/// 와이어프레임: docs/wireframe/AppScout_Wireframe.pdf S9~S12
/// 요구사항·체크리스트: docs/feature-guide.md#profile
///
/// - [ ] State: 프로필, 로딩 상태, 내비게이션 path(이름 편집 / 이메일 편집 / 설정), 이미지 업로드 상태, 알럿
/// - [ ] 편집 화면은 별도 리듀서(EditNameFeature, EditEmailFeature)로 만들고 delegate 액션으로 결과 전달
/// - [ ] 편집 화면은 @Dependency(\.dismiss)로 스스로 닫기 (부모의 path.pop 대신)
/// - [ ] 이미지 변경: PhotosPicker → loadTransferable(type: Data.self) → profileUseCase.updateAvatar
/// - [ ] 우상단 톱니바퀴 → SettingsFeature push
@Reducer
public struct ProfileFeature {
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

    /// 프로필 조회·수정·이미지 업로드
    @Dependency(\.profileUseCase) var profileUseCase

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
