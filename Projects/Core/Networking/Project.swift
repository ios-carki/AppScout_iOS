import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.frameworkModule(
    name: Module.Core.networking.rawValue,
    dependencies: [
        .External.alamofire,
    ]
)
