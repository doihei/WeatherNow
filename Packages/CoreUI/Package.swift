// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoreUI",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "CoreUI",
            targets: ["CoreUI"]
        ),
    ],
    dependencies: [
        .package(path: "../CoreModels"),
    ],
    targets: [
        .target(
            name: "CoreUI",
            dependencies: ["CoreModels"]
        ),
        .testTarget(
            name: "CoreUITests",
            dependencies: ["CoreUI"]
        ),
    ]
)
