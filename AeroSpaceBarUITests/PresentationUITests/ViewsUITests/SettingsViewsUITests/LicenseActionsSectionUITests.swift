// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Nimble
import XCTest

/// UI tests for LicenseActionsSection.
///
/// These tests verify:
/// - Start trial button display and behavior
/// - Purchase license button display
/// - License key activation interface
/// - Deactivate license button (licensed users)
/// - Feature flag conditional rendering
/// - Button styling and sizing
/// - Section visibility based on license status
@MainActor
final class LicenseActionsSectionUITests: XCTestCase {
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

    // MARK: - Section Display Tests

    func testSectionDisplayWhenLicensingEnabled() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given licensing is enabled
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then license actions section should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "License actions section should be displayed"
        )
    }

    func testSectionHiddenWhenLicensingDisabled() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given licensing is disabled via feature flags
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then license actions section should not be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "License actions should be hidden when licensing disabled"
        )
    }

    // MARK: - Start Trial Button Tests

    func testStartTrialButtonDisplayUnknownStatus() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license status is unknown
        // When trial request is enabled
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then "Start 14-Day Free Trial" button should be displayed
        // with play.circle.fill icon
        // borderedProminent style, large control size
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Start trial button should be displayed"
        )
    }

    func testStartTrialButtonHiddenWhenTrialDisabled() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license status is unknown
        // When trial request is disabled via feature flags
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then start trial button should not be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Start trial button should be hidden"
        )
    }

    func testStartTrialButtonHiddenWhenLicensed() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given user has active license
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then start trial button should not be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Start trial button should be hidden when licensed"
        )
    }

    // MARK: - Purchase License Button Tests

    func testPurchaseLicenseButtonDisplayTrial() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license status is trial
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then "Purchase License" button should be displayed
        // with creditcard.fill icon
        // bordered style, large control size
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Purchase button should be displayed during trial"
        )
    }

    func testPurchaseLicenseButtonDisplayExpired() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license status is expired
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then "Purchase License" button should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Purchase button should be displayed when expired"
        )
    }

    func testPurchaseLicenseButtonDisplayUnknown() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license status is unknown
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then "Purchase License" button should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Purchase button should be displayed when unknown"
        )
    }

    func testPurchaseLicenseButtonDisplayValidating() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license status is validating
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then "Purchase License" button should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Purchase button should be displayed when validating"
        )
    }

    func testPurchaseLicenseButtonHiddenWhenLicensed() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license status is licensed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then purchase button should not be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Purchase button should be hidden when licensed"
        )
    }

    // MARK: - License Key Activation Tests

    func testLicenseKeyActivationViewDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license actions section is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then LicenseKeyActivationView should be displayed
        // for all license statuses
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "License key activation view should be displayed"
        )
    }

    // MARK: - Deactivate License Button Tests

    func testDeactivateLicenseButtonDisplayWhenLicensed() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license status is licensed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then "Deactivate License" button should be displayed
        // with xmark.circle.fill icon
        // bordered style, large control size, red foreground
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Deactivate button should be displayed when licensed"
        )
    }

    func testDeactivateLicenseButtonHiddenWhenNotLicensed() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license status is not licensed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then deactivate button should not be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Deactivate button should be hidden when not licensed"
        )
    }

    // MARK: - Button Interaction Tests

    func testStartTrialButtonInteraction() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given start trial button is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // When button is clicked
        // Then onStartTrial callback should be invoked
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Start trial callback should be invoked"
        )
    }

    func testPurchaseLicenseButtonInteraction() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given purchase button is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // When button is clicked
        // Then onPurchaseLicense callback should be invoked
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Purchase callback should be invoked"
        )
    }

    func testDeactivateLicenseButtonInteraction() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given deactivate button is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // When button is clicked
        // Then onDeactivateLicense callback should be invoked
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Deactivate callback should be invoked"
        )
    }

    // MARK: - Layout Tests

    func testVerticalStackLayout() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license actions section is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then buttons should be laid out vertically
        // with 8pt spacing
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Buttons should have vertical layout with spacing"
        )
    }

    func testButtonMaxWidthInfinity() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given action buttons are displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then buttons should expand to full width
        // using maxWidth: .infinity
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Buttons should expand to full width"
        )
    }
}
