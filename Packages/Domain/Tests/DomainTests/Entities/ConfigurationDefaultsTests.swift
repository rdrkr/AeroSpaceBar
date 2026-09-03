// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Nimble
import XCTest

/// Tests for ConfigurationDefaults enum.
///
/// These tests verify all default values for application settings, including
/// conditional DEBUG/RELEASE defaults, computed properties, and UI configuration.
@MainActor
final class ConfigurationDefaultsTests: XCTestCase {
    // MARK: - Application Settings Tests

    func testShowWindowTitlesDefault() {
        // Given default value
        // When accessing showWindowTitles
        let value = ConfigurationDefaults.showWindowTitles

        // Then should be true
        expect(value) == true
    }

    func testConfigFilePathDefault() {
        // Given default value
        // When accessing configFilePath
        let path = ConfigurationDefaults.configFilePath

        // Then should be in user's home directory
        expect(path.contains(NSHomeDirectory())) == true
        expect(path.contains(".config/aerospacebar")) == true
        expect(path.hasSuffix("aerospacebar.toml")) == true
    }

    func testFocusWindowOnClickDefault() {
        // Given default value
        // When accessing focusWindowOnClick
        let value = ConfigurationDefaults.focusWindowOnClick

        // Then should be true
        expect(value) == true
    }

    func testShowEmptySpacesDefault() {
        // Given default value
        // When accessing showEmptySpaces
        let value = ConfigurationDefaults.showEmptySpaces

        // Then should be false
        expect(value) == false
    }

    func testShowGroupsDefault() {
        // Given default value
        // When accessing showGroups
        let value = ConfigurationDefaults.showGroups

        // Then should be true
        expect(value) == true
    }

    // MARK: - DEBUG/RELEASE Build Tests

    #if DEBUG
        func testEnablePerformanceMetricsInDebugMode() {
            // Given DEBUG build
            // When accessing enablePerformanceMetrics
            let value = ConfigurationDefaults.enablePerformanceMetrics

            // Then should be true in DEBUG
            expect(value) == true
        }

        func testLogLevelInDebugMode() {
            // Given DEBUG build
            // When accessing logLevel
            let level = ConfigurationDefaults.logLevel

            // Then should be debug level
            expect(level) == Logger.Level.debug
        }
    #else
        func testEnablePerformanceMetricsInReleaseMode() {
            // Given RELEASE build
            // When accessing enablePerformanceMetrics
            let value = ConfigurationDefaults.enablePerformanceMetrics

            // Then should be false in RELEASE
            expect(value) == false
        }

        func testLogLevelInReleaseMode() {
            // Given RELEASE build
            // When accessing logLevel
            let level = ConfigurationDefaults.logLevel

            // Then should be info level
            expect(level) == Logger.Level.info
        }
    #endif

    func testIsOptimizedPerformanceEnabledDefault() {
        // Given default value
        // When accessing isOptimizedPerformanceEnabled
        let value = ConfigurationDefaults.isOptimizedPerformanceEnabled

        // Then should be true
        expect(value) == true
    }

    // MARK: - UI Configuration Tests

    func testMenuBarHeightDefault() {
        // Given default value
        // When accessing menuBarHeight
        let height = ConfigurationDefaults.menuBarHeight

        // Then should be reasonable value
        expect(height) == 39
        expect(height).to(beGreaterThan(0), description: "Height should be positive")
    }

    func testMenuBarVerticalPaddingDefault() {
        // Given default value
        // When accessing menuBarVerticalPadding
        let padding = ConfigurationDefaults.menuBarVerticalPadding

        // Then should be small positive value
        expect(padding) == 1
        expect(padding).to(beGreaterThan(0), description: "Padding should be positive")
    }

    func testMenuBarHorizontalPaddingDefault() {
        // Given default value
        // When accessing menuBarHorizontalPadding
        let padding = ConfigurationDefaults.menuBarHorizontalPadding

        // Then should be reasonable value
        expect(padding) == 49
        expect(padding).to(beGreaterThan(0), description: "Padding should be positive")
    }

    func testWidgetSpacingDefault() {
        // Given default value
        // When accessing widgetSpacing
        let spacing = ConfigurationDefaults.widgetSpacing

        // Then should be small positive value
        expect(spacing) == 4
        expect(spacing).to(beGreaterThan(0), description: "Spacing should be positive")
    }

    func testWindowIconSizeDefault() {
        // Given default value
        // When accessing windowIconSize
        let size = ConfigurationDefaults.windowIconSize

        // Then should be reasonable value
        expect(size) == 22
        expect(size).to(beGreaterThan(0), description: "Size should be positive")
    }

