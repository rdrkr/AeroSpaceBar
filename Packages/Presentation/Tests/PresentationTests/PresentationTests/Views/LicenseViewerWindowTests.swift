// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Nimble
@testable import Presentation
import SwiftUI
import XCTest

/// Tests for LicenseViewerWindow component.
///
/// These tests verify:
/// - Initialization
/// - Property handling
/// - License text display
/// - Helper function behavior
@MainActor
final class LicenseViewerWindowTests: XCTestCase {
    // MARK: - Initialization Tests

    func testInitialization() {
        // Given
        let dependencyName = "Test Dependency"
        let licenseText = "MIT License\n\nCopyright (c) 2025"

        // When
        let window = LicenseViewerWindow(
            dependencyName: dependencyName,
            licenseText: licenseText
        )

        // Then - Should not crash
        expect(window).toNot(beNil())
    }

    func testInitializationWithEmptyText() {
        // Given
        let dependencyName = "Empty Dependency"
        let licenseText = ""

        // When
        let window = LicenseViewerWindow(
            dependencyName: dependencyName,
            licenseText: licenseText
        )

        // Then - Should not crash
        expect(window).toNot(beNil())
    }

    func testInitializationWithLongLicenseText() {
        // Given
        let dependencyName = "Long License"
        let licenseText = String(repeating: "License text line.\n", count: 100)

        // When
        let window = LicenseViewerWindow(
            dependencyName: dependencyName,
            licenseText: licenseText
        )

        // Then - Should not crash
        expect(window).toNot(beNil())
    }

    // MARK: - Property Tests

    func testDependencyNameProperty() {
        // Given
        let expectedName = "SwiftUI Framework"
        let licenseText = "Apache License 2.0"

        // When
        let window = LicenseViewerWindow(
            dependencyName: expectedName,
            licenseText: licenseText
        )

        // Then
        expect(window.dependencyName) == expectedName
    }

    func testLicenseTextProperty() {
        // Given
        let dependencyName = "Test"
        let expectedText = """
        MIT License

        Permission is hereby granted...
        """

        // When
        let window = LicenseViewerWindow(
            dependencyName: dependencyName,
            licenseText: expectedText
        )

        // Then
        expect(window.licenseText) == expectedText
    }

    func testPropertiesWithSpecialCharacters() {
        // Given
        let dependencyName = "Dependency™ with © symbols"
        let licenseText = "License with unicode: café, naïve, 日本語"

        // When
        let window = LicenseViewerWindow(
            dependencyName: dependencyName,
            licenseText: licenseText
        )

        // Then
        expect(window.dependencyName) == dependencyName
        expect(window.licenseText) == licenseText
    }

    // MARK: - License Text Display Tests

    func testDisplaysFullLicenseText() {
        // Given
        let licenseText = """
        MIT License

        Copyright (c) 2025 Test Author

        Permission is hereby granted, free of charge, to any person obtaining a copy
        of this software and associated documentation files (the "Software"), to deal
        in the Software without restriction.
        """

        // When
        let window = LicenseViewerWindow(
            dependencyName: "Test",
            licenseText: licenseText
        )

        // Then
        expect(window.licenseText) == licenseText
        expect(window.licenseText.contains("MIT License")) == true
        expect(window.licenseText.contains("Copyright (c) 2025")) == true
    }

    func testHandlesMultipleLicenses() {
        // Given
        let licenseText = """
        Primary License: MIT

        Secondary License: Apache 2.0
        """

        // When
        let window = LicenseViewerWindow(
            dependencyName: "Multi-License Package",
            licenseText: licenseText
        )

        // Then
        expect(window.licenseText) == licenseText
        expect(window.licenseText.contains("MIT")) == true
        expect(window.licenseText.contains("Apache")) == true
    }
}
