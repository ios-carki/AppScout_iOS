import AppDetailFeature
import ComposableArchitecture
import Domain
import Foundation

/// 즐겨찾기 화면 리듀서
///
/// 와이어프레임: docs/wireframe/AppScout_Wireframe.pdf S7~S8
/// 요구사항·체크리스트: docs/feature-guide.md#favorites
///
/// - 목록은 DB 관찰 스트림으로만 갱신한다. 삭제 후 배열에서 직접 빼지 않는다.
///   그래서 상세에서 ♥를 해제하고 돌아와도 이미 목록에서 사라져 있다.
/// - 탭 전환은 이 화면이 할 수 없으므로 `delegate(.searchTabRequested)`로 부모(RootFeature)에 알린다.
@Reducer
public struct FavoritesFeature {
    @Reducer
    public enum Path {
        case detail(AppDetailFeature)
    }

    @ObservableState
    public struct State: Equatable {
        var favorites: IdentifiedArrayOf<FavoriteApp> = []

        enum LoadState: Equatable {
            /// 첫 스트림 값을 기다리는 중 (로컬 DB라 거의 즉시 끝남)
            case loading
            case loaded
            case failed(String)
        }
        var loadState: LoadState = .loading

        var path = StackState<Path.State>()
        @Presents var alert: AlertState<Action.Alert>?

        public init() {}
    }

    public enum Action {
        case onAppear
        case favoritesUpdated([FavoriteApp])
        case favoritesFailed(String)
        case retryButtonTapped
        case cellTapped(FavoriteApp)
        case deleteSwiped(id: FavoriteApp.ID)
        case deleteFailed(String)
        case searchButtonTapped

        case path(StackActionOf<Path>)
        case alert(PresentationAction<Alert>)
        case delegate(Delegate)

        public enum Alert: Equatable {}

        @CasePathable
        public enum Delegate: Equatable {
            /// 빈 상태의 "앱 검색하러 가기" → 검색 탭으로 바꿔 달라는 요청
            case searchTabRequested
        }
    }

    @Dependency(\.favoriteUseCase) var favoriteUseCase

    enum CancelID {
        case favorites
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear, .retryButtonTapped:
                if case .failed = state.loadState {
                    state.loadState = .loading
                }
                return .run { send in
                    do {
                        for try await favorites in favoriteUseCase.observeAll() {
                            await send(.favoritesUpdated(favorites))
                        }
                    } catch {
                        await send(.favoritesFailed(error.userMessage))
                    }
                }
                .cancellable(id: CancelID.favorites, cancelInFlight: true)

            case let .favoritesUpdated(favorites):
                state.favorites = IdentifiedArray(uniqueElements: favorites)
                state.loadState = .loaded
                return .none

            case let .favoritesFailed(message):
                // 이미 목록을 보여 주고 있으면 기존 목록을 유지한다
                if state.loadState != .loaded {
                    state.loadState = .failed(message)
                }
                return .none

            case let .cellTapped(favorite):
                state.path.append(.detail(AppDetailFeature.State(app: AppSummary(favorite))))
                return .none

            case let .deleteSwiped(id):
                return .run { _ in
                    try await favoriteUseCase.remove(appID: id)
                } catch: { error, send in
                    await send(.deleteFailed(error.userMessage))
                }

            case let .deleteFailed(message):
                state.alert = AlertState {
                    TextState("삭제하지 못했어요")
                } actions: {
                    ButtonState(role: .cancel) { TextState("확인") }
                } message: {
                    TextState(message)
                }
                return .none

            case .searchButtonTapped:
                return .send(.delegate(.searchTabRequested))

            case .path, .alert, .delegate:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
        .ifLet(\.$alert, action: \.alert)
    }
}

extension FavoritesFeature.Path.State: Equatable {}

extension AppSummary {
    /// 즐겨찾기 스냅샷으로 상세 화면을 열 때 사용한다.
    /// 스냅샷에는 평가 수·가격이 없으므로 상세 응답이 오기 전까지 0, "-"로 둔다.
    init(_ favorite: FavoriteApp) {
        self.init(
            id: favorite.id,
            name: favorite.name,
            sellerName: favorite.sellerName,
            iconURL: favorite.iconURL,
            primaryGenre: favorite.primaryGenre,
            averageRating: favorite.averageRating,
            ratingCount: 0,
            formattedPrice: "-"
        )
    }
}
