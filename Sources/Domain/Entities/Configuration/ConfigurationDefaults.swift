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

    /// Whether to show window titles by default.
    public static let showWindowTitles = true

    /// Default configuration file path.
    public static var configFilePath: String {
        NSHomeDirectory() + "/.config/aerospacebar/aerospacebar.toml"
    }

    /// Whether to focus a window when clicking on it by default.
    public static let focusWindowOnClick = true

    /// Whether to show empty spaces in the interface by default.
    public static let showEmptySpaces = false

    /// Whether to show groups in the interface by default.
    public static let showGroups = true

    /// Whether to enable performance metrics collection by default.
    public static let enablePerformanceMetrics = debugMode

    /// Whether to enable optimized performance behavior by default.
    public static let isOptimizedPerformanceEnabled = true

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

    /// Default visual configuration for space elements.
    public static let defaultSpaceVisualConfig: VisualProperties = .init(
        backgroundTintColor: .white,
        backgroundOpacity: 0.2,
        backgroundBlurRadius: 0.0,
        borderTintColor: .white,
        borderOpacity: 0.0,
        borderWidth: 0.0,
        cornerRadius: 14,
        foregroundColor: .white
    )

    /// Default space configuration for organizing spaces.
    public static let spacesVisualConfiguration: [VisualProperties] = []

    /// Default spaces appearance mode.
    public static let spacesAppearanceMode: SpacesAppearanceMode = .allSpaces

    /// Default group configuration for menu bar applications.
    public static let groups: [Domain.Group] = Group.singleGroup

    /// Default groups appearance mode.
    public static let groupsAppearanceMode: GroupsAppearanceMode = .matchSpaces

    /// Default global visual configuration for all groups.
    public static let defaultGroupsGlobalVisualConfig: VisualProperties = .init(
        backgroundTintColor: defaultSpaceVisualConfig.backgroundTintColor,
        backgroundOpacity: min(defaultSpaceVisualConfig.backgroundOpacity, 0.2),
        backgroundBlurRadius: defaultSpaceVisualConfig.backgroundBlurRadius,
        borderTintColor: defaultSpaceVisualConfig.borderTintColor,
        borderOpacity: defaultSpaceVisualConfig.borderOpacity,
        borderWidth: defaultSpaceVisualConfig.borderWidth,
        cornerRadius: defaultSpaceVisualConfig.cornerRadius,
        foregroundColor: .primary
    )
}
