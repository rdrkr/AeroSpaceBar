// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Domain
import SwiftUI

/// A view that displays a window with its icon and optional title.
///
/// This view represents a single window and shows its application icon
/// and optionally its title if the window is focused. It provides
/// interactive functionality for switching to the window.
struct WindowView: View {
    /// The window to display.
    let window: Domain.Window

    /// The space that contains this window.
    let space: Space

    /// Whether window titles should be displayed.
    let showWindowTitles: Bool

    /// Whether window clicking functionality is enabled.
    let focusWindowOnClick: Bool

    /// The space foreground color for text elements.
    let spaceForegroundColor: Color

    /// The space background tint color.
    let spaceBackgroundTintColor: Color

    /// Callback invoked when the user wants to switch to a space.
    /// - Parameters:
    ///   - space: The space to switch to
    ///   - needWindowFocus: Whether to focus a window after switching
    let onSwitchToSpace: (Space, Bool) -> Void

    /// Callback invoked when the user wants to switch to a window.
    /// - Parameter window: The window to switch to
    let onSwitchToWindow: (Domain.Window) -> Void

    /// Whether the window view is currently being hovered.
    @State private var isHovered = false

    // MARK: - Computed Properties

    /// Computed property for title text to avoid repeated calculations.
    /// - Returns: The window title if multiple apps of the same type exist, otherwise the app name
    private var titleText: String {
        let sameAppCount = space.windows.count(where: { $0.appName == window.appName })
        return sameAppCount > 1 ? window.title : (window.appName ?? "")
    }

    /// Computed property for space focus state to avoid repeated calculations.
    /// - Returns: True if any window in the space is focused
    private var spaceIsFocused: Bool {
        space.windows.contains {
            $0.isFocused
        }
    }

    // MARK: - Body

    /// The body of the window view.
    ///
    /// This view creates a horizontal layout showing the window's application icon
    /// and optionally its title, with proper styling and interactions.
    var body: some View {
        HStack {
            WindowIconView(window: window, iconSize: ConfigurationDefaults.windowIconSize)
                .windowFocusState(window.isFocused, spaceIsFocused: spaceIsFocused)
                .tag("window-\(window.id)-icon-container")

            if window.isFocused, showWindowTitles, !titleText.isEmpty {
                WindowTitleView(
                    titleText: titleText,
                    windowId: window.id,
                    spaceForegroundColor: spaceForegroundColor
                )
            }
        }
        .padding(.vertical, ConfigurationDefaults.menuBarVerticalPadding)
        .background(
            WindowHoverBackground(
                color: spaceForegroundColor,
                isHovered: focusWindowOnClick ? isHovered : false
            )
        )
        .cornerRadius(8)
        .transition(.blurReplace)
        .conditionalInteraction(
            isEnabled: focusWindowOnClick,
            isHovered: $isHovered,
            onTap: {
                Task { @MainActor in
                    onSwitchToSpace(space, false)
                    try await Task.sleep(for: .milliseconds(100))
                    onSwitchToWindow(window)
                }
            }
        )
        .tag("window-\(window.id)-view")
    }
}

// MARK: - Supporting Views

/// A reusable view for displaying window icons.
///
/// This view displays the application icon for a window, with a fallback
/// to a system icon if no application icon is available.
private struct WindowIconView: View {
    /// The window whose icon should be displayed.
    let window: Domain.Window

    /// The size for the icon display.
    let iconSize: Double

    /// The body of the window icon view.
    /// - Returns: A view containing either the app icon or a fallback icon
    var body: some View {
        ZStack {
            if let icon = window.appIcon {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: iconSize, height: iconSize)
                    .iconShadow()
                    .tag("window-\(window.id)-icon")
            } else {
                Image(systemName: "questionmark.circle")
                    .resizable()
                    .frame(width: iconSize, height: iconSize)
                    .foregroundColor(.secondary)
                    .tag("window-\(window.id)-fallback-icon")
            }
        }
    }
}

/// A reusable view for displaying window titles.
///
/// This view displays the title text for a window with proper styling
/// and truncation for long titles.
private struct WindowTitleView: View {
    /// The title text to display.
    let titleText: String

    /// The window ID for tagging purposes.
    let windowId: Int

    /// The foreground color for the title text.
    let spaceForegroundColor: Color

    /// Truncated title text for display purposes.
    /// - Returns: The title text truncated to 50 characters if necessary
    private var truncatedTitleText: String {
        titleText.count > 50 ? String(titleText.prefix(50)) + "..." : titleText
    }

    /// The body of the window title view.
    /// - Returns: A view containing the styled title text
    var body: some View {
        HStack(spacing: 2) {
            Text(truncatedTitleText)
                .foregroundColor(spaceForegroundColor)
                .textShadow()
                .fontWeight(.semibold)
                .tag("window-\(windowId)-title")

            Spacer().frame(width: 2)
        }
        .tag("window-\(windowId)-title-container")
    }
}

/// A reusable view for window hover background.
///
/// This view provides a background color that appears when the window is hovered,
/// creating a visual feedback for interactive elements.
private struct WindowHoverBackground: View {
    /// The background color to display when hovered.
    let color: Color

    /// Whether the window is currently being hovered.
    let isHovered: Bool

    /// The body of the window hover background view.
    /// - Returns: A colored background with opacity based on hover state
    var body: some View {
        color.opacity(isHovered ? 0.4 : 0.0)
    }
}

#Preview {
    let window = Window(
        id: 1,
        title: "Sample Window",
        appName: "Sample App",
        isFocused: true,
        workspace: "1",
        appIcon: nil,
        visualConfig: VisualContainer(
            backgroundTintColor: .clear,
            backgroundOpacity: 0.0,
            backgroundBlurRadius: 0.0,
            borderTintColor: .white,
            borderOpacity: 0.3,
            borderWidth: 1.0,
            cornerRadius: 8.0,
            foregroundColor: .primary
        )
    )

    let space = Space(
        id: "1",
        isFocused: false,
        windows: [window]
    )

    WindowView(
        window: window,
        space: space,
        showWindowTitles: true,
        focusWindowOnClick: true,
        spaceForegroundColor: .primary,
        spaceBackgroundTintColor: .blue,
        onSwitchToSpace: { _, _ in },
        onSwitchToWindow: { _ in }
    )
    .padding()
}
