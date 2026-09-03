// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Nimble
import SwiftUI
import XCTest

/// Tests for SpacesSettings class.
///
/// These tests verify SpacesSettings with both OptionalMode and RequiredMode,
/// decode() merging logic, per-space properties arrays, and type aliases.
@MainActor
final class SpacesSettingsTests: XCTestCase {
    // MARK: - RequiredMode Initialization Tests

    func testRequiredModeInitialization() {
        // Given required mode parameters
        let showEmptySpaces = true
        let colorProps = [ConfigurationDefaults.spaceColorProperties, ConfigurationDefaults.spaceColorProperties]
        let geometricProps = [GeometricProperties(), GeometricProperties()]
        let effectProps = [EffectProperties(), EffectProperties()]
        let appearanceMode = "per-space"
        let globalColor = ConfigurationDefaults.spaceColorProperties
        let globalGeometric = GeometricProperties()
        let globalEffect = EffectProperties()

        // When creating required settings
        let settings = SpacesSettings<RequiredMode>(
            showEmptySpaces: showEmptySpaces,
            hiddenSpaces: [],
            spacesColorProperties: colorProps,
            spacesGeometricProperties: geometricProps,
            spacesEffectProperties: effectProps,
            spacesAppearanceMode: appearanceMode,
            globalSpacesColorProperties: globalColor,
            globalSpacesGeometricProperties: globalGeometric,
            globalSpacesEffectProperties: globalEffect,

            showAppleButtonAsSpace: ConfigurationDefaults.showAppleButtonAsSpace,
            appleButtonColorProperties: ConfigurationDefaults.appleButtonColorProperties,
            appleButtonGeometricProperties: ConfigurationDefaults.appleButtonGeometricProperties,
            appleButtonEffectProperties: ConfigurationDefaults.appleButtonEffectProperties
        )

        // Then all properties should be set
        expect(settings.showEmptySpaces) == showEmptySpaces
        expect(settings.spacesColorProperties) == colorProps
        expect(settings.spacesGeometricProperties) == geometricProps
        expect(settings.spacesEffectProperties) == effectProps
        expect(settings.spacesAppearanceMode) == appearanceMode
        expect(settings.globalSpacesColorProperties) == globalColor
        expect(settings.globalSpacesGeometricProperties) == globalGeometric
        expect(settings.globalSpacesEffectProperties) == globalEffect
    }

    // MARK: - OptionalMode Initialization Tests

    func testOptionalModeInitializationWithValues() {
        // Given optional mode parameters
        let showEmptySpaces: Bool? = false
        let colorProps: [ColorProperties]? = [ConfigurationDefaults.spaceColorProperties]
        let geometricProps: [GeometricProperties]? = [GeometricProperties()]
        let effectProps: [EffectProperties]? = [EffectProperties()]
        let appearanceMode: String? = "all-spaces"
        let globalColor: ColorProperties? = ConfigurationDefaults.spaceColorProperties
        let globalGeometric: GeometricProperties? = GeometricProperties()
        let globalEffect: EffectProperties? = EffectProperties()

        // When creating optional settings
        let settings = SpacesSettings<OptionalMode>(
            showEmptySpaces: showEmptySpaces,
            hiddenSpaces: [],
            spacesColorProperties: colorProps,
            spacesGeometricProperties: geometricProps,
            spacesEffectProperties: effectProps,
            spacesAppearanceMode: appearanceMode,
            globalSpacesColorProperties: globalColor,
            globalSpacesGeometricProperties: globalGeometric,
            globalSpacesEffectProperties: globalEffect,

            showAppleButtonAsSpace: nil,
            appleButtonColorProperties: nil,
            appleButtonGeometricProperties: nil,
            appleButtonEffectProperties: nil
        )

        // Then all properties should be set
        expect(settings.showEmptySpaces) == showEmptySpaces
        expect(settings.spacesColorProperties) == colorProps
        expect(settings.spacesGeometricProperties) == geometricProps
        expect(settings.spacesEffectProperties) == effectProps
        expect(settings.spacesAppearanceMode) == appearanceMode
        expect(settings.globalSpacesColorProperties) == globalColor
        expect(settings.globalSpacesGeometricProperties) == globalGeometric
        expect(settings.globalSpacesEffectProperties) == globalEffect
    }

