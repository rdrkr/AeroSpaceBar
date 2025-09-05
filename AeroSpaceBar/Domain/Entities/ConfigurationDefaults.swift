// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation
import SwiftUI

/// Configuration struct containing all default values for application settings.
///
/// This struct centralizes all default configuration values, making it easy to
/// manage and modify defaults across the application. It follows the domain-driven
/// design pattern by keeping configuration concerns within the domain layer.
@MainActor
struct ConfigurationDefaults {
    #if DEBUG
        private static let debugMode = true
    #else
        private static let debugMode = false
    #endif

    // MARK: - Application Settings

    /// Whether to show window titles by default.
    static let showWindowTitles = true

    /// Default AeroSpace binary path (empty string means auto-detection).
    static let aeroSpacePath = ""

    /// Default background opacity level for the space elements.
    static let spaceBackgroundOpacity = 0.4

    /// Default background blur radius for space elements in points.
    static let spaceBackgroundBlurRadius: CGFloat = 0.0

    /// Default background tint color for space elements.
    static let spaceBackgroundTintColor = Color.white

    /// Default foreground color for space elements.
    static let spaceForegroundColor = Color.white

    /// Default border tint color for space elements.
    static let spaceBorderTintColor = Color.white

    /// Default border opacity level for the space elements.
    static let spaceBorderOpacity = 0.0

    /// Default border width for the space elements in points.
    static let spaceBorderWidth: CGFloat = 0.0

    /// Whether to focus a window when clicking on it by default.
    static let focusWindowOnClick = true

    /// Whether to show empty spaces in the interface by default.
    static let showEmptySpaces = false

    /// Whether to enable performance metrics collection by default.
    static let enablePerformanceMetrics = debugMode

    /// Whether to enable optimized performance behavior by default.
    static let isOptimizedPerformanceEnabled = true

    /// Default log level for application logging.
    static let logLevel = Logger.Level.info

    // MARK: - UI Configuration

    /// Default height of the menu bar interface in points.
    static let menuBarHeight: CGFloat = 39

    /// Default vertical padding for the menu bar interface in points.
    static let menuBarVerticalPadding: CGFloat = 1

    /// Default horizontal padding for the menu bar interface in points.
    static let menuBarHorizontalPadding: CGFloat = 53

    /// Default spacing between widgets in the menu bar in points.
    static let widgetSpacing: CGFloat = 6

    /// Default animation duration in seconds.
    static let animationDuration = 0.2

    /// Default size of window icons in points.
    static let windowIconSize: CGFloat = 22.5

    /// Default corner radius for space elements in points.
    static let spaceCornerRadius: CGFloat = 14
}
