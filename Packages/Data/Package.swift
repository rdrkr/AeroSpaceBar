// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import PackageDescription

/// Define the package.
public let package = Package(
    name: "Data",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "Data",
            targets: ["Data"]
        )
    ],
    dependencies: [
        .package(path: "../Domain"),
        .package(url: "https://github.com/LebJe/TOMLKit.git", exact: "0.6.0"),
        .package(url: "https://github.com/rdrkr/AsyncFileMonitor.git", exact: "1.0.0"),
        .package(url: "https://github.com/lmsqueezy/lemonsqueezy-swift.git", exact: "1.3.0"),
        .package(url: "https://github.com/sparkle-project/Sparkle.git", exact: "2.8.0")
    ],
    targets: [
        .target(
            name: "Data",
            dependencies: [
                .product(name: "Domain", package: "Domain"),
                .product(name: "AsyncFileMonitor", package: "AsyncFileMonitor"),
                .product(name: "LemonSqueezy", package: "lemonsqueezy-swift"),
                .product(name: "Sparkle", package: "Sparkle"),
                .product(name: "TOMLKit", package: "TOMLKit")
            ],
            path: "Sources/Data",
            swiftSettings: [
                .treatAllWarnings(as: .error),
                .strictMemorySafety()
            ],
            plugins: [
                .plugin(name: "SecretGeneratorPlugin")
            ]
        ),
        .plugin(
            name: "SecretGeneratorPlugin",
            capability: .buildTool(),
            path: "Plugins/SecretGeneratorPlugin"
        ),
        .testTarget(
            name: "DataTests",
            dependencies: [
                .target(name: "Data")
            ],
            path: "Tests/DataTests",
            swiftSettings: [
                .treatAllWarnings(as: .error),
                .strictMemorySafety()
            ]
        )
    ]
)
