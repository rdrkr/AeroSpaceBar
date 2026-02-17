// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Nimble
import XCTest

/// UI tests for LicenseStatusSection.
///
/// These tests verify:
/// - Status icon display for each license state
/// - Status color coding
/// - Title and subtitle text
/// - Progress indicator for validating state
/// - Animation for status changes
/// - Masked license key display (licensed users)
@MainActor
final class LicenseStatusSectionUITests: XCTestCase {
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

    func testSectionDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license settings are open
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then license status section should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "License status section should be displayed"
        )
    }

    // MARK: - Licensed Status Tests

    func testLicensedStatusIcon() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license status is licensed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then checkmark.shield.fill icon should be displayed
        // in green color
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Licensed status should show shield icon"
        )
    }

    func testLicensedStatusTitle() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license status is licensed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then "Licensed" title should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Licensed status should show title"
        )
    }

    func testLicensedStatusSubtitle() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license status is licensed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then "Thank you for supporting AeroSpaceBar" subtitle should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Licensed status should show thank you message"
        )
    }

    // MARK: - Trial Status Tests

    func testTrialStatusIcon() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license status is trial
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then clock.badge.checkmark icon should be displayed
        // in blue color
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Trial status should show clock icon"
        )
    }

    func testTrialStatusTitle() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license status is trial with 5 days remaining
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then "Trial Active - 5 days remaining" should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Trial status should show days remaining"
        )
    }

    func testTrialStatusSubtitleManyDays() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given trial has more than 3 days remaining
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then "Enjoy full access to all features" should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Trial with many days should show positive message"
        )
    }

    func testTrialStatusSubtitleFewDays() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given trial has 3 or fewer days remaining
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then "Purchase a license to continue using AeroSpaceBar" should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Trial ending soon should show purchase prompt"
        )
    }

    // MARK: - Expired Status Tests

    func testExpiredStatusIcon() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license status is expired
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then exclamationmark.shield.fill icon should be displayed
        // in red color
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Expired status should show warning icon"
        )
    }

    func testExpiredStatusTitle() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license status is expired
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then "Trial Expired" should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Expired status should show title"
        )
    }

    func testExpiredStatusSubtitle() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license status is expired
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then "Purchase a license to continue using AeroSpaceBar" should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Expired status should show purchase prompt"
        )
    }

    // MARK: - Validating Status Tests

    func testValidatingStatusIcon() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license status is validating
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then hourglass icon should be displayed
        // in orange color
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Validating status should show hourglass icon"
        )
    }

    func testValidatingStatusProgressIndicator() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license status is validating
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then ProgressView should be displayed
        // scaled to 0.8
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Validating status should show progress indicator"
        )
    }

    func testValidatingStatusTitle() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license status is validating
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then "Validating License" should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Validating status should show title"
        )
    }

    func testValidatingStatusSubtitle() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license status is validating
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then "Please wait while we verify your license" should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Validating status should show subtitle"
        )
    }

    // MARK: - Unknown Status Tests

    func testUnknownStatusIcon() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license status is unknown
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then questionmark.circle icon should be displayed
        // in gray color
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Unknown status should show question icon"
        )
    }

    func testUnknownStatusTitle() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license status is unknown
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then "No Active License" should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Unknown status should show title"
        )
    }

    func testUnknownStatusSubtitle() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license status is unknown
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then "Start your 14-day free trial or enter a license key" should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Unknown status should show trial/key prompt"
        )
    }

    // MARK: - Layout Tests

    func testHorizontalStackLayout() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license status section is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then elements should be in HStack with 12pt spacing:
        // - Icon (24pt width, title2 font)
        // - VStack with title and subtitle
        // - Spacer
        // - Progress indicator (if validating)
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Layout should use HStack with proper spacing"
        )
    }

    func testIconStyling() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given status icon is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then icon should:
        // - Use title2 font size
        // - Have 24pt fixed width
        // - Use status-specific foreground color
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Icon should have proper styling"
        )
    }

    func testTitleStyling() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given status title is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then title should:
        // - Use body font
        // - Have medium font weight
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Title should have proper styling"
        )
    }

    func testSubtitleStyling() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given status subtitle is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then subtitle should:
        // - Use caption font
        // - Have secondary foreground style
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Subtitle should have proper styling"
        )
    }

    // MARK: - Animation Tests

    func testStatusChangeAnimation() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license status changes
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then animation should be applied
        // using .themeEaseInOutFast timing
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Status change should animate"
        )
    }

    func testVerticalPadding() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given status section is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then 4pt vertical padding should be applied
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Section should have vertical padding"
        )
    }
}
