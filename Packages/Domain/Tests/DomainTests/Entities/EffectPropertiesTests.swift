// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Nimble
import XCTest

/// Tests for EffectProperties entity.
///
/// These tests verify EffectProperties initialization, coding/decoding,
/// equality, hashing, and DefaultInitializable conformance.
@MainActor
final class EffectPropertiesTests: XCTestCase {
    // MARK: - Initialization Tests

    func testInitializationWithAllParameters() {
        // Given parameters
        let backgroundOpacity = 0.8
        let backgroundBlurRadius = 10.0
        let borderOpacity = 0.9

        // When creating effect properties
        let props = EffectProperties(
            backgroundOpacity: backgroundOpacity,
            backgroundBlurRadius: backgroundBlurRadius,
            borderOpacity: borderOpacity
        )

        // Then all properties should be set
        expect(props.backgroundOpacity) == backgroundOpacity
        expect(props.backgroundBlurRadius) == backgroundBlurRadius
        expect(props.borderOpacity) == borderOpacity
    }

    func testDefaultInitialization() {
        // When creating with default init
        let props = EffectProperties()

        // Then should have default values from ConfigurationDefaults
        expect(props.backgroundOpacity).toNot(beNil())
        expect(props.backgroundBlurRadius).toNot(beNil())
        expect(props.borderOpacity).toNot(beNil())
    }

    // MARK: - Coding Tests

    func testEncodingAndDecoding() throws {
        // Given effect properties
        let original = EffectProperties(
            backgroundOpacity: 0.75,
            backgroundBlurRadius: 15.0,
            borderOpacity: 0.85
        )

        // When encoding and decoding
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(EffectProperties.self, from: data)

        // Then should match original
        expect(decoded.backgroundOpacity) == original.backgroundOpacity
        expect(decoded.backgroundBlurRadius) == original.backgroundBlurRadius
        expect(decoded.borderOpacity) == original.borderOpacity
    }

    func testCodingKeysMapping() throws {
        // Given effect properties
        let props = EffectProperties(
            backgroundOpacity: 0.8,
            backgroundBlurRadius: 10.0,
            borderOpacity: 1.0
        )

        // When encoding
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(props)
        let jsonString = String(bytes: data, encoding: .utf8) ?? ""

        // Then should use kebab-case keys
        expect(jsonString.contains("background-opacity")) == true
        expect(jsonString.contains("background-blur-radius")) == true
        expect(jsonString.contains("border-opacity")) == true
    }

    func testRoundTripCoding() throws {
        // Given various effect values
        let testCases = [
            (backgroundOpacity: 0.0, backgroundBlurRadius: 0.0, borderOpacity: 0.0),
            (backgroundOpacity: 0.5, backgroundBlurRadius: 5.0, borderOpacity: 0.5),
            (backgroundOpacity: 1.0, backgroundBlurRadius: 10.0, borderOpacity: 1.0),
            (backgroundOpacity: 0.75, backgroundBlurRadius: 20.0, borderOpacity: 0.85),
            (backgroundOpacity: 0.3, backgroundBlurRadius: 15.5, borderOpacity: 0.95)
        ]

        for testCase in testCases {
            // When encoding and decoding
            let original = EffectProperties(
                backgroundOpacity: testCase.backgroundOpacity,
                backgroundBlurRadius: testCase.backgroundBlurRadius,
                borderOpacity: testCase.borderOpacity
            )

            let encoder = JSONEncoder()
            let data = try encoder.encode(original)
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(EffectProperties.self, from: data)

            // Then should match original
            expect(decoded) == original
        }
    }

    // MARK: - Equality Tests

    func testEqualityWithSameValues() {
        // Given two properties with same values
        let props1 = EffectProperties(
            backgroundOpacity: 0.8,
            backgroundBlurRadius: 10.0,
            borderOpacity: 0.9
        )

        let props2 = EffectProperties(
            backgroundOpacity: 0.8,
            backgroundBlurRadius: 10.0,
            borderOpacity: 0.9
        )

        // Then they should be equal
        expect(props1) == props2
    }

    func testInequalityWithDifferentBackgroundOpacity() {
        // Given two properties with different background opacity
        let props1 = EffectProperties(backgroundOpacity: 0.8, backgroundBlurRadius: 10.0, borderOpacity: 0.9)
        let props2 = EffectProperties(backgroundOpacity: 0.5, backgroundBlurRadius: 10.0, borderOpacity: 0.9)

        // Then they should not be equal
        expect(props1) != props2
    }

