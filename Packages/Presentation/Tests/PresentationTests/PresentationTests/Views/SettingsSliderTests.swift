// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Nimble
@testable import Presentation
import SwiftUI
import XCTest

/// Tests for SettingsSlider view component.
///
/// These tests verify:
/// - Initialization with various formatters
/// - Value binding behavior
/// - Percentage formatter
/// - Points formatter
/// - Custom formatter
@MainActor
final class SettingsSliderTests: XCTestCase {
    // MARK: - Initialization Tests

    func testInitializationWithCustomFormatter() {
        // Given
        var value = 50.0

        // When
        let slider = SettingsSlider(
            value: Binding(
                get: { value },
                set: { value = $0 }
            ),
            in: 0 ... 100,
            defaultValue: 50,
            stickiness: 5,
            label: "Test Slider",
            helpText: "Test help text",
            valueFormatter: { "\($0)" }
        )

        // Then - Should not crash
        expect(slider).toNot(beNil())
    }

    func testInitializationWithPercentageFormatter() {
        // Given
        var value = 0.5

        // When
        let slider = SettingsSlider(
            value: Binding(
                get: { value },
                set: { value = $0 }
            ),
            in: 0 ... 1,
            defaultValue: 0.5,
            stickiness: 0.05,
            label: "Opacity",
            helpText: "Adjust opacity",
            displayAsPercentage: true
        )

        // Then - Should not crash
        expect(slider).toNot(beNil())
    }

    func testInitializationWithPointsFormatter() {
        // Given
        var value = 10.0

        // When
        let slider = SettingsSlider(
            value: Binding(
                get: { value },
                set: { value = $0 }
            ),
            in: 0 ... 20,
            defaultValue: 10,
            stickiness: 1,
            label: "Border Width",
            helpText: "Adjust border",
            displayAsPoints: true
        )

        // Then - Should not crash
        expect(slider).toNot(beNil())
    }

    // MARK: - Binding Tests

    func testBindingUpdatesValue() {
        // Given
        var value = 0.0
        let binding = Binding(
            get: { value },
            set: { value = $0 }
        )

        // When
        binding.wrappedValue = 75.0

        // Then
        expect(value) == 75.0
    }

    // MARK: - Formatter Tests

    func testPercentageFormatter() {
        // Given
        var value = 0.75
        let slider = SettingsSlider(
            value: Binding(
                get: { value },
                set: { value = $0 }
            ),
            in: 0 ... 1,
            defaultValue: 0.5,
            stickiness: 0.05,
            label: "Test",
            helpText: "Test",
            displayAsPercentage: true
        )

        // When
        let formatted = slider.valueFormatter(0.75)

        // Then
        expect(formatted) == "75%"
    }

    func testPointsFormatter() {
        // Given
        var value = 10.0
        let slider = SettingsSlider(
            value: Binding(
                get: { value },
                set: { value = $0 }
            ),
            in: 0 ... 20,
            defaultValue: 10,
            stickiness: 1,
            label: "Test",
            helpText: "Test",
            displayAsPoints: true
        )

        // When
        let formatted = slider.valueFormatter(10.0)

        // Then
        expect(formatted) == "10 pts"
    }

    func testCustomFormatter() {
        // Given
        var value = 42.0
        let customFormatter: (Double) -> String = { "Value: \(Int($0))" }
        let slider = SettingsSlider(
            value: Binding(
                get: { value },
                set: { value = $0 }
            ),
            in: 0 ... 100,
            defaultValue: 50,
            stickiness: 5,
            label: "Test",
            helpText: "Test",
            valueFormatter: customFormatter
        )

        // When
        let formatted = slider.valueFormatter(42.0)

        // Then
        expect(formatted) == "Value: 42"
    }

    // MARK: - Property Tests

    func testBoundsProperty() {
        // Given
        var value = 50.0
        let bounds: ClosedRange<Double> = 0 ... 100

        // When
        let slider = SettingsSlider(
            value: Binding(
                get: { value },
                set: { value = $0 }
            ),
            in: bounds,
            defaultValue: 50,
            stickiness: 5,
            label: "Test",
            helpText: "Test",
            valueFormatter: { "\($0)" }
        )

        // Then
        expect(slider.bounds) == bounds
    }

    func testDefaultValueProperty() {
        // Given
        var value = 50.0
        let defaultValue = 75.0

        // When
        let slider = SettingsSlider(
            value: Binding(
                get: { value },
                set: { value = $0 }
            ),
            in: 0 ... 100,
            defaultValue: defaultValue,
            stickiness: 5,
            label: "Test",
            helpText: "Test",
            valueFormatter: { "\($0)" }
        )

        // Then
        expect(slider.defaultValue) == defaultValue
    }

    func testStickinessProperty() {
        // Given
        var value = 50.0
        let stickiness = 10.0

        // When
        let slider = SettingsSlider(
            value: Binding(
                get: { value },
                set: { value = $0 }
            ),
            in: 0 ... 100,
            defaultValue: 50,
            stickiness: stickiness,
            label: "Test",
            helpText: "Test",
            valueFormatter: { "\($0)" }
        )

        // Then
        expect(slider.stickiness) == stickiness
    }
}
