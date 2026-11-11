import ComposableArchitecture
import Domain
import Foundation
import AppDetailFeature

/// 즐겨찾기 화면 리듀서 (뼈대)
///
/// 와이어프레임: docs/wireframe/AppScout_Wireframe.pdf S7~S8
/// 요구사항·체크리스트: docs/feature-guide.md#favorites
///
/// - [ ] State: 즐겨찾기 목록(IdentifiedArrayOf), 내비게이션 path
/// - [ ] 목록은 DB 변경 스트림을 구독해서 자동 갱신 (상세에서 하트를 눌러도 즉시 반영)
/// - [ ] 스와이프 삭제 → favoriteUseCase.remove
/// - [ ] 셀 탭 → AppDetailFeature push (@Reducer enum Path)
@Reducer
public struct FavoritesFeature {
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

    /// 즐겨찾기 목록 구독·삭제
    @Dependency(\.favoriteUseCase) var favoriteUseCase

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
