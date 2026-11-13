import ComposableArchitecture
import Domain
import Testing
@testable import SettingsFeature

/// TestStore로 설정 리듀서를 검증한다.
@MainActor
@Suite("SettingsFeature")
struct SettingsFeatureTests {
    @Test("테마 변경 → @Shared 값 변경")
    func themeChanged() async {
        let store = TestStore(initialState: SettingsFeature.State()) {
            SettingsFeature()
        }

        await store.send(.themeChanged(.dark)) {
            $0.$theme.withLock { $0 = .dark }
        }
    }

    @Test("최근 검색어 개수 구독")
    func observeRecentKeywords() async {
        let store = TestStore(initialState: SettingsFeature.State()) {
            SettingsFeature()
        } withDependencies: {
            $0.recentKeywordUseCase.observe = {
                AsyncThrowingStream {
                    $0.yield(RecentKeyword.mocks)
                    $0.finish()
                }
            }
        }

        await store.send(.onAppear)
        await store.receive(\.recentKeywordsUpdated) {
            $0.recentKeywordCount = RecentKeyword.mocks.count
        }
    }

    @Test("전체 삭제 탭 → 다이얼로그 → 확인 → deleteAll 호출")
    func clearConfirmed() async {
        let deleted = LockIsolated(false)
        let store = TestStore(initialState: SettingsFeature.State()) {
            SettingsFeature()
        } withDependencies: {
            $0.recentKeywordUseCase.deleteAll = { deleted.setValue(true) }
        }

        await store.send(.clearRecentKeywordsTapped) {
            $0.confirmationDialog = Self.dialog
        }
        await store.send(.confirmationDialog(.presented(.clearConfirmed))) {
            $0.confirmationDialog = nil
        }
        #expect(deleted.value)
    }

    @Test("다이얼로그 취소 → deleteAll 호출 없음")
    func clearCancelled() async {
        let store = TestStore(initialState: SettingsFeature.State()) {
            SettingsFeature()
        }   // deleteAll 미정의 → 호출되면 실패

        await store.send(.clearRecentKeywordsTapped) {
            $0.confirmationDialog = Self.dialog
        }
        await store.send(.confirmationDialog(.dismiss)) {
            $0.confirmationDialog = nil
        }
    }

    @Test("삭제 실패 → 알럿")
    func clearFailed() async {
        let store = TestStore(initialState: SettingsFeature.State()) {
            SettingsFeature()
        } withDependencies: {
            $0.recentKeywordUseCase.deleteAll = { throw DomainError.storage }
        }

        await store.send(.clearRecentKeywordsTapped) {
            $0.confirmationDialog = Self.dialog
        }
        await store.send(.confirmationDialog(.presented(.clearConfirmed))) {
            $0.confirmationDialog = nil
        }
        await store.receive(\.clearFailed) {
            $0.alert = AlertState {
                TextState("삭제하지 못했어요")
            } actions: {
                ButtonState(role: .cancel) { TextState("확인") }
            } message: {
                TextState(DomainError.storage.message)
            }
        }
    }

    static let dialog = ConfirmationDialogState<SettingsFeature.Action.Dialog> {
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
}
