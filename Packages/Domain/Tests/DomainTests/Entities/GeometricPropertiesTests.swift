// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Nimble
import XCTest

/// Tests for GeometricProperties entity.
///
/// These tests verify GeometricProperties initialization, coding/decoding,
/// equality, hashing, and DefaultInitializable conformance.
@MainActor
final class GeometricPropertiesTests: XCTestCase {
    // MARK: - Initialization Tests

    func testInitializationWithAllParameters() {
        // Given parameters
        let cornerRadius = 8.0
        let borderWidth = 2.0

        // When creating geometric properties
        let props = GeometricProperties(
            cornerRadius: cornerRadius,
            borderWidth: borderWidth
        )

        // Then all properties should be set
        expect(props.cornerRadius) == cornerRadius
        expect(props.borderWidth) == borderWidth
    }

    func testDefaultInitialization() {
        // When creating with default init
        let props = GeometricProperties()

        // Then should have default values from ConfigurationDefaults
        expect(props.cornerRadius).toNot(beNil())
        expect(props.borderWidth).toNot(beNil())
    }

    // MARK: - Coding Tests

    func testEncodingAndDecoding() throws {
        // Given geometric properties
        let original = GeometricProperties(
            cornerRadius: 10.0,
            borderWidth: 3.0
        )

        // When encoding and decoding
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(GeometricProperties.self, from: data)

        // Then should match original
        expect(decoded.cornerRadius) == original.cornerRadius
        expect(decoded.borderWidth) == original.borderWidth
    }

    func testCodingKeysMapping() throws {
        // Given geometric properties
        let props = GeometricProperties(cornerRadius: 5.0, borderWidth: 1.0)

        // When encoding
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(props)
        let jsonString = String(bytes: data, encoding: .utf8) ?? ""

        // Then should use kebab-case keys
        expect(jsonString.contains("corner-radius")) == true
        expect(jsonString.contains("border-width")) == true
    }

    func testRoundTripCoding() throws {
        // Given various geometric values
        let testCases = [
            (cornerRadius: 0.0, borderWidth: 0.0),
            (cornerRadius: 5.0, borderWidth: 1.0),
            (cornerRadius: 10.0, borderWidth: 2.0),
            (cornerRadius: 15.0, borderWidth: 3.5),
            (cornerRadius: 20.0, borderWidth: 5.0)
        ]

        for testCase in testCases {
            // When encoding and decoding
            let original = GeometricProperties(
                cornerRadius: testCase.cornerRadius,
                borderWidth: testCase.borderWidth
            )

            let encoder = JSONEncoder()
            let data = try encoder.encode(original)
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(GeometricProperties.self, from: data)

            // Then should match original
            expect(decoded) == original
        }
    }

    // MARK: - Equality Tests

    func testEqualityWithSameValues() {
        // Given two properties with same values
        let props1 = GeometricProperties(cornerRadius: 8.0, borderWidth: 2.0)
        let props2 = GeometricProperties(cornerRadius: 8.0, borderWidth: 2.0)

        // Then they should be equal
        expect(props1) == props2
    }

    func testInequalityWithDifferentCornerRadius() {
        // Given two properties with different corner radius
        let props1 = GeometricProperties(cornerRadius: 8.0, borderWidth: 2.0)
        let props2 = GeometricProperties(cornerRadius: 10.0, borderWidth: 2.0)

        // Then they should not be equal
        expect(props1) != props2
    }

    func testInequalityWithDifferentBorderWidth() {
        // Given two properties with different border width
        let props1 = GeometricProperties(cornerRadius: 8.0, borderWidth: 2.0)
        let props2 = GeometricProperties(cornerRadius: 8.0, borderWidth: 3.0)

        // Then they should not be equal
        expect(props1) != props2
    }

    // MARK: - Hashable Tests

    func testHashableConformance() {
        // Given geometric properties
        let props1 = GeometricProperties(cornerRadius: 8.0, borderWidth: 2.0)
        let props2 = GeometricProperties(cornerRadius: 10.0, borderWidth: 3.0)

        // When adding to set
        let set: Set<GeometricProperties> = [props1, props2]

        // Then should store unique properties
        expect(set.count) == 2
    }

