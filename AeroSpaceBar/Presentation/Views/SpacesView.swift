// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// The main spaces view that displays spaces and windows.
///
/// This view provides the primary interface for the AeroSpaceBar application,
/// showing a visual representation of spaces and their associated windows
/// in the menu bar area. It displays the desktop wallpaper as background.
/// This view follows clean architecture principles by only interacting with ViewModels.
struct SpacesView: View {
    /// The spaces ViewModel for managing spaces data and interactions.
    @EnvironmentObject private var viewModel: SpacesViewModel

    /// Whether the wallpaper should be visible (faded in).
    @State private var isWallpaperVisible = false

    // MARK: - Computed Properties

    /// Computed property for wallpaper to avoid repeated access
    private var wallpaper: NSImage? {
        viewModel.widgetState.wallpaper
    }

    /// Computed property for spaces to avoid repeated access
    private var spaces: [Space] {
        viewModel.widgetState.spaces
    }

    /// Computed property for animation duration
    private var animationDuration: Double {
        viewModel.animationDuration
    }

    /// Computed property for widget spacing
    private var widgetSpacing: CGFloat {
        viewModel.widgetSpacing
    }

    /// Computed property for menu bar horizontal padding
    private var menuBarHorizontalPadding: CGFloat {
        viewModel.menuBarHorizontalPadding
    }

    /// Computed property for menu bar height
    private var menuBarHeight: CGFloat {
        viewModel.menuBarHeight
    }

    /// Computed property for window corner radius
    private var cornerRadius: CGFloat {
        viewModel.spaceCornerRadius
    }

    /// Computed property for whether to show window titles
    private var showWindowTitles: Bool {
        viewModel.showWindowTitles
    }

    /// The body of the spaces view.
    ///
    /// This view creates a horizontal layout of spaces with their associated windows,
    /// using the captured desktop wallpaper as background.
    var body: some View {
        // Main menu bar content
        HStack(spacing: widgetSpacing) {
            ZStack(alignment: .leading) {
                // Use captured desktop wallpaper as background
                if let originalWallpaper = wallpaper {
                    Group {
                        let screenWidth = originalWallpaper.size.width
                        let screenHeight = originalWallpaper.size.height

                        Image(nsImage: originalWallpaper)
                            .frame(width: (screenWidth / 2) - menuBarHorizontalPadding, height: screenHeight)
                            .offset(
                                x: (screenWidth / 4) - (menuBarHorizontalPadding / 2),
                                y: 0
                            )
                            .clipped()
                            .tag("spaces-wallpaper-background")

                        HStack(spacing: widgetSpacing) {
                            ForEach(spaces) { space in
                                SpaceView(space: space)
                                    .tag("space-\(space.id)")
                            }
                        }
                        .offset(y: isWallpaperVisible ? 0 : -menuBarHeight)
                        .tag("spaces-container")
                    }
                    .spaceCornerRadius(cornerRadius)
                    .opacity(isWallpaperVisible ? 1.0 : 0.0)
                    .animation(.smooth(duration: animationDuration), value: isWallpaperVisible)
                    .tag("spaces-wallpaper-group")
                } else {
                    // Default background when no wallpaper is set
                    Color.black
                        .opacity(0)
                        .tag("spaces-default-background")
                }
            }
            .tag("spaces-content-zstack")
        }
        .animation(
            .smooth(duration: animationDuration),
            value: showWindowTitles
        )
        .animation(
            .smooth(duration: animationDuration),
            value: spaces
        )
        .padding(.leading, menuBarHorizontalPadding)
        .onChange(of: viewModel.widgetState) { oldWidgetState, newWidgetState in
            handleWidgetStateChange(oldState: oldWidgetState, newState: newWidgetState)
        }
        .tag("spaces-main-view")
    }

    // MARK: - Private Methods

    /// Handles widget state changes to manage wallpaper visibility
    private func handleWidgetStateChange(
        oldState: SpacesViewModel.WidgetState,
        newState: SpacesViewModel.WidgetState
    ) {
        if newState.wallpaper != nil, !newState.spaces.isEmpty {
            // Fade in wallpaper when spaces are available and image is loaded
            if !isWallpaperVisible {
                isWallpaperVisible = true
            }
            // Fade out and back in when image is loaded and spaces are available
            else if oldState.wallpaper != newState.wallpaper, isWallpaperVisible {
                isWallpaperVisible = false

                DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                    isWallpaperVisible = true
                }
            }
        }
    }
}

/// A view that displays a space with its associated windows.
///
/// This view represents a single space/workspace and shows its identifier
/// along with the windows that belong to it. It provides interactive
/// functionality for switching to the space.
private struct SpaceView: View {
    /// The spaces ViewModel for managing spaces data and interactions.
    @EnvironmentObject var viewModel: SpacesViewModel

