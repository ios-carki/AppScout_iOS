import ComposableArchitecture
import Foundation

/// 화면 모드. UserDefaults에 저장되어 재실행 후에도 유지된다.
public enum AppTheme: String, CaseIterable, Sendable {
    case system
    case light
    case dark

    public var title: String {
        switch self {
        case .system: "시스템"
        case .light: "라이트"
        case .dark: "다크"
        }
    }
}

extension SharedKey where Self == AppStorageKey<AppTheme>.Default {
    /// 설정 화면이 바꾸고 RootView가 읽는 테마 값
    public static var appTheme: Self {
        Self[.appStorage("appTheme"), default: .system]
    }
}
