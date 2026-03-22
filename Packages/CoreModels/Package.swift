// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoreModels",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "CoreModels",
            targets: ["CoreModels"]
        ),
    ],
    targets: [
        .target(
            name: "CoreModels"
        ),
        .testTarget(
            name: "CoreModelsTests",
            dependencies: ["CoreModels"]
        ),
    ]
)
