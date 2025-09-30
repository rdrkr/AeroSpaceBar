// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

// MARK: - Theme System

// Centralized theming system for AeroSpaceBar application.
//
// This system provides consistent typography, colors, and spacing values
// used throughout the application to ensure visual cohesion and maintainability.

// MARK: - Color System

/// Color system providing semantic colors for consistent theming.
extension Color {
    // MARK: - Semantic Colors

    /// Primary accent color used for interactive elements and emphasis.
    ///
    /// Used for:
    /// - Primary buttons
    /// - Links and interactive text
    /// - Selected states
    static let themePrimary: Color = .blue

    /// Success color used for positive status indicators.
    ///
    /// Used for:
    /// - Success messages
    /// - Positive status indicators
    /// - Confirmation states
    static let themeSuccess: Color = .green

    /// Error color used for negative status indicators and alerts.
    ///
    /// Used for:
    /// - Error messages
    /// - Validation failures
    /// - Alert states
    static let themeError: Color = .red

    /// Warning color used for cautionary messages and alerts.
    ///
    /// Used for:
    /// - Warning messages
    /// - Attention-requiring states
    /// - Tip indicators
    static let themeWarning: Color = .orange

    // MARK: - UI Element Colors

    /// Secondary text color used for less prominent text elements.
    ///
    /// Used for:
    /// - Descriptions and help text
    /// - Secondary labels
    /// - Placeholder text
    static let themeSecondary: Color = .secondary

    /// Background color for cards and elevated surfaces.
    ///
    /// Used for:
    /// - Card backgrounds
    /// - Modal backgrounds
    /// - Elevated panels
    static let themeCardBackground: Color = .init(.controlBackgroundColor)

    // MARK: - Shadow Colors

    /// Standard shadow color for UI elements.
    static let themeShadow: Color = .shadow

    /// Icon shadow color for application icons.
    static let themeIconShadow: Color = .iconShadow

    /// Foreground shadow color for text elements.
    static let themeForegroundShadow: Color = .foregroundShadow
}

// MARK: - Color Extensions

/// Color extensions providing shadow and theme colors.
extension Color {
    /// Standard shadow color for UI elements.
    static let shadow: Color = .black.opacity(0.5)

    /// Icon shadow color for application icons.
    static let iconShadow: Color = .black.opacity(0.1)

    /// Foreground shadow color for text elements.
    static let foregroundShadow: Color = .black.opacity(0.5)
}

// MARK: - Animation System

/// Animation system providing consistent timing and easing.
extension Animation {
    /// Smooth animation with default duration.
    static let themeSmooth: Animation = .smooth(duration: 0.3)

    /// Fast smooth animation for immediate interactions.
    static let themeSmoothFastest: Animation = .smooth(duration: 0.05)

    /// Fast smooth animation for quick interactions.
    static let themeSmoothFast: Animation = .smooth(duration: 0.15)

    /// Slow smooth animation for emphasis.
    static let themeSmoothSlow: Animation = .smooth(duration: 0.5)

    /// Easing animation with default duration.
    static let themeEaseInOut: Animation = .easeInOut(duration: 0.3)

    /// Fast easing animation for immediate interactions.
    static let themeEaseInOutFastest: Animation = .easeInOut(duration: 0.05)

    /// Fast easing animation for quick interactions.
    static let themeEaseInOutFast: Animation = .easeInOut(duration: 0.15)

    /// Slow easing animation for emphasis.
    static let themeEaseInOutSlow: Animation = .easeInOut(duration: 0.5)
}
