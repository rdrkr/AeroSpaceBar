// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Centralized UserDefaults key management for the AeroSpaceBar application.
///
/// This enum provides a single source of truth for all UserDefaults keys used
/// throughout the application. It ensures consistent naming conventions and
/// makes it easy to track and manage all persisted settings.
///
/// All keys follow the pattern: `com.aerospacebar.preferences.{category}.{setting}`
/// to maintain consistency and avoid conflicts.
public enum UserDefaultsKeys: String, CaseIterable {
    // MARK: - General Preferences

    /// Whether to show window titles in the interface.
    case showWindowTitles = "com.aerospacebar.preferences.showWindowTitles"

    /// Whether to focus a window immediately when clicking on it.
    case focusWindowOnClick = "com.aerospacebar.preferences.focusWindowOnClick"

    /// Whether to show empty spaces in the interface.
    case showEmptySpaces = "com.aerospacebar.preferences.showEmptySpaces"

    /// Whether to show groups in the interface.
    case showGroups = "com.aerospacebar.preferences.showGroups"

    /// Whether to launch the application at login.
    case launchAtLogin = "com.aerospacebar.preferences.launchAtLogin"

    // MARK: - Logging Preferences

    /// The current log level for application logging.
    case logLevel = "com.aerospacebar.preferences.logLevel"

    /// Whether to enable performance metrics collection and logging.
    case enablePerformanceMetrics = "com.aerospacebar.preferences.enablePerformanceMetrics"

    /// Whether to enable optimized performance behavior.
    case isOptimizedPerformanceEnabled = "com.aerospacebar.preferences.isOptimizedPerformanceEnabled"

    // MARK: - AeroSpace Integration

    /// Source of AeroSpace installation to use: homebrew or
    case aeroSpaceInstallSource = "com.aerospacebar.preferences.aeroSpaceInstallSource"

    /// Custom absolute path to the AeroSpace binary (used when source == .custom)
    case aeroSpaceCustomPath = "com.aerospacebar.preferences.aeroSpaceCustomPath"

    // MARK: - UI Configuration Preferences

    /// The vertical padding for the menu bar interface in points.
    case menuBarVerticalPadding = "com.aerospacebar.preferences.ui.menuBarVerticalPadding"

    /// The horizontal padding for the menu bar interface in points.
    case menuBarHorizontalPadding = "com.aerospacebar.preferences.ui.menuBarHorizontalPadding"

    /// The spacing between widgets in the menu bar in points.
    case widgetSpacing = "com.aerospacebar.preferences.ui.widgetSpacing"

    /// The animation duration in seconds.
    case animationDuration = "com.aerospacebar.preferences.ui.animationDuration"

    /// The size of window icons in points.
    case windowIconSize = "com.aerospacebar.preferences.ui.windowIconSize"

    /// The spaces configuration for organizing spaces.
    case spacesVisualConfiguration = "com.aerospacebar.preferences.spacesVisualConfiguration"

    /// The spaces appearance mode (per space, all spaces).
    case spacesAppearanceMode = "com.aerospacebar.preferences.spacesAppearanceMode"

    /// The global visual configuration for space elements.
    case globalSpacesVisualConfig = "com.aerospacebar.preferences.globalSpacesVisualConfig"

    /// The group configuration for organizing menu bar applications.
    case groups = "com.aerospacebar.preferences.ui.groups"

    /// The groups appearance mode (per app, all groups, same as spaces).
    case groupsAppearanceMode = "com.aerospacebar.preferences.ui.groupsAppearanceMode"

    /// The global visual configuration for all groups.
    case globalGroupsVisualConfig = "com.aerospacebar.preferences.ui.globalGroupsVisualConfig"

    // MARK: - Profile Preferences

    /// The user's display name for their profile.
    case profileUserName = "com.aerospacebar.profile.userName"

    /// The user's profile image data.
    case profileImageData = "com.aerospacebar.profile.imageData"
}
