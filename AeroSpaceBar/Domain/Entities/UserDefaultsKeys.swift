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
enum UserDefaultsKeys: String, CaseIterable {
    // MARK: - General Preferences

    /// Whether to show window titles in the interface.
    case showWindowTitles = "com.aerospacebar.preferences.showWindowTitles"

    /// Whether to focus a window immediately when clicking on it.
    case focusWindowOnClick = "com.aerospacebar.preferences.focusWindowOnClick"

    /// Whether to launch the application at login.
    case launchAtLogin = "com.aerospacebar.preferences.launchAtLogin"

    // MARK: - Appearance Preferences

    /// The transparency level of the menu bar panel (0.1 to 1.0).
    case transparency = "com.aerospacebar.preferences.transparency"

    // MARK: - Logging Preferences

    /// The current log level for application logging.
    case logLevel = "com.aerospacebar.preferences.logLevel"

    /// Whether to enable performance metrics collection and logging.
    case enablePerformanceMetrics = "com.aerospacebar.preferences.enablePerformanceMetrics"

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

    /// The corner radius for space elements in points.
    case spaceCornerRadius = "com.aerospacebar.preferences.ui.spaceCornerRadius"

    /// The corner radius for window elements in points.
    case windowCornerRadius = "com.aerospacebar.preferences.ui.windowCornerRadius"
}
