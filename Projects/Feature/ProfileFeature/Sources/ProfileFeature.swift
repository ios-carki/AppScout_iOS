import ComposableArchitecture
import Domain
import Foundation
import SettingsFeature

/// 프로필 화면 리듀서
///
/// 와이어프레임: docs/wireframe/AppScout_Wireframe.pdf S9~S12
/// 요구사항·체크리스트: docs/feature-guide.md#profile
///
/// - 탭에 들어올 때마다 다시 조회한다. 프로필이 아직 없을 때만 로딩/에러를 보여 주고,
///   이미 있으면 기존 값을 유지한 채 조용히 갱신한다.
/// - 편집 화면은 저장 성공 시 delegate로 새 프로필을 넘긴다 (재조회하지 않음).
/// - 사진: View의 PhotosPicker가 Data로 바꿔 `photoPicked`로 보낸다. 압축은 Data 계층이 한다.
@Reducer
public struct ProfileFeature {
    @Reducer
    public enum Path {
        case edit(EditFieldFeature)
        case settings(SettingsFeature)
    }

    @ObservableState
    public struct State: Equatable {
        var profile: Profile?

        enum LoadState: Equatable {
            case loading
            case loaded
            case failed(String)
        }
        var loadState: LoadState = .loading
        var isUploadingAvatar = false

        var path = StackState<Path.State>()
        @Presents var alert: AlertState<Action.Alert>?

        public init() {}
    }

    public enum Action {
        case onAppear
        case profileResponse(Result<Profile, any Error>)
        case retryButtonTapped
        case nameRowTapped
        case emailRowTapped
        case settingsButtonTapped
        case photoPicked(Data)
        case avatarUploadResponse(Result<Profile, any Error>)

        case path(StackActionOf<Path>)
        case alert(PresentationAction<Alert>)

        public enum Alert: Equatable {}
    }

    @Dependency(\.profileUseCase) var profileUseCase

    enum CancelID {
        case fetch
        case upload
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear, .retryButtonTapped:
                if state.profile == nil {
                    state.loadState = .loading
                }
                return .run { send in
                    do {
                        await send(.profileResponse(.success(try await profileUseCase.fetch())))
                    } catch {
                        await send(.profileResponse(.failure(error)))
                    }
                }
                .cancellable(id: CancelID.fetch, cancelInFlight: true)

            case let .profileResponse(.success(profile)):
                state.profile = profile
                state.loadState = .loaded
                return .none

            case let .profileResponse(.failure(error)):
                // 이미 보여 주는 프로필이 있으면 실패해도 그대로 둔다
                if state.profile == nil {
                    state.loadState = .failed(error.userMessage)
                }
                return .none

            case .nameRowTapped:
                guard let profile = state.profile else { return .none }
                state.path.append(.edit(EditFieldFeature.State(field: .name, original: profile.name)))
                return .none

            case .emailRowTapped:
                guard let profile = state.profile else { return .none }
                state.path.append(.edit(EditFieldFeature.State(field: .email, original: profile.email)))
                return .none

            case .settingsButtonTapped:
                state.path.append(.settings(SettingsFeature.State()))
                return .none

            case let .photoPicked(data):
                guard !state.isUploadingAvatar else { return .none }
                state.isUploadingAvatar = true
                return .run { send in
                    do {
                        await send(.avatarUploadResponse(.success(try await profileUseCase.updateAvatar(imageData: data))))
                    } catch {
                        await send(.avatarUploadResponse(.failure(error)))
                    }
                }
                .cancellable(id: CancelID.upload)

            case let .avatarUploadResponse(.success(profile)):
                state.isUploadingAvatar = false
                state.profile = profile
                return .none

            case let .avatarUploadResponse(.failure(error)):
                state.isUploadingAvatar = false
                state.alert = AlertState {
                    TextState("사진을 바꾸지 못했어요")
                } actions: {
                    ButtonState(role: .cancel) { TextState("확인") }
                } message: {
                    TextState(error.userMessage)
                }
                return .none

            case let .path(.element(_, action: .edit(.delegate(.profileUpdated(profile))))):
                state.profile = profile
                return .none

            case .path, .alert:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
        .ifLet(\.$alert, action: \.alert)
    }
}

extension ProfileFeature.Path.State: Equatable {}
