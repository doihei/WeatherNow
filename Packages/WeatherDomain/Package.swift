// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WeatherDomain",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(
            name: "WeatherDomain",
            targets: ["WeatherDomain"]
        ),
    ],
    dependencies: [
        .package(path: "../CoreModels"),
        .package(path: "../CoreNetwork"),
        .package(
            url: "https://github.com/pointfreeco/swift-dependencies",
            from: "1.0.0"
        ),
    ],
    targets: [
        .target(
            name: "WeatherDomain",
            dependencies: [
                "CoreModels",
                "CoreNetwork",
                .product(name: "Dependencies", package: "swift-dependencies"),
            ]
        ),
        .testTarget(
            name: "WeatherDomainTests",
            dependencies: [
                "WeatherDomain",
                "CoreNetwork",
                "CoreModels",
                .product(name: "Dependencies", package: "swift-dependencies"),
            ]
        ),
    ]
)
