import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.frameworkModule(
    name: "Data",
    dependencies: [
        .domain,
        .core(.networking),
        .core(.database),
    ]
)
