// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Nimble
import XCTest

/// Tests for ConfigurationData class.
///
/// These tests verify ConfigurationData with both OptionalMode and RequiredMode,
/// decode() merging logic for all configuration sections, and type aliases.
@MainActor
final class ConfigurationDataTests: XCTestCase {
    // MARK: - Test Helpers

    private struct DefaultRequiredSettings {
        let general: GeneralSettings<RequiredMode>
        let spaces: SpacesSettings<RequiredMode>
        let groups: GroupsSettings<RequiredMode>
        let advanced: AdvancedSettings<RequiredMode>
    }

    private func createDefaultRequiredSettings() -> DefaultRequiredSettings {
        DefaultRequiredSettings(
            general: GeneralSettings<RequiredMode>(
                showWindowTitles: false,
                aeroSpacePath: "/usr/local/bin/aerospace",
                themeMode: .custom,
                themePresetColorProperties: .nord,
                themePresetGeometricProperties: GeometricProperties(),
                themePresetEffectProperties: EffectProperties()
            ),
            spaces: SpacesSettings<RequiredMode>(
                showEmptySpaces: false,
                spacesColorProperties: [],
                spacesGeometricProperties: [],
                spacesEffectProperties: [],
                spacesAppearanceMode: "all-spaces",
                globalSpacesColorProperties: ConfigurationDefaults.spaceColorProperties,
                globalSpacesGeometricProperties: GeometricProperties(),
                globalSpacesEffectProperties: EffectProperties()
            ),
            groups: GroupsSettings<RequiredMode>(
                showGroups: false,
                groups: [],
                groupsAppearanceMode: "all-groups",
                globalGroupsColorProperties: ConfigurationDefaults.groupsGlobalColorProperties,
                globalGroupsGeometricProperties: GeometricProperties(),
                globalGroupsEffectProperties: EffectProperties()
            ),
            advanced: AdvancedSettings<RequiredMode>(
                focusWindowOnClick: true,
                enablePerformanceMetrics: false,
                isOptimizedPerformanceEnabled: false,
                logLevel: "info"
            )
        )
    }

    // MARK: - RequiredMode Initialization Tests

    func testRequiredModeInitialization() {
        // Given required mode settings
        let defaults = createDefaultRequiredSettings()

        // When creating configuration data
        let config = ConfigurationData<RequiredMode>(
            general: defaults.general,
            spaces: defaults.spaces,
            groups: defaults.groups,
            advanced: defaults.advanced
        )

        // Then all sections should be set
        expect(config.general.aeroSpacePath) == defaults.general.aeroSpacePath
        expect(config.spaces.showEmptySpaces) == defaults.spaces.showEmptySpaces
        expect(config.groups.showGroups) == defaults.groups.showGroups
        expect(config.advanced.logLevel) == defaults.advanced.logLevel
    }

    // MARK: - OptionalMode Initialization Tests

    func testOptionalModeInitializationWithValues() {
        // Given optional mode settings with values
        let general: GeneralSettings<RequiredMode>? = GeneralSettings<RequiredMode>(
            showWindowTitles: true,
            aeroSpacePath: "/custom/path",
            themeMode: .preset,
            themePresetColorProperties: .dracula,
            themePresetGeometricProperties: GeometricProperties(),
            themePresetEffectProperties: EffectProperties()
        )

        let spaces: SpacesSettings<RequiredMode>? = SpacesSettings<RequiredMode>(
            showEmptySpaces: true,
            spacesColorProperties: [],
            spacesGeometricProperties: [],
            spacesEffectProperties: [],
            spacesAppearanceMode: "per-space",
            globalSpacesColorProperties: ConfigurationDefaults.spaceColorProperties,
            globalSpacesGeometricProperties: GeometricProperties(),
            globalSpacesEffectProperties: EffectProperties()
        )

        let groups: GroupsSettings<RequiredMode>? = GroupsSettings<RequiredMode>(
            showGroups: true,
            groups: [],
            groupsAppearanceMode: "per-group",
            globalGroupsColorProperties: ConfigurationDefaults.groupsGlobalColorProperties,
            globalGroupsGeometricProperties: GeometricProperties(),
            globalGroupsEffectProperties: EffectProperties()
        )

        let advanced: AdvancedSettings<RequiredMode>? = AdvancedSettings<RequiredMode>(
            focusWindowOnClick: false,
            enablePerformanceMetrics: true,
            isOptimizedPerformanceEnabled: true,
            logLevel: "debug"
        )

        // When creating optional configuration data
        let config = ConfigurationData<OptionalMode>(
            general: general,
            spaces: spaces,
            groups: groups,
            advanced: advanced
        )

        // Then all sections should be set
        expect(config.general).toNot(beNil())
        expect(config.spaces).toNot(beNil())
        expect(config.groups).toNot(beNil())
        expect(config.advanced).toNot(beNil())
    }

