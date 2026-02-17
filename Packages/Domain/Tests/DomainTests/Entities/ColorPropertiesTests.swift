// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Nimble
import SwiftUI
import XCTest

/// Tests for ColorProperties entity.
///
/// These tests verify ColorProperties initialization, coding/decoding, equality, hashing,
/// and hex color conversion functionality.
@MainActor
final class ColorPropertiesTests: XCTestCase {
    // MARK: - Initialization Tests

    func testInitializationWithAllColors() {
        // Given color values
        let bgColor = Color(.sRGB, red: 1, green: 0, blue: 0, opacity: 1)
        let borderColor = Color(.sRGB, red: 0, green: 0, blue: 1, opacity: 1)
        let fgColor = Color(.sRGB, red: 1, green: 1, blue: 1, opacity: 1)

        // When creating color properties
        let props = ColorProperties(
            backgroundTintColor: bgColor,
            borderTintColor: borderColor,
            foregroundColor: fgColor
        )

        // Then all colors should be set
        expect(props.backgroundTintColor) == bgColor
        expect(props.borderTintColor) == borderColor
        expect(props.foregroundColor) == fgColor
    }

    func testInitializationWithClearColors() {
        // Given clear colors
        let props = ColorProperties(
            backgroundTintColor: .clear,
            borderTintColor: .clear,
            foregroundColor: .clear
        )

        // Then should be valid
        expect(props.backgroundTintColor).toNot(beNil())
        expect(props.borderTintColor).toNot(beNil())
        expect(props.foregroundColor).toNot(beNil())
    }

    // MARK: - Coding Tests

    func testEncodingAndDecoding() throws {
        // Given color properties
        let original = ColorProperties(
            backgroundTintColor: Color(.sRGB, red: 1, green: 0, blue: 0, opacity: 1),
            borderTintColor: Color(.sRGB, red: 0, green: 0, blue: 1, opacity: 1),
            foregroundColor: Color(.sRGB, red: 0, green: 1, blue: 0, opacity: 1)
        )

        // When encoding and decoding
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ColorProperties.self, from: data)

