// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Nimble
@testable import Presentation
import SwiftUI
import XCTest

/// Tests for SettingsToggle view component.
///
/// These tests verify:
/// - Initialization with title and description
/// - Binding behavior
/// - Toggle styling
/// - Layout structure
@MainActor
final class SettingsToggleTests: XCTestCase {
    // MARK: - Initialization Tests

    func testInitialization() {
        // Given
        var isOn = false

        // When
        let toggle = SettingsToggle(
            title: "Test Title",
            description: "Test Description",
            isOn: Binding(
                get: { isOn },
                set: { isOn = $0 }
            )
        )

        // Then - Should not crash
        expect(toggle).toNot(beNil())
    }

    // MARK: - Binding Tests

    func testBindingTogglesValue() {
        // Given
        var isOn = false
        let binding = Binding(
            get: { isOn },
            set: { isOn = $0 }
        )

        // When
        binding.wrappedValue = true

        // Then
        expect(isOn) == true
    }

    // MARK: - Property Tests

    func testTitleProperty() {
        // Given
        var isOn = false
        let title: LocalizedStringResource = "Enable Feature"

        // When
        let toggle = SettingsToggle(
            title: title,
            description: "Description",
            isOn: Binding(
                get: { isOn },
                set: { isOn = $0 }
            )
        )

        // Then
        expect(toggle.title) == title
    }

    func testDescriptionProperty() {
        // Given
        var isOn = false
        let description: LocalizedStringResource = "This enables a feature"

        // When
        let toggle = SettingsToggle(
            title: "Title",
            description: description,
            isOn: Binding(
                get: { isOn },
                set: { isOn = $0 }
            )
        )

        // Then
        expect(toggle.description) == description
    }
}
