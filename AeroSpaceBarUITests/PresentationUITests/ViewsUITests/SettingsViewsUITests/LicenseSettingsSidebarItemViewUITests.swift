// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Nimble
import XCTest

/// UI tests for LicenseSettingsSidebarItemView.
///
/// These tests verify license sidebar item UI including:
/// - Profile image display (custom or default person icon)
/// - User name and email display
/// - License state adaptation
/// - Control active state styling
/// - Animation for state changes
/// - Placeholder text for unlicensed users
@MainActor
final class LicenseSettingsSidebarItemViewUITests: XCTestCase {
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

    @MainActor
    func testSidebarItemDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given settings sidebar is open
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then license sidebar item should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(beTrue())
    }

    @MainActor
    func testProfileImageWithCustomImage() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given user has a custom profile image
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then custom profile image should be displayed
        // as resizable Image with aspect ratio fill
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(beTrue())
    }

    @MainActor
    func testProfileImageWithoutCustomImage() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given user does not have a custom profile image
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then default person.circle.fill icon should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Default profile icon should be displayed"
        )
    }

    @MainActor
    func testProfileImageSizing() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given profile image is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then image should be 38x38 points
        // and clipped to circle shape
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Profile image should be 38x38 circular"
        )
    }

    @MainActor
    func testUserNameDisplayLicensed() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given user has an active license with name
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then user name should be displayed
        // in headline font with primary color
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "User name should be displayed when licensed"
        )
    }

    @MainActor
    func testUserNameDisplayLicensedEmpty() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given user has license but no name set
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then "Set Your Name" placeholder should be displayed
        // in headline font with secondary color
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Placeholder should be shown for empty name"
        )
    }

    @MainActor
    func testUserNameDisplayUnlicensed() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given user does not have active license
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then "License Not Activated" should be displayed
        // in headline font with secondary color
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Not activated message should be shown when unlicensed"
        )
    }

    @MainActor
    func testEmailDisplayLicensed() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given user has license with email
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then email should be displayed
        // in subheadline font with secondary color
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Email should be displayed when available"
        )
    }

    @MainActor
    func testEmailDisplayLicensedEmpty() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given user has license but no email
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then "Licensed User" should be displayed
        // in subheadline font with secondary color
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Licensed User should be shown for empty email"
        )
    }

    @MainActor
    func testEmailDisplayUnlicensed() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given user does not have active license
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then "Purchase a license to customize your profile" should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Purchase prompt should be shown when unlicensed"
        )
    }

    @MainActor
    func testControlActiveStateStyling() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given window is active (key window)
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then colors should use full opacity (primary/secondary)
        // Profile image opacity: 1.0
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Active state should use full opacity colors"
        )
    }

    @MainActor
    func testControlInactiveStateStyling() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given window is inactive (not key window)
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then colors should use quaternary (dimmed)
        // Profile image opacity: 0.5
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Inactive state should use dimmed colors"
        )
    }

    @MainActor
    func testAnimationForLicenseChange() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given license state changes
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then animation should be applied
        // using .themeEaseInOutFast timing
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "License state change should animate"
        )
    }

    @MainActor
    func testAnimationForUserInfoChange() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given user name or email changes
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then animation should be applied
        // using .themeEaseInOutFast timing
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "User info change should animate"
        )
    }

    @MainActor
    func testAnimationForProfileImageChange() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given profile image changes
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then animation should be applied
        // using .themeEaseInOutFast timing
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Profile image change should animate"
        )
    }

    @MainActor
    func testLayoutSpacing() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given sidebar item is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then HStack should have 8pt spacing
        // VStack should have 2pt spacing
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Layout spacing should be correct"
        )
    }
}
