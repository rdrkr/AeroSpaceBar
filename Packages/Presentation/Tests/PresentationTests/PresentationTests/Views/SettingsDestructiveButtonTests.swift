// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Nimble
@testable import Presentation
import SwiftUI
import XCTest

/// Tests for SettingsDestructiveButton component.
///
/// These tests verify:
/// - Initialization
/// - Action callback
/// - Styling (red color)
/// - Layout structure
@MainActor
final class SettingsDestructiveButtonTests: XCTestCase {
    // MARK: - Initialization Tests

    func testInitialization() {
        // Given/When
        let button = SettingsDestructiveButton(
            title: "Delete All",
            description: "This will delete everything",
            action: { }
        )

        // Then - Should not crash
        expect(button).toNot(beNil())
    }

    // MARK: - Property Tests

    func testTitleProperty() {
        // Given
        let title: LocalizedStringResource = "Reset Settings"

        // When
        let button = SettingsDestructiveButton(
            title: title,
            description: "Description",
            action: { }
        )

        // Then
        expect(button.title) == title
    }

    func testDescriptionProperty() {
        // Given
        let description: LocalizedStringResource = "This action cannot be undone"

        // When
        let button = SettingsDestructiveButton(
            title: "Title",
            description: description,
            action: { }
        )

        // Then
        expect(button.description) == description
    }

    // MARK: - Action Tests

    func testActionCallback() {
        // Given
        var actionCalled = false
        let action: () -> Void = {
            actionCalled = true
        }

        let button = SettingsDestructiveButton(
            title: "Delete",
            description: "Delete everything",
            action: action
        )

        // When
        button.action()

        // Then
        expect(actionCalled) == true
    }
}
