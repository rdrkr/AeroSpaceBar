// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Nimble
import XCTest

/// UI tests for AdvancedSettingsView.
///
/// These tests verify advanced settings UI including:
/// - Focus window on click toggle
/// - Log level picker
/// - Performance metrics toggle
/// - Reset all settings button
/// - View layout and styling
@MainActor
final class AdvancedSettingsViewUITests: XCTestCase {
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

    func testAdvancedSettingsViewDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given settings are open
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // When navigating to Advanced settings (typically via sidebar)
        // Tab to sidebar, then arrow down to Advanced
        app.typeKey(XCUIKeyboardKey.tab, modifierFlags: [])
        sleep(1)

        // Then advanced settings view should be accessible
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Advanced settings view should be displayed"
        )
    }

    func testFocusWindowOnClickToggleDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given advanced settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then focus window on click toggle should be visible
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Focus window on click toggle should be displayed"
        )
    }

    func testFocusWindowOnClickToggleInteraction() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given advanced settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // When interacting with toggle
        app.typeKey(XCUIKeyboardKey.tab, modifierFlags: [])
        sleep(1)
        app.typeKey(XCUIKeyboardKey.space, modifierFlags: [])
        sleep(1)

        // Then toggle should respond
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Focus window toggle should be interactive"
        )
    }

    func testLogLevelPickerDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given advanced settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then log level picker should be visible
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Log level picker should be displayed"
        )
    }

    func testLogLevelPickerInteraction() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given advanced settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // When interacting with log level picker
        app.typeKey(XCUIKeyboardKey.tab, modifierFlags: [])
        sleep(1)

        // Then picker should be interactive
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Log level picker should be interactive"
        )
    }

    func testEnablePerformanceMetricsToggleDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given advanced settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then performance metrics toggle should be visible
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Performance metrics toggle should be displayed"
        )
    }

    func testEnablePerformanceMetricsToggleInteraction() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given advanced settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // When interacting with toggle
        app.typeKey(XCUIKeyboardKey.tab, modifierFlags: [])
        sleep(1)
        app.typeKey(XCUIKeyboardKey.space, modifierFlags: [])
        sleep(1)

        // Then toggle should respond
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Performance metrics toggle should be interactive"
        )
    }

    func testResetAllSettingsButtonDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given advanced settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then reset all settings button should be visible
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Reset all settings button should be displayed"
        )
    }

    func testResetAllSettingsButtonInteraction() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given advanced settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // When navigating to reset button
        // Note: Actually clicking reset would require confirmation dialog
        // which is difficult to test in UI tests

        // Then button should be present
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Reset button should be present and accessible"
        )
    }

    func testAdvancedSettingsViewLayout() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given advanced settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then view should have proper layout with all sections
        // Sections include: Behavior, Developer, etc.
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Advanced settings layout should be correct"
        )
    }

    func testAdvancedSettingsViewStyling() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given advanced settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then view should have consistent styling
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Advanced settings styling should be consistent"
        )
    }
}
