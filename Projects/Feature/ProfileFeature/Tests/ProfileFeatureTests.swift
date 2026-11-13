import ComposableArchitecture
import Domain
import Foundation
import Testing
@testable import ProfileFeature

/// TestStore로 프로필 리듀서를 검증한다. (docs/feature-guide.md#profile 의 "테스트 목록")
@MainActor
@Suite("ProfileFeature")
struct ProfileFeatureTests {
    @Test("조회 성공 → 프로필 표시")
    func fetchSuccess() async {
        let store = TestStore(initialState: ProfileFeature.State()) {
            ProfileFeature()
        } withDependencies: {
            $0.profileUseCase.fetch = { .mock }
        }

        await store.send(.onAppear)
        await store.receive(\.profileResponse.success) {
            $0.profile = .mock
            $0.loadState = .loaded
        }
    }

    @Test("첫 조회 실패 → 에러, 이미 프로필이 있으면 실패해도 유지")
    func fetchFailure() async {
        let store = TestStore(initialState: ProfileFeature.State()) {
            ProfileFeature()
        } withDependencies: {
            $0.profileUseCase.fetch = { throw DomainError.network }
        }

        await store.send(.onAppear)
        await store.receive(\.profileResponse.failure) {
            $0.loadState = .failed(DomainError.network.message)
        }

        var loaded = ProfileFeature.State()
        loaded.profile = .mock
        loaded.loadState = .loaded
        let store2 = TestStore(initialState: loaded) {
            ProfileFeature()
        } withDependencies: {
            $0.profileUseCase.fetch = { throw DomainError.network }
        }

        await store2.send(.onAppear)
        await store2.receive(\.profileResponse.failure)   // 상태 변화 없음
    }

    @Test("편집 화면의 delegate → 프로필 갱신")
    func profileUpdatedFromEdit() async {
        var state = ProfileFeature.State()
        state.profile = .mock
        state.loadState = .loaded
        let store = TestStore(initialState: state) {
            ProfileFeature()
        }

        await store.send(.nameRowTapped) {
            $0.path[id: 0] = .edit(EditFieldFeature.State(field: .name, original: Profile.mock.name))
        }

        let updated = Profile(name: "철수", email: Profile.mock.email, avatarURL: nil)
        await store.send(.path(.element(id: 0, action: .edit(.delegate(.profileUpdated(updated)))))) {
            $0.profile = updated
        }
    }

    @Test("설정 버튼 → 설정 push")
    func settingsButtonTapped() async {
        let store = TestStore(initialState: ProfileFeature.State()) {
            ProfileFeature()
        }
        await store.send(.settingsButtonTapped) {
            $0.path[id: 0] = .settings(.init())
        }
    }

    @Test("사진 업로드 성공 → 프로필 갱신")
    func uploadSuccess() async {
        let uploaded = Profile(name: "Chris", email: "chris@example.com", avatarURL: URL(string: "http://localhost/a.jpg"))
        var state = ProfileFeature.State()
        state.profile = .mock
        let store = TestStore(initialState: state) {
            ProfileFeature()
        } withDependencies: {
            $0.profileUseCase.updateAvatar = { _ in uploaded }
        }

        await store.send(.photoPicked(Data([0x01]))) {
            $0.isUploadingAvatar = true
        }
        await store.receive(\.avatarUploadResponse.success) {
            $0.isUploadingAvatar = false
            $0.profile = uploaded
        }
    }

    @Test("사진 업로드 실패 → 알럿, 기존 사진 유지")
    func uploadFailure() async {
        var state = ProfileFeature.State()
        state.profile = .mock
        let store = TestStore(initialState: state) {
            ProfileFeature()
        } withDependencies: {
            $0.profileUseCase.updateAvatar = { _ in throw DomainError.validation(.imageTooLarge(maximumMegabytes: 20)) }
        }

        await store.send(.photoPicked(Data([0x01]))) {
            $0.isUploadingAvatar = true
        }
        await store.receive(\.avatarUploadResponse.failure) {
            $0.isUploadingAvatar = false
            $0.alert = AlertState {
                TextState("사진을 바꾸지 못했어요")
            } actions: {
                ButtonState(role: .cancel) { TextState("확인") }
            } message: {
                TextState(ValidationError.imageTooLarge(maximumMegabytes: 20).message)
            }
        }
    }
}

@MainActor
@Suite("EditFieldFeature")
struct EditFieldFeatureTests {
    @Test("형식 오류 → 저장 불가, 0.5초 뒤 인라인 오류")
    func invalidInput() async {
        let clock = TestClock()
        let store = TestStore(initialState: EditFieldFeature.State(field: .email, original: "chris@example.com")) {
            EditFieldFeature()
        } withDependencies: {
            $0.continuousClock = clock
        }

        await store.send(.textChanged("chris@")) {
            $0.text = "chris@"
        }
        #expect(!store.state.canSave)

        await clock.advance(by: .milliseconds(500))
        await store.receive(\.validationDebounced) {
            $0.errorMessage = ValidationError.emailInvalid.message
        }
    }

    @Test("값이 바뀌지 않았으면 저장 불가")
    func unchanged() async {
        let store = TestStore(initialState: EditFieldFeature.State(field: .name, original: "Chris")) {
            EditFieldFeature()
        }
        #expect(!store.state.canSave)
        await store.send(.saveButtonTapped)
    }

    @Test("저장 성공 → delegate 전송 + dismiss 호출")
    func saveSuccess() async {
        let dismissed = LockIsolated(false)
        let updated = Profile(name: "철수", email: "chris@example.com", avatarURL: nil)
        var state = EditFieldFeature.State(field: .name, original: "Chris")
        state.text = "철수"

        let store = TestStore(initialState: state) {
            EditFieldFeature()
        } withDependencies: {
            $0.profileUseCase.updateName = { _ in updated }
            $0.dismiss = DismissEffect { dismissed.setValue(true) }
        }

        await store.send(.saveButtonTapped) {
            $0.isSaving = true
        }
        await store.receive(\.saveResponse.success) {
            $0.isSaving = false
        }
        await store.receive(\.delegate.profileUpdated, updated)
        #expect(dismissed.value)
    }

    @Test("서버 422 → 인라인 오류")
    func serverValidationError() async {
        var state = EditFieldFeature.State(field: .email, original: "chris@example.com")
        state.text = "new@example.com"
        let store = TestStore(initialState: state) {
            EditFieldFeature()
        } withDependencies: {
            $0.profileUseCase.updateEmail = { _ in
                throw DomainError.validation(.server(message: "이미 사용 중인 이메일이에요."))
            }
        }

        await store.send(.saveButtonTapped) {
            $0.isSaving = true
        }
        await store.receive(\.saveResponse.failure) {
            $0.isSaving = false
            $0.errorMessage = "이미 사용 중인 이메일이에요."
        }
    }

    @Test("네트워크 오류 → 알럿, 입력값 유지")
    func networkError() async {
        var state = EditFieldFeature.State(field: .name, original: "Chris")
        state.text = "철수"
        let store = TestStore(initialState: state) {
            EditFieldFeature()
        } withDependencies: {
            $0.profileUseCase.updateName = { _ in throw DomainError.network }
        }

        await store.send(.saveButtonTapped) {
            $0.isSaving = true
        }
        await store.receive(\.saveResponse.failure) {
            $0.isSaving = false
            $0.alert = AlertState {
                TextState("저장하지 못했어요")
            } actions: {
                ButtonState(role: .cancel) { TextState("확인") }
            } message: {
                TextState(DomainError.network.message)
            }
        }
    }
}
