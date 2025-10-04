// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import PackageDescription

let package = Package(
    name: "Presentation",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "Presentation",
            targets: ["Presentation"]
        )
    ],
    dependencies: [
        .package(path: "../Data")
    ],
    targets: [
        .target(
            name: "Presentation",
            dependencies: [
                .product(name: "Data", package: "Data")
            ],
            path: "Sources/Presentation",
            swiftSettings: [
                .treatAllWarnings(as: .error),
                .strictMemorySafety()
            ]
        ),
        .testTarget(
            name: "PresentationTests",
            dependencies: [
                .target(name: "Presentation")
            ],
            path: "Tests/PresentationTests",
            swiftSettings: [
                .treatAllWarnings(as: .error),
                .strictMemorySafety()
            ]
        ),
        .testTarget(
            name: "PresentationUITests",
            dependencies: [
                .target(name: "Presentation")
            ],
            path: "Tests/PresentationUITests",
            swiftSettings: [
                .treatAllWarnings(as: .error),
                .strictMemorySafety()
            ]
        )
    ]
)
