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
        .executable(
            name: "AeroSpaceBar",
            targets: ["AeroSpaceBar"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/LebJe/TOMLKit.git", from: "0.6.0"),
        .package(url: "https://github.com/mac-cain13/R.swift.git", from: "7.0.0")
    ],
    targets: [
        // MARK: - Main App

        .executableTarget(
            name: "AeroSpaceBar",
            dependencies: [
                "TOMLKit",
                .product(name: "RswiftLibrary", package: "R.swift")
            ],
            path: "AeroSpaceBar",
            plugins: [.plugin(name: "RswiftGeneratePublicResources", package: "R.swift")]
        ),

        // MARK: - Test Targets

        .testTarget(
            name: "AeroSpaceBarUITests",
            dependencies: ["AeroSpaceBar"],
            path: "AeroSpaceBarUITests"
        ),

        .testTarget(
            name: "AeroSpaceBarTests",
            dependencies: ["AeroSpaceBar"],
            path: "AeroSpaceBarTests"
        )
    ]
)
