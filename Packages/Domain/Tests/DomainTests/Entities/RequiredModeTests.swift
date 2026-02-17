// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

@testable import Domain
import Nimble
import XCTest

/// Tests for RequiredMode phantom type.
///
/// These tests verify:
/// - Protocol conformance to OptionalTypeMapping
/// - Type alias definitions
/// - Phantom type behavior
final class RequiredModeTests: XCTestCase {
    // MARK: - Protocol Conformance Tests

    func testOptionalTypeMappingConformance() {
        // Given/When/Then - Should compile
        let _: any OptionalTypeMapping.Type = RequiredMode.self
    }

    // MARK: - Type Alias Tests

    func testBoolType() {
        // Given
        let value: RequiredMode.BoolType? = nil

        // Then
        expect(value).to(beNil())
        expect(RequiredMode.BoolType.self == Bool.self) == true
    }

    func testStringType() {
        // Given
        let value: RequiredMode.StringType? = nil

        // Then
        expect(value).to(beNil())
        expect(RequiredMode.StringType.self == String.self) == true
    }

    func testThemeModeType() {
        // Given
        let value: RequiredMode.ThemeModeType? = nil

        // Then
        expect(value).to(beNil())
        expect(RequiredMode.ThemeModeType.self == ThemeMode.self) == true
    }

    func testThemePresetColorPropertiesType() {
        // Given
        let value: RequiredMode.ThemePresetColorPropertiesType? = nil

        // Then
        expect(value).to(beNil())
        expect(RequiredMode.ThemePresetColorPropertiesType.self == ThemePresetColorProperties.self) == true
    }

    func testColorPropertiesArrayType() {
        // Given
        let value: RequiredMode.ColorPropertiesArrayType? = nil

        // Then
        expect(value).to(beNil())
        expect(RequiredMode.ColorPropertiesArrayType.self == [ColorProperties].self) == true
    }

    func testGeometricPropertiesArrayType() {
        // Given
        let value: RequiredMode.GeometricPropertiesArrayType? = nil

        // Then
        expect(value).to(beNil())
        expect(RequiredMode.GeometricPropertiesArrayType.self == [GeometricProperties].self) == true
    }

    func testEffectPropertiesArrayType() {
        // Given
        let value: RequiredMode.EffectPropertiesArrayType? = nil

        // Then
        expect(value).to(beNil())
        expect(RequiredMode.EffectPropertiesArrayType.self == [EffectProperties].self) == true
    }

    func testGroupArrayType() {
        // Given
        let value: RequiredMode.GroupArrayType? = nil

        // Then
        expect(value).to(beNil())
        expect(RequiredMode.GroupArrayType.self == [Domain.Group].self) == true
    }

    func testColorPropertiesType() {
        // Given
        let value: RequiredMode.ColorPropertiesType? = nil

        // Then
        expect(value).to(beNil())
        expect(RequiredMode.ColorPropertiesType.self == ColorProperties.self) == true
    }

    func testGeometricPropertiesType() {
        // Given
        let value: RequiredMode.GeometricPropertiesType? = nil

        // Then
        expect(value).to(beNil())
        expect(RequiredMode.GeometricPropertiesType.self == GeometricProperties.self) == true
    }

    func testEffectPropertiesType() {
        // Given
        let value: RequiredMode.EffectPropertiesType? = nil

        // Then
        expect(value).to(beNil())
        expect(RequiredMode.EffectPropertiesType.self == EffectProperties.self) == true
    }
}
