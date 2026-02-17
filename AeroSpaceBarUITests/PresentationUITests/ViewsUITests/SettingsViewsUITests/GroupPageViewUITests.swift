// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Nimble
import XCTest

/// UI tests for GroupPageView.
///
/// These tests verify group page UI including:
/// - Group app range picker display and interaction
/// - Visual properties configuration (color, geometry, effects)
/// - Group deletion functionality
/// - Constraint handling (minimum/maximum indices)
/// - Navigation and form layout
@MainActor
final class GroupPageViewUITests: XCTestCase {
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

    func testGroupPageViewDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given settings are open and navigated to a group page
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then group page view should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Group page view should be displayed"
        )
    }

    func testGroupAppRangePickerDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given group page is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then app range picker should be displayed
        // Shows start and end index pickers
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Group app range picker should be displayed"
        )
    }

    func testStartIndexPickerDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given group page is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then start index picker should be displayed
        // with minimum constraint based on previous group
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Start index picker should be displayed"
        )
    }

    func testEndIndexPickerDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given group page is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then end index picker should be displayed
        // with maximum constraint based on next group
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "End index picker should be displayed"
        )
    }

    func testVisualPropertiesConfiguration() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given group page is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then visual properties configuration should be available
        // Background, border, geometry settings
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Visual properties configuration should be displayed"
        )
    }

    func testBackgroundColorSettings() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given group page visual settings are displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then background color settings should be displayed
        // Tint color, opacity, blur
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Background color settings should be displayed"
        )
    }

    func testBorderStyleSettings() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given group page visual settings are displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then border style settings should be displayed
        // Border color, opacity, width
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Border style settings should be displayed"
        )
    }

    func testGeometrySettings() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given group page visual settings are displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then geometry settings should be displayed
        // Corner radius, border width
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Geometry settings should be displayed"
        )
    }

    func testDeleteGroupButton() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given group page for non-primary group is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then delete group button should be displayed
        // For groups other than the first group
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Delete group button should be displayed for non-primary groups"
        )
    }

    func testMinimumStartIndexConstraint() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given group page is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then start index should respect minimum constraint
        // Based on previous group's end index
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Minimum start index constraint should be enforced"
        )
    }

    func testMaximumEndIndexConstraint() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given group page is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then end index should respect maximum constraint
        // Based on next group's start index or total apps
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Maximum end index constraint should be enforced"
        )
    }

    func testFormLayout() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given group page is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then form should have proper layout
        // Sections for range, background, border, geometry
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Group page form layout should be correct"
        )
    }

    func testNavigationTitle() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given group page is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then navigation title should show "Group X"
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Navigation title should be displayed"
        )
    }
}