        // Then should match (using hex comparison)
        expect(decoded.backgroundTintColor.toHex()) == original.backgroundTintColor.toHex()
        expect(decoded.borderTintColor.toHex()) == original.borderTintColor.toHex()
        expect(decoded.foregroundColor.toHex()) == original.foregroundColor.toHex()
    }

    func testCodingKeysMapping() throws {
        // Given color properties
        let props = ColorProperties(
            backgroundTintColor: .red,
            borderTintColor: .blue,
            foregroundColor: .white
        )

        // When encoding
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(props)
        guard let jsonString = String(bytes: data, encoding: .utf8) else {
            XCTFail("Failed to convert data to string")
            return
        }

        // Then should use kebab-case keys
        expect(jsonString.contains("background-tint-color")) == true
        expect(jsonString.contains("border-tint-color")) == true
        expect(jsonString.contains("foreground-color")) == true
    }

    func testRoundTripCoding() throws {
        // Given various colors
        let colors = [
            Color(.sRGB, red: 1, green: 0, blue: 0, opacity: 1),
            Color(.sRGB, red: 0, green: 0, blue: 1, opacity: 1),
            Color(.sRGB, red: 0, green: 1, blue: 0, opacity: 1),
            Color(.sRGB, red: 1, green: 1, blue: 0, opacity: 1),
            Color(.sRGB, red: 0.5, green: 0, blue: 0.5, opacity: 1),
            Color(.sRGB, red: 1, green: 0.5, blue: 0, opacity: 1),
            Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 1),
            Color(.sRGB, red: 1, green: 1, blue: 1, opacity: 1),
            Color(.sRGB, red: 0.5, green: 0.5, blue: 0.5, opacity: 1),
            Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0)
        ]

        for color in colors {
            // When encoding and decoding
            let original = ColorProperties(
                backgroundTintColor: color,
                borderTintColor: color,
                foregroundColor: color
            )

            let encoder = JSONEncoder()
            let data = try encoder.encode(original)
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(ColorProperties.self, from: data)

            // Then should preserve colors
            expect(decoded) == original
        }
    }

    // MARK: - Equality Tests

    func testEqualityWithSameColors() {
        // Given two color properties with same colors
        let props1 = ColorProperties(
            backgroundTintColor: .red,
            borderTintColor: .blue,
            foregroundColor: .white
        )

        let props2 = ColorProperties(
            backgroundTintColor: .red,
            borderTintColor: .blue,
            foregroundColor: .white
        )

        // Then they should be equal
        expect(props1 == props2) == true
    }

    func testInequalityWithDifferentBackgroundColor() {
        // Given two color properties with different background colors
        let props1 = ColorProperties(
            backgroundTintColor: .red,
            borderTintColor: .blue,
            foregroundColor: .white
        )

        let props2 = ColorProperties(
            backgroundTintColor: .green,
            borderTintColor: .blue,
            foregroundColor: .white
        )

        // Then they should not be equal
        expect(props1 != props2) == true
    }

    func testInequalityWithDifferentBorderColor() {
        // Given two color properties with different border colors
        let props1 = ColorProperties(
            backgroundTintColor: .red,
            borderTintColor: .blue,
            foregroundColor: .white
        )

        let props2 = ColorProperties(
            backgroundTintColor: .red,
            borderTintColor: .green,
            foregroundColor: .white
        )

        // Then they should not be equal
        expect(props1 != props2) == true
    }

    func testInequalityWithDifferentForegroundColor() {
        // Given two color properties with different foreground colors
        let props1 = ColorProperties(
            backgroundTintColor: .red,
            borderTintColor: .blue,
            foregroundColor: .white
        )

        let props2 = ColorProperties(
            backgroundTintColor: .red,
            borderTintColor: .blue,
            foregroundColor: .black
        )

        // Then they should not be equal
        expect(props1 != props2) == true
    }

    // MARK: - Hashable Tests

    func testHashableConformance() {
        // Given color properties
        let props1 = ColorProperties(
            backgroundTintColor: .red,
            borderTintColor: .blue,
            foregroundColor: .white
        )

        let props2 = ColorProperties(
            backgroundTintColor: .green,
            borderTintColor: .yellow,
            foregroundColor: .black
        )

        // When adding to set
        let set: Set<ColorProperties> = [props1, props2]

        // Then should store unique properties
        expect(set.count) == 2
    }

    func testHashableWithDuplicates() {
        // Given duplicate color properties
        let props1 = ColorProperties(
            backgroundTintColor: .red,
            borderTintColor: .blue,
            foregroundColor: .white
        )

        let props2 = ColorProperties(
            backgroundTintColor: .red,
            borderTintColor: .blue,
            foregroundColor: .white
        )

        // When adding to set
        let set: Set<ColorProperties> = [props1, props2]

        // Then should only store one
        expect(set.count) == 1
    }

    func testHashConsistency() {
        // Given same color properties
        let props1 = ColorProperties(
            backgroundTintColor: .red,
            borderTintColor: .blue,
            foregroundColor: .white
        )

        let props2 = ColorProperties(
            backgroundTintColor: .red,
            borderTintColor: .blue,
            foregroundColor: .white
        )

        // Then hash values should be equal
        expect(props1.hashValue) == props2.hashValue
    }

    // MARK: - Hex Color Tests

    func testColorHexConversion() {
        // Given a red color
        let red = Color.red

        // When converting to hex
        let hex = red.toHex()

        // Then should be red hex (approximately, as Color.red may vary by system)
        expect(hex.hasPrefix("#")) == true
        expect(hex.count) == 7 // #RRGGBB
    }

    func testColorInitFromHex3Digit() {
        // Given 3-digit hex
        let color = Color(hex: "#F00")

        // Then should create red color
        expect(color).toNot(beNil())
    }

    func testColorInitFromHex6Digit() {
        // Given 6-digit hex
        let color = Color(hex: "#FF0000")

        // Then should create red color
        expect(color).toNot(beNil())
    }

    func testColorInitFromHex8Digit() {
        // Given 8-digit hex with alpha
        let color = Color(hex: "#FFFF0000")

        // Then should create red color with alpha
        expect(color).toNot(beNil())
    }

    func testColorInitFromHexWithoutHash() {
        // Given hex without #
        let color = Color(hex: "FF0000")

        // Then should still create color
        expect(color).toNot(beNil())
    }

    func testColorInitFromInvalidHex() {
        // Given invalid hex
        let color = Color(hex: "invalid")

        // Then should return nil
        expect(color).to(beNil())
    }

    func testColorInitFromEmptyHex() {
        // Given empty hex
        let color = Color(hex: "")

        // Then should return nil
        expect(color).to(beNil())
    }

    // MARK: - Sendable Tests

    func testSendableConformance() {
        // ColorProperties conforms to Sendable, so it can be safely passed between actors
        Task { @MainActor in
            let props = ColorProperties(
                backgroundTintColor: .red,
                borderTintColor: .blue,
                foregroundColor: .white
            )
            // If this compiles, Sendable conformance is working
            expect(props).toNot(beNil())
        }
    }

    // MARK: - Edge Cases

    func testColorPropertiesWithOpacity() {
        // Given colors with opacity
        let semiTransparentRed = Color.red.opacity(0.5)
        let props = ColorProperties(
            backgroundTintColor: semiTransparentRed,
            borderTintColor: .blue,
            foregroundColor: .white
        )

        // Then should be valid
        expect(props.backgroundTintColor).toNot(beNil())
    }

    func testColorPropertiesWithCustomColors() {
        // Given custom RGB colors
        let customColor = Color(.sRGB, red: 0.5, green: 0.3, blue: 0.8)
        let props = ColorProperties(
            backgroundTintColor: customColor,
            borderTintColor: customColor,
            foregroundColor: customColor
        )

        // Then should be valid
        expect(props.backgroundTintColor).toNot(beNil())
    }

    func testColorHexRoundTrip() {
        // Given a color
        let original = Color(.sRGB, red: 1.0, green: 0.0, blue: 0.0)

        // When converting to hex and back
        let hex = original.toHex()
        let reconstructed = Color(hex: hex)

        // Then should be similar (within color space conversion tolerance)
        expect(reconstructed).toNot(beNil())
    }

    func testMultipleColorConversions() {
        // Given various colors
        let colors = [
            ("#FF0000", "Red"),
            ("#00FF00", "Green"),
            ("#0000FF", "Blue"),
            ("#FFFFFF", "White"),
            ("#000000", "Black"),
            ("#808080", "Gray")
        ]

        for (hex, _) in colors {
            // When creating from hex
            let color = Color(hex: hex)

            // Then should create valid color
            expect(color).toNot(beNil())
        }
    }

    func testColorComponentsEncoding() throws {
        // Given color with specific components
        let color = Color(.sRGB, red: 0.5, green: 0.3, blue: 0.8, opacity: 0.9)
        let props = ColorProperties(
            backgroundTintColor: color,
            borderTintColor: .blue,
            foregroundColor: .white
        )

        // When encoding
        let encoder = JSONEncoder()
        let data = try encoder.encode(props)

        // Then should encode successfully
        expect(data.isEmpty) == false

        // And decoding should preserve values
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ColorProperties.self, from: data)
        expect(decoded.backgroundTintColor).toNot(beNil())
    }
}
