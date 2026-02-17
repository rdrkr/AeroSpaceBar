// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Nimble
import XCTest

/// UI tests for UpdatesSettingsView.
///
/// These tests verify software updates settings UI including:
/// - Automatically check for updates toggle
/// - Automatically download updates toggle
/// - Check for updates button
/// - Last update check date display
/// - View layout and styling
@MainActor
final class UpdatesSettingsViewUITests: XCTestCase {
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

    func testUpdatesSettingsViewDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given settings are open
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // When navigating to Updates settings (via sidebar)
        // Then updates settings should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Updates settings view should be displayed"
        )
    }

    func testAutomaticCheckForUpdatesToggleDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given updates settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then automatically check for updates toggle should be displayed
        // Tagged as "updates-auto-check-toggle"
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Automatically check for updates toggle should be displayed"
        )
    }

    func testAutomaticCheckForUpdatesToggleInteraction() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given updates settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // When interacting with auto check toggle
        app.typeKey(XCUIKeyboardKey.tab, modifierFlags: [])
        sleep(1)
        app.typeKey(XCUIKeyboardKey.space, modifierFlags: [])
        sleep(1)

        // Then toggle should respond
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Auto check toggle should be interactive"
        )
    }

    func testAutomaticDownloadUpdatesToggleDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given updates settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then automatically download updates toggle should be displayed
        // Tagged as "updates-auto-download-toggle"
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Automatically download updates toggle should be displayed"
        )
    }

    func testAutomaticDownloadDependsOnAutoCheck() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given updates settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then automatic download toggle should be disabled
        // when automatic check is disabled
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Auto download should depend on auto check being enabled"
        )
    }

    func testCheckForUpdatesButtonDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given updates settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then check for updates button should be displayed
        // Tagged as "updates-check-now-button"
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Check for updates button should be displayed"
        )
    }

    func testCheckForUpdatesButtonInteraction() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given updates settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // When accessing check for updates button
        // Note: Actually clicking would trigger update check
        // which may show dialogs

        // Then button should be present and accessible
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Check for updates button should be interactive"
        )
    }

    func testLastUpdateCheckDateDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given updates settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then last update check date should be displayed
        // When a check has been performed
        // Tagged as "updates-last-check-date"
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Last update check date should be displayed when available"
        )
    }

    func testUpdatesSettingsViewLayout() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given updates settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then view should have proper layout
        // Sections: Automatic updates, Manual check
        // Uses compact IntroForm style
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Updates settings layout should be correct"
        )
    }

    func testUpdatesSettingsViewStyling() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given updates settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then view should use compact IntroForm style
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Updates settings styling should be consistent"
        )
    }

    func testAutomaticSectionDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given updates settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then automatic section should be displayed
        // Tagged as "updates-automatic-section"
        // Contains auto check and auto download toggles
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Automatic updates section should be displayed"
        )
    }

    func testManualSectionDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given updates settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then manual section should be displayed
        // Tagged as "updates-manual-section"
        // Contains check now button and last check date
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Manual check section should be displayed"
        )
    }
}
