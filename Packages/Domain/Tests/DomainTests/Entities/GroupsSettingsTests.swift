// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Nimble
import XCTest

/// Tests for GroupsSettings class.
///
/// These tests verify GroupsSettings with both OptionalMode and RequiredMode,
/// decode() merging logic, groups array handling, and type aliases.
@MainActor
final class GroupsSettingsTests: XCTestCase {
    // MARK: - RequiredMode Initialization Tests

    func testRequiredModeInitialization() {
        // Given required mode parameters
        let showGroups = true
        let groups = [
            Group(
                id: 1,
                startIndex: 1,
                endIndex: 5,
                colorProperties: ConfigurationDefaults.groupsGlobalColorProperties,
                geometricProperties: GeometricProperties(),
                effectProperties: EffectProperties()
            )
        ]
        let appearanceMode = "per-group"
        let colorProps = ConfigurationDefaults.groupsGlobalColorProperties
        let geometricProps = GeometricProperties()
        let effectProps = EffectProperties()

        // When creating required settings
        let settings = GroupsSettings<RequiredMode>(
            showGroups: showGroups,
            groups: groups,
            groupsAppearanceMode: appearanceMode,
            globalGroupsColorProperties: colorProps,
            globalGroupsGeometricProperties: geometricProps,
            globalGroupsEffectProperties: effectProps
        )

        // Then all properties should be set
        expect(settings.showGroups) == showGroups
        expect(settings.groups) == groups
        expect(settings.groupsAppearanceMode) == appearanceMode
        expect(settings.globalGroupsColorProperties) == colorProps
        expect(settings.globalGroupsGeometricProperties) == geometricProps
        expect(settings.globalGroupsEffectProperties) == effectProps
    }

    // MARK: - OptionalMode Initialization Tests

    func testOptionalModeInitializationWithValues() {
        // Given optional mode parameters
        let showGroups: Bool? = true
        let groups: [Group]? = [
            Group(
                id: 1,
                startIndex: 1,
                endIndex: 3,
                colorProperties: ConfigurationDefaults.groupsGlobalColorProperties,
                geometricProperties: GeometricProperties(),
                effectProperties: EffectProperties()
            )
        ]
        let appearanceMode: String? = "all-groups"
        let colorProps: ColorProperties? = ConfigurationDefaults.groupsGlobalColorProperties
        let geometricProps: GeometricProperties? = GeometricProperties()
        let effectProps: EffectProperties? = EffectProperties()

        // When creating optional settings
        let settings = GroupsSettings<OptionalMode>(
            showGroups: showGroups,
            groups: groups,
            groupsAppearanceMode: appearanceMode,
            globalGroupsColorProperties: colorProps,
            globalGroupsGeometricProperties: geometricProps,
            globalGroupsEffectProperties: effectProps
        )

        // Then all properties should be set
        expect(settings.showGroups) == showGroups
        expect(settings.groups) == groups
        expect(settings.groupsAppearanceMode) == appearanceMode
        expect(settings.globalGroupsColorProperties) == colorProps
        expect(settings.globalGroupsGeometricProperties) == geometricProps
        expect(settings.globalGroupsEffectProperties) == effectProps
    }

    func testOptionalModeInitializationWithNils() {
        // Given optional mode with nil values
        let settings = GroupsSettings<OptionalMode>(
            showGroups: nil,
            groups: nil,
            groupsAppearanceMode: nil,
            globalGroupsColorProperties: nil,
            globalGroupsGeometricProperties: nil,
            globalGroupsEffectProperties: nil
        )

        // Then all properties should be nil
        expect(settings.showGroups).to(beNil())
        expect(settings.groups).to(beNil())
        expect(settings.groupsAppearanceMode).to(beNil())
        expect(settings.globalGroupsColorProperties).to(beNil())
        expect(settings.globalGroupsGeometricProperties).to(beNil())
        expect(settings.globalGroupsEffectProperties).to(beNil())
    }

    // MARK: - Decode Method Tests

