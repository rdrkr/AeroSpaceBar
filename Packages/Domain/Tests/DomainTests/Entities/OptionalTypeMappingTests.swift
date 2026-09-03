// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Nimble
import XCTest

/// Tests for OptionalTypeMapping protocol and OptionalType protocol.
///
/// These tests verify the phantom type system for configuration optionality,
/// including protocol conformance, type aliases, and decode functionality.
@MainActor
final class OptionalTypeMappingTests: XCTestCase {
    // MARK: - OptionalMode Conformance Tests

    func testOptionalModeConformsToProtocol() {
        /// Given OptionalMode type
        /// Then should conform to OptionalTypeMapping
        func requiresMapping(_: (some OptionalTypeMapping).Type) { }
        requiresMapping(OptionalMode.self)
    }

    func testOptionalModeCodableConformance() {
        /// Given OptionalMode type
        /// Then should conform to Codable
        func requiresCodable(_: (some Codable).Type) { }
        requiresCodable(OptionalMode.self)
    }

    func testOptionalModeTypeAliases() {
        // Given OptionalMode type aliases
        // Then should be optional variants
        expect(OptionalMode.BoolType.self == Bool?.self) == true
        expect(OptionalMode.StringType.self == String?.self) == true
        expect(OptionalMode.ThemeModeType.self == ThemeMode?.self) == true
        expect(OptionalMode.ThemePresetColorPropertiesType.self == ThemePresetColorProperties?.self) == true
        expect(OptionalMode.ColorPropertiesArrayType.self == [ColorProperties]?.self) == true
        expect(OptionalMode.GeometricPropertiesArrayType.self == [GeometricProperties]?.self) == true
        expect(OptionalMode.EffectPropertiesArrayType.self == [EffectProperties]?.self) == true
        expect(OptionalMode.GroupArrayType.self == [Domain.Group]?.self) == true
        expect(OptionalMode.ColorPropertiesType.self == ColorProperties?.self) == true
        expect(OptionalMode.GeometricPropertiesType.self == GeometricProperties?.self) == true
        expect(OptionalMode.EffectPropertiesType.self == EffectProperties?.self) == true
    }

    // MARK: - RequiredMode Conformance Tests

    func testRequiredModeConformsToProtocol() {
        /// Given RequiredMode type
        /// Then should conform to OptionalTypeMapping
        func requiresMapping(_: (some OptionalTypeMapping).Type) { }
        requiresMapping(RequiredMode.self)
    }

    func testRequiredModeCodableConformance() {
        /// Given RequiredMode type
        /// Then should conform to Codable
        func requiresCodable(_: (some Codable).Type) { }
        requiresCodable(RequiredMode.self)
    }

    func testRequiredModeTypeAliases() {
        // Given RequiredMode type aliases
        // Then should be non-optional variants
        expect(RequiredMode.BoolType.self == Bool.self) == true
        expect(RequiredMode.StringType.self == String.self) == true
        expect(RequiredMode.ThemeModeType.self == ThemeMode.self) == true
        expect(RequiredMode.ThemePresetColorPropertiesType.self == ThemePresetColorProperties.self) == true
        expect(RequiredMode.ColorPropertiesArrayType.self == [ColorProperties].self) == true
        expect(RequiredMode.GeometricPropertiesArrayType.self == [GeometricProperties].self) == true
        expect(RequiredMode.EffectPropertiesArrayType.self == [EffectProperties].self) == true
        expect(RequiredMode.GroupArrayType.self == [Domain.Group].self) == true
        expect(RequiredMode.ColorPropertiesType.self == ColorProperties.self) == true
        expect(RequiredMode.GeometricPropertiesType.self == GeometricProperties.self) == true
        expect(RequiredMode.EffectPropertiesType.self == EffectProperties.self) == true
    }

    // MARK: - OptionalType Protocol Tests

