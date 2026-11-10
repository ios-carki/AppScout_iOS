import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.frameworkModule(
    name: Module.Feature.search.rawValue,
    dependencies: [
        .External.composableArchitecture,
        .domain,
        .shared(.designSystem),
        .feature(.appDetail),
    ]
)
