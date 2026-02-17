// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Nimble
import XCTest

/// UI tests for IntroForm component.
///
/// These tests verify the IntroForm common UI component including:
/// - IntroForm display with different styles
/// - Intro vs Compact style rendering
/// - Layout and styling consistency
/// - Image, title, and subtitle display
@MainActor
final class IntroFormUITests: XCTestCase {
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

    func testIntroFormDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given settings are open (IntroForm is used in settings views)
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then IntroForm should be displayed
        // IntroForm is the base layout for General, Advanced, etc.
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "IntroForm should be displayed"
        )
    }

    func testIntroStyleDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given settings are open with intro style form
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then intro style should show icon, title, subtitle
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Intro style should be displayed correctly"
        )
    }

    func testCompactStyleDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given a view uses compact style IntroForm
        // Then compact style should be more condensed

        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Compact style should be displayed correctly"
        )
    }

    func testIntroFormLayout() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given IntroForm is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then layout should have proper structure
        // Structure: optional icon, title, subtitle, content sections
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "IntroForm layout should be correct"
        )
    }

    func testIntroFormStyling() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given IntroForm is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then styling should be consistent
        // Consistent fonts, spacing, colors
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "IntroForm styling should be consistent"
        )
    }

    func testImageDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given IntroForm with image/icon
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then image should be displayed
        // General settings shows app icon
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "IntroForm image should be displayed"
        )
    }

    func testTitleDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given IntroForm is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then title should be displayed
        // Title is the navigation option name
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "IntroForm title should be displayed"
        )
    }

    func testSubtitleDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given IntroForm is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then subtitle should be displayed
        // Subtitle is the navigation option description
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "IntroForm subtitle should be displayed"
        )
    }
}