    func testInequalityWithDifferentBackgroundBlurRadius() {
        // Given two properties with different blur radius
        let props1 = EffectProperties(backgroundOpacity: 0.8, backgroundBlurRadius: 10.0, borderOpacity: 0.9)
        let props2 = EffectProperties(backgroundOpacity: 0.8, backgroundBlurRadius: 15.0, borderOpacity: 0.9)

        // Then they should not be equal
        expect(props1) != props2
    }

    func testInequalityWithDifferentBorderOpacity() {
        // Given two properties with different border opacity
        let props1 = EffectProperties(backgroundOpacity: 0.8, backgroundBlurRadius: 10.0, borderOpacity: 0.9)
        let props2 = EffectProperties(backgroundOpacity: 0.8, backgroundBlurRadius: 10.0, borderOpacity: 1.0)

        // Then they should not be equal
        expect(props1) != props2
    }

    // MARK: - Hashable Tests

    func testHashableConformance() {
        // Given effect properties
        let props1 = EffectProperties(backgroundOpacity: 0.8, backgroundBlurRadius: 10.0, borderOpacity: 0.9)
        let props2 = EffectProperties(backgroundOpacity: 0.5, backgroundBlurRadius: 5.0, borderOpacity: 0.7)

        // When adding to set
        let set: Set<EffectProperties> = [props1, props2]

        // Then should store unique properties
        expect(set.count) == 2
    }

    func testHashableWithDuplicates() {
        // Given duplicate effect properties
        let props1 = EffectProperties(backgroundOpacity: 0.8, backgroundBlurRadius: 10.0, borderOpacity: 0.9)
        let props2 = EffectProperties(backgroundOpacity: 0.8, backgroundBlurRadius: 10.0, borderOpacity: 0.9)

        // When adding to set
        let set: Set<EffectProperties> = [props1, props2]

        // Then should only store one
        expect(set.count) == 1
    }

    func testHashConsistency() {
        // Given same effect properties
        let props1 = EffectProperties(backgroundOpacity: 0.8, backgroundBlurRadius: 10.0, borderOpacity: 0.9)
        let props2 = EffectProperties(backgroundOpacity: 0.8, backgroundBlurRadius: 10.0, borderOpacity: 0.9)

        // Then hash values should be equal
        expect(props1.hashValue) == props2.hashValue
    }

    // MARK: - DefaultInitializable Tests

    func testConformsToDefaultInitializable() {
        // When using default initializer
        let props = EffectProperties()

        // Then should be valid instance
        expect(props).toNot(beNil())
    }

    // MARK: - Sendable Tests

    func testSendableConformance() {
        // EffectProperties conforms to Sendable
        Task { @MainActor in
            let props = EffectProperties(backgroundOpacity: 0.8, backgroundBlurRadius: 10.0, borderOpacity: 0.9)
            // If this compiles, Sendable conformance is working
            expect(props).toNot(beNil())
        }
    }

    // MARK: - Opacity Value Tests

    func testOpacityAtZero() {
        // Given zero opacity (fully transparent)
        let props = EffectProperties(backgroundOpacity: 0.0, backgroundBlurRadius: 10.0, borderOpacity: 0.0)

        // Then should be valid
        expect(props.backgroundOpacity) == 0.0
        expect(props.borderOpacity) == 0.0
    }

    func testOpacityAtOne() {
        // Given full opacity
        let props = EffectProperties(backgroundOpacity: 1.0, backgroundBlurRadius: 10.0, borderOpacity: 1.0)

        // Then should be valid
        expect(props.backgroundOpacity) == 1.0
        expect(props.borderOpacity) == 1.0
    }

    func testOpacityOutOfStandardRange() {
        // Given opacity values outside 0-1 (technically invalid but type allows)
        let props = EffectProperties(backgroundOpacity: 1.5, backgroundBlurRadius: 10.0, borderOpacity: -0.5)

        // Then should store the values (validation happens at UI level)
        expect(props.backgroundOpacity) == 1.5
        expect(props.borderOpacity) == -0.5
    }

    // MARK: - Blur Radius Tests

    func testBlurRadiusAtZero() {
        // Given zero blur (no blur)
        let props = EffectProperties(backgroundOpacity: 0.8, backgroundBlurRadius: 0.0, borderOpacity: 0.9)

        // Then should be valid
        expect(props.backgroundBlurRadius) == 0.0
    }

    func testBlurRadiusVeryLarge() {
        // Given very large blur radius
        let props = EffectProperties(backgroundOpacity: 0.8, backgroundBlurRadius: 100.0, borderOpacity: 0.9)

        // Then should handle large values
        expect(props.backgroundBlurRadius) == 100.0
    }

