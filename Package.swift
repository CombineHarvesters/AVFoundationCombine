// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "AVFoundationCombine",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "AVFoundationCombine",
            targets: ["AVFoundationCombine"]),
    ],
    targets: [
        .target(
            name: "AVFoundationCombine"),
        .testTarget(
            name: "AVFoundationCombineTests",
            dependencies: ["AVFoundationCombine"]),
    ]
)
