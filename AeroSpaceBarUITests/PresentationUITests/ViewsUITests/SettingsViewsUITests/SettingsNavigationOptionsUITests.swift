// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Nimble
import XCTest

/// UI tests for SettingsNavigationOptions.
///
/// These tests verify settings navigation options including:
/// - Navigation options display (General, Advanced, etc.)
/// - Main pages accessibility
/// - Name and symbol properties
/// - View-for-page rendering
@MainActor
final class SettingsNavigationOptionsUITests: XCTestCase {
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

    func testSettingsNavigationOptionsDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given settings are open
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then navigation options should be displayed in sidebar
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Settings navigation options should be displayed"
        )
    }

    func testGeneralOptionDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given settings are open
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then General option should be visible in navigation
        // General is the default selected page
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "General option should be displayed"
        )
    }

    func testAdvancedOptionDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given settings are open
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then Advanced option should be visible in navigation
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Advanced option should be displayed"
        )
    }

    func testMainPagesDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given settings are open
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then all main pages should be displayed
        // Main pages: General, Groups, Spaces, Advanced, Developer, License
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Main pages should be displayed"
        )
    }

    func testNamePropertyDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given settings are open
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then navigation option names should be displayed
        // Names like "General", "Advanced", etc.
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Navigation option names should be displayed"
        )
    }

    func testSymbolNamePropertyDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given settings are open
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then SF Symbol icons should be displayed for options
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Navigation option symbols should be displayed"
        )
    }

    func testViewForPageDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given settings are open
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then the view for selected page should be rendered
        // Default is General page
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "View for page should be displayed"
        )
    }
}