    func testBlurRadiusNegative() {
        // Given negative blur (technically invalid but type allows)
        let props = EffectProperties(backgroundOpacity: 0.8, backgroundBlurRadius: -5.0, borderOpacity: 0.9)

        // Then should store the value
        expect(props.backgroundBlurRadius) == -5.0
    }

    // MARK: - Precision Tests

    func testFloatingPointPrecision() {
        // Given values with many decimal places
        let props = EffectProperties(
            backgroundOpacity: 0.123456789,
            backgroundBlurRadius: 10.987654321,
            borderOpacity: 0.555555555
        )

        // Then should preserve values
        expect(props.backgroundOpacity).to(beCloseTo(0.123456789, within: 0.00000001))
        expect(props.backgroundBlurRadius).to(beCloseTo(10.987654321, within: 0.00000001))
        expect(props.borderOpacity).to(beCloseTo(0.555555555, within: 0.00000001))
    }

    func testCodingPreservesFloatingPointPrecision() throws {
        // Given precise floating point values
        let original = EffectProperties(
            backgroundOpacity: 0.123456789,
            backgroundBlurRadius: 10.987654321,
            borderOpacity: 0.555555555
        )

        // When encoding and decoding
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(EffectProperties.self, from: data)

        // Then should preserve precision
        expect(decoded.backgroundOpacity).to(beCloseTo(original.backgroundOpacity, within: 0.00001))
        expect(decoded.backgroundBlurRadius).to(beCloseTo(original.backgroundBlurRadius, within: 0.00001))
        expect(decoded.borderOpacity).to(beCloseTo(original.borderOpacity, within: 0.00001))
    }

    // MARK: - Edge Cases

    func testAllMinimumValues() {
        // Given minimum values
        let props = EffectProperties(
            backgroundOpacity: 0.0,
            backgroundBlurRadius: 0.0,
            borderOpacity: 0.0
        )

        // Then should be valid
        expect(props.backgroundOpacity) == 0.0
        expect(props.backgroundBlurRadius) == 0.0
        expect(props.borderOpacity) == 0.0
    }

    func testAllMaximumStandardValues() {
        // Given maximum standard values
        let props = EffectProperties(
            backgroundOpacity: 1.0,
            backgroundBlurRadius: 50.0,
            borderOpacity: 1.0
        )

        // Then should be valid
        expect(props.backgroundOpacity) == 1.0
        expect(props.backgroundBlurRadius) == 50.0
        expect(props.borderOpacity) == 1.0
    }

    func testJSONStructure() throws {
        // Given effect properties
        let props = EffectProperties(
            backgroundOpacity: 0.8,
            backgroundBlurRadius: 10.5,
            borderOpacity: 0.9
        )

        // When encoding to JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(props)
        let jsonString = String(bytes: data, encoding: .utf8) ?? ""

        // Then should have correct structure
        expect(jsonString.contains("\"background-blur-radius\"")) == true
        expect(jsonString.contains("\"background-opacity\"")) == true
        expect(jsonString.contains("\"border-opacity\"")) == true
        expect(jsonString.contains("0.8")) == true
        expect(jsonString.contains("10.5")) == true
        expect(jsonString.contains("0.9")) == true
    }

    func testMultipleInstancesInArray() {
        // Given multiple effect properties
        let properties = [
            EffectProperties(backgroundOpacity: 0.5, backgroundBlurRadius: 5.0, borderOpacity: 0.6),
            EffectProperties(backgroundOpacity: 0.7, backgroundBlurRadius: 10.0, borderOpacity: 0.8),
            EffectProperties(backgroundOpacity: 0.9, backgroundBlurRadius: 15.0, borderOpacity: 1.0)
        ]

        // Then should maintain distinct values
        expect(properties.count) == 3
        expect(properties[0].backgroundOpacity) == 0.5
        expect(properties[1].backgroundOpacity) == 0.7
        expect(properties[2].backgroundOpacity) == 0.9
    }

    func testTypicalUIValues() {
        // Given typical UI effect values
        let props = EffectProperties(
            backgroundOpacity: 0.85, // Slightly transparent
            backgroundBlurRadius: 12.0, // Moderate blur
            borderOpacity: 0.95 // Almost opaque border
        )

        // Then should represent realistic UI configuration
        expect(props.backgroundOpacity) > 0.0
        expect(props.backgroundOpacity) < 1.0
        expect(props.backgroundBlurRadius) > 0.0
        expect(props.borderOpacity) > 0.0
        expect(props.borderOpacity) < 1.0
    }
}
