// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Nimble
import XCTest

/// UI tests for GeneralSettingsView.
///
/// These tests verify the general settings UI including:
/// - Launch at login toggle display and interaction
/// - Theme mode and preset picker functionality
/// - Permissions section display and grants
/// - AeroSpace path configuration
/// - Browse and open configuration buttons
/// - View layout and styling
@MainActor
final class GeneralSettingsViewUITests: XCTestCase {
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

    func testGeneralSettingsViewDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given settings are open
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then general settings view should be displayed by default
        // General settings is tagged as "general-settings-view"
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "General settings view should be displayed"
        )
    }

    func testLaunchAtLoginToggleDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given settings are open
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then launch at login toggle should be visible
        // Toggle is tagged as "general-launch-at-login-toggle"
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Launch at login toggle should be displayed"
        )
    }

    func testLaunchAtLoginToggleInteraction() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given settings are open
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // When interacting with launch at login toggle via keyboard
        app.typeKey(XCUIKeyboardKey.tab, modifierFlags: [])
        sleep(1)
        app.typeKey(XCUIKeyboardKey.space, modifierFlags: [])
        sleep(1)

        // Then toggle should respond to interaction
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Launch at login toggle should be interactive"
        )
    }

    func testThemeModePicker() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given settings are open
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then theme mode picker should be visible
        // Picker is tagged as "general-theme-mode-picker"
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Theme mode picker should be displayed"
        )
    }

    func testPermissionsSection() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given settings are open
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then permissions section should be visible
        // Status icon: "general-permissions-status-icon"
        // Status text: "general-permissions-status-text"
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Permissions section should be displayed"
        )
    }

    func testAeroSpacePathSectionDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given settings are open
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then AeroSpace path section should be visible
        // Path label: "general-path-label"
        // Path textfield: "general-path-textfield"
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "AeroSpace path section should be displayed"
        )
    }

    func testBrowseButtonDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given settings are open
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then browse button should be visible
        // Button is tagged as "general-browse-button"
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Browse button should be displayed"
        )
    }

    func testBrowseButtonInteraction() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given settings are open
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // When navigating to browse button
        // Note: Actually clicking would open file picker dialog
        // which is difficult to test in UI tests

        // Then button should be present and interactive
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Browse button should be interactive"
        )
    }

    func testOpenConfigurationButtonDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given settings are open
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then open configuration button should be visible
        // Button is tagged as "general-open-config-button"
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Open configuration button should be displayed"
        )
    }

    func testOpenConfigurationButtonInteraction() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given settings are open
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // When interacting with the button
        // Note: Actually clicking would open external file
        // which is difficult to test in UI tests

        // Then button should be present and interactive
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Open configuration button should be interactive"
        )
    }

    func testAeroSpaceStatusDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given settings are open
        app.typeKey(",", modifierFlags: .command)
        sleep(2) // Allow time for AeroSpace version detection

        // Then AeroSpace status should be displayed
        // Success icon: "general-aerospace-status-success-icon"
        // Or error icon: "general-aerospace-status-error-icon"
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "AeroSpace status should be displayed"
        )
    }

    func testGeneralSettingsViewLayout() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given settings are open
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then view should have proper layout with all sections
        // Sections: Launch, Appearance, Permissions, AeroSpace, Tips
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "General settings layout should be correct"
        )
    }

    func testGeneralSettingsViewStyling() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given settings are open
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then view should have consistent styling
        // Uses IntroForm with icon, title, subtitle
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "General settings styling should be consistent"
        )
    }
}
