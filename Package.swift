// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftRoonAPI",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SwiftRoonAPI",
            targets: ["SwiftRoonAPI"]
        ),
        .library(
            name: "RoonTransportAPI",
            targets: ["RoonTransportAPI"]
        )
    ],
    dependencies: [
        .package(url: "git@github.com:Slorq/SwiftLogger.git", .upToNextMajor(from: "0.0.1")),
        .package(url: "https://github.com/robbiehanson/CocoaAsyncSocket", .upToNextMajor(from: "7.0.0")),
    ],
    targets: [

        // API

        .target(
            name: "SwiftRoonAPICore",
            path: "SwiftRoonAPICore",
            exclude: [
                "Tests"
            ],
            sources: [
                "SwiftRoonAPICore/"
            ]
        ),
        .target(
            name: "SwiftRoonAPI",
            dependencies: ["SwiftRoonAPICore", "CocoaAsyncSocket", "SwiftLogger"],
            path: "SwiftRoonAPI",
            exclude: [
                "Tests",
            ],
            sources: [
                "SwiftRoonAPI/",
            ],
            swiftSettings: [
                .unsafeFlags(["-suppress-warnings"]),
            ]
        ),
        .target(
            name: "RoonTransportAPI",
            dependencies: ["SwiftRoonAPI", "SwiftLogger"],
            path: "TransportAPI",
            exclude: [
                "Tests",
            ],
            sources: [
                "TransportAPI/",
            ]
        ),

        // Test targets

        .testTarget(
            name: "SwiftRoonAPICoreTests",
            dependencies: ["SwiftRoonAPICore"],
            path: "SwiftRoonAPICore/Tests"
        ),
        .testTarget(
            name: "SwiftRoonAPITests",
            dependencies: ["SwiftRoonAPI"],
            path: "SwiftRoonAPI/Tests"
        ),
        .testTarget(
            name: "RoonTransportAPITests",
            dependencies: ["RoonTransportAPI"],
            path: "TransportAPI/Tests"
        ),
    ]
)