    func testOptionalModeInitializationWithNils() {
        // Given optional mode with nil values
        let settings = SpacesSettings<OptionalMode>(
            showEmptySpaces: nil,
            hiddenSpaces: nil,
            spacesColorProperties: nil,
            spacesGeometricProperties: nil,
            spacesEffectProperties: nil,
            spacesAppearanceMode: nil,
            globalSpacesColorProperties: nil,
            globalSpacesGeometricProperties: nil,
            globalSpacesEffectProperties: nil,

            showAppleButtonAsSpace: nil,
            appleButtonColorProperties: nil,
            appleButtonGeometricProperties: nil,
            appleButtonEffectProperties: nil
        )

        // Then all properties should be nil
        expect(settings.showEmptySpaces).to(beNil())
        expect(settings.spacesColorProperties).to(beNil())
        expect(settings.spacesGeometricProperties).to(beNil())
        expect(settings.spacesEffectProperties).to(beNil())
        expect(settings.spacesAppearanceMode).to(beNil())
        expect(settings.globalSpacesColorProperties).to(beNil())
        expect(settings.globalSpacesGeometricProperties).to(beNil())
        expect(settings.globalSpacesEffectProperties).to(beNil())
    }

    // MARK: - Decode Method Tests

    func testDecodeWithAllOptionalValuesNil() throws {
        // Given optional settings with all nil values
        let optional = SpacesSettings<OptionalMode>(
            showEmptySpaces: nil,
            hiddenSpaces: nil,
            spacesColorProperties: nil,
            spacesGeometricProperties: nil,
            spacesEffectProperties: nil,
            spacesAppearanceMode: nil,
            globalSpacesColorProperties: nil,
            globalSpacesGeometricProperties: nil,
            globalSpacesEffectProperties: nil,

            showAppleButtonAsSpace: nil,
            appleButtonColorProperties: nil,
            appleButtonGeometricProperties: nil,
            appleButtonEffectProperties: nil
        )

        // And default settings
        let defaultSettings = SpacesSettings<RequiredMode>(
            showEmptySpaces: false,
            hiddenSpaces: [],
            spacesColorProperties: [],
            spacesGeometricProperties: [],
            spacesEffectProperties: [],
            spacesAppearanceMode: "per-space",
            globalSpacesColorProperties: ConfigurationDefaults.spaceColorProperties,
            globalSpacesGeometricProperties: GeometricProperties(),
            globalSpacesEffectProperties: EffectProperties(),

            showAppleButtonAsSpace: ConfigurationDefaults.showAppleButtonAsSpace,
            appleButtonColorProperties: ConfigurationDefaults.appleButtonColorProperties,
            appleButtonGeometricProperties: ConfigurationDefaults.appleButtonGeometricProperties,
            appleButtonEffectProperties: ConfigurationDefaults.appleButtonEffectProperties
        )

        // When decoding
        let decoded = try SpacesSettings<RequiredMode>.decode(from: optional, defaultValue: defaultSettings)

        // Then should use all default values
        expect(decoded.showEmptySpaces) == defaultSettings.showEmptySpaces
        expect(decoded.spacesColorProperties) == defaultSettings.spacesColorProperties
        expect(decoded.spacesGeometricProperties) == defaultSettings.spacesGeometricProperties
        expect(decoded.spacesEffectProperties) == defaultSettings.spacesEffectProperties
        expect(decoded.spacesAppearanceMode) == defaultSettings.spacesAppearanceMode
        expect(decoded.globalSpacesColorProperties) == defaultSettings.globalSpacesColorProperties
        expect(decoded.globalSpacesGeometricProperties) == defaultSettings.globalSpacesGeometricProperties
        expect(decoded.globalSpacesEffectProperties) == defaultSettings.globalSpacesEffectProperties
    }

