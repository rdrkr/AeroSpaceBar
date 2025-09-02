// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import PackageDescription

let package = Package(
    name: "AeroSpaceBar",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "AeroSpaceBar",
            targets: ["AeroSpaceBar"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/LebJe/TOMLKit.git", from: "0.6.0")
    ],
    targets: [
        .target(
            name: "AeroSpaceBar",
            dependencies: ["TOMLKit"]
        ),
        .testTarget(
            name: "AeroSpaceBarUITests",
            dependencies: ["AeroSpaceBar"]
        ),
        .testTarget(
            name: "AeroSpaceBarTests",
            dependencies: ["AeroSpaceBar"]
        )
    ]
)
