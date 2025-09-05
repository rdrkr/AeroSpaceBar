// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

// MARK: - Theme System

// Centralized theming system for AeroSpaceBar application.
//
// This system provides consistent typography, colors, and spacing values
// used throughout the application to ensure visual cohesion and maintainability.

// MARK: - Typography

/// Typography system providing consistent font styles across the application.
extension Font {
    /// Caption text font (11pt) used for secondary text, descriptions, and help text.
    ///
    /// Commonly used for:
    /// - Settings descriptions
    /// - Error messages and status text
    /// - Value displays next to sliders
    /// - Help text and tooltips
    static let themeCaption: Font = .system(size: 11)

    /// Body text font (13pt) used for primary interface text.
    ///
    /// Commonly used for:
    /// - Primary labels
    /// - Button text
    /// - Form field labels
    static let themeBody: Font = .system(size: 13)

    /// Title font (14pt) used for section headers and emphasis.
    ///
    /// Commonly used for:
    /// - Section titles
    /// - Modal headers
    /// - Emphasized text
    static let themeTitle: Font = .system(size: 14, weight: .semibold)

    /// Small body font (12pt) used for secondary interface elements.
    ///
    /// Commonly used for:
    /// - Secondary labels
    /// - Tip titles
    /// - Compact interface text
    static let themeSmallBody: Font = .system(size: 12)
}

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

// MARK: - Spacing System

/// Spacing system providing consistent layout values.
extension CGFloat {
    // MARK: - Standard Spacing

    /// Extra small spacing (4pt) for tight layouts.
    static let themeSpacingXS: CGFloat = 4

    /// Small spacing (8pt) for compact layouts.
    static let themeSpacingS: CGFloat = 8

    /// Medium spacing (16pt) for standard layouts.
    static let themeSpacingM: CGFloat = 16

    /// Large spacing (24pt) for generous layouts.
    static let themeSpacingL: CGFloat = 24

    /// Extra large spacing (32pt) for section separation.
    static let themeSpacingXL: CGFloat = 32

    // MARK: - Component Spacing

    /// Corner radius for space elements.
    static let themeSpaceCornerRadius: CGFloat = 8.0

    /// Corner radius for window elements.
    static let themeWindowCornerRadius: CGFloat = 4.0

    /// Corner radius for card elements.
    static let themeCardCornerRadius: CGFloat = 12.0

    /// Fixed width for value display elements.
    static let themeValueDisplayWidth: CGFloat = 34
}

// MARK: - Animation System

/// Animation system providing consistent timing and easing.
extension Animation {
    /// Smooth animation with default duration (0.3s).
    static let themeSmooth: Animation = .smooth(duration: 0.3)

    /// Fast smooth animation for quick interactions (0.15s).
    static let themeSmoothFast: Animation = .smooth(duration: 0.15)

    /// Slow smooth animation for emphasis (0.5s).
    static let themeSmoothSlow: Animation = .smooth(duration: 0.5)
}
