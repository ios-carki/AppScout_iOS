import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.appModule(
    dependencies: [
        .feature(.root),
        .External.composableArchitecture,
        .domain,
        .data,
        .core(.networking),
        .core(.database),
        .shared(.designSystem),
    ]
)
