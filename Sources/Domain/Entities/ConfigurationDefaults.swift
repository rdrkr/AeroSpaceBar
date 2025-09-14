// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation
import SwiftUI

/// Configuration struct containing all default values for application settings.
///
/// This struct centralizes all default configuration values, making it easy to
/// manage and modify defaults across the application. It follows the domain-driven
/// design pattern by keeping configuration concerns within the domain layer.
@MainActor
public struct ConfigurationDefaults {
    #if DEBUG
        private static let debugMode = true
    #else
        private static let debugMode = false
    #endif

    // MARK: - Application Settings

    /// Whether to show window titles by default.
    public static let showWindowTitles = true

    /// Default AeroSpace binary path (empty string means auto-detection).
    public static let aeroSpacePath = ""

    /// Default background opacity level for the space elements.
    public static let spaceBackgroundOpacity = 0.2

    /// Default background blur radius for space elements in points.
    public static let spaceBackgroundBlurRadius: Double = 0.0

    /// Default background tint color for space elements.
    public static let spaceBackgroundTintColor = Color.white

    /// Default foreground color for space elements.
    public static let spaceForegroundColor = Color.white

    /// Default border tint color for space elements.
    public static let spaceBorderTintColor = Color.white

    /// Default border opacity level for the space elements.
    public static let spaceBorderOpacity = 0.0

    /// Default border width for the space elements in points.
    public static let spaceBorderWidth: Double = 0.0

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
    public static let menuBarHorizontalPadding: Double = 53

    /// Default spacing between widgets in the menu bar in points.
    public static let widgetSpacing: Double = 4

    /// Default animation duration in seconds.
    public static let animationDuration: Double = 0.2

    /// Default size of window icons in points.
    public static let windowIconSize: Double = 22.5

    /// Default corner radius for space elements in points.
    public static let spaceCornerRadius: Double = 14

    /// Default group configuration for menu bar applications.
    public static let groupsConfiguration: [Domain.Group] = Group.singleGroup

    /// Default groups appearance mode.
    public static let groupsAppearanceMode: GroupsAppearanceMode = .matchSpaces

    /// Default global background tint color for all groups.
    public static let groupsGlobalBackgroundTintColor: Color = spaceBackgroundTintColor

    /// Default global background opacity for all groups.
    public static let groupsGlobalBackgroundOpacity: Double = spaceBackgroundOpacity

    /// Default global background blur radius for all groups.
    public static let groupsGlobalBackgroundBlurRadius: Double = spaceBackgroundBlurRadius

    /// Default global border color for all groups.
    public static let groupsGlobalBorderColor: Color = spaceBorderTintColor

    /// Default global border opacity for all groups.
    public static let groupsGlobalBorderOpacity: Double = spaceBorderOpacity

    /// Default global border width for all groups.
    public static let groupsGlobalBorderWidth: Double = spaceBorderWidth

    /// Default global corner radius for all groups.
    public static let groupsGlobalCornerRadius: Double = spaceCornerRadius
}
