// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// Predefined theme presets with carefully crafted color schemes.
///
/// This enum provides popular, battle-tested color schemes that users can apply
/// to spaces and groups. Each preset includes cohesive visual properties that work
/// well together and are optimized for readability and aesthetics.
public enum ThemePresetColorProperties: String, CaseIterable, Codable, Sendable {
    /// Catppuccin Frappe - cool, mid-tone pastel theme.
    case catppuccinFrappe = "catppuccin-frappe"

    /// Catppuccin Latte - soothing pastel theme with light background.
    case catppuccinLatte = "catppuccin-latte"

    /// Catppuccin Macchiato - warm, mid-tone pastel theme.
    case catppuccinMacchiato = "catppuccin-macchiato"

    /// Catppuccin Mocha - soothing pastel theme with dark background.
    case catppuccinMocha = "catppuccin-mocha"

    /// Dracula - dark theme with vibrant, high-contrast colors.
    case dracula

    /// Gruvbox Dark - warm, retro groove color scheme with a dark background.
    case gruvboxDark = "gruvbox-dark"

    /// Gruvbox Light - warm, retro groove color scheme with a light background.
    case gruvboxLight = "gruvbox-light"

    /// Gruvbox Material Dark - modern take on Gruvbox with softer contrast.
    case gruvboxMaterialDark = "gruvbox-material-dark"

    /// Nord - arctic, north-bluish color palette.
    case nord

    /// Nord Aurora - bright accent variant of Nord theme.
    case nordAurora = "nord-aurora"

    /// One Dark - Atom's iconic dark theme.
    case oneDark = "one-dark"

    /// One Light - Atom's iconic light theme.
    case oneLight = "one-light"

    /// Solarized Dark - precision colors for machines and people.
    case solarizedDark = "solarized-dark"

    /// Solarized Light - precision colors with light background.
    case solarizedLight = "solarized-light"

    /// Tokyo Night - clean, dark theme inspired by Tokyo night cityscape.
    case tokyoNight = "tokyo-night"

    /// Tokyo Night Storm - storm variant with deeper blues.
    case tokyoNightStorm = "tokyo-night-storm"

    // MARK: - Computed Properties

    /// Returns the visual properties for this theme preset.
    public var colorProperties: ColorProperties {
        switch self {
        case .catppuccinFrappe:
            ColorProperties(
                backgroundTintColor: color(hex: "#303446"),
                borderTintColor: color(hex: "#C6D0F5"),
                foregroundColor: color(hex: "#C6D0F5")
            )

        case .catppuccinLatte:
            ColorProperties(
                backgroundTintColor: color(hex: "#EFF1F5"),
                borderTintColor: color(hex: "#4C4F69"),
                foregroundColor: color(hex: "#4C4F69")
            )

        case .catppuccinMacchiato:
            ColorProperties(
                backgroundTintColor: color(hex: "#24273A"),
                borderTintColor: color(hex: "#CAD3F5"),
                foregroundColor: color(hex: "#CAD3F5")
            )

        case .catppuccinMocha:
            ColorProperties(
                backgroundTintColor: color(hex: "#1E1E2E"),
                borderTintColor: color(hex: "#CDD6F4"),
                foregroundColor: color(hex: "#CDD6F4")
            )

        case .dracula:
            ColorProperties(
                backgroundTintColor: color(hex: "#282A36"),
                borderTintColor: color(hex: "#F8F8F2"),
                foregroundColor: color(hex: "#F8F8F2")
            )

        case .gruvboxDark:
            ColorProperties(
                backgroundTintColor: color(hex: "#282828"),
                borderTintColor: color(hex: "#EBDBB2"),
                foregroundColor: color(hex: "#EBDBB2")
            )

        case .gruvboxLight:
            ColorProperties(
                backgroundTintColor: color(hex: "#FBF1C7"),
                borderTintColor: color(hex: "#3C3836"),
                foregroundColor: color(hex: "#3C3836")
            )

        case .gruvboxMaterialDark:
            ColorProperties(
                backgroundTintColor: color(hex: "#1D2021"),
                borderTintColor: color(hex: "#D4BE98"),
                foregroundColor: color(hex: "#D4BE98")
            )

        case .nord:
            ColorProperties(
                backgroundTintColor: color(hex: "#2E3440"),
                borderTintColor: color(hex: "#ECEFF4"),
                foregroundColor: color(hex: "#ECEFF4")
            )

        case .nordAurora:
            ColorProperties(
                backgroundTintColor: color(hex: "#2E3440"),
                borderTintColor: color(hex: "#88C0D0"),
                foregroundColor: color(hex: "#88C0D0")
            )

        case .oneDark:
            ColorProperties(
                backgroundTintColor: color(hex: "#282C34"),
                borderTintColor: color(hex: "#ABB2BF"),
                foregroundColor: color(hex: "#ABB2BF")
            )

        case .oneLight:
            ColorProperties(
                backgroundTintColor: color(hex: "#FAFAFA"),
                borderTintColor: color(hex: "#383A42"),
                foregroundColor: color(hex: "#383A42")
            )

        case .solarizedDark:
            ColorProperties(
                backgroundTintColor: color(hex: "#002B36"),
                borderTintColor: color(hex: "#839496"),
                foregroundColor: color(hex: "#839496")
            )

        case .solarizedLight:
            ColorProperties(
                backgroundTintColor: color(hex: "#FDF6E3"),
                borderTintColor: color(hex: "#657B83"),
                foregroundColor: color(hex: "#657B83")
            )

        case .tokyoNight:
            ColorProperties(
                backgroundTintColor: color(hex: "#1A1B26"),
                borderTintColor: color(hex: "#C0CAF5"),
                foregroundColor: color(hex: "#C0CAF5")
            )

        case .tokyoNightStorm:
            ColorProperties(
                backgroundTintColor: color(hex: "#24283B"),
                borderTintColor: color(hex: "#A9B1D6"),
                foregroundColor: color(hex: "#A9B1D6")
            )
        }
    }

