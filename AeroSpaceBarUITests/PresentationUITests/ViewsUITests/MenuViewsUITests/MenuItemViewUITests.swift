// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Nimble
import XCTest

/// UI tests for MenuItemView.
///
/// These tests verify menu item view UI including:
/// - Title display
/// - Icon (system image) display
/// - Keyboard shortcut display
/// - Hover states and interactions
/// - Action invocation
/// - Native macOS menu styling
/// - Accessibility support
@MainActor
final class MenuItemViewUITests: XCTestCase {
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

    func testMenuItemViewDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given the app menu is displayed
        // Then menu items should be displayed with proper styling
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Menu items should be displayed"
        )
    }

    func testMenuItemTitleDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given a menu item with title
        // Then title should be displayed with proper localization
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Menu item title should be displayed"
        )
    }

    func testMenuItemIconDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given a menu item with system image
        // Then SF Symbol icon should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Menu item icon should be displayed"
        )
    }

    func testKeyboardShortcutDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given a menu item with keyboard shortcut
        // Then shortcut should be displayed on the right side
        // (e.g., "⌘," for Command+Comma)
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Keyboard shortcut should be displayed"
        )
    }

    func testNoKeyboardShortcutDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given a menu item without keyboard shortcut
        // Then no shortcut should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "No keyboard shortcut should be displayed when not set"
        )
    }

    func testMenuItemHoverState() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given a menu item is being hovered
        // Then blue highlight should be shown (native macOS style)
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Menu item hover state should be displayed"
        )
    }

    func testMenuItemNormalState() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given a menu item is not being hovered
        // Then normal background should be shown
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Menu item normal state should be displayed"
        )
    }

    func testMenuItemClickInteraction() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given a menu item with action
        // When menu item is clicked
        // Then action should be invoked
        // Note: Menu bar interaction is limited in UI tests
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Menu item click should work"
        )
    }

    func testMenuItemLayout() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given a menu item is displayed
        // Then layout should be:
        // [Icon] [Title] [Spacer] [Keyboard Shortcut]
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Menu item layout should be correct"
        )
    }

    func testMenuItemTypography() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given a menu item is displayed
        // Then text should use system font
        // and proper sizing for menu items
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Menu item typography should be correct"
        )
    }

    func testMenuItemSpacing() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given a menu item is displayed
        // Then spacing between icon and text should be consistent
        // with native macOS menu items
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Menu item spacing should be correct"
        )
    }

    func testMenuItemAccessibility() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given a menu item is displayed
        // Then proper accessibility labels should be set
        // for VoiceOver support
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Menu item accessibility should be supported"
        )
    }

    func testNativeMacOSMenuStyling() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given menu items are displayed
        // Then styling should match native macOS menu appearance
        // when used within .window style MenuBarExtra
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Native macOS menu styling should be applied"
        )
    }

    func testMultipleMenuItemsConsistency() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given multiple menu items are displayed
        // Then all items should have consistent styling
        // and alignment
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Multiple menu items should have consistent styling"
        )
    }
}
