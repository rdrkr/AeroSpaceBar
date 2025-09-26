// swift-tools-version: 6.2
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
        ),
        .library(
            name: "Domain",
            targets: ["Domain"]
        ),
        .library(
            name: "Service",
            targets: ["Service"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/WilhelmOks/ModifiedCopyMacro.git", from: "2.1.2"),
        .package(url: "https://github.com/LebJe/TOMLKit.git", from: "0.6.0")
    ],
    targets: [
        .executableTarget(
            name: "AeroSpaceBar",
            dependencies: [
                .target(name: "Service")
            ],
            path: "Sources/Presentation",
            exclude: [
                "AeroSpaceBar.entitlements",
                "AppIcon.icon",
                "Info.plist"
            ],
            resources: [
                .process("Resources/Assets.xcassets"),
                .process("Resources/Localizable.xcstrings")
            ],
            swiftSettings: [
                .treatAllWarnings(as: .error),
                .strictMemorySafety()
            ],
            linkerSettings: [
                .linkedFramework("AppIntents")
            ]
        ),
        .target(
            name: "Domain",
            dependencies: [
                .product(name: "ModifiedCopyMacro", package: "ModifiedCopyMacro")
            ],
            path: "Sources/Domain",
            swiftSettings: [
                .treatAllWarnings(as: .error),
                .strictMemorySafety()
            ],
            linkerSettings: [
                .linkedFramework("AppIntents")
            ]
        ),
        .target(
            name: "Service",
            dependencies: [
                .target(name: "Domain"),
                .product(name: "TOMLKit", package: "TOMLKit")
            ],
            path: "Sources/Service",
            swiftSettings: [
                .treatAllWarnings(as: .error),
                .strictMemorySafety()
            ],
            linkerSettings: [
                .linkedFramework("AppIntents")
            ]
        ),
        .testTarget(
            name: "AeroSpaceBarUITests",
            dependencies: [
                .target(name: "AeroSpaceBar")
            ],
            path: "Tests/PresentationUITests",
            swiftSettings: [
                .treatAllWarnings(as: .error),
                .strictMemorySafety()
            ]
        ),
        .testTarget(
            name: "AeroSpaceBarTests",
            dependencies: [
                .target(name: "AeroSpaceBar")
            ],
            path: "Tests/PresentationTests",
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
        ),
        .testTarget(
            name: "ServiceTests",
            dependencies: [
                .target(name: "Service")
            ],
            path: "Tests/ServiceTests",
            swiftSettings: [
                .treatAllWarnings(as: .error),
                .strictMemorySafety()
            ]
        )
    ]
)