    func testDecodeWithAllOptionalValuesNil() throws {
        // Given optional settings with all nil values
        let optional = GroupsSettings<OptionalMode>(
            showGroups: nil,
            groups: nil,
            groupsAppearanceMode: nil,
            globalGroupsColorProperties: nil,
            globalGroupsGeometricProperties: nil,
            globalGroupsEffectProperties: nil
        )

        // And default settings
        let defaultSettings = GroupsSettings<RequiredMode>(
            showGroups: false,
            groups: [],
            groupsAppearanceMode: "per-group",
            globalGroupsColorProperties: ConfigurationDefaults.groupsGlobalColorProperties,
            globalGroupsGeometricProperties: GeometricProperties(),
            globalGroupsEffectProperties: EffectProperties()
        )

        // When decoding
        let decoded = try GroupsSettings<RequiredMode>.decode(
            from: optional,
            defaultValue: defaultSettings
        )

        // Then should use all default values
        expect(decoded.showGroups) == defaultSettings.showGroups
        expect(decoded.groups) == defaultSettings.groups
        expect(decoded.groupsAppearanceMode) == defaultSettings.groupsAppearanceMode
        expect(decoded.globalGroupsColorProperties) == defaultSettings.globalGroupsColorProperties
        expect(decoded.globalGroupsGeometricProperties) == defaultSettings.globalGroupsGeometricProperties
        expect(decoded.globalGroupsEffectProperties) == defaultSettings.globalGroupsEffectProperties
    }

    func testDecodeWithAllOptionalValuesSet() throws {
        // Given optional settings with all values set
        let customGroups = [
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
        ]
        let colorProps = ColorProperties(backgroundTintColor: .red, borderTintColor: .blue, foregroundColor: .white)
        let geometricProps = GeometricProperties(cornerRadius: 8, borderWidth: 2)
        let effectProps = EffectProperties(backgroundOpacity: 0.7, backgroundBlurRadius: 10, borderOpacity: 0.9)

        let optional = GroupsSettings<OptionalMode>(
            showGroups: true,
            groups: customGroups,
            groupsAppearanceMode: "all-groups",
            globalGroupsColorProperties: colorProps,
            globalGroupsGeometricProperties: geometricProps,
            globalGroupsEffectProperties: effectProps
        )

        // And default settings (different values)
        let defaultSettings = GroupsSettings<RequiredMode>(
            showGroups: false,
            groups: [],
            groupsAppearanceMode: "per-group",
            globalGroupsColorProperties: ConfigurationDefaults.groupsGlobalColorProperties,
            globalGroupsGeometricProperties: GeometricProperties(),
            globalGroupsEffectProperties: EffectProperties()
        )

        // When decoding
        let decoded = try GroupsSettings<RequiredMode>.decode(
            from: optional,
            defaultValue: defaultSettings
        )

        // Then should use all optional values
        expect(decoded.showGroups) == true
        expect(decoded.groups) == customGroups
        expect(decoded.groupsAppearanceMode) == "all-groups"
        expect(decoded.globalGroupsColorProperties) == colorProps
        expect(decoded.globalGroupsGeometricProperties) == geometricProps
        expect(decoded.globalGroupsEffectProperties) == effectProps
    }

