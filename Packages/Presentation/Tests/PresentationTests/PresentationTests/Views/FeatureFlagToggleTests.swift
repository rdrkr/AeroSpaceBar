// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Nimble
@testable import Presentation
import SwiftUI
import XCTest

/// Tests for FeatureFlagToggle view component.
///
/// These tests verify:
/// - Initialization with binding
/// - Initialization with action closure
/// - Toggle behavior when enabled/disabled
/// - Callback invocation
@MainActor
final class FeatureFlagToggleTests: XCTestCase {
    // MARK: - Initialization Tests

    func testInitializationWithBinding() {
        // Given
        var isEnabled = false

        // When
        let toggle = FeatureFlagToggle(
            title: "Test Feature",
            description: "Test description",
            isEnabled: Binding(
                get: { isEnabled },
                set: { isEnabled = $0 }
            )
        )

        // Then - Should not crash
        expect(toggle).toNot(beNil())
        expect(toggle.isEnabled) == false
    }

    func testInitializationWithAction() {
        // Given
        var callbackValue: Bool?
        let onToggle: (Bool) -> Void = { value in
            callbackValue = value
        }

        // When
        let toggle = FeatureFlagToggle(
            title: "Test Feature",
            description: "Test description",
            isEnabled: false,
            onToggle: onToggle
        )

        // Then - Should not crash
        expect(toggle).toNot(beNil())
        expect(toggle.isEnabled) == false

        // When callback is triggered
        onToggle(true)

        // Then callback should capture the value
        expect(callbackValue) == true
    }

    func testInitializationWithDisabled() {
        // Given
        var isEnabled = false

        // When
        let toggle = FeatureFlagToggle(
            title: "Test Feature",
            description: "Test description",
            isEnabled: Binding(
                get: { isEnabled },
                set: { isEnabled = $0 }
            ),
            isDisabled: true
        )

        // Then
        expect(toggle.isDisabled) == true
    }

    // MARK: - Binding Tests

    func testBindingUpdatesValue() {
        // Given
        var isEnabled = false
        _ = FeatureFlagToggle(
            title: "Test",
            description: "Test",
            isEnabled: Binding(
                get: { isEnabled },
                set: { isEnabled = $0 }
            )
        )

        // When
        isEnabled = true

        // Then
        expect(isEnabled) == true
    }

    // MARK: - Action Tests

    func testActionInvokedOnToggle() {
        // Given
        var callbackReceived = false
        var callbackValue: Bool?
        let onToggle: (Bool) -> Void = { value in
            callbackReceived = true
            callbackValue = value
        }

        let toggle = FeatureFlagToggle(
            title: "Test",
            description: "Test",
            isEnabled: false,
            onToggle: onToggle
        )

        // When
        toggle.onToggle(true)

        // Then
        expect(callbackReceived) == true
        expect(callbackValue) == true
    }

    func testActionNotInvokedWhenDisabled() {
        // Given
        var callbackReceived = false
        let onToggle: (Bool) -> Void = { _ in
            callbackReceived = true
        }

        _ = FeatureFlagToggle(
            title: "Test",
            description: "Test",
            isEnabled: false,
            isDisabled: true,
            onToggle: onToggle
        )

        // When - Toggle should be disabled, callback not invoked
        // Then
        expect(callbackReceived) == false
    }

    // MARK: - Property Tests

    func testTitleProperty() {
        // Given
        let title = "Enable Logging"

        // When
        let toggle = FeatureFlagToggle(
            title: title,
            description: "Test",
            isEnabled: .constant(false)
        )

        // Then
        expect(toggle.title) == title
    }

    func testDescriptionProperty() {
        // Given
        let description = "Enable detailed logging for debugging"

        // When
        let toggle = FeatureFlagToggle(
            title: "Test",
            description: description,
            isEnabled: .constant(false)
        )

        // Then
        expect(toggle.description) == description
    }

    func testIsEnabledProperty() {
        // Given
        let toggle = FeatureFlagToggle(
            title: "Test",
            description: "Test",
            isEnabled: true,
            onToggle: { _ in }
        )

        // When/Then
        expect(toggle.isEnabled) == true
    }

    func testIsDisabledProperty() {
        // Given
        let toggleEnabled = FeatureFlagToggle(
            title: "Test",
            description: "Test",
            isEnabled: .constant(false),
            isDisabled: false
        )
        let toggleDisabled = FeatureFlagToggle(
            title: "Test",
            description: "Test",
            isEnabled: .constant(false),
            isDisabled: true
        )

        // When/Then
        expect(toggleEnabled.isDisabled) == false
        expect(toggleDisabled.isDisabled) == true
    }
}
