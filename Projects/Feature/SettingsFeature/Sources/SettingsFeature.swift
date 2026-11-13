import ComposableArchitecture
import Domain
import Foundation

/// 설정 화면 리듀서
///
/// 와이어프레임: docs/wireframe/AppScout_Wireframe.pdf S13~S14
///
/// - 테마는 `@Shared(.appTheme)`. RootFeature도 같은 키를 읽으므로 바꾸는 즉시 앱 전체에 적용된다.
/// - 최근 검색어 전체 삭제는 확인 다이얼로그를 한 번 거친다. 0개면 버튼을 비활성화한다.
@Reducer
public struct SettingsFeature {
    @ObservableState
    public struct State: Equatable {
        @Shared(.appTheme) var theme
        var recentKeywordCount = 0
        @Presents var confirmationDialog: ConfirmationDialogState<Action.Dialog>?
        @Presents var alert: AlertState<Action.Alert>?

        public init() {}
    }

    public enum Action {
        case onAppear
        case themeChanged(AppTheme)
        case recentKeywordsUpdated(Int)
        case clearRecentKeywordsTapped
        case clearFailed(String)
        case confirmationDialog(PresentationAction<Dialog>)
        case alert(PresentationAction<Alert>)

        public enum Dialog: Equatable {
            case clearConfirmed
        }

        public enum Alert: Equatable {}
    }

    @Dependency(\.recentKeywordUseCase) var recentKeywordUseCase

    enum CancelID {
        case recentKeywords
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    for try await keywords in recentKeywordUseCase.observe() {
                        await send(.recentKeywordsUpdated(keywords.count))
                    }
                }
                .cancellable(id: CancelID.recentKeywords, cancelInFlight: true)

            case let .themeChanged(theme):
                state.$theme.withLock { $0 = theme }
                return .none

            case let .recentKeywordsUpdated(count):
                state.recentKeywordCount = count
                return .none

            case .clearRecentKeywordsTapped:
                state.confirmationDialog = ConfirmationDialogState {
                    TextState("최근 검색어 삭제")
                } actions: {
                    ButtonState(role: .destructive, action: .clearConfirmed) {
                        TextState("전체 삭제")
                    }
                    ButtonState(role: .cancel) {
                        TextState("취소")
                    }
                } message: {
                    TextState("최근 검색어를 모두 삭제할까요? 삭제한 검색어는 되돌릴 수 없어요.")
                }
                return .none

            case .confirmationDialog(.presented(.clearConfirmed)):
                // 삭제 후 안내는 없다. 개수와 검색 탭은 DB 관찰 스트림으로 자동 반영된다.
                return .run { _ in
                    try await recentKeywordUseCase.deleteAll()
                } catch: { error, send in
                    await send(.clearFailed(error.userMessage))
                }

            case let .clearFailed(message):
                state.alert = AlertState {
                    TextState("삭제하지 못했어요")
                } actions: {
                    ButtonState(role: .cancel) { TextState("확인") }
                } message: {
                    TextState(message)
                }
                return .none

            case .confirmationDialog, .alert:
                return .none
            }
        }
        .ifLet(\.$confirmationDialog, action: \.confirmationDialog)
        .ifLet(\.$alert, action: \.alert)
    }
}
