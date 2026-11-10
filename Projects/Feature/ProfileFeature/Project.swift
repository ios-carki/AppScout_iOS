import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.frameworkModule(
    name: Module.Feature.profile.rawValue,
    dependencies: [
        .External.composableArchitecture,
        .domain,
        .shared(.designSystem),
        .feature(.settings),
    ]
)