    func testOptionalTypeProtocolRequirements() {
        /// Given types conforming to OptionalType
        /// Then should have required associated types and methods
        func requiresOptionalType<T: OptionalType>(_: T.Type) {
            // Should have OptionalVariant
            _ = T.OptionalVariant.self
            // Should have RequiredVariant
            _ = T.RequiredVariant.self
        }

        requiresOptionalType(GeneralSettings<OptionalMode>.self)
        requiresOptionalType(GeneralSettings<RequiredMode>.self)
    }

    func testOptionalTypeCodableRequirement() {
        /// Given OptionalType protocol
        /// Then should require Codable
        func requiresCodable<T: OptionalType>(_: T.Type) {
            func needsCodable(_: (some Codable).Type) { }
            needsCodable(T.self)
        }

        requiresCodable(GeneralSettings<OptionalMode>.self)
        requiresCodable(SpacesSettings<RequiredMode>.self)
    }

    // MARK: - Configuration Integration Tests

    func testGeneralSettingsOptionalVariant() {
        // Given GeneralSettings with RequiredMode
        // Then OptionalVariant should be OptionalMode version
        expect(String(describing: GeneralSettings<RequiredMode>.OptionalVariant.self)) ==
            String(describing: GeneralSettings<OptionalMode>.self)
    }

    func testGeneralSettingsRequiredVariant() {
        // Given GeneralSettings with OptionalMode
        // Then RequiredVariant should be RequiredMode version
        expect(String(describing: GeneralSettings<OptionalMode>.RequiredVariant.self)) ==
            String(describing: GeneralSettings<RequiredMode>.self)
    }

    func testSpacesSettingsOptionalVariant() {
        // Given SpacesSettings with RequiredMode
        // Then OptionalVariant should be OptionalMode version
        expect(String(describing: SpacesSettings<RequiredMode>.OptionalVariant.self)) ==
            String(describing: SpacesSettings<OptionalMode>.self)
    }

    func testSpacesSettingsRequiredVariant() {
        // Given SpacesSettings with OptionalMode
        // Then RequiredVariant should be RequiredMode version
        expect(String(describing: SpacesSettings<OptionalMode>.RequiredVariant.self)) ==
            String(describing: SpacesSettings<RequiredMode>.self)
    }

    func testGroupsSettingsOptionalVariant() {
        // Given GroupsSettings with RequiredMode
        // Then OptionalVariant should be OptionalMode version
        expect(String(describing: GroupsSettings<RequiredMode>.OptionalVariant.self)) ==
            String(describing: GroupsSettings<OptionalMode>.self)
    }

    func testGroupsSettingsRequiredVariant() {
        // Given GroupsSettings with OptionalMode
        // Then RequiredVariant should be RequiredMode version
        expect(String(describing: GroupsSettings<OptionalMode>.RequiredVariant.self)) ==
            String(describing: GroupsSettings<RequiredMode>.self)
    }

    func testAdvancedSettingsOptionalVariant() {
        // Given AdvancedSettings with RequiredMode
        // Then OptionalVariant should be OptionalMode version
        expect(String(describing: AdvancedSettings<RequiredMode>.OptionalVariant.self)) ==
            String(describing: AdvancedSettings<OptionalMode>.self)
    }

    func testAdvancedSettingsRequiredVariant() {
        // Given AdvancedSettings with OptionalMode
        // Then RequiredVariant should be RequiredMode version
        expect(String(describing: AdvancedSettings<OptionalMode>.RequiredVariant.self)) ==
            String(describing: AdvancedSettings<RequiredMode>.self)
    }

    func testConfigurationDataOptionalVariant() {
        // Given ConfigurationData with RequiredMode
        // Then OptionalVariant should be OptionalMode version
        expect(String(describing: ConfigurationData<RequiredMode>.OptionalVariant.self)) ==
            String(describing: ConfigurationData<OptionalMode>.self)
    }

