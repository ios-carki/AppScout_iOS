import ComposableArchitecture
import Domain
import Foundation

/// 이름·이메일 편집 화면 리듀서 (와이어프레임 S11~S12)
///
/// 화면 모양과 흐름이 같아서 리듀서 하나에 편집 대상(`Field`)만 바꿔 쓴다.
/// - 값이 바뀌었고 형식이 맞을 때만 저장할 수 있다.
/// - 형식 오류는 입력이 0.5초 멈추거나 저장을 시도하면 인라인으로 보여 준다.
/// - 서버 검증 실패(422)는 인라인 오류, 그 외 실패는 알럿.
/// - 저장 성공 → `delegate(.profileUpdated)`로 부모에게 알리고 스스로 닫는다(`dismiss`).
@Reducer
public struct EditFieldFeature {
    public enum Field: Equatable, Sendable {
        case name
        case email

        var title: String {
            switch self {
            case .name: "이름"
            case .email: "이메일"
            }
        }

        /// 형식 검사. 통과하면 nil
        func validate(_ text: String) -> ValidationError? {
            do {
                switch self {
                case .name: _ = try ProfileValidator.validateName(text)
                case .email: _ = try ProfileValidator.validateEmail(text)
                }
                return nil
            } catch {
                return error
            }
        }
    }

    @ObservableState
    public struct State: Equatable {
        let field: Field
        let original: String
        var text: String
        /// 화면에 보여 줄 인라인 오류. 형식 오류는 디바운스 후에, 서버 오류는 응답 즉시 채운다.
        var errorMessage: String?
        var isSaving = false
        @Presents var alert: AlertState<Action.Alert>?

        public init(field: Field, original: String) {
            self.field = field
            self.original = original
            self.text = original
        }

        var trimmed: String { text.trimmingCharacters(in: .whitespacesAndNewlines) }
        var isChanged: Bool { trimmed != original }
        var isValid: Bool { field.validate(text) == nil }
        var canSave: Bool { isChanged && isValid && !isSaving }
    }

    public enum Action {
        case textChanged(String)
        case validationDebounced
        case saveButtonTapped
        case saveResponse(Result<Profile, any Error>)
        case alert(PresentationAction<Alert>)
        case delegate(Delegate)

        public enum Alert: Equatable {}

        @CasePathable
        public enum Delegate: Equatable {
            case profileUpdated(Profile)
        }
    }

    @Dependency(\.profileUseCase) var profileUseCase
    @Dependency(\.continuousClock) var clock
    @Dependency(\.dismiss) var dismiss

    enum CancelID {
        case validation
        case save
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .textChanged(text):
                state.text = text
                state.errorMessage = nil
                return .run { send in
                    try await clock.sleep(for: .milliseconds(500))
                    await send(.validationDebounced)
                }
                .cancellable(id: CancelID.validation, cancelInFlight: true)

            case .validationDebounced:
                state.errorMessage = state.field.validate(state.text)?.message
                return .none

            case .saveButtonTapped:
                guard !state.isSaving else { return .none }
                if let error = state.field.validate(state.text) {
                    state.errorMessage = error.message
                    return .cancel(id: CancelID.validation)
                }
                guard state.isChanged else { return .none }

                state.isSaving = true
                let field = state.field
                let text = state.text
                return .merge(
                    .cancel(id: CancelID.validation),
                    .run { send in
                        do {
                            let profile = switch field {
                            case .name: try await profileUseCase.updateName(name: text)
                            case .email: try await profileUseCase.updateEmail(email: text)
                            }
                            await send(.saveResponse(.success(profile)))
                        } catch {
                            await send(.saveResponse(.failure(error)))
                        }
                    }
                    .cancellable(id: CancelID.save, cancelInFlight: true)
                )

            case let .saveResponse(.success(profile)):
                state.isSaving = false
                return .run { send in
                    await send(.delegate(.profileUpdated(profile)))
                    await dismiss()
                }

            case let .saveResponse(.failure(error)):
                state.isSaving = false
                if case let .validation(validationError) = error as? DomainError {
                    state.errorMessage = validationError.message
                    return .none
                }
                state.alert = AlertState {
                    TextState("저장하지 못했어요")
                } actions: {
                    ButtonState(role: .cancel) { TextState("확인") }
                } message: {
                    TextState(error.userMessage)
                }
                return .none

            case .alert, .delegate:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
