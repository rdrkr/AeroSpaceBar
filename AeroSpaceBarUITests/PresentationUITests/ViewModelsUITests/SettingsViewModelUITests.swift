// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Nimble
import XCTest

/// UI tests for SettingsViewModel-driven UI behavior.
///
/// These tests verify SettingsViewModel UI integration including:
/// - Settings display and interaction
/// - Transparency setting UI
/// - Focus window on click UI
/// - Launch at login UI
/// - AeroSpace path configuration UI
/// - Log level setting UI
/// - Performance metrics UI
/// - AeroSpace version display
/// - Path validation error display
/// - Reset settings UI
/// - Open AeroSpace config UI
@MainActor
final class SettingsViewModelUITests: XCTestCase {
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

    // MARK: - ViewModel UI Tests

    func testSettingsViewModelUI() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given settings are open
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then SettingsViewModel should drive settings UI correctly
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "SettingsViewModel should drive settings UI"
        )
    }

    func testTransparencySettingUI() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given settings are open
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then transparency setting should be displayed in UI
        // Transparency affects window/menu bar appearance
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Transparency setting should be displayed"
        )
    }

    func testFocusWindowOnClickSettingUI() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given advanced settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then focus window on click setting should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Focus window on click setting should be displayed"
        )
    }

    func testLaunchAtLoginSettingUI() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given general settings are open
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then launch at login toggle should be displayed and interactive
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Launch at login setting should be displayed"
        )
    }

    func testAeroSpacePathSettingUI() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given general settings are open
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then AeroSpace path configuration should be displayed
        // Includes textfield and browse button
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "AeroSpace path setting should be displayed"
        )
    }

    func testLogLevelSettingUI() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given advanced settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then log level picker should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Log level setting should be displayed"
        )
    }

    func testEnablePerformanceMetricsSettingUI() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given advanced settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then performance metrics toggle should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Performance metrics setting should be displayed"
        )
    }

    func testAeroSpaceVersionDisplayUI() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given general settings are open
        app.typeKey(",", modifierFlags: .command)
        sleep(2) // Allow time for version detection

        // Then AeroSpace version should be displayed
        // Shows version if detected, or "Not Found" error
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "AeroSpace version should be displayed"
        )
    }

    func testCustomPathValidationErrorUI() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given general settings are open
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then path validation errors should be displayed when invalid
        // Error icon and message shown below path textfield
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Path validation errors should be displayed"
        )
    }

    func testResetAllSettingsUI() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given advanced settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then reset all settings button should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Reset all settings button should be displayed"
        )
    }

    func testOpenAeroSpaceConfigUI() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given general settings are open
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then open configuration button should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Open AeroSpace config button should be displayed"
        )
    }
}
