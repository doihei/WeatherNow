// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Tools",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.54.0"),
        .package(url: "https://github.com/realm/SwiftLint", from: "0.57.0"),
    ],
    targets: [
        .target(name: "Tools", path: "Sources"),
    ]
)
