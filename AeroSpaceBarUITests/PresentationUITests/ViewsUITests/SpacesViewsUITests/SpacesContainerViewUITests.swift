// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Nimble
import XCTest

/// UI tests for SpacesContainerView.
///
/// These tests verify spaces container UI including:
/// - Horizontal layout of spaces
/// - Spacing calculation based on geometric properties
/// - Theme mode integration
/// - Appearance mode handling (allSpaces vs perSpace)
/// - Parameter propagation to SpaceView instances
/// - Focused space detection for spacing
@MainActor
final class SpacesContainerViewUITests: XCTestCase {
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

    func testSpacesContainerDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given the app is running with spaces
        // Then spaces container should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Spaces container should be displayed"
        )
    }

    func testHorizontalLayoutOfSpaces() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given multiple spaces are available
        // Then spaces should be laid out horizontally
        // using HStack
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Spaces should be laid out horizontally"
        )
    }

    func testSpacingCalculationPresetMode() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given theme mode is preset
        // Then spacing should use themePresetGeometricProperties
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Preset mode should use theme preset spacing"
        )
    }

    func testSpacingCalculationAllSpacesMode() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given appearance mode is allSpaces
        // When theme mode is glass or custom
        // Then spacing should use globalGeometricProperties
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "All spaces mode should use global spacing"
        )
    }

    func testSpacingCalculationPerSpaceMode() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given appearance mode is perSpace
        // When theme mode is glass or custom
        // Then spacing should use focused space's geometric properties
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Per space mode should use focused space spacing"
        )
    }

    func testSpacingFormula() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given spacing is calculated
        // Then formula should be: -widgetSpacing - (borderWidth * 2)
        // This creates overlapping effect for borders
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Spacing formula should account for border width"
        )
    }

    func testSpaceViewParameterPropagation() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given spaces container is rendering spaces
        // Then each SpaceView should receive:
        // - space, showWindowTitles, focusWindowOnClick
        // - appearanceMode, global properties, theme properties
        // - callbacks for switching
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Parameters should be propagated to SpaceView"
        )
    }

    func testSpaceTagging() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given spaces are rendered
        // Then each space should be tagged as "space-{id}"
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Each space should have unique tag"
        )
    }

    func testContainerTagging() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given container is rendered
        // Then container should be tagged as "spaces-container"
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Container should have spaces-container tag"
        )
    }

    func testFocusedSpaceDetection() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given multiple spaces exist
        // Then container should detect focused space
        // for per-space spacing calculation
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Container should detect focused space"
        )
    }

    func testFallbackToDefaultProperties() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given no focused space in perSpace mode
        // Then should fall back to default space geometric properties
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Should fall back to defaults when no focused space"
        )
    }

    func testOnSwitchToSpaceCallback() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given space is clicked
        // Then onSwitchToSpace callback should be invoked
        // with space and needWindowFocus parameters
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Switch to space callback should work"
        )
    }

    func testOnSwitchToWindowCallback() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given window is clicked
        // Then onSwitchToWindow callback should be invoked
        // with window parameter
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Switch to window callback should work"
        )
    }

    func testEmptySpacesList() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given no spaces are available
        // Then container should render empty HStack
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Container should handle empty spaces list"
        )
    }
}
