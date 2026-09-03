// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Nimble
import XCTest

/// Tests for GeneralSettings class.
///
/// These tests verify GeneralSettings with both OptionalMode and RequiredMode,
/// decode() merging logic, Codable conformance, and type aliases.
@MainActor
final class GeneralSettingsTests: XCTestCase {
    // MARK: - RequiredMode Initialization Tests

    func testRequiredModeInitialization() {
        // Given required mode parameters
        let showWindowTitles = true
        let aeroSpacePath = "/usr/local/bin/aerospace"
        let themeMode = ThemeMode.preset
        let themePreset = ThemePresetColorProperties.nord
        let geometric = GeometricProperties()
        let effect = EffectProperties()

        // When creating required settings
        let settings = GeneralSettings<RequiredMode>(
            showWindowTitles: showWindowTitles,
            aeroSpacePath: aeroSpacePath,
            themeMode: themeMode,
            themePresetColorProperties: themePreset,
            themePresetGeometricProperties: geometric,
            themePresetEffectProperties: effect,

            quickHideEnabled: ConfigurationDefaults.quickHideEnabled,
            quickHideTriggerKey: ConfigurationDefaults.quickHideTriggerKey
        )

        // Then all properties should be set
        expect(settings.showWindowTitles) == showWindowTitles
        expect(settings.aeroSpacePath) == aeroSpacePath
        expect(settings.themeMode) == themeMode
        expect(settings.themePresetColorProperties) == themePreset
        expect(settings.themePresetGeometricProperties) == geometric
        expect(settings.themePresetEffectProperties) == effect
    }

    // MARK: - OptionalMode Initialization Tests

    func testOptionalModeInitializationWithValues() {
        // Given optional mode parameters
        let showWindowTitles: Bool? = true
        let aeroSpacePath: String? = "/usr/local/bin/aerospace"
        let themeMode: ThemeMode? = .preset
        let themePreset: ThemePresetColorProperties? = .nord
        let geometric: GeometricProperties? = GeometricProperties()
        let effect: EffectProperties? = EffectProperties()

        // When creating optional settings
        let settings = GeneralSettings<OptionalMode>(
            showWindowTitles: showWindowTitles,
            aeroSpacePath: aeroSpacePath,
            themeMode: themeMode,
            themePresetColorProperties: themePreset,
            themePresetGeometricProperties: geometric,
            themePresetEffectProperties: effect,

            quickHideEnabled: nil,
            quickHideTriggerKey: nil
        )

        // Then all properties should be set
        expect(settings.showWindowTitles) == showWindowTitles
        expect(settings.aeroSpacePath) == aeroSpacePath
        expect(settings.themeMode) == themeMode
        expect(settings.themePresetColorProperties) == themePreset
        expect(settings.themePresetGeometricProperties) == geometric
        expect(settings.themePresetEffectProperties) == effect
    }

    func testOptionalModeInitializationWithNils() {
        // Given optional mode with nil values
        let showWindowTitles: Bool? = nil
        let aeroSpacePath: String? = nil
        let themeMode: ThemeMode? = nil
        let themePreset: ThemePresetColorProperties? = nil
        let geometric: GeometricProperties? = nil
        let effect: EffectProperties? = nil

        // When creating optional settings
        let settings = GeneralSettings<OptionalMode>(
            showWindowTitles: showWindowTitles,
            aeroSpacePath: aeroSpacePath,
            themeMode: themeMode,
            themePresetColorProperties: themePreset,
            themePresetGeometricProperties: geometric,
            themePresetEffectProperties: effect,

            quickHideEnabled: nil,
            quickHideTriggerKey: nil
        )

        // Then all properties should be nil
        expect(settings.showWindowTitles).to(beNil())
        expect(settings.aeroSpacePath).to(beNil())
        expect(settings.themeMode).to(beNil())
        expect(settings.themePresetColorProperties).to(beNil())
        expect(settings.themePresetGeometricProperties).to(beNil())
        expect(settings.themePresetEffectProperties).to(beNil())
    }

    // MARK: - Decode Method Tests

