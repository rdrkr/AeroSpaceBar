// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

@testable import Domain
import Nimble
import XCTest

/// Tests for OptionalMode phantom type.
///
/// These tests verify:
/// - OptionalTypeMapping protocol conformance
/// - All type aliases are optional (Optional<T>)
/// - Type mapping for configuration parsing
final class OptionalModeTests: XCTestCase {
    // MARK: - Protocol Conformance Tests

    func testConformsToOptionalTypeMapping() {
        // Given/When/Then - Should compile
        let _: any OptionalTypeMapping.Type = OptionalMode.self
    }

    // MARK: - Type Alias Tests

    func testBoolTypeIsOptional() {
        // Given/When
        let value: OptionalMode.BoolType = nil

        // Then
        expect(value).to(beNil())
        expect(String(describing: OptionalMode.BoolType.self)) == String(describing: Bool?.self)
    }

    func testStringTypeIsOptional() {
        // Given/When
        let value: OptionalMode.StringType = nil

        // Then
        expect(value).to(beNil())
        expect(String(describing: OptionalMode.StringType.self)) == String(describing: String?.self)
    }

    func testThemeModeTypeIsOptional() {
        // Given/When
        let value: OptionalMode.ThemeModeType = nil

        // Then
        expect(value).to(beNil())
        expect(String(describing: OptionalMode.ThemeModeType.self)) == String(describing: ThemeMode?.self)
    }

    func testThemePresetColorPropertiesTypeIsOptional() {
        // Given/When
        let value: OptionalMode.ThemePresetColorPropertiesType = nil

        // Then
        expect(value).to(beNil())
        expect(String(describing: OptionalMode.ThemePresetColorPropertiesType.self)) ==
            String(describing: ThemePresetColorProperties?.self)
    }

    func testColorPropertiesArrayTypeIsOptional() {
        // Given/When
        let value: OptionalMode.ColorPropertiesArrayType = nil

        // Then
        expect(value).to(beNil())
        expect(String(describing: OptionalMode.ColorPropertiesArrayType.self)) ==
            String(describing: [ColorProperties]?.self)
    }

    func testGeometricPropertiesArrayTypeIsOptional() {
        // Given/When
        let value: OptionalMode.GeometricPropertiesArrayType = nil

        // Then
        expect(value).to(beNil())
        expect(String(describing: OptionalMode.GeometricPropertiesArrayType.self)) ==
            String(describing: [GeometricProperties]?.self)
    }

    func testEffectPropertiesArrayTypeIsOptional() {
        // Given/When
        let value: OptionalMode.EffectPropertiesArrayType = nil

        // Then
        expect(value).to(beNil())
        expect(String(describing: OptionalMode.EffectPropertiesArrayType.self)) ==
            String(describing: [EffectProperties]?.self)
    }

    func testGroupArrayTypeIsOptional() {
        // Given/When
        let value: OptionalMode.GroupArrayType = nil

        // Then
        expect(value).to(beNil())
        expect(String(describing: OptionalMode.GroupArrayType.self)) == String(describing: [Domain.Group]?.self)
    }

    func testColorPropertiesTypeIsOptional() {
        // Given/When
        let value: OptionalMode.ColorPropertiesType = nil

        // Then
        expect(value).to(beNil())
        expect(String(describing: OptionalMode.ColorPropertiesType.self)) == String(describing: ColorProperties?.self)
    }

    func testGeometricPropertiesTypeIsOptional() {
        // Given/When
        let value: OptionalMode.GeometricPropertiesType = nil

        // Then
        expect(value).to(beNil())
        expect(String(describing: OptionalMode.GeometricPropertiesType.self)) ==
            String(describing: GeometricProperties?.self)
    }

    func testEffectPropertiesTypeIsOptional() {
        // Given/When
        let value: OptionalMode.EffectPropertiesType = nil

        // Then
        expect(value).to(beNil())
        expect(String(describing: OptionalMode.EffectPropertiesType.self)) == String(describing: EffectProperties?.self)
    }

    // MARK: - Usage Tests

    func testOptionalModeUsageForTOMLParsing() {
        // Given - Simulating TOML parsing where fields may be missing
        let boolValue: OptionalMode.BoolType = nil
        let stringValue: OptionalMode.StringType = "test"
        let arrayValue: OptionalMode.ColorPropertiesArrayType = []

        // When/Then - Should handle nil and non-nil values
        expect(boolValue).to(beNil())
        expect(stringValue) == "test"
        expect(arrayValue?.isEmpty) == true
    }
}