    func testOptionalModeInitializationWithNils() {
        // Given optional mode with nil sections
        let config = ConfigurationData<OptionalMode>(
            general: nil,
            spaces: nil,
            groups: nil,
            advanced: nil
        )

        // Then all sections should be nil (since OptionalMode makes them optional)
        expect(config.general).to(beNil())
        expect(config.spaces).to(beNil())
        expect(config.groups).to(beNil())
        expect(config.advanced).to(beNil())
    }

    // MARK: - Decode Method Tests

    func testDecodeWithAllOptionalSectionsNil() throws {
        // Given optional config with all nil sections
        let optional = ConfigurationData<OptionalMode>(
            general: nil,
            spaces: nil,
            groups: nil,
            advanced: nil
        )

        // And default config
        let defaults = createDefaultRequiredSettings()
        let defaultConfig = ConfigurationData<RequiredMode>(
            general: defaults.general,
            spaces: defaults.spaces,
            groups: defaults.groups,
            advanced: defaults.advanced
        )

        // When decoding
        let decoded = try ConfigurationData<RequiredMode>.decode(from: optional, defaultValue: defaultConfig)

        // Then should use all default sections
        expect(decoded.general.aeroSpacePath) == defaultConfig.general.aeroSpacePath
        expect(decoded.spaces.showEmptySpaces) == defaultConfig.spaces.showEmptySpaces
        expect(decoded.groups.showGroups) == defaultConfig.groups.showGroups
        expect(decoded.advanced.logLevel) == defaultConfig.advanced.logLevel
    }

    func testDecodeWithAllOptionalSectionsSet() throws {
        // Given optional config with all sections set
        let customGeneral = GeneralSettings<RequiredMode>(
            showWindowTitles: true,
            aeroSpacePath: "/custom/path",
            themeMode: .glass,
            themePresetColorProperties: .tokyoNight,
            themePresetGeometricProperties: GeometricProperties(cornerRadius: 8, borderWidth: 2),
            themePresetEffectProperties: EffectProperties(
                backgroundOpacity: 0.8,
                backgroundBlurRadius: 5,
                borderOpacity: 1.0
            )
        )

        let customSpaces = SpacesSettings<RequiredMode>(
            showEmptySpaces: true,
            spacesColorProperties: [ConfigurationDefaults.spaceColorProperties],
            spacesGeometricProperties: [GeometricProperties()],
            spacesEffectProperties: [EffectProperties()],
            spacesAppearanceMode: "per-space",
            globalSpacesColorProperties: ConfigurationDefaults.spaceColorProperties,
            globalSpacesGeometricProperties: GeometricProperties(),
            globalSpacesEffectProperties: EffectProperties()
        )

        let customGroups = GroupsSettings<RequiredMode>(
            showGroups: true,
            groups: [
                Group(
                    id: 1,
                    startIndex: 1,
                    endIndex: 5,
                    colorProperties: ConfigurationDefaults.groupsGlobalColorProperties,
                    geometricProperties: GeometricProperties(),
                    effectProperties: EffectProperties()
                )
            ],
            groupsAppearanceMode: "per-group",
            globalGroupsColorProperties: ConfigurationDefaults.groupsGlobalColorProperties,
            globalGroupsGeometricProperties: GeometricProperties(),
            globalGroupsEffectProperties: EffectProperties()
        )

        let customAdvanced = AdvancedSettings<RequiredMode>(
            focusWindowOnClick: false,
            enablePerformanceMetrics: true,
            isOptimizedPerformanceEnabled: true,
            logLevel: "debug"
        )

        let optional = ConfigurationData<OptionalMode>(
            general: customGeneral,
            spaces: customSpaces,
            groups: customGroups,
            advanced: customAdvanced
        )

        // And default config (different values)
        let defaults = createDefaultRequiredSettings()
        let defaultConfig = ConfigurationData<RequiredMode>(
            general: defaults.general,
            spaces: defaults.spaces,
            groups: defaults.groups,
            advanced: defaults.advanced
        )

        // When decoding
        let decoded = try ConfigurationData<RequiredMode>.decode(from: optional, defaultValue: defaultConfig)

        // Then should use all optional sections
        expect(decoded.general.aeroSpacePath) == "/custom/path"
        expect(decoded.general.showWindowTitles) == true
        expect(decoded.spaces.showEmptySpaces) == true
        expect(decoded.spaces.spacesAppearanceMode) == "per-space"
        expect(decoded.groups.showGroups) == true
        expect(decoded.groups.groups.count) == 1
        expect(decoded.advanced.logLevel) == "debug"
        expect(decoded.advanced.enablePerformanceMetrics) == true
    }