    func testDecodeWithAllOptionalValuesNil() throws {
        // Given optional settings with all nil values
        let optional = GeneralSettings<OptionalMode>(
            showWindowTitles: nil,
            aeroSpacePath: nil,
            themeMode: nil,
            themePresetColorProperties: nil,
            themePresetGeometricProperties: nil,
            themePresetEffectProperties: nil,

            quickHideEnabled: nil,
            quickHideTriggerKey: nil
        )

        // And default settings
        let defaultSettings = GeneralSettings<RequiredMode>(
            showWindowTitles: false,
            aeroSpacePath: "/default/path",
            themeMode: .custom,
            themePresetColorProperties: .dracula,
            themePresetGeometricProperties: GeometricProperties(),
            themePresetEffectProperties: EffectProperties(),

            quickHideEnabled: ConfigurationDefaults.quickHideEnabled,
            quickHideTriggerKey: ConfigurationDefaults.quickHideTriggerKey
        )

        // When decoding
        let decoded = try GeneralSettings<RequiredMode>.decode(
            from: optional,
            defaultValue: defaultSettings
        )

        // Then should use all default values
        expect(decoded.showWindowTitles) == defaultSettings.showWindowTitles
        expect(decoded.aeroSpacePath) == defaultSettings.aeroSpacePath
        expect(decoded.themeMode) == defaultSettings.themeMode
        expect(decoded.themePresetColorProperties) == defaultSettings.themePresetColorProperties
        expect(decoded.themePresetGeometricProperties) == defaultSettings.themePresetGeometricProperties
        expect(decoded.themePresetEffectProperties) == defaultSettings.themePresetEffectProperties
    }

    func testDecodeWithAllOptionalValuesSet() throws {
        // Given optional settings with all values set
        let geometric = GeometricProperties(cornerRadius: 10, borderWidth: 2)
        let effect = EffectProperties(backgroundOpacity: 0.8, backgroundBlurRadius: 5, borderOpacity: 1.0)

        let optional = GeneralSettings<OptionalMode>(
            showWindowTitles: true,
            aeroSpacePath: "/custom/path",
            themeMode: .glass,
            themePresetColorProperties: .nord,
            themePresetGeometricProperties: geometric,
            themePresetEffectProperties: effect,

            quickHideEnabled: nil,
            quickHideTriggerKey: nil
        )

        // And default settings (different values)
        let defaultSettings = GeneralSettings<RequiredMode>(
            showWindowTitles: false,
            aeroSpacePath: "/default/path",
            themeMode: .custom,
            themePresetColorProperties: .dracula,
            themePresetGeometricProperties: GeometricProperties(),
            themePresetEffectProperties: EffectProperties(),

            quickHideEnabled: ConfigurationDefaults.quickHideEnabled,
            quickHideTriggerKey: ConfigurationDefaults.quickHideTriggerKey
        )

        // When decoding
        let decoded = try GeneralSettings<RequiredMode>.decode(
            from: optional,
            defaultValue: defaultSettings
        )

        // Then should use all optional values
        expect(decoded.showWindowTitles) == true
        expect(decoded.aeroSpacePath) == "/custom/path"
        expect(decoded.themeMode) == ThemeMode.glass
        expect(decoded.themePresetColorProperties) == ThemePresetColorProperties.nord
        expect(decoded.themePresetGeometricProperties) == geometric
        expect(decoded.themePresetEffectProperties) == effect
    }

    func testDecodeWithMixedOptionalValues() throws {
        // Given optional settings with mixed values
        let optional = GeneralSettings<OptionalMode>(
            showWindowTitles: true,
            aeroSpacePath: nil, // Will use default
            themeMode: .preset,
            themePresetColorProperties: nil, // Will use default
            themePresetGeometricProperties: GeometricProperties(cornerRadius: 8, borderWidth: 1),
            themePresetEffectProperties: nil, // Will use default

            quickHideEnabled: nil,
            quickHideTriggerKey: nil
        )

        // And default settings
        let defaultSettings = GeneralSettings<RequiredMode>(
            showWindowTitles: false,
            aeroSpacePath: "/default/path",
            themeMode: .custom,
            themePresetColorProperties: .dracula,
            themePresetGeometricProperties: GeometricProperties(),
            themePresetEffectProperties: EffectProperties(),

            quickHideEnabled: ConfigurationDefaults.quickHideEnabled,
            quickHideTriggerKey: ConfigurationDefaults.quickHideTriggerKey
        )

        // When decoding
        let decoded = try GeneralSettings<RequiredMode>.decode(
            from: optional,
            defaultValue: defaultSettings
        )

        // Then should merge correctly
        expect(decoded.showWindowTitles).to(beTrue(), description: "Should use optional value")
        expect(decoded.aeroSpacePath) == "/default/path"
        expect(decoded.themeMode) == .preset
        expect(decoded.themePresetColorProperties) == .dracula
        expect(decoded.themePresetGeometricProperties.cornerRadius).to(
            equal(8),
            description: "Should use optional value"
        )
        expect(decoded.themePresetEffectProperties).to(
            equal(defaultSettings.themePresetEffectProperties),
            description: "Should use default value"
        )
    }

