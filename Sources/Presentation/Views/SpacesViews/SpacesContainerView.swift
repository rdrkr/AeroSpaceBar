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

    /// The appearance mode for spaces visual configuration.
    let appearanceMode: SpacesAppearanceMode

    /// The global visual configuration (used when appearanceMode is .allSpaces).
    let globalVisualConfiguration: VisualProperties

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
        HStack(spacing: -ConfigurationDefaults.widgetSpacing - (spacingVisualConfig.borderWidth * 2)) {
            ForEach(spaces) { space in
                SpaceView(
                    space: space,
                    showWindowTitles: showWindowTitles,
                    focusWindowOnClick: focusWindowOnClick,
                    appearanceMode: appearanceMode,
                    globalVisualConfiguration: globalVisualConfiguration,
                    onSwitchToSpace: onSwitchToSpace,
                    onSwitchToWindow: onSwitchToWindow
                )
                .tag("space-\(space.id)")
            }
        }
        .tag("spaces-container")
    }

    // MARK: - Helper Methods

    /// Returns the visual configuration to use for spacing calculations.
    /// Uses global configuration when in .allSpaces mode, or the focused space's configuration in .perSpace mode.
    private var spacingVisualConfig: VisualProperties {
        switch appearanceMode {
        case .allSpaces:
            globalVisualConfiguration
        case .perSpace:
            spaces.first(where: \.isFocused)?.visualConfig ?? globalVisualConfiguration
        @unknown default:
            globalVisualConfiguration
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
        globalVisualConfiguration: VisualProperties(
            backgroundTintColor: .blue,
            backgroundOpacity: 0.2,
            backgroundBlurRadius: 8.0,
            borderTintColor: .white,
            borderOpacity: 0.8,
            borderWidth: 2.0,
            cornerRadius: 8.0,
            foregroundColor: .primary
        ),
        onSwitchToSpace: { _, _ in },
        onSwitchToWindow: { _ in }
    )
    .padding()
}
