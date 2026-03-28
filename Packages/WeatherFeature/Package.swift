// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WeatherFeature",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "WeatherFeatureMVVM", targets: ["WeatherFeatureMVVM"]),
        .library(name: "WeatherFeatureTCA", targets: ["WeatherFeatureTCA"]),
    ],
    dependencies: [
        .package(path: "../WeatherDomain"),
        .package(path: "../CoreUI"),
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "1.17.0"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-dependencies",
            from: "1.0.0"
        ),
    ],
    targets: [
        .target(
            name: "WeatherFeatureMVVM",
            dependencies: [
                "WeatherDomain",
                "CoreUI",
                .product(name: "Dependencies", package: "swift-dependencies"),
            ],
            path: "Sources/MVVM"
        ),
        .target(
            name: "WeatherFeatureTCA",
            dependencies: [
                "WeatherDomain",
                "CoreUI",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ],
            path: "Sources/TCA"
        ),
        .testTarget(
            name: "WeatherFeatureMVVMTests",
            dependencies: [
                "WeatherFeatureMVVM",
                "WeatherDomain",
                .product(name: "Dependencies", package: "swift-dependencies"),
            ],
            path: "Tests/WeatherFeatureMVVMTests"
        ),
        .testTarget(
            name: "WeatherFeatureTCATests",
            dependencies: [
                "WeatherFeatureTCA",
                "WeatherDomain",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ],
            path: "Tests/WeatherFeatureTCATests"
        ),
    ]
)