    func testDecodeWithMixedOptionalSections() throws {
        // Given optional config with mixed sections
        let customGeneral = GeneralSettings<RequiredMode>(
            showWindowTitles: true,
            aeroSpacePath: "/custom/path",
            themeMode: .preset,
            themePresetColorProperties: .gruvboxDark,
            themePresetGeometricProperties: GeometricProperties(),
            themePresetEffectProperties: EffectProperties()
        )

        let optional = ConfigurationData<OptionalMode>(
            general: customGeneral,
            spaces: nil, // Will use default
            groups: nil, // Will use default
            advanced: AdvancedSettings<RequiredMode>(
                focusWindowOnClick: false,
                enablePerformanceMetrics: true,
                isOptimizedPerformanceEnabled: false,
                logLevel: "warning"
            )
        )

        // And default config
        let defaults = createDefaultRequiredSettings()
        let defaultConfig = ConfigurationData<RequiredMode>(
            general: defaults.general,
            spaces: defaults.spaces,
            groups: defaults.groups,
            advanced: defaults.advanced
        )

        // When decoding
        let decoded = try ConfigurationData<RequiredMode>.decode(from: optional, defaultValue: defaultConfig)

        // Then should merge correctly
        expect(decoded.general.aeroSpacePath) == "/custom/path"
        expect(decoded.spaces.showEmptySpaces).to(
            equal(defaultConfig.spaces.showEmptySpaces),
            description: "Should use default spaces"
        )
        expect(decoded.groups.showGroups).to(
            equal(defaultConfig.groups.showGroups),
            description: "Should use default groups"
        )
        expect(decoded.advanced.logLevel) == "warning"
    }

    // MARK: - Type Alias Tests

    func testOptionalVariantTypeAlias() {
        // Given OptionalVariant type alias
        let config: ConfigurationData<RequiredMode>.OptionalVariant = ConfigurationData<OptionalMode>(
            general: nil,
            spaces: nil,
            groups: nil,
            advanced: nil
        )

        // Then should be correct type
        expect(String(describing: type(of: config))) == String(describing: ConfigurationData<OptionalMode>.self)
    }

    func testRequiredVariantTypeAlias() {
        // Given RequiredVariant type alias
        let defaults = createDefaultRequiredSettings()
        let config: ConfigurationData<OptionalMode>.RequiredVariant = ConfigurationData<RequiredMode>(
            general: defaults.general,
            spaces: defaults.spaces,
            groups: defaults.groups,
            advanced: defaults.advanced
        )

        // Then should be correct type
        expect(String(describing: type(of: config))) == String(describing: ConfigurationData<RequiredMode>.self)
    }

    // MARK: - Integration Scenarios

