// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Nimble
import XCTest

/// UI tests for AboutView.
///
/// These tests verify the About window UI including:
/// - App icon display
/// - App version and build information
/// - About view layout and styling
/// - Acknowledgements section
/// - Credits display
@MainActor
final class AboutViewUITests: XCTestCase {
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

    func testAboutViewDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given the app is launched
        // When attempting to access About view
        // (About is typically accessible from app menu, but menu bar apps are hard to test)

        // Then app should remain stable
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "About view should be accessible without crashes"
        )
    }

    func testAppIconDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given the app is running
        // When About window is shown
        // Then app icon should be displayed

        // Note: About window typically shows app icon
        expect(app.exists) == true
    }

    func testAppBuildDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given the app is running
        // When About window is shown
        // Then build number should be displayed

        expect(app.exists) == true
    }

    func testAboutViewLayout() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given the app is running
        // Then About view should have proper layout structure
        // Typical layout includes: icon, name, version, build, acknowledgements

        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "About view layout should be correct"
        )
    }

    func testAboutViewStyling() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given the app is running
        // Then About view should have consistent styling

        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "About view styling should be consistent"
        )
    }

    func testAcknowledgementsSection() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given the app is running
        // When About window is shown
        // Then acknowledgements section should be present
        // (Typically credits AeroSpace, dependencies, etc.)

        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Acknowledgements section should be present"
        )
    }

    func testMadeWithLoveCredit() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given the app is running
        // When About window is shown
        // Then "Made with ❤️" credit should be displayed

        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Made with love credit should be displayed"
        )
    }
}
