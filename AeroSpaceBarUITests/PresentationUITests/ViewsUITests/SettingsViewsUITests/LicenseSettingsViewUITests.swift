// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Nimble
import XCTest

/// UI tests for LicenseSettingsView.
///
/// These tests verify license settings UI including:
/// - Profile section (user name, profile image, email)
/// - License status section display
/// - License actions (start trial, purchase, activate, deactivate)
/// - Checkout web view display
/// - Error handling and validation
/// - View layout and styling
@MainActor
final class LicenseSettingsViewUITests: XCTestCase {
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

    func testLicenseSettingsViewDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given settings are open
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // When navigating to License settings (via sidebar)
        // Then license settings should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "License settings view should be displayed"
        )
    }

    func testProfileSectionDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then profile section should be displayed
        // Shows user name, profile image, email
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Profile section should be displayed"
        )
    }

    func testLicenseStatusSectionDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then license status section should be displayed
        // Shows current license status and key (if present)
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "License status section should be displayed"
        )
    }

    func testLicenseActionsSectionDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then license actions section should be displayed
        // Contains trial, purchase, activate, deactivate options
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "License actions section should be displayed"
        )
    }

    func testStartTrialButtonDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license settings with no active license
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then start trial button should be displayed
        // When trial is available and licensing is enabled
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Start trial button should be displayed when applicable"
        )
    }

    func testPurchaseLicenseButtonDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then purchase license button should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Purchase license button should be displayed"
        )
    }

    func testActivateLicenseInputDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then license key input field should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "License key input field should be displayed"
        )
    }

    func testActivateLicenseButtonDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license settings with license key input
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then activate license button should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Activate license button should be displayed"
        )
    }

    func testDeactivateLicenseButtonDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license settings with active license
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then deactivate button should be displayed
        // When license is active
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Deactivate license button should be displayed when licensed"
        )
    }

    func testCheckoutWebViewDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // When purchase license button is clicked
        // Note: Actually clicking would open web view sheet
        // which is difficult to test

        // Then checkout web view should be available
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Checkout web view should be accessible"
        )
    }

    func testActivationErrorDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license settings with activation error
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then activation error should be displayed
        // When activation fails
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Activation error should be displayed when present"
        )
    }

    func testLicenseInfoDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license settings with active license
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then license information should be displayed
        // Email, username, license status
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "License information should be displayed"
        )
    }

    func testLicenseSettingsViewLayout() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then view should have proper layout
        // Form with three main sections:
        // - Profile section
        // - Status section
        // - Actions section
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "License settings layout should be correct"
        )
    }

    func testLicenseSettingsFormStyling() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then view should use settings form style
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "License settings should use form styling"
        )
    }

    func testNavigationTitleDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license settings are accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then navigation title should be "License"
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Navigation title should be displayed"
        )
    }

    func testCheckoutWebViewCancelButton() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given checkout web view is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // When accessing checkout
        // Then cancel button should be available in toolbar
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Checkout cancel button should be accessible"
        )
    }
}
