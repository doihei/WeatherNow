// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WeatherDomain",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "WeatherDomain",
            targets: ["WeatherDomain"]
        ),
    ],
    dependencies: [
        .package(path: "../CoreModels"),
        .package(path: "../CoreNetwork"),
    ],
    targets: [
        .target(
            name: "WeatherDomain",
            dependencies: ["CoreModels", "CoreNetwork"]
        ),
        .testTarget(
            name: "WeatherDomainTests",
            dependencies: ["WeatherDomain"]
        ),
    ]
)
