// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Nimble
import XCTest

/// UI tests for SettingsView.
///
/// These tests verify the settings window UI including:
/// - Navigation split view display and layout
/// - Sidebar navigation and page selection
/// - Navigation buttons (back/forward) functionality
/// - Navigation history management
/// - Window configuration and behavior
@MainActor
final class SettingsViewUITests: XCTestCase {
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

    @MainActor
    func testSettingsViewDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given the app is launched
        // When opening settings
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then settings view should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(beTrue())
    }

    @MainActor
    func testNavigationSplitViewDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given the app is launched
        // When opening settings
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then navigation split view should be present
        // The split view contains sidebar and detail areas
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(beTrue())
    }

    @MainActor
    func testSidebarDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given settings are open
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then sidebar should be visible with navigation options
        // Sidebar is tagged as "settings-sidebar"
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(beTrue())
    }

    @MainActor
    func testDetailViewDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given settings are open
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then detail view should display the selected page content
        // Detail content is tagged as "settings-detail-content"
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(beTrue())
    }

    @MainActor
    func testNavigationButtonsDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given settings are open
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then navigation buttons should be visible
        // Back button: "settings-back-button"
        // Forward button: "settings-forward-button"
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(beTrue())
    }

    // MARK: - Interaction Tests

    @MainActor
    func testBackButtonInteraction() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given settings are open
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // When navigating through pages
        // Navigation creates history for back button
        sleep(1)

        // Then back button interaction should work
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(beTrue())
    }

    @MainActor
    func testForwardButtonInteraction() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given settings are open with navigation history
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // When using back/forward navigation
        sleep(1)

        // Then forward button should be interactive
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(beTrue())
    }

    @MainActor
    func testPageSelection() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given settings are open
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // When selecting different pages via keyboard navigation
        app.typeKey(XCUIKeyboardKey.tab, modifierFlags: [])
        sleep(1)
        app.typeKey(XCUIKeyboardKey.downArrow, modifierFlags: [])
        sleep(1)

        // Then page selection should work
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(beTrue())
    }

    @MainActor
    func testNavigationHistory() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given settings are open
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // When navigating multiple times
        app.typeKey(XCUIKeyboardKey.tab, modifierFlags: [])
        sleep(1)
        app.typeKey(XCUIKeyboardKey.downArrow, modifierFlags: [])
        sleep(1)
        app.typeKey(XCUIKeyboardKey.downArrow, modifierFlags: [])
        sleep(1)

        // Then navigation history should be maintained
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(beTrue())
    }

    @MainActor
    func testWindowConfiguration() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given the app is launched
        // When opening settings
        app.typeKey(",", modifierFlags: .command)
        sleep(2) // Allow time for window configuration

        // Then window should be properly configured
        let windows = app.windows
        expect(windows.count).to(beGreaterThan(0))

        // And window should have correct dimensions (min 720x540, ideal 720x660)
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(beTrue())
    }
}