    func testDecodeWithAllOptionalValuesSet() throws {
        // Given optional settings with all values set
        let customColorProps = [
            ColorProperties(backgroundTintColor: .red, borderTintColor: .blue, foregroundColor: .white),
            ColorProperties(backgroundTintColor: .green, borderTintColor: .yellow, foregroundColor: .black)
        ]
        let customGeometricProps = [
            GeometricProperties(cornerRadius: 5, borderWidth: 1),
            GeometricProperties(cornerRadius: 10, borderWidth: 2)
        ]
        let customEffectProps = [
            EffectProperties(backgroundOpacity: 0.8, backgroundBlurRadius: 5, borderOpacity: 1.0),
            EffectProperties(backgroundOpacity: 0.6, backgroundBlurRadius: 10, borderOpacity: 0.8)
        ]

        let optional = SpacesSettings<OptionalMode>(
            showEmptySpaces: true,
            hiddenSpaces: [],
            spacesColorProperties: customColorProps,
            spacesGeometricProperties: customGeometricProps,
            spacesEffectProperties: customEffectProps,
            spacesAppearanceMode: "all-spaces",
            globalSpacesColorProperties: ColorProperties(
                backgroundTintColor: .blue,
                borderTintColor: .white,
                foregroundColor: .white
            ),
            globalSpacesGeometricProperties: GeometricProperties(cornerRadius: 8, borderWidth: 2),
            globalSpacesEffectProperties: EffectProperties(
                backgroundOpacity: 0.7,
                backgroundBlurRadius: 8,
                borderOpacity: 0.9
            ),

            showAppleButtonAsSpace: nil,
            appleButtonColorProperties: nil,
            appleButtonGeometricProperties: nil,
            appleButtonEffectProperties: nil
        )

        // And default settings (different values)
        let defaultSettings = SpacesSettings<RequiredMode>(
            showEmptySpaces: false,
            hiddenSpaces: [],
            spacesColorProperties: [],
            spacesGeometricProperties: [],
            spacesEffectProperties: [],
            spacesAppearanceMode: "per-space",
            globalSpacesColorProperties: ConfigurationDefaults.spaceColorProperties,
            globalSpacesGeometricProperties: GeometricProperties(),
            globalSpacesEffectProperties: EffectProperties(),

            showAppleButtonAsSpace: ConfigurationDefaults.showAppleButtonAsSpace,
            appleButtonColorProperties: ConfigurationDefaults.appleButtonColorProperties,
            appleButtonGeometricProperties: ConfigurationDefaults.appleButtonGeometricProperties,
            appleButtonEffectProperties: ConfigurationDefaults.appleButtonEffectProperties
        )

        // When decoding
        let decoded = try SpacesSettings<RequiredMode>.decode(from: optional, defaultValue: defaultSettings)

        // Then should use all optional values
        expect(decoded.showEmptySpaces) == true
        expect(decoded.spacesColorProperties) == customColorProps
        expect(decoded.spacesGeometricProperties) == customGeometricProps
        expect(decoded.spacesEffectProperties) == customEffectProps
        expect(decoded.spacesAppearanceMode) == "all-spaces"
        expect(decoded.globalSpacesColorProperties.backgroundTintColor) == Color.blue
        expect(decoded.globalSpacesGeometricProperties.cornerRadius) == 8
        expect(decoded.globalSpacesEffectProperties.backgroundOpacity) == 0.7
    }

    func testDecodeWithMixedOptionalValues() throws {
        // Given optional settings with mixed values
        _ = [
            ColorProperties(
                backgroundTintColor: .red,
                borderTintColor: .blue,
                foregroundColor: .white
            )
        ]

        let optional = SpacesSettings<OptionalMode>(
            showEmptySpaces: true,
            hiddenSpaces: [],
            spacesColorProperties: nil, // Will use default
            spacesGeometricProperties: [GeometricProperties(cornerRadius: 6, borderWidth: 1)],
            spacesEffectProperties: nil, // Will use default
            spacesAppearanceMode: "all-spaces",
            globalSpacesColorProperties: nil, // Will use default
            globalSpacesGeometricProperties: GeometricProperties(cornerRadius: 7, borderWidth: 2),
            globalSpacesEffectProperties: nil, // Will use default

            showAppleButtonAsSpace: nil,
            appleButtonColorProperties: nil,
            appleButtonGeometricProperties: nil,
            appleButtonEffectProperties: nil
        )

        // And default settings
        let defaultSettings = SpacesSettings<RequiredMode>(
            showEmptySpaces: false,
            hiddenSpaces: [],
            spacesColorProperties: [ConfigurationDefaults.spaceColorProperties],
            spacesGeometricProperties: [],
            spacesEffectProperties: [EffectProperties()],
            spacesAppearanceMode: "per-space",
            globalSpacesColorProperties: ConfigurationDefaults.spaceColorProperties,
            globalSpacesGeometricProperties: GeometricProperties(),
            globalSpacesEffectProperties: EffectProperties(),

            showAppleButtonAsSpace: ConfigurationDefaults.showAppleButtonAsSpace,
            appleButtonColorProperties: ConfigurationDefaults.appleButtonColorProperties,
            appleButtonGeometricProperties: ConfigurationDefaults.appleButtonGeometricProperties,
            appleButtonEffectProperties: ConfigurationDefaults.appleButtonEffectProperties
        )

        // When decoding
        let decoded = try SpacesSettings<RequiredMode>.decode(from: optional, defaultValue: defaultSettings)

        // Then should merge correctly
        expect(decoded.showEmptySpaces).to(beTrue(), description: "Should use optional value")
        expect(decoded.spacesColorProperties).to(
            equal(defaultSettings.spacesColorProperties),
            description: "Should use default value"
        )
        expect(decoded.spacesGeometricProperties.count) == 1
        expect(decoded.spacesGeometricProperties[0].cornerRadius) == 6
        expect(decoded.spacesEffectProperties).to(
            equal(defaultSettings.spacesEffectProperties),
            description: "Should use default value"
        )
        expect(decoded.spacesAppearanceMode) == "all-spaces"
        expect(decoded.globalSpacesColorProperties).to(
            equal(defaultSettings.globalSpacesColorProperties),
            description: "Should use default value"
        )
        expect(decoded.globalSpacesGeometricProperties.cornerRadius).to(
            equal(7),
            description: "Should use optional value"
        )
        expect(decoded.globalSpacesEffectProperties).to(
            equal(defaultSettings.globalSpacesEffectProperties),
            description: "Should use default value"
        )
    }

