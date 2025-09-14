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

    /// The spacing between spaces.
    let widgetSpacing: Double

    /// The duration for view animations in seconds.
    let animationDuration: Double

    /// The vertical padding applied to menu bar elements.
    let menuBarVerticalPadding: Double

    /// The size of window icons displayed in the menu bar.
    let windowIconSize: Double

    /// Whether window titles should be displayed.
    let showWindowTitles: Bool

    /// Whether window clicking functionality is enabled.
    let focusWindowOnClick: Bool

    /// The visual configuration for space containers.
    let visualConfiguration: VisualContainer

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
        HStack(spacing: -widgetSpacing - (visualConfiguration.borderWidth * 2)) {
            ForEach(spaces) { space in
                SpaceView(
                    space: space,
                    animationDuration: animationDuration,
                    widgetSpacing: widgetSpacing,
                    menuBarVerticalPadding: menuBarVerticalPadding,
                    windowIconSize: windowIconSize,
                    showWindowTitles: showWindowTitles,
                    focusWindowOnClick: focusWindowOnClick,
                    visualConfiguration: visualConfiguration,
                    onSwitchToSpace: onSwitchToSpace,
                    onSwitchToWindow: onSwitchToWindow
                )
                .tag("space-\(space.id)")
            }
        }
        .tag("spaces-container")
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
        widgetSpacing: 8.0,
        animationDuration: 0.3,
        menuBarVerticalPadding: 4.0,
        windowIconSize: 16.0,
        showWindowTitles: true,
        focusWindowOnClick: true,
        visualConfiguration: VisualContainer.space(
            background: BackgroundProperties(
                tintColor: .blue,
                opacity: 0.2,
                blurRadius: 8.0
            ),
            border: BorderProperties(
                tintColor: .white,
                opacity: 0.8,
                width: 2.0
            ),
            cornerRadius: 8.0,
            foregroundColor: .primary
        ),
        onSwitchToSpace: { _, _ in },
        onSwitchToWindow: { _ in }
    )
    .padding()
}
