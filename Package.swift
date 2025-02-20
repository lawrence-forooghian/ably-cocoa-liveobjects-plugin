// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AblyLiveObjects",
    platforms: [
        .macOS(.v11),
        .iOS(.v14),
        .tvOS(.v14),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AblyLiveObjects",
            targets: ["AblyLiveObjects"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/ably/ably-cocoa",
            branch: "2035-investigate-liveobjects-plugin"
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AblyLiveObjects",
            dependencies: [
                .product(
                    name: "Ably",
                    package: "ably-cocoa"
                ),
                .product(
                    name: "AblyPlugin",
                    package: "ably-cocoa"
                )
            ]
        ),
        .testTarget(
            name: "AblyLiveObjectsTests",
            dependencies: ["AblyLiveObjects"]
        ),
    ]
)