    /// The space to display.
    let space: Space

    /// Whether the space view is currently being hovered.
    @State var isHovered = false

    // MARK: - Computed Properties

    /// Computed property for focus state to avoid repeated calculations
    private var isFocused: Bool {
        space.windows.contains {
            $0.isFocused
        } || space.isFocused
    }

    /// Computed property for space corner radius
    private var cornerRadius: CGFloat {
        viewModel.spaceCornerRadius
    }

    /// Computed property for widget spacing
    private var widgetSpacing: CGFloat {
        viewModel.widgetSpacing
    }

    /// The body of the space view.
    ///
    /// This view creates a horizontal layout showing the space identifier
    /// and its associated windows with proper styling and interactions.
    var body: some View {
        HStack(spacing: 0) {
            Spacer().frame(width: 10)

            Text(space.id)
                .font(.headline)
                .foregroundColor(viewModel.spaceForegroundColor)
                .frame(minWidth: 15)
                .fixedSize(horizontal: true, vertical: false)
                .tag("space-\(space.id)-identifier")

            Spacer().frame(width: 5)

            HStack(spacing: 2) {
                ForEach(space.windows) { window in
                    WindowView(window: window, space: space)
                        .tag("window-\(window.id)")
                }
            }
            .tag("space-\(space.id)-windows-container")

            Spacer().frame(width: widgetSpacing)
        }
        .spaceFocusState(
            isFocused,
            configuration: SpaceFocusState.Configuration(
                backgroundOpacity: viewModel.spaceBackgroundOpacity,
                backgroundBlurRadius: viewModel.spaceBackgroundBlurRadius,
                backgroundTintColor: viewModel.spaceBackgroundTintColor,
                foregroundColor: viewModel.spaceForegroundColor,
                borderTintColor: viewModel.spaceBorderTintColor,
                borderOpacity: viewModel.spaceBorderOpacity,
                borderCornerRadius: viewModel.spaceCornerRadius,
                borderWidth: viewModel.spaceBorderWidth
            )
        )
        .spaceCornerRadius(cornerRadius)
        .standardShadow()
        .blurReplaceTransition()
        .onTapGesture {
            DispatchQueue.main.async {
                viewModel.switchToSpace(space, needWindowFocus: true)
            }
        }
        .hoverState($isHovered)
        .tag("space-\(space.id)-view")
    }
}

/// A view that displays a window with its icon and optional title.
///
/// This view represents a single window and shows its application icon
/// and optionally its title if the window is focused. It provides
/// interactive functionality for switching to the window.
private struct WindowView: View {
    /// The spaces ViewModel for managing spaces data and interactions.
    @EnvironmentObject var viewModel: SpacesViewModel

    /// The window to display.
    let window: Window

    /// The space that contains this window.
    let space: Space

    /// Whether the window view is currently being hovered.
    @State var isHovered = false

    // MARK: - Computed Properties

    /// Computed property for window icon size
    private var iconSize: CGFloat {
        viewModel.windowIconSize
    }

    /// Computed property for menu bar vertical padding
    private var verticalPadding: CGFloat {
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

    /// The body of the window view.
    ///
    /// This view creates a horizontal layout showing the window's application icon
    /// and optionally its title, with proper styling and interactions.
    var body: some View {
        HStack {
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
                        .tag("window-\(window.id)-fallback-icon")
                }
            }
            .windowFocusState(window.isFocused, spaceIsFocused: spaceIsFocused)
            .tag("window-\(window.id)-icon-container")

            if window.isFocused, showWindowTitles, !titleText.isEmpty {
                HStack {
                    Text(
                        titleText.count > 50
                            ? String(titleText.prefix(50)) + "..."
                            : titleText
                    )
                    .foregroundColor(viewModel.spaceForegroundColor)
                    .textShadow()
                    .fontWeight(.semibold)
                    .tag("window-\(window.id)-title")

                    Spacer().frame(width: 5)
                }
                .tag("window-\(window.id)-title-container")
            }
        }
        .padding(.vertical, verticalPadding)
        .background(
            viewModel.spaceBackgroundTintColor
                .opacity(isHovered ? 0.4 : 0.0)
        )
        .windowCornerRadius(8)
        .blurReplaceTransition()
        .smoothAnimation()
        .contentShape(.rect)
        .onTapGesture {
            DispatchQueue.main.async {
                viewModel.switchToSpace(space)
                usleep(100_000)
                viewModel.switchToWindow(window)
            }
        }
        .hoverState($isHovered)
        .tag("window-\(window.id)-view")
    }
}
