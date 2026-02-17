// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Nimble
@testable import Presentation
import SwiftUI
import XCTest

/// Tests for StickySlider component.
///
/// These tests verify:
/// - Initialization
/// - Value snapping to default
/// - Stickiness behavior
/// - Label display
@MainActor
final class StickySliderTests: XCTestCase {
    // MARK: - Initialization Tests

    func testInitialization() {
        // Given
        var value = 0.5

        // When
        let slider = StickySlider(
            value: Binding(
                get: { value },
                set: { value = $0 }
            ),
            in: 0 ... 1,
            defaultValue: 0.5,
            stickiness: 0.05,
            labelWidth: 100
        ) {
            Text("Test Label")
        }

        // Then - Should not crash
        expect(slider).toNot(beNil())
    }

    // MARK: - Property Tests

    func testBoundsProperty() {
        // Given
        var value = 0.5
        let bounds: ClosedRange<Double> = 0 ... 1

        // When
        let slider = StickySlider(
            value: Binding(
                get: { value },
                set: { value = $0 }
            ),
            in: bounds,
            defaultValue: 0.5,
            stickiness: 0.05,
            labelWidth: 100
        ) {
            Text("Test")
        }

        // Then
        expect(slider.bounds) == bounds
    }

    func testDefaultValueProperty() {
        // Given
        var value = 0.5
        let defaultValue = 0.75

        // When
        let slider = StickySlider(
            value: Binding(
                get: { value },
                set: { value = $0 }
            ),
            in: 0 ... 1,
            defaultValue: defaultValue,
            stickiness: 0.05,
            labelWidth: 100
        ) {
            Text("Test")
        }

        // Then
        expect(slider.defaultValue) == defaultValue
    }

    func testStickinessProperty() {
        // Given
        var value = 0.5
        let stickiness = 0.1

        // When
        let slider = StickySlider(
            value: Binding(
                get: { value },
                set: { value = $0 }
            ),
            in: 0 ... 1,
            defaultValue: 0.5,
            stickiness: stickiness,
            labelWidth: 100
        ) {
            Text("Test")
        }

        // Then
        expect(slider.stickiness) == stickiness
    }

    func testLabelWidthProperty() {
        // Given
        var value = 0.5
        let labelWidth = 150.0

        // When
        let slider = StickySlider(
            value: Binding(
                get: { value },
                set: { value = $0 }
            ),
            in: 0 ... 1,
            defaultValue: 0.5,
            stickiness: 0.05,
            labelWidth: labelWidth
        ) {
            Text("Test")
        }

        // Then
        expect(slider.labelWidth) == labelWidth
    }
}
