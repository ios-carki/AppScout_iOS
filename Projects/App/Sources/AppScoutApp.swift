import ComposableArchitecture
import Database
import DesignSystem
import RootFeature
import SwiftUI

@main
struct AppScoutApp: App {
    /// Store는 앱 전체에서 한 번만 만든다.
    /// `body` 안에서 만들면 body가 다시 평가될 때 새 Store가 생겨 상태가 초기화될 수 있다.
    @MainActor
    static let store = Store(initialState: RootFeature.State()) {
        RootFeature()
            ._printChanges()
    }

    init() {
        DesignSystem.registerFonts()

        // SQLiteData 기본 DB 연결. 앱 생명주기에서 딱 한 번, 가능한 한 일찍 설정해야 한다.
        // 테스트·프리뷰에서는 각자 임시 DB를 쓰므로 여기서 설정하지 않는다.
        if !isTesting {
            prepareDependencies {
                $0.defaultDatabase = try! appDatabase()
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            if isTesting {
                // 유닛 테스트 실행 중에는 실제 화면·의존성을 띄우지 않는다.
                EmptyView()
            } else {
                RootView(store: Self.store)
            }
        }
    }
}