    func testSettingsIconSmallSizeDefault() {
        // Given default value
        // When accessing settingsIconSmallSize
        let size = ConfigurationDefaults.settingsIconSmallSize

        // Then should be reasonable value
        expect(size) == 13.0
        expect(size).to(beGreaterThan(0), description: "Size should be positive")
    }

    // MARK: - Space Visual Properties Tests

    func testSpaceColorPropertiesDefault() {
        // Given default value
        // When accessing spaceColorProperties
        let props = ConfigurationDefaults.spaceColorProperties

        // Then should have white colors
        expect(props.backgroundTintColor) == .white
        expect(props.borderTintColor) == .white
        expect(props.foregroundColor) == .white
    }

    func testSpaceGeometricPropertiesDefault() {
        // Given default value
        // When accessing spaceGeometricProperties
        let props = ConfigurationDefaults.spaceGeometricProperties

        // Then should have reasonable values
        expect(props.cornerRadius) == 14
        expect(props.borderWidth) == 0.0
        expect(props.cornerRadius) > 0
    }

    func testSpaceEffectPropertiesDefault() {
        // Given default value
        // When accessing spaceEffectProperties
        let props = ConfigurationDefaults.spaceEffectProperties

        // Then should have reasonable opacity values
        expect(props.backgroundOpacity) == 0.2
        expect(props.backgroundBlurRadius) == 0.0
        expect(props.borderOpacity) == 0.8
        expect(props.backgroundOpacity) > 0
        expect(props.backgroundOpacity) < 1
        expect(props.borderOpacity) > 0
        expect(props.borderOpacity) < 1
    }

    // MARK: - Spaces Configuration Tests

    func testSpacesColorPropertiesDefault() {
        // Given default value
        // When accessing spacesColorProperties
        let props = ConfigurationDefaults.spacesColorProperties

        // Then should be empty array
        expect(props.isEmpty) == true
    }

    func testSpacesGeometricPropertiesDefault() {
        // Given default value
        // When accessing spacesGeometricProperties
        let props = ConfigurationDefaults.spacesGeometricProperties

        // Then should be empty array
        expect(props.isEmpty) == true
    }

    func testSpacesEffectPropertiesDefault() {
        // Given default value
        // When accessing spacesEffectProperties
        let props = ConfigurationDefaults.spacesEffectProperties

        // Then should be empty array
        expect(props.isEmpty) == true
    }

    func testSpacesAppearanceModeDefault() {
        // Given default value
        // When accessing spacesAppearanceMode
        let mode = ConfigurationDefaults.spacesAppearanceMode

        // Then should be allSpaces mode
        expect(mode) == .allSpaces
    }

    // MARK: - Groups Configuration Tests

    func testGroupsDefault() {
        // Given default value
        // When accessing groups
        let groups = ConfigurationDefaults.groups

        // Then should have single group
        expect(groups) == Group.singleGroup
        expect(groups.count) == 1
    }

    func testGroupsAppearanceModeDefault() {
        // Given default value
        // When accessing groupsAppearanceMode
        let mode = ConfigurationDefaults.groupsAppearanceMode

        // Then should be matchSpaces mode
        expect(mode) == .matchSpaces
    }

    func testGroupsGlobalColorPropertiesDefault() {
        // Given default value
        // When accessing groupsGlobalColorProperties
        let props = ConfigurationDefaults.groupsGlobalColorProperties

        // Then should inherit from space properties with primary foreground
        expect(props.backgroundTintColor).to(
            equal(ConfigurationDefaults.spaceColorProperties.backgroundTintColor),
            description: "Should inherit background from space"
        )
        expect(props.borderTintColor).to(
            equal(ConfigurationDefaults.spaceColorProperties.borderTintColor),
            description: "Should inherit border from space"
        )
        expect(props.foregroundColor) == .primary
    }

    func testGroupsGlobalGeometricPropertiesDefault() {
        // Given default value
        // When accessing groupsGlobalGeometricProperties
        let props = ConfigurationDefaults.groupsGlobalGeometricProperties

        // Then should inherit from space properties
        expect(props.cornerRadius).to(
            equal(ConfigurationDefaults.spaceGeometricProperties.cornerRadius),
            description: "Should inherit corner radius from space"
        )
        expect(props.borderWidth).to(
            equal(ConfigurationDefaults.spaceGeometricProperties.borderWidth),
            description: "Should inherit border width from space"
        )
    }

