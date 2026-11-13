import ComposableArchitecture
import Domain
import Foundation

/// 상세 화면 리듀서
///
/// 와이어프레임: docs/wireframe/AppScout_Wireframe.pdf S4~S6
/// 요구사항·체크리스트: docs/feature-guide.md#app-detail
///
/// - 진입 시 받은 AppSummary로 상단을 먼저 그리고, 나머지는 상세 응답 후 표시
/// - onAppear(.task)에서 즐겨찾기 여부 구독 + (처음이면) 상세 요청을 함께 시작
/// - 하트는 DB 관찰 스트림으로만 바뀐다 (낙관적 업데이트 없음). 토글 실패 시 알럿
/// - 404는 다시 시도 없는 에러, 그 외 실패는 다시 시도 가능
@Reducer
public struct AppDetailFeature {
    @ObservableState
    public struct State: Equatable {
        public let app: AppSummary
        var detail: AppDetail?
        var loadState: LoadState = .loading
        var isFavorite: Bool = false
        /// 토글 처리 중. 끝나기 전의 탭은 무시한다 (빠른 연속 탭 → 경쟁 상태 방지)
        var isTogglingFavorite = false
        var isDescriptionExpanded: Bool = false

        enum LoadState: Equatable {
            case loading
            case loaded
            case failed(message: String, canRetry: Bool)
        }

        @Presents var alert: AlertState<Action.Alert>?

        public init(app: AppSummary) {
            self.app = app
        }
    }

    public enum Action {
        case onAppear
        case appStoreButtonTapped

        case favoriteButtonTapped
        case favoriteUpdated(Bool)
        case toggleResponse(Result<Bool, any Error>)

        case descriptionMoreButtonTapped

        case detailResponse(Result<AppDetail, any Error>)
        case retryButtonTapped

        case alert(PresentationAction<Alert>)

        /// 알럿 버튼이 보내는 Action. 지금은 "확인"만 있어서 비어 있다.
        public enum Alert: Equatable {}
    }

    enum CancelID {
        case detail
        case favorite
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
                let favorite = observeFavorite(appID: state.app.id)
                
                guard state.detail == nil else { return favorite }
                
                return .merge(
                    fetchDetail(state: &state),
                    favorite
                )
            case .appStoreButtonTapped:
                guard let url = state.detail?.appStoreURL else {
                    return .none
                }
                return .run { _ in
                    await openURL(url)
                }
            case .favoriteButtonTapped:
                // 이전 토글이 끝나기 전이면 무시
                guard !state.isTogglingFavorite else { return .none }
                state.isTogglingFavorite = true

                return toggleFavorite(app: state.app)
            case .favoriteUpdated(let favorite):
                state.isFavorite = favorite

                return .none
            case .toggleResponse(.success):
                // 하트 모양은 observeIsFavorite 스트림이 바꾼다. 여기서는 처리 중 표시만 해제
                state.isTogglingFavorite = false

                return .none
            case .toggleResponse(.failure(let error)):
                state.isTogglingFavorite = false
                let message = error.userMessage
                state.alert = AlertState(title: {
                    TextState("기기에 저장하지 못했어요")
                }, actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                }, message: {
                    TextState(message)
                })
                
                return .none
            case .descriptionMoreButtonTapped:
                state.isDescriptionExpanded = true
                return .none

            case .detailResponse(.success(let detail)):
                state.detail = detail
                state.loadState = .loaded

                return .none
            case .detailResponse(.failure(let error)):
                let domainError = error as? DomainError

                state.loadState = .failed(
                    message: error.userMessage,
                    canRetry: domainError != .notFound
                )

                return .none
            case .retryButtonTapped:
                return fetchDetail(state: &state)
            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }

    private func fetchDetail(state: inout State) -> Effect<Action> {
        state.loadState = .loading

        let id = state.app.id

        return .run { send in
            do {
                let data = try await fetchAppDetailUseCase.execute(id: id)

                await send(.detailResponse(.success(data)))
            } catch let error {
                await send(.detailResponse(.failure(error)))
            }
        }
        .cancellable(id: CancelID.detail, cancelInFlight: true)
    }

    private func toggleFavorite(app: AppSummary) -> Effect<Action> {
        .run { send in
            do {
                let isFavorite = try await favoriteUseCase.toggle(app: app)
                await send(.toggleResponse(.success(isFavorite)))
            } catch {
                await send(.toggleResponse(.failure(error)))
            }
        }
    }

    private func observeFavorite(appID: Int) -> Effect<Action> {
        return .run { send in
            for try await isFavorite in favoriteUseCase.observeIsFavorite(
                appID: appID
            ) {
                await send(.favoriteUpdated(isFavorite))
            }
        }
        .cancellable(id: CancelID.favorite, cancelInFlight: true)
    }
}
