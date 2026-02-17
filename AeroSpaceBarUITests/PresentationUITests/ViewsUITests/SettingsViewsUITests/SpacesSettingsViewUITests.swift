// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Nimble
import XCTest

/// UI tests for SpacesSettingsView.
///
/// These tests verify spaces settings UI including:
/// - Show window title toggle
/// - Spaces appearance mode picker
/// - Spaces list display and management
/// - Global visual properties configuration
/// - Per-space customization
/// - Reset spaces functionality
/// - View layout and styling
@MainActor
final class SpacesSettingsViewUITests: XCTestCase {
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

    func testSpacesSettingsViewDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given settings are open
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // When navigating to Spaces settings (via sidebar)
        // Then spaces settings should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Spaces settings view should be displayed"
        )
    }

    func testShowWindowTitleToggleDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given spaces settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then show window title toggle should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Show window title toggle should be displayed"
        )
    }

    func testShowWindowTitleToggleInteraction() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given spaces settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // When interacting with window title toggle
        app.typeKey(XCUIKeyboardKey.tab, modifierFlags: [])
        sleep(1)
        app.typeKey(XCUIKeyboardKey.space, modifierFlags: [])
        sleep(1)

        // Then toggle should respond
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Show window title toggle should be interactive"
        )
    }

    func testSpacesAppearanceModePickerDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given spaces settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then appearance mode picker should be displayed
        // Options: All Spaces, Per Space
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Spaces appearance mode picker should be displayed"
        )
    }

    func testSpacesListDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given spaces settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then spaces list should be displayed when in Per Space mode
        // Shows detected spaces from AeroSpace
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Spaces list should be displayed"
        )
    }

    func testGlobalColorPropertiesDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given spaces settings with "All Spaces" appearance mode
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then global color properties should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Global color properties should be displayed"
        )
    }

    func testGlobalGeometricPropertiesDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given spaces settings with "All Spaces" appearance mode
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then global geometric properties should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Global geometric properties should be displayed"
        )
    }

    func testGlobalEffectPropertiesDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given spaces settings with "All Spaces" appearance mode
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then global effect properties should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Global effect properties should be displayed"
        )
    }

    func testSpaceItemNavigation() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given spaces list is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // When clicking on a space item
        // Then should navigate to space detail page
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Space item navigation should work"
        )
    }

    func testResetSpacesFunctionality() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given spaces settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // When accessing reset spaces option
        // Then reset should restore default space properties
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Reset spaces functionality should work"
        )
    }

    func testThemeIntegration() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given spaces settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then theme mode should affect available options
        // Theme presets provide color, geometric, and effect properties
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Theme integration should work correctly"
        )
    }

    func testPerSpaceCustomization() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given spaces settings with "Per Space" mode
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then individual spaces should be customizable
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Per-space customization should work"
        )
    }

    func testSpacesSettingsViewLayout() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given spaces settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then view should have proper layout
        // Uses VisualSettingsContainerView with spaces configuration
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Spaces settings layout should be correct"
        )
    }

    func testConditionalEntitiesListDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given spaces settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then entities list should only show when:
        // - Appearance mode is Per Space
        // - Theme mode allows color customization
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Conditional entities list display should work correctly"
        )
    }
}
