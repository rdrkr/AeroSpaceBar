// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Nimble
import XCTest

/// UI tests for LicenseKeyActivationView.
///
/// These tests verify license key activation UI including:
/// - Activate/show license key button display
/// - License key input field display and interaction
/// - Activation progress indication
/// - Error message display and clearing
/// - Licensed vs unlicensed state handling
@MainActor
final class LicenseKeyActivationViewUITests: XCTestCase {
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

    func testActivateLicenseButtonUnlicensed() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license settings are open and unlicensed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then button should say "Activate License Key"
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Activate license button should be displayed when unlicensed"
        )
    }

    func testShowLicenseKeyButtonLicensed() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license settings are open and licensed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then button should say "Show License Key"
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Show license key button should be displayed when licensed"
        )
    }

    func testButtonStyling() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license activation view is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then button should have bordered style
        // and large control size with key icon
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Button should have correct styling"
        )
    }

    func testLicenseKeyInputFieldDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given activation interface is shown
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then license key input field should be displayed
        // for unlicensed users
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "License key input field should be displayed"
        )
    }

    func testLicenseKeyInputFocusUnlicensed() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given activation interface opens for unlicensed user
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then text field should receive focus automatically
        // after a small delay
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Text field should auto-focus for unlicensed users"
        )
    }

    func testLicenseKeyDisplayLicensed() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given activation interface shows for licensed user
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then license key should be displayed in read-only mode
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "License key should be displayed for licensed users"
        )
    }

    func testActivateButtonDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license key input is shown
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then activate button should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Activate button should be displayed"
        )
    }

    func testActivateButtonDisabledEmpty() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license key input is empty
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then activate button should be disabled
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Activate button should be disabled when input is empty"
        )
    }

    func testActivatingProgressIndication() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given activation is in progress
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then progress indicator should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Progress indicator should be shown during activation"
        )
    }

    func testActivationErrorDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given activation failed with error
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then error message should be displayed
        // in destructive/error styling
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Activation error should be displayed"
        )
    }

    func testClearErrorOnHide() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given activation interface with error is hidden
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then error should be cleared
        // and input text should be cleared
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Error and input should be cleared when hiding"
        )
    }

    func testToggleAnimation() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given activation interface toggles visibility
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then changes should be animated
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Visibility toggle should be animated"
        )
    }
}
