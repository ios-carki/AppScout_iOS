import ProjectDescription

public let appName = "AppScout"
public let bundlePrefix = "com.carki.appscout"
public let deployment: DeploymentTargets = .iOS("17.0")

/// 언어 모드는 Swift 5 (엄격한 동시성 검사 없이 TCA 복습에 집중하기 위함)
public let commonSettings: Settings = .settings(
    base: [
        "SWIFT_VERSION": "5.0",
        "ENABLE_USER_SCRIPT_SANDBOXING": "YES",
    ]
)

extension Project {

    // MARK: - Framework Module

    /// Feature / Domain / Data / Core / Shared 모듈 공통 템플릿.
    /// - Parameters:
    ///   - name: 모듈(타깃) 이름
    ///   - hasResources: `Resources/**`를 포함할지 여부
    ///   - hasExample: 단독 실행용 Example 앱 타깃을 만들지 여부
    ///   - dependencies: 프레임워크 타깃 의존성
    ///   - testDependencies: 테스트 타깃에 추가로 필요한 의존성
    public static func frameworkModule(
        name: String,
        hasResources: Bool = false,
        hasExample: Bool = false,
        dependencies: [TargetDependency] = [],
        testDependencies: [TargetDependency] = []
    ) -> Project {
        let frameworkTarget = Target.target(
            name: name,
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "\(bundlePrefix).\(name.lowercased())",
            deploymentTargets: deployment,
            sources: ["Sources/**"],
            resources: hasResources ? ["Resources/**"] : nil,
            dependencies: dependencies
        )

        let testTarget = Target.target(
            name: "\(name)Tests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "\(bundlePrefix).\(name.lowercased()).tests",
            deploymentTargets: deployment,
            sources: ["Tests/**"],
            resources: ["Tests/Resources/**"],
            dependencies: [.target(name: name)] + testDependencies
        )

        let exampleTarget = Target.target(
            name: "\(name)Example",
            destinations: .iOS,
            product: .app,
            bundleId: "\(bundlePrefix).\(name.lowercased()).example",
            deploymentTargets: deployment,
            infoPlist: .extendingDefault(with: [
                "UILaunchScreen": [:],
                "APIBaseURL": "$(API_BASE_URL)",
                "NSAppTransportSecurity": ["NSAllowsLocalNetworking": true],
            ]),
            sources: ["Example/Sources/**"],
            resources: ["Example/Resources/**"],
            dependencies: [.target(name: name)],
            settings: .settings(configurations: [
                .debug(name: .debug, xcconfig: .relativeToRoot("Configs/Debug.xcconfig")),
                .release(name: .release, xcconfig: .relativeToRoot("Configs/Release.xcconfig")),
            ])
        )

        var targets = [frameworkTarget, testTarget]
        if hasExample {
            targets.append(exampleTarget)
        }

        return Project(
            name: name,
            settings: commonSettings,
            targets: targets,
            resourceSynthesizers: .default
        )
    }

    // MARK: - App Module

    public static func appModule(
        dependencies: [TargetDependency],
        testDependencies: [TargetDependency] = []
    ) -> Project {
        Project(
            name: "App",
            settings: commonSettings,
            targets: [
                .target(
                    name: appName,
                    destinations: .iOS,
                    product: .app,
                    bundleId: "\(bundlePrefix)$(BUNDLE_ID_SUFFIX)",
                    deploymentTargets: deployment,
                    infoPlist: .extendingDefault(with: [
                        "CFBundleDisplayName": "$(APP_DISPLAY_NAME)",
                        "UILaunchScreen": [:],
                        "UISupportedInterfaceOrientations": ["UIInterfaceOrientationPortrait"],
                        "APIBaseURL": "$(API_BASE_URL)",
                        // 로컬 FastAPI 서버(http://localhost:8000) 접속 허용
                        "NSAppTransportSecurity": ["NSAllowsLocalNetworking": true],
                    ]),
                    sources: ["Sources/**"],
                    resources: ["Resources/**"],
                    dependencies: dependencies,
                    settings: .settings(configurations: [
                        .debug(name: .debug, xcconfig: .relativeToRoot("Configs/Debug.xcconfig")),
                        .release(name: .release, xcconfig: .relativeToRoot("Configs/Release.xcconfig")),
                    ])
                ),
                .target(
                    name: "\(appName)Tests",
                    destinations: .iOS,
                    product: .unitTests,
                    bundleId: "\(bundlePrefix).tests",
                    deploymentTargets: deployment,
                    sources: ["Tests/**"],
                    dependencies: [.target(name: appName)] + testDependencies
                ),
            ]
        )
    }
}
