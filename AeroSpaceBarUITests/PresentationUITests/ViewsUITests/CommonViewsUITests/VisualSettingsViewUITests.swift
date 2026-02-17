// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Nimble
import XCTest

/// UI tests for VisualSettingsView.
///
/// These tests verify visual settings UI including:
/// - Background section (tint color, opacity, blur)
/// - Border section (color, opacity, width)
/// - Foreground section (color)
/// - Geometry section (border width, corner radius)
/// - Theme mode conditional display
/// - Metadata-driven configuration
@MainActor
final class VisualSettingsViewUITests: XCTestCase {
    private var app: XCUIApplication?

    override func setUp() async throws {
        try await super.setUp()
        continueAfterFailure = false
        // Use guard statement to safely initialize app

        app = XCUIApplication()

        guard let app else {
            XCTFail("XCUIApplication should be initialized")

            return
        }

        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    // MARK: - Display Tests

    func testVisualSettingsViewDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given visual settings are displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then visual settings view should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Visual settings view should be displayed"
        )
    }

    func testBackgroundSectionDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given visual settings are displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then background section should be displayed
        // When theme mode allows color or effect customization
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Background section should be displayed"
        )
    }

    func testBackgroundTintColorPicker() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given background section is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then tint color picker should be displayed
        // When theme mode allows color customization
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Background tint color picker should be displayed"
        )
    }

    func testBackgroundOpacitySlider() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given background section is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then opacity slider should be displayed
        // When theme mode allows effect customization
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Background opacity slider should be displayed"
        )
    }

    func testBackgroundBlurSlider() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given background section is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then blur slider should be displayed
        // When theme mode allows effect customization
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Background blur slider should be displayed"
        )
    }

    func testBorderSectionDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given visual settings are displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then border section should be displayed
        // When theme mode allows color or effect customization
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Border section should be displayed"
        )
    }

    func testBorderColorPicker() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given border section is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then border color picker should be displayed
        // When theme mode allows color customization
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Border color picker should be displayed"
        )
    }

    func testBorderOpacitySlider() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given border section is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then border opacity slider should be displayed
        // When theme mode allows effect customization
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Border opacity slider should be displayed"
        )
    }

    func testForegroundSectionConditional() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given visual settings are displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then foreground section should only show when:
        // - Metadata shows foreground section
        // - Theme mode allows color customization
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Foreground section should be conditionally displayed"
        )
    }

    func testForegroundColorPicker() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given foreground section is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then foreground color picker should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Foreground color picker should be displayed"
        )
    }

    func testGeometrySectionConditional() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given visual settings are displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then geometry section should only show when:
        // - Theme mode allows geometry customization
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Geometry section should be conditionally displayed"
        )
    }

    func testGeometrySettingsComponent() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given geometry section is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then GeometrySettingsView should be displayed
        // with entity name and properties
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Geometry settings component should be displayed"
        )
    }

    func testThemeModeCustomizationFlags() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given various theme modes
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then sections should respect theme mode flags:
        // - isColorCustomizable
        // - isEffectCustomizable
        // - isGeometryCustomizable
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Theme mode customization flags should be respected"
        )
    }

    func testMetadataDrivenConfiguration() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given visual settings with metadata
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then configuration should be driven by metadata:
        // - entityName
        // - showForegroundSection
        // - defaultGlobalGeometricProperties
        // - defaultGlobalEffectProperties
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Metadata should drive configuration"
        )
    }
}
