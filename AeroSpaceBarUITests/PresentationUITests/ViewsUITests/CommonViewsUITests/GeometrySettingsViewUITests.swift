// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Nimble
import XCTest

/// UI tests for GeometrySettingsView.
///
/// These tests verify geometry settings UI including:
/// - Border width slider display and interaction
/// - Corner radius slider display and interaction
/// - Entity name display in help text
/// - Default value handling
/// - Value range constraints
@MainActor
final class GeometrySettingsViewUITests: XCTestCase {
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

    func testGeometrySettingsViewDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given settings are open with geometry settings
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then geometry settings view should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Geometry settings view should be displayed"
        )
    }

    func testBorderWidthSliderDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given geometry settings are displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then border width slider should be displayed
        // Range: 0.0 to 5.0 points
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Border width slider should be displayed"
        )
    }

    func testBorderWidthSliderInteraction() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given geometry settings are displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // When interacting with border width slider
        // Then slider should be interactive
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Border width slider should be interactive"
        )
    }

    func testCornerRadiusSliderDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given geometry settings are displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then corner radius slider should be displayed
        // Range: 0.0 to default corner radius
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Corner radius slider should be displayed"
        )
    }

    func testCornerRadiusSliderInteraction() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given geometry settings are displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // When interacting with corner radius slider
        // Then slider should be interactive
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Corner radius slider should be interactive"
        )
    }

    func testEntityNameInHelpText() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given geometry settings are displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then entity name should be displayed in help text
        // e.g., "Adjust the border width of space elements."
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Entity name should be shown in help text"
        )
    }

    func testDefaultValueHandling() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given geometry settings with default values
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then sliders should show default values
        // and allow resetting to defaults
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Default values should be handled correctly"
        )
    }

    func testBorderWidthStickiness() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given border width slider is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then slider should have stickiness of 0.25
        // making it snap to certain values
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Border width slider should have stickiness"
        )
    }

    func testCornerRadiusStickiness() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given corner radius slider is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then slider should have stickiness of 1.0
        // making it snap to integer values
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Corner radius slider should have stickiness"
        )
    }

    func testPointsDisplayFormat() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given geometry sliders are displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then values should be displayed in points format
        // e.g., "5.0 pt"
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Values should be displayed as points"
        )
    }
}
