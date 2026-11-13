import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.frameworkModule(
    name: Module.Feature.root.rawValue,
    dependencies: [
        .External.composableArchitecture,
        .domain,
        .shared(.designSystem),
        .feature(.search),
        .feature(.favorites),
        .feature(.profile),
        .feature(.settings),
    ]
)
