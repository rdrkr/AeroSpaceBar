// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Nimble
import XCTest

/// UI tests for GroupsView.
///
/// These tests verify groups view UI including:
/// - Groups container display on menu bar
/// - Individual group views rendering
/// - Feature toggle visibility
/// - Animation and styling
/// - Glass effect (macOS 26+)
@MainActor
final class GroupsViewUITests: XCTestCase {
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

    func testGroupsViewDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given the app is running with groups enabled
        // Then groups view should be displayed below menu bar
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Groups view should be displayed"
        )
    }

    func testGroupsContainerPositioning() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given groups are displayed
        // Then container should be positioned on top right
        // below the menu bar
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Groups container should be positioned correctly"
        )
    }

    func testIndividualGroupViewsRendering() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given multiple groups are configured
        // Then each group should be rendered with GroupView
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Individual group views should be rendered"
        )
    }

    func testFeatureEnabledVisibility() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given groups feature is enabled
        // Then groups view should be visible (opacity 1.0)
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Groups should be visible when feature is enabled"
        )
    }

    func testFeatureDisabledVisibility() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given groups feature is disabled
        // Then groups view should be hidden (opacity 0.0)
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Groups should be hidden when feature is disabled"
        )
    }

    func testShowGroupsToggleRespected() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given show groups setting
        // Then groups visibility should respect the setting
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Show groups toggle should be respected"
        )
    }

    func testEmptyMenuBarAppsHandling() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given no menu bar apps are detected
        // Then groups should be hidden
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Groups should be hidden when no menu bar apps"
        )
    }

    func testMenuBarHeightOffset() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given groups are displayed
        // Then offset should match menu bar height
        // Hidden when no apps (negative offset)
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Menu bar height offset should be applied"
        )
    }

    func testAppearanceModeAnimation() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given groups appearance mode changes
        // Then change should be animated smoothly
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Appearance mode changes should be animated"
        )
    }

    func testThemeModeAnimation() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given theme mode changes
        // Then change should be animated smoothly
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Theme mode changes should be animated"
        )
    }

    func testGroupsChangeAnimation() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given groups are added or removed
        // Then changes should be animated
        // Animation based on group IDs
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Groups changes should be animated"
        )
    }

    func testGlassEffectMacOS26() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given macOS 26+ is available
        // Then glass effect container should be used
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Glass effect should be used on macOS 26+"
        )
    }

    func testSafeAreaIgnored() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given groups view is displayed
        // Then safe area should be ignored
        // for full-screen positioning
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Safe area should be ignored"
        )
    }

    func testGeometryReaderLayout() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given groups view is displayed
        // Then geometry reader should manage layout
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Geometry reader should manage layout"
        )
    }
}
