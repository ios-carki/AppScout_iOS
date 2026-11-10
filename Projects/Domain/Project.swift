import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.frameworkModule(
    name: "Domain",
    dependencies: [
        .External.dependencies,
        .External.dependenciesMacros,
    ]
)
