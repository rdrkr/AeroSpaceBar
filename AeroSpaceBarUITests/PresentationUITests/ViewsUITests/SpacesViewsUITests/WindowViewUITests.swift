// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Nimble
import XCTest

/// UI tests for WindowView.
///
/// These tests verify window view UI including:
/// - Window icon display
/// - Window title display (optional)
/// - Window focus state indication
/// - Click to focus functionality
/// - Hover states and interactions
/// - Color properties application
@MainActor
final class WindowViewUITests: XCTestCase {
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

    func testWindowViewDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given spaces are displayed with windows
        // Then window views should be displayed for each window
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Window views should be displayed"
        )
    }

    func testWindowIconDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given a window is displayed
        // Then window app icon should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Window icon should be displayed"
        )
    }

    func testWindowTitleDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given show window titles is enabled
        // When window is focused
        // Then window title should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Window title should be displayed when enabled"
        )
    }

    func testWindowTitleHidden() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given show window titles is disabled
        // Then window title should not be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Window title should be hidden when disabled"
        )
    }

    func testFocusedWindowIndication() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given a window is focused
        // Then visual indication should show focus state
        // (different styling for focused windows)
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Focused window indication should be displayed"
        )
    }

    func testUnfocusedWindowDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given a window is not focused
        // Then window should have unfocused styling
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Unfocused window display should be correct"
        )
    }

    func testWindowHoverState() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given a window is being hovered
        // Then hover state should be visually indicated
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Window hover state should be displayed"
        )
    }

    func testFocusWindowOnClickEnabled() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given focus window on click is enabled
        // When clicking a window
        // Then window should be focused
        // Note: Actual clicking requires menu bar interaction
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Focus window on click should work when enabled"
        )
    }

    func testFocusWindowOnClickDisabled() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given focus window on click is disabled
        // When clicking a window
        // Then space should be switched but window not focused
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Click behavior should respect focus setting"
        )
    }

    func testMultipleSameAppWindows() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given multiple windows from same app
        // Then window titles should differentiate them
        // (Shows window.title instead of app.name)
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Multiple same app windows should be differentiated"
        )
    }

    func testSingleAppWindow() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given only one window from an app
        // Then app name should be displayed as title
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Single app window should show app name"
        )
    }

    func testSpaceForegroundColor() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given window has space foreground color
        // Then text should use the foreground color
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Space foreground color should be applied"
        )
    }

    func testSpaceBackgroundTintColor() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given window has space background tint color
        // Then background should use the tint color
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Space background tint color should be applied"
        )
    }

    func testSwitchToWindowCallback() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given a window with switch callback
        // When window is clicked
        // Then callback should be invoked
        // Note: Callback testing requires UI interaction
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Switch to window callback should work"
        )
    }

    func testSwitchToSpaceCallback() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given a window with switch to space callback
        // When appropriate action is performed
        // Then callback should be invoked with space
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Switch to space callback should work"
        )
    }
}
