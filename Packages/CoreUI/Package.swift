// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "CoreUI",
    defaultLocalization: "ja", // Required for packages with localized resources
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(
            name: "CoreUI",
            targets: ["CoreUI"]
        ),
    ],
    dependencies: [
        .package(path: "../CoreModels"),
        .package(url: "https://github.com/SFSafeSymbols/SFSafeSymbols.git", from: "5.3.0"),
    ],
    targets: [
        .target(
            name: "CoreUI",
            dependencies: [
                "CoreModels",
                .product(name: "SFSafeSymbols", package: "SFSafeSymbols"),
            ],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "CoreUITests",
            dependencies: ["CoreUI"]
        ),
    ]
)
