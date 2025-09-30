// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Domain
import SwiftUI

/// A container view that displays all spaces in a horizontal layout.
///
/// This view manages the layout of individual SpaceView instances,
/// providing consistent spacing and organization for all spaces.
struct SpacesContainerView: View {
    /// The spaces to display.
    let spaces: [Space]

    /// Whether window titles should be displayed.
    let showWindowTitles: Bool

    /// Whether window clicking functionality is enabled.
    let focusWindowOnClick: Bool

    /// The appearance mode for spaces color properties.
    let appearanceMode: SpacesAppearanceMode

    /// The global color properties (used when appearanceMode is .allSpaces).
    let globalColorProperties: ColorProperties

    /// The global geometric properties
    let globalGeometricProperties: GeometricProperties

    /// The global effect properties
    let globalEffectProperties: EffectProperties

    /// The theme mode for visual customization.
    let themeMode: ThemeMode

    /// The selected theme preset.
    let themePresetColorProperties: ThemePresetColorProperties

    /// The geometric properties for theme preset elements.
    let themePresetGeometricProperties: GeometricProperties

    /// The effect properties for theme preset elements.
    let themePresetEffectProperties: EffectProperties

    /// Callback invoked when the user wants to switch to a space.
    /// - Parameters:
    ///   - space: The space to switch to
    ///   - needWindowFocus: Whether to focus a window after switching
    let onSwitchToSpace: (Space, Bool) -> Void

    /// Callback invoked when the user wants to switch to a window.
    /// - Parameter window: The window to switch to
    let onSwitchToWindow: (Domain.Window) -> Void

    // MARK: - Body

    /// The body of the spaces container view.
    /// - Returns: A horizontal stack containing all space views with proper parameters
    var body: some View {
        HStack(spacing: -ConfigurationDefaults.widgetSpacing - (spacingGeometricProperties.borderWidth * 2)) {
            ForEach(spaces) { space in
                SpaceView(
                    space: space,
                    showWindowTitles: showWindowTitles,
                    focusWindowOnClick: focusWindowOnClick,
                    appearanceMode: appearanceMode,
                    globalColorProperties: globalColorProperties,
                    globalGeometricProperties: globalGeometricProperties,
                    globalEffectProperties: globalEffectProperties,
                    themeMode: themeMode,
                    themePresetColorProperties: themePresetColorProperties,
                    themePresetGeometricProperties: themePresetGeometricProperties,
                    themePresetEffectProperties: themePresetEffectProperties,
                    onSwitchToSpace: onSwitchToSpace,
                    onSwitchToWindow: onSwitchToWindow
                )
                .tag("space-\(space.id)")
            }
        }
        .tag("spaces-container")
    }

    // MARK: - Helper Methods

    /// Returns the geometric properties to use for spacing calculations.
    /// Uses global configuration when in .allSpaces mode, or the focused space's configuration in .perSpace mode.
    private var spacingGeometricProperties: GeometricProperties {
        switch themeMode {
        case .preset: themePresetGeometricProperties

        case .glass,
             .custom:
            switch appearanceMode {
            case .allSpaces: globalGeometricProperties

            case .perSpace:
                spaces.first(where: \.isFocused)?.geometricProperties ?? ConfigurationDefaults
                    .spaceGeometricProperties

            default: globalGeometricProperties
            }

        default:
            // For unknown theme modes, fall back to custom behavior
            switch appearanceMode {
            case .allSpaces: globalGeometricProperties

            case .perSpace:
                spaces.first(where: \.isFocused)?.geometricProperties ?? ConfigurationDefaults
                    .spaceGeometricProperties

            default: globalGeometricProperties
            }
        }
    }
}

#Preview {
    let spaces = [
        Space(id: "1", isFocused: true, windows: []),
        Space(id: "2", isFocused: false, windows: []),
        Space(id: "3", isFocused: false, windows: [])
    ]

    SpacesContainerView(
        spaces: spaces,
        showWindowTitles: true,
        focusWindowOnClick: true,
        appearanceMode: .allSpaces,
        globalColorProperties: ColorProperties(
            backgroundTintColor: .blue,
            borderTintColor: .white,
            foregroundColor: .primary
        ),
        globalGeometricProperties: GeometricProperties(
            cornerRadius: 14.0,
            borderWidth: 2.0
        ),
        globalEffectProperties: ConfigurationDefaults.spaceEffectProperties,
        themeMode: .custom,
        themePresetColorProperties: .catppuccinMocha,
        themePresetGeometricProperties: ConfigurationDefaults.themePresetGeometricProperties,
        themePresetEffectProperties: ConfigurationDefaults.themePresetEffectProperties,
        onSwitchToSpace: { _, _ in },
        onSwitchToWindow: { _ in }
    )
    .padding()
}