    // MARK: - Per-Space Properties Array Tests

    func testEmptyPerSpaceArrays() {
        // Given empty arrays
        let settings = SpacesSettings<RequiredMode>(
            showEmptySpaces: true,
            hiddenSpaces: [],
            spacesColorProperties: [],
            spacesGeometricProperties: [],
            spacesEffectProperties: [],
            spacesAppearanceMode: "per-space",
            globalSpacesColorProperties: ConfigurationDefaults.spaceColorProperties,
            globalSpacesGeometricProperties: GeometricProperties(),
            globalSpacesEffectProperties: EffectProperties(),

            showAppleButtonAsSpace: ConfigurationDefaults.showAppleButtonAsSpace,
            appleButtonColorProperties: ConfigurationDefaults.appleButtonColorProperties,
            appleButtonGeometricProperties: ConfigurationDefaults.appleButtonGeometricProperties,
            appleButtonEffectProperties: ConfigurationDefaults.appleButtonEffectProperties
        )

        // Then should accept empty arrays
        expect(settings.spacesColorProperties.isEmpty) == true
        expect(settings.spacesGeometricProperties.isEmpty) == true
        expect(settings.spacesEffectProperties.isEmpty) == true
    }

    func testMultiplePerSpaceProperties() {
        // Given multiple per-space properties
        let colorProps = [
            ColorProperties(backgroundTintColor: .red, borderTintColor: .white, foregroundColor: .white),
            ColorProperties(backgroundTintColor: .blue, borderTintColor: .white, foregroundColor: .white),
            ColorProperties(backgroundTintColor: .green, borderTintColor: .white, foregroundColor: .white)
        ]

        let settings = SpacesSettings<RequiredMode>(
            showEmptySpaces: true,
            hiddenSpaces: [],
            spacesColorProperties: colorProps,
            spacesGeometricProperties: [],
            spacesEffectProperties: [],
            spacesAppearanceMode: "per-space",
            globalSpacesColorProperties: ConfigurationDefaults.spaceColorProperties,
            globalSpacesGeometricProperties: GeometricProperties(),
            globalSpacesEffectProperties: EffectProperties(),

            showAppleButtonAsSpace: ConfigurationDefaults.showAppleButtonAsSpace,
            appleButtonColorProperties: ConfigurationDefaults.appleButtonColorProperties,
            appleButtonGeometricProperties: ConfigurationDefaults.appleButtonGeometricProperties,
            appleButtonEffectProperties: ConfigurationDefaults.appleButtonEffectProperties
        )

        // Then should store all properties
        expect(settings.spacesColorProperties.count) == 3
        expect(settings.spacesColorProperties) == colorProps
    }

    // MARK: - Appearance Mode Tests

    func testAppearanceModeValues() {
        // Given different appearance mode values
        let modes = ["per-space", "all-spaces"]

        for mode in modes {
            // When creating settings with each mode
            let settings = SpacesSettings<RequiredMode>(
                showEmptySpaces: true,
                hiddenSpaces: [],
                spacesColorProperties: [],
                spacesGeometricProperties: [],
                spacesEffectProperties: [],
                spacesAppearanceMode: mode,
                globalSpacesColorProperties: ConfigurationDefaults.spaceColorProperties,
                globalSpacesGeometricProperties: GeometricProperties(),
                globalSpacesEffectProperties: EffectProperties(),

                showAppleButtonAsSpace: ConfigurationDefaults.showAppleButtonAsSpace,
                appleButtonColorProperties: ConfigurationDefaults.appleButtonColorProperties,
                appleButtonGeometricProperties: ConfigurationDefaults.appleButtonGeometricProperties,
                appleButtonEffectProperties: ConfigurationDefaults.appleButtonEffectProperties
            )

            // Then should accept the mode
            expect(settings.spacesAppearanceMode) == mode
        }
    }

