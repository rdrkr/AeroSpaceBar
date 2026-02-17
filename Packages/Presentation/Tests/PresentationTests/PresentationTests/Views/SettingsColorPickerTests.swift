// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Nimble
@testable import Presentation
import SwiftUI
import XCTest

/// Tests for SettingsColorPicker component.
///
/// These tests verify:
/// - Initialization
/// - Color binding
/// - Opacity support
/// - Accessibility
@MainActor
final class SettingsColorPickerTests: XCTestCase {
    // MARK: - Initialization Tests

    func testInitialization() {
        // Given
        var color = Color.blue

        // When
        let picker = SettingsColorPicker(
            title: "Background Color",
            description: "Choose background color",
            selectedColor: Binding(
                get: { color },
                set: { color = $0 }
            )
        )

        // Then - Should not crash
        expect(picker).toNot(beNil())
    }

    func testInitializationWithOpacity() {
        // Given
        var color = Color.blue

        // When
        let picker = SettingsColorPicker(
            title: "Background Color",
            description: "Choose background color",
            selectedColor: Binding(
                get: { color },
                set: { color = $0 }
            ),
            supportsOpacity: true
        )

        // Then
        expect(picker.supportsOpacity) == true
    }

    // MARK: - Property Tests

    func testTitleProperty() {
        // Given
        var color = Color.blue
        let title: LocalizedStringResource = "Custom Title"

        // When
        let picker = SettingsColorPicker(
            title: title,
            description: "Description",
            selectedColor: Binding(
                get: { color },
                set: { color = $0 }
            )
        )

        // Then
        expect(picker.title == title) == true
    }

    func testDescriptionProperty() {
        // Given
        var color = Color.blue
        let description: LocalizedStringResource = "Custom Description"

        // When
        let picker = SettingsColorPicker(
            title: "Title",
            description: description,
            selectedColor: Binding(
                get: { color },
                set: { color = $0 }
            )
        )

        // Then
        expect(picker.description == description) == true
    }

    func testAccessibilityLabelProperty() {
        // Given
        var color = Color.blue
        let title: LocalizedStringResource = "Background Color"

        // When
        let picker = SettingsColorPicker(
            title: title,
            description: "Description",
            selectedColor: Binding(
                get: { color },
                set: { color = $0 }
            )
        )

        // Then
        expect(picker.accessibilityLabel == String(localized: title)) == true
    }

    func testSupportsOpacityDefault() {
        // Given
        var color = Color.blue

        // When
        let picker = SettingsColorPicker(
            title: "Title",
            description: "Description",
            selectedColor: Binding(
                get: { color },
                set: { color = $0 }
            )
        )

        // Then
        expect(picker.supportsOpacity) == false
    }

    // MARK: - Binding Tests

    func testColorBindingUpdates() {
        // Given
        var color = Color.blue
        let binding = Binding(
            get: { color },
            set: { color = $0 }
        )

        // When
        binding.wrappedValue = Color.red

        // Then
        expect(color == .red) == true
    }
}
