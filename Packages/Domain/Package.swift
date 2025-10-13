// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import PackageDescription

/// Define the package.
public let package = Package(
    name: "Domain",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "Domain",
            targets: ["Domain"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/WilhelmOks/ModifiedCopyMacro.git", exact: "2.1.2")
    ],
    targets: [
        .target(
            name: "Domain",
            dependencies: [
                .product(name: "ModifiedCopy", package: "ModifiedCopyMacro")
            ],
            path: "Sources/Domain",
            resources: [
                .process("Resources/Localizable.xcstrings")
            ],
            swiftSettings: [
                .treatAllWarnings(as: .error),
                .strictMemorySafety()
            ]
        ),
        .testTarget(
            name: "DomainTests",
            dependencies: [
                .target(name: "Domain")
            ],
            path: "Tests/DomainTests",
            swiftSettings: [
                .treatAllWarnings(as: .error),
                .strictMemorySafety()
            ]
        )
    ]
)
