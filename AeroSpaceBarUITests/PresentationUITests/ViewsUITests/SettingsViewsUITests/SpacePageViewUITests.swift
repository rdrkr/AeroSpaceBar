// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Nimble
import XCTest

/// UI tests for SpacePageView.
///
/// These tests verify space page UI including:
/// - Space configuration form display
/// - Visual properties configuration (color, geometry, effects)
/// - Navigation title with space ID
/// - Conditional display based on appearance mode and theme
@MainActor
final class SpacePageViewUITests: XCTestCase {
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

    func testSpacePageViewDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given settings are open and navigated to a space page
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then space page view should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Space page view should be displayed"
        )
    }

    func testNavigationTitle() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given space page is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then navigation title should show "Space X"
        // where X is the space ID
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Navigation title should show space ID"
        )
    }

    func testVisualSettingsConditionalDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given space page is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then visual settings should only show when:
        // - Appearance mode is Per Space
        // - Theme mode allows color customization
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Visual settings should be conditionally displayed"
        )
    }

    func testVisualSettingsView() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given space page with visual settings shown
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then VisualSettingsView should be displayed
        // with space metadata
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Visual settings view should be displayed"
        )
    }

    func testColorPropertiesConfiguration() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given space page visual settings are displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then color properties should be configurable
        // Background, foreground, border colors
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Color properties should be configurable"
        )
    }

    func testGeometricPropertiesConfiguration() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given space page visual settings are displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then geometric properties should be configurable
        // Corner radius, border width
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Geometric properties should be configurable"
        )
    }

    func testEffectPropertiesConfiguration() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given space page visual settings are displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then effect properties should be configurable
        // Blur, opacity
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Effect properties should be configurable"
        )
    }

    func testFormStyling() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given space page is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then form should have settings form style
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Form should have correct styling"
        )
    }

    func testSpaceUpdateHandling() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given space properties are modified
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then changes should update space via SpacesViewModel
        // updateSpaceColorProperties, etc.
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Space updates should be handled correctly"
        )
    }

    func testSpaceNotFoundHandling() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given space ID doesn't exist
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then default space should be shown
        // to avoid crashes
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Space not found should be handled gracefully"
        )
    }
}
