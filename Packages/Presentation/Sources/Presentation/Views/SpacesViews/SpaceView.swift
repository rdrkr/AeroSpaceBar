// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Domain
import SwiftUI

/// A view that displays a space with its associated windows.
///
/// This view represents a single space/workspace and shows its identifier
/// along with the windows that belong to it. It provides interactive
/// functionality for switching to the space.
struct SpaceView: View {
    /// The space to display.
    let space: Space

    /// Whether window titles should be displayed.
    let showWindowTitles: Bool

    /// Whether window clicking functionality is enabled.
    let focusWindowOnClick: Bool

    /// The appearance mode determining which styling properties to use.
    let appearanceMode: SpacesAppearanceMode

    /// The global color properties (used when appearanceMode is .allSpaces).
    let globalColorProperties: ColorProperties

    /// The global geometric properties.
    let globalGeometricProperties: GeometricProperties

    /// The global effect properties.
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

    /// Whether the space view is currently being hovered.
    @State private var isHovered = false

    // MARK: - Computed Properties

    /// The color properties based on the current appearance mode and theme mode.
    private var currentColorProperties: ColorProperties {
        switch themeMode {
        case .preset: themePresetColorProperties.colorProperties

        case .glass,
             .custom:
            switch appearanceMode {
            case .allSpaces: globalColorProperties
            case .perSpace: space.colorProperties
            }
        }
    }

    /// The geometric properties based on the current appearance mode and theme mode.
    private var currentGeometricProperties: GeometricProperties {
        switch themeMode {
        case .preset: themePresetGeometricProperties

        case .glass,
             .custom:
            switch appearanceMode {
            case .allSpaces: globalGeometricProperties
            case .perSpace: space.geometricProperties
            }
        }
    }

    /// The effect properties based on the current appearance mode and theme mode.
    private var currentEffectProperties: EffectProperties {
        switch themeMode {
        case .preset: themePresetEffectProperties

        case .glass,
             .custom:
            switch appearanceMode {
            case .allSpaces: globalEffectProperties
            case .perSpace: space.effectProperties
            }
        }
    }

    /// Computed property for focus state to avoid repeated calculations.
    /// - Returns: True if any window in the space is focused or the space itself is focused
    private var isFocused: Bool {
        space.windows.contains(where: \.isFocused) || space.isFocused
    }

    /// Computed property for minimum height to match spaces with windows.
    /// - Returns: The calculated height based on icon size and padding
    private var spaceHeight: Double {
        ConfigurationDefaults.windowIconSize +
            (ConfigurationDefaults.menuBarVerticalPadding * 2) +
            (currentGeometricProperties.borderWidth * 2)
    }

    // MARK: - Body

    /// The body of the space view.
    ///
    /// This view creates a horizontal layout showing the space identifier
    /// and its associated windows with proper styling and interactions.
    var body: some View {
        HStack(spacing: 0) {
            Spacer().frame(width: 8)

            Text(space.title)
                .font(.headline)
                .foregroundColor(currentColorProperties.foregroundColor)
                .frame(minWidth: 15)
                .fixedSize(horizontal: true, vertical: false)
                .textShadow()
                .tag("space-\(space.id)-identifier")

            Spacer().frame(width: 4)

            HStack(spacing: 2) {
                ForEach(space.windows) { window in
                    WindowView(
                        window: window,
                        space: space,
                        showWindowTitles: showWindowTitles,
                        focusWindowOnClick: focusWindowOnClick,
                        spaceForegroundColor: currentColorProperties.foregroundColor,
                        spaceBackgroundTintColor: currentColorProperties.backgroundTintColor,
                        onSwitchToSpace: onSwitchToSpace,
                        onSwitchToWindow: onSwitchToWindow
                    )
                    .tag("window-\(window.id)")
                }
            }
            .tag("space-\(space.id)-windows-container")

            Spacer().frame(width: 8)
        }
        .frame(height: spaceHeight)
        .spaceFocusState(
            isFocused,
            colorProperties: currentColorProperties,
            geometricProperties: currentGeometricProperties,
            effectProperties: currentEffectProperties,
            themeMode: themeMode
        )
        .conditionalInteraction(
            isEnabled: focusWindowOnClick,
            isHovered: $isHovered
        ) {
            onSwitchToSpace(space, true)
        }
        .tag("space-\(space.id)-view")
    }
}

#Preview {
    SpaceView(
        space: Space(
            id: "1",
            isFocused: true,
            windows: []
        ),
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
