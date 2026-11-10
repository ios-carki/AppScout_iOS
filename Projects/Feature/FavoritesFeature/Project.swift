import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.frameworkModule(
    name: Module.Feature.favorites.rawValue,
    dependencies: [
        .External.composableArchitecture,
        .domain,
        .shared(.designSystem),
        .feature(.appDetail),
    ]
)
