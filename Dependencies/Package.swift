// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Dependencies",
    products: [
        .library(name: "Dependencies", targets: ["Dependencies"]),
    ],
    dependencies: [
        .package(url: "https://github.com/jp-fan-app/swift-client", from: "0.19.0"),
    ],
    targets: [
        .target(name: "Dependencies", dependencies: ["JPFanAppClient"]),
        .testTarget(name: "DependenciesTests", dependencies: ["Dependencies"]),
    ]
)