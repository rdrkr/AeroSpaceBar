// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation
import SwiftUI

/// Configuration struct containing all default values for application settings.
///
/// This struct centralizes all default configuration values, making it easy to
/// manage and modify defaults across the application. It follows the domain-driven
/// design pattern by keeping configuration concerns within the domain layer.
public enum ConfigurationDefaults {
    #if DEBUG
        private static let debugMode = true
    #else
        private static let debugMode = false
    #endif

    // MARK: - Application Settings

    /// Whether to show window titles.
    public static let showWindowTitles = true

    /// Default configuration file path.
    public static var configFilePath: String {
        NSHomeDirectory() + "/.config/aerospacebar/aerospacebar.toml"
    }

    /// Whether to focus a window when clicking on it.
    public static let focusWindowOnClick = true

    /// Whether to show empty spaces in the interface.
    public static let showEmptySpaces = false

    /// Whether to show the Apple Button as a space background.
    public static let showAppleButtonAsSpace = false

    /// Whether to show groups in the interface.
    public static let showGroups = true

    /// Whether to enable performance metrics collection.
    public static let enablePerformanceMetrics = debugMode

    /// Whether to enable optimized performance behavior.
    public static let isOptimizedPerformanceEnabled = true

    /// Whether the Quick Hide feature is enabled by default.
    public static let quickHideEnabled = true

    /// Default modifier key for the Quick Hide feature.
    public static let quickHideTriggerKey: QuickHideTriggerKey = .fn

    /// Default log level for application logging.
    public static let logLevel = debugMode ? Logger.Level.debug : Logger.Level.info

    // MARK: - UI Configuration

    /// Default height of the menu bar interface in points.
    public static let menuBarHeight: Double = 39

    /// Default vertical padding for the menu bar interface in points.
    public static let menuBarVerticalPadding: Double = 1

    /// Default horizontal padding for the menu bar interface in points.
    public static let menuBarHorizontalPadding: Double = 50

    /// Default spacing between widgets in the menu bar in points.
    public static let widgetSpacing: Double = 4

    /// Default size of window icons in points.
    public static let windowIconSize: Double = 22

    /// Default size of settings icons in points.
    public static let settingsIconSmallSize: Double = 13.0

    /// Default color properties for space elements.
    public static let spaceColorProperties: ColorProperties = .init(
        backgroundTintColor: .white,
        borderTintColor: .white,
        foregroundColor: .white
    )

    /// Default geometric properties for space elements.
    public static let spaceGeometricProperties: GeometricProperties = .init(
        cornerRadius: 14,
        borderWidth: 0.0
    )

    /// Default effect properties for space elements.
    public static let spaceEffectProperties: EffectProperties = .init(
        backgroundOpacity: 0.2,
        backgroundBlurRadius: 0.0,
        borderOpacity: 0.8
    )

    /// Default color properties for the Apple Button element.
    public static let appleButtonColorProperties: ColorProperties = .init(
        backgroundTintColor: .white,
        borderTintColor: .white,
        foregroundColor: .white
    )

    /// Default geometric properties for the Apple Button element.
    public static let appleButtonGeometricProperties: GeometricProperties = .init(
        cornerRadius: 14,
        borderWidth: 0.0
    )

    /// Default effect properties for the Apple Button element.
    public static let appleButtonEffectProperties: EffectProperties = .init(
        backgroundOpacity: 0.2,
        backgroundBlurRadius: 0.0,
        borderOpacity: 0.8
    )

    /// Default space configuration for organizing spaces.
    public static let spacesColorProperties: [ColorProperties] = []

    /// Default geometric configuration for organizing spaces.
    public static let spacesGeometricProperties: [GeometricProperties] = []

    /// Default effect configuration for organizing spaces.
    public static let spacesEffectProperties: [EffectProperties] = []

    /// Default spaces appearance mode.
    public static let spacesAppearanceMode: SpacesAppearanceMode = .allSpaces

    /// Default group configuration for menu bar applications.
    public static let groups: [Domain.Group] = Group.singleGroup

    /// Default groups appearance mode.
    public static let groupsAppearanceMode: GroupsAppearanceMode = .matchSpaces

    /// Default global color properties for all groups.
    public static let groupsGlobalColorProperties: ColorProperties = .init(
        backgroundTintColor: spaceColorProperties.backgroundTintColor,
        borderTintColor: spaceColorProperties.borderTintColor,
        foregroundColor: .primary
    )

    /// Default geometric properties for all groups.
    public static let groupsGlobalGeometricProperties: GeometricProperties = .init(
        cornerRadius: spaceGeometricProperties.cornerRadius,
        borderWidth: spaceGeometricProperties.borderWidth
    )

    /// Default effect properties for all groups.
    public static let groupsGlobalEffectProperties: EffectProperties = .init(
        backgroundOpacity: min(spaceEffectProperties.backgroundOpacity, 0.2),
        backgroundBlurRadius: spaceEffectProperties.backgroundBlurRadius,
        borderOpacity: spaceEffectProperties.borderOpacity
    )

    /// Default theme mode for visual customization.
    public static let themeMode: ThemeMode = .preset

    /// Default theme preset for preset mode.
    public static let themePresetColorProperties: ThemePresetColorProperties = .catppuccinMocha

    /// Default geometric properties for visual containers using theme preset.
    public static let themePresetGeometricProperties: GeometricProperties = .init(
        cornerRadius: spaceGeometricProperties.cornerRadius,
        borderWidth: 2.0
    )

    /// Default effect properties for visual containers using theme preset.
    public static let themePresetEffectProperties: EffectProperties = .init(
        backgroundOpacity: 0.8,
        backgroundBlurRadius: 0.8,
        borderOpacity: 0.8
    )
}
