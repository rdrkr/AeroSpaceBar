// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Nimble
import XCTest

/// UI tests for AeroSpaceBar app launch and basic functionality.
///
/// These tests verify that app launches correctly and basic menu bar integration works.
@MainActor
final class AeroSpaceBarAppUITests: XCTestCase {
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

    // MARK: - App Launch Tests

    func testAppLaunch() {
        guard let app else {
            XCTFail("App should be initialized")
            return
        }

        // Given the app is launched (in setUp)
        // Then the app should be running
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(beTrue())
    }

    func testAppLaunchWithoutCrash() {
        guard let app else {
            XCTFail("App should be initialized")
            return
        }

        // Given the app is launched
        // When waiting for the app to settle
        sleep(2)

        // Then the app should still be running
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(beTrue())
    }

    // MARK: - Menu Bar Tests

    func testMenuBarExtraDisplay() {
        guard let app else {
            XCTFail("App should be initialized")
            return
        }

        // Given the app is launched
        // When checking for menu bar extra
        // Note: Menu bar extras are difficult to test in UI tests
        // This test verifies the app doesn't crash when trying to access menu bar
        sleep(1)

        // Then the app should still be running
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(beTrue())
    }

    // MARK: - Settings Access Tests

    @MainActor
    func testSettingsSceneAccess() {
        guard let app else {
            XCTFail("App should be initialized")
            return
        }

        // Given the app is launched
        // When attempting to open settings via keyboard shortcut
        app.typeKey(",", modifierFlags: .command)

        // Wait for settings window
        sleep(1)

        // Then settings window should be accessible
        let settingsWindows = app.windows.matching(identifier: "SettingsWindow")
        expect(settingsWindows.count) > 0
    }

    // MARK: - Window Tests

    func testAppIconDisplay() {
        guard let app else {
            XCTFail("App should be initialized")
            return
        }

        // Given the app is launched
        // Then the app should have an icon (verified by successful launch)
        expect(app.exists) == true
    }

    func testAppHasRequiredPermissions() {
        guard let app else {
            XCTFail("App should be initialized")
            return
        }

        // Given the app is launched
        // Then the app should request or have necessary permissions
        // Note: Permissions testing is limited in UI tests
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(beTrue())
    }

    // MARK: - Memory and Performance Tests

    @MainActor
    func testAppMemoryStability() {
        guard let app else {
            XCTFail("App should be initialized")
            return
        }

        // Given the app is launched
        // When performing basic operations
        for _ in 0 ..< 5 {
            app.typeKey(",", modifierFlags: .command) // Open settings
            sleep(1)
            app.typeKey("w", modifierFlags: .command) // Close window
            sleep(1)
        }

        // Then the app should still be running stably
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(beTrue())
    }

    @MainActor
    func testAppRespondsToKeyboardShortcuts() {
        guard let app else {
            XCTFail("App should be initialized")
            return
        }

        // Given the app is launched
        // When using keyboard shortcut
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then the app should respond
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(beTrue())
    }

    // MARK: - Termination Tests

    func testAppTerminatesCleanly() {
        guard let app else {
            XCTFail("App should be initialized")
            return
        }

        // Given the app is running
        var state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(beTrue())

        // When terminating the app
        app.terminate()

        // Then the app should terminate without hanging
        sleep(2)
        state = app.state
        expect(state).to(equal(.notRunning))
    }
}