    func testCompleteConfigurationFromTOML() throws {
        // Simulates loading configuration from TOML file
        // Given partial TOML data (only general section provided)
        let tomlData = ConfigurationData<OptionalMode>(
            general: GeneralSettings<RequiredMode>(
                showWindowTitles: true,
                aeroSpacePath: "/opt/aerospace",
                themeMode: .preset,
                themePresetColorProperties: .nord,
                themePresetGeometricProperties: GeometricProperties(),
                themePresetEffectProperties: EffectProperties()
            ),
            spaces: nil, // Not in TOML
            groups: nil, // Not in TOML
            advanced: nil // Not in TOML
        )

        // And application defaults
        let defaults = createDefaultRequiredSettings()
        let defaultConfig = ConfigurationData<RequiredMode>(
            general: defaults.general,
            spaces: defaults.spaces,
            groups: defaults.groups,
            advanced: defaults.advanced
        )

        // When merging with defaults
        let merged = try ConfigurationData<RequiredMode>.decode(from: tomlData, defaultValue: defaultConfig)

        // Then should have complete configuration
        expect(merged.general.aeroSpacePath) == "/opt/aerospace"
        expect(merged.spaces.showEmptySpaces).to(
            equal(defaultConfig.spaces.showEmptySpaces),
            description: "Should use default"
        )
        expect(merged.groups.showGroups) == defaultConfig.groups.showGroups
        expect(merged.advanced.logLevel) == defaultConfig.advanced.logLevel
    }

    func testFullyCustomizedConfiguration() {
        // Given fully customized configuration
        let general = GeneralSettings<RequiredMode>(
            showWindowTitles: true,
            aeroSpacePath: "/custom/aerospace",
            themeMode: .glass,
            themePresetColorProperties: .tokyoNightStorm,
            themePresetGeometricProperties: GeometricProperties(cornerRadius: 10, borderWidth: 2),
            themePresetEffectProperties: EffectProperties(
                backgroundOpacity: 0.9,
                backgroundBlurRadius: 8,
                borderOpacity: 1.0
            )
        )

        let spaces = SpacesSettings<RequiredMode>(
            showEmptySpaces: true,
            spacesColorProperties: [
                ConfigurationDefaults.spaceColorProperties,
                ConfigurationDefaults.spaceColorProperties
            ],
            spacesGeometricProperties: [GeometricProperties(), GeometricProperties()],
            spacesEffectProperties: [EffectProperties(), EffectProperties()],
            spacesAppearanceMode: "per-space",
            globalSpacesColorProperties: ConfigurationDefaults.spaceColorProperties,
            globalSpacesGeometricProperties: GeometricProperties(),
            globalSpacesEffectProperties: EffectProperties()
        )

        let groups = GroupsSettings<RequiredMode>(
            showGroups: true,
            groups: [
                Group(
                    id: 1,
                    startIndex: 1,
                    endIndex: 5,
                    colorProperties: ConfigurationDefaults.groupsGlobalColorProperties,
                    geometricProperties: GeometricProperties(),
                    effectProperties: EffectProperties()
                ),
                Group(
                    id: 2,
                    startIndex: 6,
                    endIndex: 10,
                    colorProperties: ConfigurationDefaults.groupsGlobalColorProperties,
                    geometricProperties: GeometricProperties(),
                    effectProperties: EffectProperties()
                )
            ],
            groupsAppearanceMode: "per-group",
            globalGroupsColorProperties: ConfigurationDefaults.groupsGlobalColorProperties,
            globalGroupsGeometricProperties: GeometricProperties(),
            globalGroupsEffectProperties: EffectProperties()
        )

        let advanced = AdvancedSettings<RequiredMode>(
            focusWindowOnClick: true,
            enablePerformanceMetrics: true,
            isOptimizedPerformanceEnabled: true,
            logLevel: "debug"
        )

        let config = ConfigurationData<RequiredMode>(
            general: general,
            spaces: spaces,
            groups: groups,
            advanced: advanced
        )

        // Then should have all customizations
        expect(config.general.showWindowTitles) == true
        expect(config.spaces.showEmptySpaces) == true
        expect(config.groups.showGroups) == true
        expect(config.groups.groups.count) == 2
        expect(config.advanced.enablePerformanceMetrics) == true
    }
}
