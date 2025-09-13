// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Domain
import SwiftUI

/// A view that displays a window with its icon and optional title.
///
/// This view represents a single window and shows its application icon
/// and optionally its title if the window is focused. It provides
/// interactive functionality for switching to the window.
struct WindowView: View {
    /// The spaces ViewModel for managing spaces data and interactions.
    @EnvironmentObject var viewModel: SpacesViewModel

    /// The window to display.
    let window: Domain.Window

    /// The space that contains this window.
    let space: Space

    /// Whether the window view is currently being hovered.
    @State var isHovered = false

    // MARK: - Computed Properties

    /// Computed property for window icon size
    private var iconSize: Double {
        viewModel.windowIconSize
    }

    /// Computed property for menu bar vertical padding
    private var verticalPadding: Double {
        viewModel.menuBarVerticalPadding
    }

    /// Computed property for title text to avoid repeated calculations
    private var titleText: String {
        let sameAppCount = space.windows.count(where: { $0.appName == window.appName })
        return sameAppCount > 1 ? window.title : (window.appName ?? "")
    }

    /// Computed property for space focus state to avoid repeated calculations
    private var spaceIsFocused: Bool {
        space.windows.contains {
            $0.isFocused
        }
    }

    /// Computed property for whether to show window titles
    private var showWindowTitles: Bool {
        viewModel.showWindowTitles
    }

    // MARK: - Body

    /// The body of the window view.
    ///
    /// This view creates a horizontal layout showing the window's application icon
    /// and optionally its title, with proper styling and interactions.
    var body: some View {
        HStack {
            WindowIconView(window: window, iconSize: iconSize)
                .windowFocusState(window.isFocused, spaceIsFocused: spaceIsFocused)
                .tag("window-\(window.id)-icon-container")

            if window.isFocused, showWindowTitles, !titleText.isEmpty {
                WindowTitleView(titleText: titleText, windowId: window.id)
            }
        }
        .padding(.vertical, verticalPadding)
        .background(
            WindowHoverBackground(
                color: viewModel.spaceBackgroundTintColor,
                isHovered: viewModel.focusWindowOnClick ? isHovered : false
            )
        )
        .windowCornerRadius(8)
        .blurReplaceTransition()
        .smoothAnimation(duration: viewModel.animationDuration)
        .contentShape(.rect)
        .conditionalInteraction(
            isEnabled: viewModel.focusWindowOnClick,
            isHovered: $isHovered,
            onTap: {
                DispatchQueue.main.async {
                    viewModel.switchToSpace(space)
                    usleep(100_000)
                    viewModel.switchToWindow(window)
                }
            }
        )
        .tag("window-\(window.id)-view")
    }
}

// MARK: - Supporting Views

/// A reusable view for displaying window icons
private struct WindowIconView: View {
    let window: Domain.Window
    let iconSize: Double

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

/// A reusable view for displaying window titles
private struct WindowTitleView: View {
    @EnvironmentObject private var viewModel: SpacesViewModel

    let titleText: String
    let windowId: Int

    private var truncatedTitleText: String {
        titleText.count > 50 ? String(titleText.prefix(50)) + "..." : titleText
    }

    var body: some View {
        HStack {
            Text(truncatedTitleText)
                .foregroundColor(viewModel.spaceForegroundColor)
                .textShadow()
                .fontWeight(.semibold)
                .tag("window-\(windowId)-title")

            Spacer().frame(width: 5)
        }
        .tag("window-\(windowId)-title-container")
    }
}

/// A reusable view for window hover background
private struct WindowHoverBackground: View {
    let color: Color
    let isHovered: Bool

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
        appIcon: nil
    )

    let space = Space(
        id: "1",
        isFocused: false,
        windows: [window]
    )

    WindowView(window: window, space: space)
        .environmentObject(DependencyContainer.shared.getSpacesViewModel())
        .padding()
}
