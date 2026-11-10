import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.frameworkModule(
    name: Module.Shared.designSystem.rawValue,
    hasResources: true,
    dependencies: [
        .External.kingfisher,
    ]
)