    func testConfigurationDataRequiredVariant() {
        // Given ConfigurationData with OptionalMode
        // Then RequiredVariant should be RequiredMode version
        expect(String(describing: ConfigurationData<OptionalMode>.RequiredVariant.self)) ==
            String(describing: ConfigurationData<RequiredMode>.self)
    }

    // MARK: - Decode Functionality Tests

    func testDecodeMethodExists() throws {
        // Given OptionalType conforming type
        // When creating optional and default values
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

        let defaultValue = GeneralSettings<RequiredMode>(
            showWindowTitles: false,
            aeroSpacePath: "/default",
            themeMode: .custom,
            themePresetColorProperties: .nord,
            themePresetGeometricProperties: GeometricProperties(),
            themePresetEffectProperties: EffectProperties(),

            quickHideEnabled: ConfigurationDefaults.quickHideEnabled,
            quickHideTriggerKey: ConfigurationDefaults.quickHideTriggerKey
        )

        // Then decode method should exist and work
        let decoded = try GeneralSettings<RequiredMode>.decode(from: optional, defaultValue: defaultValue)
        expect(decoded.showWindowTitles) == false
        expect(decoded.aeroSpacePath) == "/default"
    }

    func testDecodeWithAllSettings() throws {
        // Given all settings types
        let optionalGeneral = GeneralSettings<OptionalMode>(
            showWindowTitles: true,
            aeroSpacePath: "/custom",
            themeMode: .preset,
            themePresetColorProperties: .dracula,
            themePresetGeometricProperties: GeometricProperties(),
            themePresetEffectProperties: EffectProperties(),

            quickHideEnabled: nil,
            quickHideTriggerKey: nil
        )

        let optionalSpaces = SpacesSettings<OptionalMode>(
            showEmptySpaces: true,
            hiddenSpaces: [],
            spacesColorProperties: [],
            spacesGeometricProperties: [],
            spacesEffectProperties: [],
            spacesAppearanceMode: "all-spaces",
            globalSpacesColorProperties: ConfigurationDefaults.spaceColorProperties,
            globalSpacesGeometricProperties: GeometricProperties(),
            globalSpacesEffectProperties: EffectProperties(),

            showAppleButtonAsSpace: nil,
            appleButtonColorProperties: nil,
            appleButtonGeometricProperties: nil,
            appleButtonEffectProperties: nil
        )

        let optionalGroups = GroupsSettings<OptionalMode>(
            showGroups: true,
            showForegroundOverlay: nil,
            groups: [],
            groupsAppearanceMode: "all-groups",
            globalGroupsColorProperties: ConfigurationDefaults.groupsGlobalColorProperties,
            globalGroupsGeometricProperties: GeometricProperties(),
            globalGroupsEffectProperties: EffectProperties()
        )

        let optionalAdvanced = AdvancedSettings<OptionalMode>(
            focusWindowOnClick: true,
            enablePerformanceMetrics: false,
            isOptimizedPerformanceEnabled: true,
            logLevel: "debug"
        )

        // And defaults
        let defaultGeneral = GeneralSettings<RequiredMode>(
            showWindowTitles: false,
            aeroSpacePath: "/default",
            themeMode: .custom,
            themePresetColorProperties: .nord,
            themePresetGeometricProperties: GeometricProperties(),
            themePresetEffectProperties: EffectProperties(),

            quickHideEnabled: ConfigurationDefaults.quickHideEnabled,
            quickHideTriggerKey: ConfigurationDefaults.quickHideTriggerKey
        )

        let defaultSpaces = SpacesSettings<RequiredMode>(
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

        let defaultGroups = GroupsSettings<RequiredMode>(
            showGroups: false,
            showForegroundOverlay: ConfigurationDefaults.showForegroundOverlay,
            groups: [],
            groupsAppearanceMode: "per-group",
            globalGroupsColorProperties: ConfigurationDefaults.groupsGlobalColorProperties,
            globalGroupsGeometricProperties: GeometricProperties(),
            globalGroupsEffectProperties: EffectProperties()
        )

        let defaultAdvanced = AdvancedSettings<RequiredMode>(
            focusWindowOnClick: false,
            enablePerformanceMetrics: false,
            isOptimizedPerformanceEnabled: false,
            logLevel: "info"
        )

        // When decoding all settings
        let decodedGeneral = try GeneralSettings<RequiredMode>.decode(
            from: optionalGeneral,
            defaultValue: defaultGeneral
        )
        let decodedSpaces = try SpacesSettings<RequiredMode>.decode(from: optionalSpaces, defaultValue: defaultSpaces)
        let decodedGroups = try GroupsSettings<RequiredMode>.decode(from: optionalGroups, defaultValue: defaultGroups)
        let decodedAdvanced = try AdvancedSettings<RequiredMode>.decode(
            from: optionalAdvanced,
            defaultValue: defaultAdvanced
        )

        // Then all should decode correctly
        expect(decodedGeneral.showWindowTitles) == true
        expect(decodedSpaces.showEmptySpaces) == true
        expect(decodedGroups.showGroups) == true
        expect(decodedAdvanced.focusWindowOnClick) == true
    }

    // MARK: - Type Safety Tests

    func testPhantomTypesProvideTypeSafety() {
        // Given configuration with different modes
        func acceptsOptional(_: GeneralSettings<OptionalMode>) { }
        func acceptsRequired(_: GeneralSettings<RequiredMode>) { }

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

        let required = GeneralSettings<RequiredMode>(
            showWindowTitles: false,
            aeroSpacePath: "/path",
            themeMode: .custom,
            themePresetColorProperties: .nord,
            themePresetGeometricProperties: GeometricProperties(),
            themePresetEffectProperties: EffectProperties(),

            quickHideEnabled: ConfigurationDefaults.quickHideEnabled,
            quickHideTriggerKey: ConfigurationDefaults.quickHideTriggerKey
        )

        // Then types should be distinct
        acceptsOptional(optional)
        acceptsRequired(required)

        // And should not be interchangeable
        expect(String(describing: type(of: optional))) != String(describing: type(of: required))
    }

    // MARK: - Integration Purpose Tests

    func testOptionalModeForTOMLParsing() {
        // Given OptionalMode is for TOML parsing
        // Then all fields can be nil
        let tomlConfig = GeneralSettings<OptionalMode>(
            showWindowTitles: nil, // Missing from TOML
            aeroSpacePath: nil, // Missing from TOML
            themeMode: .preset, // Present in TOML
            themePresetColorProperties: .nord, // Present in TOML
            themePresetGeometricProperties: nil, // Missing from TOML
            themePresetEffectProperties: nil, // Missing from TOML

            quickHideEnabled: nil,
            quickHideTriggerKey: nil
        )

        // Can represent partial TOML data
        expect(tomlConfig.showWindowTitles).to(beNil())
        expect(tomlConfig.themeMode).toNot(beNil())
    }

    func testRequiredModeForRuntimeUsage() {
        // Given RequiredMode is for runtime usage
        // Then all fields must have values
        let runtimeConfig = GeneralSettings<RequiredMode>(
            showWindowTitles: true,
            aeroSpacePath: "/usr/local/bin/aerospace",
            themeMode: .preset,
            themePresetColorProperties: .nord,
            themePresetGeometricProperties: GeometricProperties(),
            themePresetEffectProperties: EffectProperties(),

            quickHideEnabled: ConfigurationDefaults.quickHideEnabled,
            quickHideTriggerKey: ConfigurationDefaults.quickHideTriggerKey
        )

        // All fields are guaranteed to have values at runtime
        expect(runtimeConfig.showWindowTitles).toNot(beNil())
        expect(runtimeConfig.aeroSpacePath).toNot(beNil())
        expect(runtimeConfig.themeMode).toNot(beNil())
        expect(runtimeConfig.themePresetColorProperties).toNot(beNil())
    }
}