    /// Returns a human-readable display name for the theme.
    public var displayName: String {
        switch self {
        case .catppuccinFrappe: "Catppuccin Frappé"
        case .catppuccinLatte: "Catppuccin Latte"
        case .catppuccinMacchiato: "Catppuccin Macchiato"
        case .catppuccinMocha: "Catppuccin Mocha"
        case .dracula: "Dracula"
        case .gruvboxDark: "Gruvbox Dark"
        case .gruvboxLight: "Gruvbox Light"
        case .gruvboxMaterialDark: "Gruvbox Material Dark"
        case .nord: "Nord"
        case .nordAurora: "Nord Aurora"
        case .oneDark: "One Dark"
        case .oneLight: "One Light"
        case .solarizedDark: "Solarized Dark"
        case .solarizedLight: "Solarized Light"
        case .tokyoNight: "Tokyo Night"
        case .tokyoNightStorm: "Tokyo Night Storm"
        }
    }

    /// Returns a brief description of the theme.
    public var description: LocalizedStringResource {
        switch self {
        case .catppuccinFrappe: LocalizedStringResource("Cool, mid-tone pastel theme")
        case .catppuccinLatte: LocalizedStringResource("Soothing pastel theme with light background")
        case .catppuccinMacchiato: LocalizedStringResource("Warm, mid-tone pastel theme")
        case .catppuccinMocha: LocalizedStringResource("Soothing pastel theme with dark background")
        case .dracula: LocalizedStringResource("Dark theme with vibrant, high-contrast colors")
        case .gruvboxDark: LocalizedStringResource("Warm, retro groove color scheme with dark background")
        case .gruvboxLight: LocalizedStringResource("Warm, retro groove color scheme with light background")
        case .gruvboxMaterialDark: LocalizedStringResource("Modern take on Gruvbox with softer contrast")
        case .nord: LocalizedStringResource("Arctic, north-bluish color palette")
        case .nordAurora: LocalizedStringResource("Bright accent variant of Nord theme")
        case .oneDark: LocalizedStringResource("Atom's iconic dark theme")
        case .oneLight: LocalizedStringResource("Atom's iconic light theme")
        case .solarizedDark: LocalizedStringResource("Precision colors for machines and people")
        case .solarizedLight: LocalizedStringResource("Precision colors with light background")
        case .tokyoNight: LocalizedStringResource("Clean, dark theme inspired by Tokyo cityscape")
        case .tokyoNightStorm: LocalizedStringResource("Storm variant with deeper blues")
        }
    }

    // MARK: - Private Helpers

    /// Creates a Color from a hex string, returning white as fallback.
    /// This is safe because all hex values in this enum are validated.
    /// - Parameter hex: The hex color string
    /// - Returns: The parsed Color
    private func color(hex: String) -> Color {
        Color(hex: hex) ?? .white
    }
}
