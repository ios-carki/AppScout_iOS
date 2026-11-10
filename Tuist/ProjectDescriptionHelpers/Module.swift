import ProjectDescription

/// 프로젝트 안의 모든 모듈을 타입으로 정의한다.
/// 문자열로 모듈 이름을 적다가 생기는 오타를 막고, 경로 규칙을 한 곳에서 관리하기 위함.
public enum Module {
    public enum Feature: String, CaseIterable {
        case root = "RootFeature"
        case search = "SearchFeature"
        case appDetail = "AppDetailFeature"
        case favorites = "FavoritesFeature"
        case profile = "ProfileFeature"
        case settings = "SettingsFeature"
    }

    public enum Core: String, CaseIterable {
        case networking = "Networking"
        case database = "Database"
    }

    public enum Shared: String, CaseIterable {
        case designSystem = "DesignSystem"
    }
}

// MARK: - 내부 모듈 의존성

extension TargetDependency {
    public static func feature(_ module: Module.Feature) -> TargetDependency {
        .project(
            target: module.rawValue,
            path: .relativeToRoot("Projects/Feature/\(module.rawValue)")
        )
    }

    public static func core(_ module: Module.Core) -> TargetDependency {
        .project(
            target: module.rawValue,
            path: .relativeToRoot("Projects/Core/\(module.rawValue)")
        )
    }

    public static func shared(_ module: Module.Shared) -> TargetDependency {
        .project(
            target: module.rawValue,
            path: .relativeToRoot("Projects/Shared/\(module.rawValue)")
        )
    }

    public static let domain: TargetDependency = .project(
        target: "Domain",
        path: .relativeToRoot("Projects/Domain")
    )

    public static let data: TargetDependency = .project(
        target: "Data",
        path: .relativeToRoot("Projects/Data")
    )
}

// MARK: - 외부 라이브러리 의존성

extension TargetDependency {
    public enum External {
        public static let composableArchitecture: TargetDependency = .external(name: "ComposableArchitecture")
        public static let dependencies: TargetDependency = .external(name: "Dependencies")
        public static let dependenciesMacros: TargetDependency = .external(name: "DependenciesMacros")
        public static let sqliteData: TargetDependency = .external(name: "SQLiteData")
        /// SQLiteData가 내부적으로 쓰는 GRDB. ValueObservation(DB 변경 관찰)을 쓰기 위해 직접 연결한다.
        public static let grdb: TargetDependency = .external(name: "GRDB")
        public static let alamofire: TargetDependency = .external(name: "Alamofire")
        public static let kingfisher: TargetDependency = .external(name: "Kingfisher")
    }
}
