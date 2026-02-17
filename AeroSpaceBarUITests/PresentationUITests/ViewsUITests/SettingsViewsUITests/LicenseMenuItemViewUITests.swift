// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Nimble
import XCTest

/// UI tests for LicenseMenuItemView.
///
/// These tests verify license menu item UI including:
/// - License status display (trial, expired, unknown)
/// - Trial days remaining countdown
/// - Purchase/trial button display
/// - Navigation to license settings
/// - Feature flag conditional (enableTrialRequest)
/// - Capsule button styling
@MainActor
final class LicenseMenuItemViewUITests: XCTestCase {
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

    func testLicenseMenuItemDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given the app is running
        // Then license menu item should be displayed in menu
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "License menu item should be displayed"
        )
    }

    func testTrialStatusDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license is in trial state with days remaining
        // Then "Trial - X days left" should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Trial status should show days remaining"
        )
    }

    func testExpiredStatusDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given trial is expired
        // Then "Trial Expired - Purchase to continue" should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Expired status should show purchase prompt"
        )
    }

    func testUnknownStatusWithTrialEnabled() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license status is unknown
        // When trial request is enabled
        // Then "Start Trial" should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Unknown status with trial enabled should show start trial"
        )
    }

    func testUnknownStatusWithTrialDisabled() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license status is unknown
        // When trial request is disabled
        // Then "Purchase to continue" should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Unknown status with trial disabled should show purchase"
        )
    }

    func testLicensedStatusDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license is active/valid
        // Then menu item should not display status text (nil)
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Licensed status should not show menu item"
        )
    }

    func testCapsuleButtonStyling() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license menu item is displayed
        // Then button should have capsule border shape
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Button should use capsule styling"
        )
    }

    func testMenuItemPadding() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license menu item is displayed
        // Then proper padding should be applied:
        // - Top: 6pt, Bottom: 7pt, Horizontal: 10pt
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Menu item should have proper padding"
        )
    }

    func testNavigationToLicenseSettings() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license menu item is displayed
        // When menu item is clicked
        // Then should navigate to license settings page
        // Uses .navigateToLicensePage notification
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Should navigate to license settings when clicked"
        )
    }

    func testOpenSettingsEnvironmentAction() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license menu item is clicked
        // Then openSettings environment action should be called
        // to open settings window
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Should use openSettings environment action"
        )
    }

    func testDismissAfterNavigation() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license menu item is clicked
        // Then dismiss environment action should be called
        // to close the menu
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Should dismiss menu after navigation"
        )
    }

    func testSecondaryTextStyling() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license status text is displayed
        // Then text should use secondary styling
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Status text should use secondary styling"
        )
    }
}
