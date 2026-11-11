import ComposableArchitecture
import Domain
import Foundation
import AppDetailFeature

/// 검색 화면 리듀서 (뼈대)
///
/// 와이어프레임: docs/wireframe/AppScout_Wireframe.pdf S1~S3
/// 요구사항·체크리스트: docs/feature-guide.md#search
///
/// - [ ] State: 검색어(query), 최근 검색어 목록, 검색 결과·페이지 정보, 로딩/에러 상태, 알럿, 내비게이션 path
/// - [ ] @Reducer enum Path { case detail(AppDetailFeature) } 로 결과 → 상세 push (NavigationStack(path:))
/// - [ ] 입력 300ms 디바운스 후 자동 검색, 제출(onSubmit) 시 즉시 검색 + 최근 검색어 저장
/// - [ ] 최근 검색어는 onAppear(.task)에서 장기 실행 Effect로 구독, 화면이 사라지면 취소
/// - [ ] 마지막 셀 근처에서 다음 페이지 요청 (중복 요청 방지)
/// - [ ] 검색 중 새 검색어가 오면 이전 요청 취소 (.cancellable(id:cancelInFlight:))
@Reducer
public struct SearchFeature {
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

    /// 검색 API (페이지네이션)
    @Dependency(\.searchAppsUseCase) var searchAppsUseCase
    /// 최근 검색어 저장·구독·삭제
    @Dependency(\.recentKeywordUseCase) var recentKeywordUseCase
    /// 입력 디바운스(300ms)
    @Dependency(\.continuousClock) var continuousClock

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