    func testDecodeWithMixedOptionalValues() throws {
        // Given optional settings with mixed values
        _ = [
            Group(
                id: 1,
                startIndex: 1,
                endIndex: 3,
                colorProperties: ConfigurationDefaults.groupsGlobalColorProperties,
                geometricProperties: GeometricProperties(),
                effectProperties: EffectProperties()
            )
        ]

        let optional = GroupsSettings<OptionalMode>(
            showGroups: true,
            groups: nil, // Will use default
            groupsAppearanceMode: "all-groups",
            globalGroupsColorProperties: nil, // Will use default
            globalGroupsGeometricProperties: GeometricProperties(cornerRadius: 5, borderWidth: 1),
            globalGroupsEffectProperties: nil // Will use default
        )

        // And default settings
        let defaultSettings = GroupsSettings<RequiredMode>(
            showGroups: false,
            groups: [
                Group(
                    id: 0,
                    startIndex: 1,
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

        // When decoding
        let decoded = try GroupsSettings<RequiredMode>.decode(
            from: optional,
            defaultValue: defaultSettings
        )

        // Then should merge correctly
        expect(decoded.showGroups) == true
        expect(decoded.groups) == defaultSettings.groups
        expect(decoded.groupsAppearanceMode) == "all-groups"
        expect(decoded.globalGroupsColorProperties).to(
            equal(defaultSettings.globalGroupsColorProperties),
            description: "Should use default value"
        )
        expect(decoded.globalGroupsGeometricProperties.cornerRadius).to(
            equal(5),
            description: "Should use optional value"
        )
        expect(decoded.globalGroupsEffectProperties).to(
            equal(defaultSettings.globalGroupsEffectProperties),
            description: "Should use default value"
        )
    }

    // MARK: - Groups Array Tests

    func testEmptyGroupsArray() {
        // Given empty groups array
        let settings = GroupsSettings<RequiredMode>(
            showGroups: true,
            groups: [],
            groupsAppearanceMode: "per-group",
            globalGroupsColorProperties: ConfigurationDefaults.groupsGlobalColorProperties,
            globalGroupsGeometricProperties: GeometricProperties(),
            globalGroupsEffectProperties: EffectProperties()
        )

        // Then should accept empty array
        expect(settings.groups.isEmpty) == true
    }

    func testMultipleGroups() {
        // Given multiple groups
        let groups = [
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
            ),
            Group(
                id: 3,
                startIndex: 11,
                endIndex: 15,
                colorProperties: ConfigurationDefaults.groupsGlobalColorProperties,
                geometricProperties: GeometricProperties(),
                effectProperties: EffectProperties()
            )
        ]

        let settings = GroupsSettings<RequiredMode>(
            showGroups: true,
            groups: groups,
            groupsAppearanceMode: "per-group",
            globalGroupsColorProperties: ConfigurationDefaults.groupsGlobalColorProperties,
            globalGroupsGeometricProperties: GeometricProperties(),
            globalGroupsEffectProperties: EffectProperties()
        )

        // Then should store all groups
        expect(settings.groups.count) == 3
        expect(settings.groups) == groups
    }

    // MARK: - Appearance Mode Tests

    func testAppearanceModeValues() {
        // Given different appearance mode values
        let modes = ["per-group", "all-groups"]

        for mode in modes {
            // When creating settings with each mode
            let settings = GroupsSettings<RequiredMode>(
                showGroups: true,
                groups: [],
                groupsAppearanceMode: mode,
                globalGroupsColorProperties: ConfigurationDefaults.groupsGlobalColorProperties,
                globalGroupsGeometricProperties: GeometricProperties(),
                globalGroupsEffectProperties: EffectProperties()
            )

            // Then should accept the mode
            expect(settings.groupsAppearanceMode) == mode
        }
    }

    // MARK: - Type Alias Tests

    func testOptionalVariantTypeAlias() {
        // Given OptionalVariant type alias
        let settings: GroupsSettings<RequiredMode>.OptionalVariant = GroupsSettings<OptionalMode>(
            showGroups: nil,
            groups: nil,
            groupsAppearanceMode: nil,
            globalGroupsColorProperties: nil,
            globalGroupsGeometricProperties: nil,
            globalGroupsEffectProperties: nil
        )

        // Then should be correct type
        expect(type(of: settings) == GroupsSettings<OptionalMode>.self) == true
    }

    func testRequiredVariantTypeAlias() {
        // Given RequiredVariant type alias
        let settings: GroupsSettings<OptionalMode>.RequiredVariant = GroupsSettings<RequiredMode>(
            showGroups: false,
            groups: [],
            groupsAppearanceMode: "",
            globalGroupsColorProperties: ConfigurationDefaults.groupsGlobalColorProperties,
            globalGroupsGeometricProperties: GeometricProperties(),
            globalGroupsEffectProperties: EffectProperties()
        )

        // Then should be correct type
        expect(type(of: settings) == GroupsSettings<RequiredMode>.self) == true
    }

    // MARK: - Integration Scenarios

    func testDisabledGroupsConfiguration() {
        // Given groups disabled
        let settings = GroupsSettings<RequiredMode>(
            showGroups: false,
            groups: [],
            groupsAppearanceMode: "per-group",
            globalGroupsColorProperties: ConfigurationDefaults.groupsGlobalColorProperties,
            globalGroupsGeometricProperties: GeometricProperties(),
            globalGroupsEffectProperties: EffectProperties()
        )

        // Then should have disabled configuration
        expect(settings.showGroups) == false
        expect(settings.groups.isEmpty) == true
    }

    func testFullyConfiguredGroups() {
        // Given fully configured groups
        let groups = [
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
        ]

        let settings = GroupsSettings<RequiredMode>(
            showGroups: true,
            groups: groups,
            groupsAppearanceMode: "all-groups",
            globalGroupsColorProperties: ColorProperties(
                backgroundTintColor: .blue,
                borderTintColor: .white,
                foregroundColor: .white
            ),
            globalGroupsGeometricProperties: GeometricProperties(cornerRadius: 6, borderWidth: 1),
            globalGroupsEffectProperties: EffectProperties(
                backgroundOpacity: 0.8,
                backgroundBlurRadius: 5,
                borderOpacity: 1.0
            )
        )

        // Then should have complete configuration
        expect(settings.showGroups) == true
        expect(settings.groups.count) == 2
        expect(settings.groupsAppearanceMode) == "all-groups"
    }
}