    func testGroupsGlobalEffectPropertiesDefault() {
        // Given default value
        // When accessing groupsGlobalEffectProperties
        let props = ConfigurationDefaults.groupsGlobalEffectProperties

        // Then should have conservative opacity with inherited other properties
        expect(props.backgroundOpacity) == 0.2
        expect(props.backgroundBlurRadius).to(
            equal(ConfigurationDefaults.spaceEffectProperties.backgroundBlurRadius),
            description: "Should inherit blur radius from space"
        )
        expect(props.borderOpacity).to(
            equal(ConfigurationDefaults.spaceEffectProperties.borderOpacity),
            description: "Should inherit border opacity from space"
        )
    }

    // MARK: - Theme Configuration Tests

    func testThemeModeDefault() {
        // Given default value
        // When accessing themeMode
        let mode = ConfigurationDefaults.themeMode

        // Then should be preset mode
        expect(mode) == .preset
    }

    func testThemePresetColorPropertiesDefault() {
        // Given default value
        // When accessing themePresetColorProperties
        let preset = ConfigurationDefaults.themePresetColorProperties

        // Then should be Catppuccin Mocha
        expect(preset) == .catppuccinMocha
    }

    func testThemePresetGeometricPropertiesDefault() {
        // Given default value
        // When accessing themePresetGeometricProperties
        let props = ConfigurationDefaults.themePresetGeometricProperties

        // Then should have themed values
        expect(props.cornerRadius).to(
            equal(ConfigurationDefaults.spaceGeometricProperties.cornerRadius),
            description: "Should inherit corner radius from space"
        )
        expect(props.borderWidth) == 2.0
    }

    func testThemePresetEffectPropertiesDefault() {
        // Given default value
        // When accessing themePresetEffectProperties
        let props = ConfigurationDefaults.themePresetEffectProperties

        // Then should have themed values
        expect(props.backgroundOpacity) == 0.8
        expect(props.backgroundBlurRadius) == 0.8
        expect(props.borderOpacity) == 0.8
        expect(props.backgroundOpacity) > 0
        expect(props.backgroundOpacity) < 1
        expect(props.borderOpacity) > 0
        expect(props.borderOpacity) < 1
    }

    // MARK: - Consistency Tests

    func testGroupsInheritFromSpaces() {
        // Given group and space defaults
        let spaceColor = ConfigurationDefaults.spaceColorProperties
        let spaceGeometric = ConfigurationDefaults.spaceGeometricProperties
        let spaceEffect = ConfigurationDefaults.spaceEffectProperties
        let groupColor = ConfigurationDefaults.groupsGlobalColorProperties
        let groupGeometric = ConfigurationDefaults.groupsGlobalGeometricProperties
        let groupEffect = ConfigurationDefaults.groupsGlobalEffectProperties

        // Then groups should inherit most properties from spaces
        expect(groupColor.backgroundTintColor) == spaceColor.backgroundTintColor
        expect(groupColor.borderTintColor) == spaceColor.borderTintColor
        expect(groupGeometric.cornerRadius) == spaceGeometric.cornerRadius
        expect(groupGeometric.borderWidth) == spaceGeometric.borderWidth
        expect(groupEffect.backgroundBlurRadius) == spaceEffect.backgroundBlurRadius
        expect(groupEffect.borderOpacity) == spaceEffect.borderOpacity
    }

    func testThemePresetsUseSpaceGeometry() {
        // Given theme and space defaults
        let spaceGeometric = ConfigurationDefaults.spaceGeometricProperties
        let themeGeometric = ConfigurationDefaults.themePresetGeometricProperties

        // Then theme should inherit corner radius
        expect(themeGeometric.cornerRadius).to(
            equal(spaceGeometric.cornerRadius),
            description: "Theme should use space corner radius"
        )
    }

    func testAllOpacityValuesInValidRange() {
        // Given all effect properties
        let props = [
            ConfigurationDefaults.spaceEffectProperties,
            ConfigurationDefaults.groupsGlobalEffectProperties,
            ConfigurationDefaults.themePresetEffectProperties
        ]

        // When checking opacity values
        for prop in props {
            // Then all should be in valid range [0, 1]
            expect(prop.backgroundOpacity) > 0
            expect(prop.backgroundOpacity) < 1
            expect(prop.borderOpacity) > 0
            expect(prop.borderOpacity) < 1
        }
    }

    func testAllSizesArePositive() {
        // Given all size values
        let sizes = [
            ConfigurationDefaults.menuBarHeight,
            ConfigurationDefaults.menuBarVerticalPadding,
            ConfigurationDefaults.menuBarHorizontalPadding,
            ConfigurationDefaults.widgetSpacing,
            ConfigurationDefaults.windowIconSize,
            ConfigurationDefaults.settingsIconSmallSize
        ]

        // When checking sizes
        for size in sizes {
            // Then all should be positive
            expect(size).to(beGreaterThan(0), description: "Size \(size) should be positive")
        }
    }
}
