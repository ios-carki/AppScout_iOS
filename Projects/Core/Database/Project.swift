import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.frameworkModule(
    name: Module.Core.database.rawValue,
    dependencies: [
        .External.sqliteData,
    ]
)