    // MARK: - Type Alias Tests

    func testOptionalVariantTypeAlias() {
        // Given OptionalVariant type alias
        let settings: GeneralSettings<RequiredMode>.OptionalVariant = GeneralSettings<OptionalMode>(
            showWindowTitles: nil,
            aeroSpacePath: nil,
            themeMode: nil,
            themePresetColorProperties: nil,
            themePresetGeometricProperties: nil,
            themePresetEffectProperties: nil,

            quickHideEnabled: nil,
            quickHideTriggerKey: nil
        )

        // Then should be correct type
        expect(type(of: settings) == GeneralSettings<OptionalMode>.self) == true
    }

    func testRequiredVariantTypeAlias() {
        // Given RequiredVariant type alias
        let settings: GeneralSettings<OptionalMode>.RequiredVariant = GeneralSettings<RequiredMode>(
            showWindowTitles: false,
            aeroSpacePath: "",
            themeMode: .custom,
            themePresetColorProperties: .dracula,
            themePresetGeometricProperties: GeometricProperties(),
            themePresetEffectProperties: EffectProperties(),

            quickHideEnabled: ConfigurationDefaults.quickHideEnabled,
            quickHideTriggerKey: ConfigurationDefaults.quickHideTriggerKey
        )

        // Then should be correct type
        expect(type(of: settings) == GeneralSettings<RequiredMode>.self) == true
    }

    // MARK: - Theme Mode Tests

    func testAllThemeModesSupported() {
        // Given all theme modes
        let themeModes: [ThemeMode] = [.preset, .glass, .custom]

        for mode in themeModes {
            // When creating settings with each theme mode
            let settings = GeneralSettings<RequiredMode>(
                showWindowTitles: true,
                aeroSpacePath: "/path",
                themeMode: mode,
                themePresetColorProperties: .nord,
                themePresetGeometricProperties: GeometricProperties(),
                themePresetEffectProperties: EffectProperties(),

                quickHideEnabled: ConfigurationDefaults.quickHideEnabled,
                quickHideTriggerKey: ConfigurationDefaults.quickHideTriggerKey
            )

            // Then should accept the theme mode
            expect(settings.themeMode) == mode
        }
    }

    func testAllThemePresetsSupported() {
        // Given all theme presets
        let presets = ThemePresetColorProperties.allCases

        for preset in presets {
            // When creating settings with each preset
            let settings = GeneralSettings<RequiredMode>(
                showWindowTitles: true,
                aeroSpacePath: "/path",
                themeMode: .preset,
                themePresetColorProperties: preset,
                themePresetGeometricProperties: GeometricProperties(),
                themePresetEffectProperties: EffectProperties(),

                quickHideEnabled: ConfigurationDefaults.quickHideEnabled,
                quickHideTriggerKey: ConfigurationDefaults.quickHideTriggerKey
            )

            // Then should accept the preset
            expect(settings.themePresetColorProperties) == preset
        }
    }

    // MARK: - Edge Cases

    func testEmptyAeroSpacePath() {
        // Given empty path
        let settings = GeneralSettings<RequiredMode>(
            showWindowTitles: true,
            aeroSpacePath: "",
            themeMode: .custom,
            themePresetColorProperties: .nord,
            themePresetGeometricProperties: GeometricProperties(),
            themePresetEffectProperties: EffectProperties(),

            quickHideEnabled: ConfigurationDefaults.quickHideEnabled,
            quickHideTriggerKey: ConfigurationDefaults.quickHideTriggerKey
        )

        // Then should accept empty path
        expect(settings.aeroSpacePath.isEmpty) == true
    }

    func testVeryLongAeroSpacePath() {
        // Given very long path
        let longPath = "/very/long/path/" + String(repeating: "subdirectory/", count: 50) + "aerospace"
        let settings = GeneralSettings<RequiredMode>(
            showWindowTitles: true,
            aeroSpacePath: longPath,
            themeMode: .custom,
            themePresetColorProperties: .nord,
            themePresetGeometricProperties: GeometricProperties(),
            themePresetEffectProperties: EffectProperties(),

            quickHideEnabled: ConfigurationDefaults.quickHideEnabled,
            quickHideTriggerKey: ConfigurationDefaults.quickHideTriggerKey
        )

        // Then should accept long path
        expect(settings.aeroSpacePath) == longPath
    }
}
