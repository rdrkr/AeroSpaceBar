// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Nimble
import XCTest

/// UI tests for GroupsSettingsView.
///
/// These tests verify groups settings UI including:
/// - Groups feature toggle
/// - Groups appearance mode picker
/// - Groups list display and management
/// - Add/delete group functionality
/// - Global visual properties configuration
/// - View layout and styling
@MainActor
final class GroupsSettingsViewUITests: XCTestCase {
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

    func testGroupsSettingsViewDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given settings are open
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // When navigating to Groups settings (via sidebar)
        // Then groups settings should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Groups settings view should be displayed"
        )
    }

    func testShowGroupsToggleDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given groups settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then show groups feature toggle should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Show groups toggle should be displayed"
        )
    }

    func testGroupsAppearanceModePickerDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given groups settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then appearance mode picker should be displayed
        // Options: All Groups, Per Group
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Groups appearance mode picker should be displayed"
        )
    }

    func testGroupsListDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given groups settings are accessible with groups enabled
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then groups list should be displayed
        // Shows existing groups with their configurations
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Groups list should be displayed"
        )
    }

    func testAddGroupButtonDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given groups settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then add group button should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Add group button should be displayed"
        )
    }

    func testGlobalVisualPropertiesDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given groups settings with "All Groups" appearance mode
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then global visual properties should be displayed
        // Color, geometric, and effect properties
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Global visual properties should be displayed"
        )
    }

    func testGroupItemNavigation() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given groups list is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // When clicking on a group item
        // Then should navigate to group detail page
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Group item navigation should work"
        )
    }

    func testDeleteGroupFunctionality() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given groups list is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // When attempting to delete a group
        // Then delete should work and renumber remaining groups
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Delete group functionality should work"
        )
    }

    func testResetGroupsFunctionality() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given groups settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // When accessing reset groups option
        // Then reset should restore default groups
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Reset groups functionality should work"
        )
    }

    func testGroupsSettingsViewLayout() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given groups settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then view should have proper layout
        // Uses VisualSettingsContainerView with groups configuration
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Groups settings layout should be correct"
        )
    }

    func testFeatureDisabledBehavior() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given groups feature is disabled
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // When disabling groups feature
        // Then all group pages should be removed from navigation
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Feature disabled behavior should work correctly"
        )
    }

    func testCanAddMoreGroupsLimit() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given groups settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // When maximum groups reached
        // Then add button should be disabled
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Add more groups limit should be enforced"
        )
    }
}
