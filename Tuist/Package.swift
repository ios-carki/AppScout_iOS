// swift-tools-version: 5.9
import PackageDescription

#if TUIST
    import ProjectDescription

    // TCA와 Point-Free 계열 패키지는 정적으로 링크하면 SwiftUI 프리뷰가 깨질 수 있어서,
    // Tuist 공식 문서 권장대로 동적 프레임워크(.framework)로 링크한다.
    // https://docs.tuist.dev/en/guides/features/projects/dependencies#the-composable-architecture
    // (TCA_Study/Tuist/Package.swift 설정을 그대로 가져옴)
    let packageSettings = PackageSettings(
        productTypes: [
            "CasePaths": .framework,
            "CasePathsCore": .framework,
            // 매크로(컴파일러 플러그인)가 의존하므로 동적이 되면 안 됨
            "CasePathsMacrosSupport": .staticFramework,
            "Clocks": .framework,
            "CombineSchedulers": .framework,
            "ComposableArchitecture": .framework,
            "ConcurrencyExtras": .framework,
            "CustomDump": .framework,
            "Dependencies": .framework,
            "DependenciesTestSupport": .framework,
            "IdentifiedCollections": .framework,
            "InternalCollectionsUtilities": .framework,
            "IssueReporting": .framework,
            "IssueReportingPackageSupport": .framework,
            "IssueReportingTestSupport": .framework,
            "OrderedCollections": .framework,
            "Perception": .framework,
            "PerceptionCore": .framework,
            "Sharing": .framework,
            "SnapshotTesting": .framework,
            "SwiftNavigation": .framework,
            "SwiftUINavigation": .framework,
            "UIKitNavigation": .framework,
            "XCTestDynamicOverlay": .framework,
        ],
        // Sharing 모듈 이름이 시스템 프레임워크와 겹치므로 SwiftSharing으로 별칭 처리
        targetSettings: [
            "ComposableArchitecture": .settings(base: [
                "OTHER_SWIFT_FLAGS": ["-module-alias", "Sharing=SwiftSharing"],
            ]),
            "Sharing": .settings(base: [
                "PRODUCT_NAME": "SwiftSharing",
                "OTHER_SWIFT_FLAGS": ["-module-alias", "Sharing=SwiftSharing"],
            ]),
            "SQLiteData": .settings(base: [
                "OTHER_SWIFT_FLAGS": ["-module-alias", "Sharing=SwiftSharing"],
            ]),
        ]
    )
#endif

let package = Package(
    name: "AppScout",
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            .upToNextMajor(from: "1.26.2")
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-dependencies",
            .upToNextMajor(from: "1.17.2")
        ),
        .package(
            url: "https://github.com/pointfreeco/sqlite-data",
            .upToNextMajor(from: "1.13.0")
        ),
        .package(
            url: "https://github.com/Alamofire/Alamofire",
            .upToNextMajor(from: "5.12.2")
        ),
        .package(
            url: "https://github.com/onevcat/Kingfisher",
            .upToNextMajor(from: "8.15.0")
        ),
    ]
)
