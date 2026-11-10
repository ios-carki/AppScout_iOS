import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.frameworkModule(
    name: Module.Feature.settings.rawValue,
    dependencies: [
        .External.composableArchitecture,
        .domain,
        .shared(.designSystem),
    ]
)
