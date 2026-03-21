// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WeatherFeature",
    platforms: [.iOS(.v17)],
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
    ],
    targets: [
        .target(
            name: "WeatherFeatureMVVM",
            dependencies: [
                "WeatherDomain",
                "CoreUI",
            ]
        ),
        .target(
            name: "WeatherFeatureTCA",
            dependencies: [
                "WeatherDomain",
                "CoreUI",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .testTarget(
            name: "WeatherFeatureTests",
            dependencies: [
                "WeatherFeatureMVVM",
                "WeatherFeatureTCA",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
    ]
)