    // MARK: - Type Alias Tests

    func testOptionalVariantTypeAlias() {
        // Given OptionalVariant type alias
        let settings: SpacesSettings<RequiredMode>.OptionalVariant = SpacesSettings<OptionalMode>(
            showEmptySpaces: nil,
            hiddenSpaces: nil,
            spacesColorProperties: nil,
            spacesGeometricProperties: nil,
            spacesEffectProperties: nil,
            spacesAppearanceMode: nil,
            globalSpacesColorProperties: nil,
            globalSpacesGeometricProperties: nil,
            globalSpacesEffectProperties: nil,

            showAppleButtonAsSpace: nil,
            appleButtonColorProperties: nil,
            appleButtonGeometricProperties: nil,
            appleButtonEffectProperties: nil
        )

        // Then should be correct type
        expect(String(describing: type(of: settings))) == String(describing: SpacesSettings<OptionalMode>.self)
    }

    func testRequiredVariantTypeAlias() {
        // Given RequiredVariant type alias
        let settings: SpacesSettings<OptionalMode>.RequiredVariant = SpacesSettings<RequiredMode>(
            showEmptySpaces: false,
            hiddenSpaces: [],
            spacesColorProperties: [],
            spacesGeometricProperties: [],
            spacesEffectProperties: [],
            spacesAppearanceMode: "",
            globalSpacesColorProperties: ConfigurationDefaults.spaceColorProperties,
            globalSpacesGeometricProperties: GeometricProperties(),
            globalSpacesEffectProperties: EffectProperties(),

            showAppleButtonAsSpace: ConfigurationDefaults.showAppleButtonAsSpace,
            appleButtonColorProperties: ConfigurationDefaults.appleButtonColorProperties,
            appleButtonGeometricProperties: ConfigurationDefaults.appleButtonGeometricProperties,
            appleButtonEffectProperties: ConfigurationDefaults.appleButtonEffectProperties
        )

        // Then should be correct type
        expect(String(describing: type(of: settings))) == String(describing: SpacesSettings<RequiredMode>.self)
    }

    // MARK: - Integration Scenarios

    func testShowEmptySpacesEnabled() {
        // Given empty spaces enabled
        let settings = SpacesSettings<RequiredMode>(
            showEmptySpaces: true,
            hiddenSpaces: [],
            spacesColorProperties: [],
            spacesGeometricProperties: [],
            spacesEffectProperties: [],
            spacesAppearanceMode: "all-spaces",
            globalSpacesColorProperties: ConfigurationDefaults.spaceColorProperties,
            globalSpacesGeometricProperties: GeometricProperties(),
            globalSpacesEffectProperties: EffectProperties(),

            showAppleButtonAsSpace: ConfigurationDefaults.showAppleButtonAsSpace,
            appleButtonColorProperties: ConfigurationDefaults.appleButtonColorProperties,
            appleButtonGeometricProperties: ConfigurationDefaults.appleButtonGeometricProperties,
            appleButtonEffectProperties: ConfigurationDefaults.appleButtonEffectProperties
        )

        // Then should show empty spaces
        expect(settings.showEmptySpaces) == true
    }

    func testFullyCustomizedSpaces() {
        // Given fully customized spaces (5 spaces with different colors)
        let colorProps = (1 ... 5).map { i in
            ColorProperties(
                backgroundTintColor: i.isMultiple(of: 2) ? .blue : .red,
                borderTintColor: .white,
                foregroundColor: .white
            )
        }

        let settings = SpacesSettings<RequiredMode>(
            showEmptySpaces: false,
            hiddenSpaces: [],
            spacesColorProperties: colorProps,
            spacesGeometricProperties: [],
            spacesEffectProperties: [],
            spacesAppearanceMode: "per-space",
            globalSpacesColorProperties: ConfigurationDefaults.spaceColorProperties,
            globalSpacesGeometricProperties: GeometricProperties(),
            globalSpacesEffectProperties: EffectProperties(),

            showAppleButtonAsSpace: ConfigurationDefaults.showAppleButtonAsSpace,
            appleButtonColorProperties: ConfigurationDefaults.appleButtonColorProperties,
            appleButtonGeometricProperties: ConfigurationDefaults.appleButtonGeometricProperties,
            appleButtonEffectProperties: ConfigurationDefaults.appleButtonEffectProperties
        )

        // Then should have all custom colors
        expect(settings.spacesColorProperties.count) == 5
        expect(settings.showEmptySpaces) == false
        expect(settings.spacesAppearanceMode) == "per-space"
    }
}