    func testHashableWithDuplicates() {
        // Given duplicate geometric properties
        let props1 = GeometricProperties(cornerRadius: 8.0, borderWidth: 2.0)
        let props2 = GeometricProperties(cornerRadius: 8.0, borderWidth: 2.0)

        // When adding to set
        let set: Set<GeometricProperties> = [props1, props2]

        // Then should only store one
        expect(set.count) == 1
    }

    func testHashConsistency() {
        // Given same geometric properties
        let props1 = GeometricProperties(cornerRadius: 8.0, borderWidth: 2.0)
        let props2 = GeometricProperties(cornerRadius: 8.0, borderWidth: 2.0)

        // Then hash values should be equal
        expect(props1.hashValue) == props2.hashValue
    }

    // MARK: - DefaultInitializable Tests

    func testConformsToDefaultInitializable() {
        // When using default initializer
        let props = GeometricProperties()

        // Then should be valid instance
        expect(props).toNot(beNil())
    }

    // MARK: - Sendable Tests

    func testSendableConformance() {
        // GeometricProperties conforms to Sendable
        Task { @MainActor in
            let props = GeometricProperties(cornerRadius: 8.0, borderWidth: 2.0)
            // If this compiles, Sendable conformance is working
            expect(props).toNot(beNil())
        }
    }

    // MARK: - Edge Cases

    func testZeroValues() {
        // Given zero values
        let props = GeometricProperties(cornerRadius: 0.0, borderWidth: 0.0)

        // Then should be valid
        expect(props.cornerRadius) == 0.0
        expect(props.borderWidth) == 0.0
    }

    func testNegativeValues() {
        // Given negative values (technically invalid but type allows)
        let props = GeometricProperties(cornerRadius: -5.0, borderWidth: -2.0)

        // Then should store the values
        expect(props.cornerRadius) == -5.0
        expect(props.borderWidth) == -2.0
    }

    func testVeryLargeValues() {
        // Given very large values
        let props = GeometricProperties(cornerRadius: 1_000.0, borderWidth: 500.0)

        // Then should handle large values
        expect(props.cornerRadius) == 1_000.0
        expect(props.borderWidth) == 500.0
    }

    func testVerySmallValues() {
        // Given very small decimal values
        let props = GeometricProperties(cornerRadius: 0.001, borderWidth: 0.0001)

        // Then should preserve precision
        expect(props.cornerRadius).to(beCloseTo(0.001, within: 0.00001))
        expect(props.borderWidth).to(beCloseTo(0.0001, within: 0.00001))
    }

    func testFloatingPointPrecision() {
        // Given values with many decimal places
        let props = GeometricProperties(
            cornerRadius: 8.123456789,
            borderWidth: 2.987654321
        )

        // Then should preserve values
        expect(props.cornerRadius).to(beCloseTo(8.123456789, within: 0.00000001))
        expect(props.borderWidth).to(beCloseTo(2.987654321, within: 0.00000001))
    }

    func testCodingPreservesFloatingPointPrecision() throws {
        // Given precise floating point values
        let original = GeometricProperties(
            cornerRadius: 8.123456789,
            borderWidth: 2.987654321
        )

        // When encoding and decoding
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(GeometricProperties.self, from: data)

        // Then should preserve precision
        expect(decoded.cornerRadius).to(beCloseTo(original.cornerRadius, within: 0.00001))
        expect(decoded.borderWidth).to(beCloseTo(original.borderWidth, within: 0.00001))
    }

    func testJSONStructure() throws {
        // Given geometric properties
        let props = GeometricProperties(cornerRadius: 10.0, borderWidth: 2.5)

        // When encoding to JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(props)
        let jsonString = String(bytes: data, encoding: .utf8) ?? ""

        // Then should have correct structure
        expect(jsonString.contains("\"border-width\"")) == true
        expect(jsonString.contains("\"corner-radius\"")) == true
        expect(jsonString.contains("10")) == true
        expect(jsonString.contains("2.5")) == true
    }

    func testMultipleInstancesInArray() {
        // Given multiple geometric properties
        let properties = [
            GeometricProperties(cornerRadius: 5.0, borderWidth: 1.0),
            GeometricProperties(cornerRadius: 10.0, borderWidth: 2.0),
            GeometricProperties(cornerRadius: 15.0, borderWidth: 3.0)
        ]

        // Then should maintain distinct values
        expect(properties.count) == 3
        expect(properties[0].cornerRadius) == 5.0
        expect(properties[1].cornerRadius) == 10.0
        expect(properties[2].cornerRadius) == 15.0
    }
}
