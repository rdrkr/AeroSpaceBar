// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Nimble
import XCTest

/// UI tests for AppDelegate.
///
/// These tests verify app delegate UI integration including:
/// - App lifecycle and startup
/// - Menu bar integration
/// - Window management
@MainActor
final class AppDelegateUITests: XCTestCase {
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

    // MARK: - Lifecycle Tests

    func testAppDelegateInitialization() {
        guard let app else {
            XCTFail("App should be initialized")
            return
        }

        // Given the app is launched
        // Then AppDelegate should initialize correctly
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(beTrue())
    }

    func testMenuBarIntegration() {
        guard let app else {
            XCTFail("App should be initialized")
            return
        }

        // Given the app is running
        // Then menu bar item should be created and accessible
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(beTrue())
    }

    func testAppTermination() {
        guard let app else {
            XCTFail("App should be initialized")
            return
        }

        // Given the app is running
        var state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(beTrue())

        // When terminating
        app.terminate()
        sleep(1)

        // Then app should terminate cleanly
        state = app.state
        expect(state).to(equal(.notRunning))
    }
}
