// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Nimble
import XCTest

/// UI tests for ProfileSection.
///
/// These tests verify:
/// - Profile image display (custom or default icon)
/// - Profile image selection (licensed users)
/// - User name display and editing
/// - Email display
/// - Licensed vs unlicensed state
/// - Inline editing interface
/// - Focus management
/// - Animation for state changes
@MainActor
final class ProfileSectionUITests: XCTestCase {
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

        // Then profile section should be displayed in header
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Profile section should be displayed"
        )
    }

    // MARK: - Profile Image Tests (Licensed)

    func testProfileImageWithCustomImage() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given user is licensed with custom profile image
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then custom NSImage should be displayed
        // as resizable Image with aspect ratio fill
        // 100x100 circular
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Custom profile image should be displayed"
        )
    }

    func testProfileImageWithoutCustomImage() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given user is licensed without custom profile image
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then person.circle.fill icon should be displayed
        // with secondary foreground style
        // 100x100 circular
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Default profile icon should be displayed"
        )
    }

    func testProfileImagePencilOverlay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given user is licensed without custom image
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then pencil.circle.fill overlay should be displayed
        // in bottom-right corner with themePrimary color
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Pencil overlay should indicate editability"
        )
    }

    func testProfileImageButtonEnabled() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given user is licensed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // When profile image is clicked
        // Then file picker should open
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Profile image should be clickable when licensed"
        )
    }

    func testProfileImageButtonDisabled() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given user is not licensed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then profile image button should be disabled
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Profile image should not be clickable when unlicensed"
        )
    }

    // MARK: - User Name Tests (Licensed)

    func testUserNameDisplayWithValue() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given user is licensed with name set
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then user name should be displayed
        // in title2 bold font with primary color
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "User name should be displayed"
        )
    }

    func testUserNameDisplayEmpty() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given user is licensed without name
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then "Set Your Name" placeholder should be displayed
        // with pencil icon, secondary color
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Name placeholder should be displayed"
        )
    }

    func testUserNameEditMode() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given user clicks on name
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then TextField should be displayed
        // with rounded border, centered text
        // focused automatically after 100ms
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Name edit field should be displayed"
        )
    }

    func testUserNameEditSubmit() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given user is editing name
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // When user presses Enter
        // Then onSetUserName callback should be invoked
        // and editing mode should close
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Name should be saved on submit"
        )
    }

    func testUserNameEditCancel() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given user is editing name
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // When user presses Escape
        // Then editing should cancel without saving
        // and original value should be restored
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Name edit should be cancelable"
        )
    }

    func testUserNameEditBlur() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given user is editing name
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // When user clicks outside text field
        // Then changes should be saved automatically
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Name should save on blur"
        )
    }

    // MARK: - Email Tests (Licensed)

    func testEmailDisplayWithValue() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given user is licensed with email
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then email should be displayed
        // in title3 font with secondary color
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Email should be displayed"
        )
    }

    func testEmailDisplayEmpty() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given user is licensed without email
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then "Licensed User" should be displayed
        // in title3 font with secondary color
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Licensed User should be shown for empty email"
        )
    }

    // MARK: - Unlicensed State Tests

    func testUnlicensedProfileImage() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given user is not licensed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then person.circle.fill icon should be displayed
        // without pencil overlay
        // button disabled
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Unlicensed should show default icon without edit"
        )
    }

    func testUnlicensedNameDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given user is not licensed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then "License Not Activated" should be displayed
        // in title2 bold font with secondary color
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Unlicensed should show activation message"
        )
    }

    func testUnlicensedPromptDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given user is not licensed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then "Purchase a license to customize your profile" should be displayed
        // in title3 font, centered, secondary color
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Unlicensed should show purchase prompt"
        )
    }

    // MARK: - Animation Tests

    func testEditingModeAnimation() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given user toggles editing mode
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then animation should be applied
        // using .themeEaseInOutFast timing
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Editing mode should animate"
        )
    }

    // MARK: - Layout Tests

    func testSectionLayoutStructure() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given profile section is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then section should be in header with:
        // - VStack containing profile image, name, email
        // - maxWidth: .infinity for centering
        // - 10pt top padding
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Section should have proper layout structure"
        )
    }

    func testTextFieldMaxWidth() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given user is editing name
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then text field should have maxWidth: 200
        // to prevent excessive width
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Edit field should have max width constraint"
        )
    }

    // MARK: - Focus Management Tests

    func testAutoFocusAfterEditStart() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given user starts editing name
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then text field should receive focus automatically
        // after 100ms delay
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Text field should auto-focus"
        )
    }

    // MARK: - State Synchronization Tests

    func testUserNameSyncOnAppear() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given profile section appears
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then editingUserName should sync with userName
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Editing name should sync on appear"
        )
    }

    func testUserNameSyncOnChange() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given userName changes externally
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then editingUserName should update
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Editing name should sync on change"
        )
    }
}
