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

    /// The body of the spaces view.
    ///
    /// This view creates a horizontal layout of spaces with their associated windows,
    /// using the captured desktop wallpaper as background.
    var body: some View {
        // Main menu bar content
        HStack(spacing: viewModel.widgetSpacing) {
            ZStack(alignment: .leading) {
                // Use captured desktop wallpaper as background
                if let originalWallpaper = viewModel.widgetState.wallpaper {
                    Group {
                        let screenWidth = originalWallpaper.size.width
                        let screenHeight = originalWallpaper.size.height

                        Image(nsImage: originalWallpaper)
                            .frame(width: (screenWidth / 2) - viewModel.menuBarHorizontalPadding, height: screenHeight)
                            .offset(
                                x: (screenWidth / 4) - (viewModel.menuBarHorizontalPadding / 2),
                                y: 0
                            )
                            .clipped()

                        HStack(spacing: viewModel.widgetSpacing) {
                            ForEach(viewModel.widgetState.spaces) { space in
                                SpaceView(space: space)
                            }
                        }
                    }
                    .opacity(isWallpaperVisible ? 1.0 : 0.0)
                    .offset(y: isWallpaperVisible ? 0 : -viewModel.menuBarHeight)
                    .animation(.smooth(duration: viewModel.animationDuration), value: isWallpaperVisible)
                } else {
                    // Default background when no wallpaper is set
                    Color.black.opacity(0)
                }
            }
        }
        .animation(
            .smooth(duration: viewModel.animationDuration),
            value: viewModel.widgetState.spaces
        )
        .padding(.leading, viewModel.menuBarHorizontalPadding)
        .onChange(of: viewModel.widgetState) { oldWigetState, newWidgetState in
            if newWidgetState.wallpaper != nil, !newWidgetState.spaces.isEmpty {
                // Fade in wallpaper when spaces are available and image is loaded
                if !isWallpaperVisible {
                    isWallpaperVisible = true
                }

                // Fade out and back in when image is loaded and spaces are available
                else if oldWigetState.wallpaper != newWidgetState.wallpaper, isWallpaperVisible {
                    isWallpaperVisible = false

                    DispatchQueue.main.asyncAfter(deadline: .now() + viewModel.animationDuration) {
                        isWallpaperVisible = true
                    }
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

    /// The body of the space view.
    ///
    /// This view creates a horizontal layout showing the space identifier
    /// and its associated windows with proper styling and interactions.
    var body: some View {
        let isFocused = space.windows.contains { $0.isFocused } || space.isFocused
        HStack(spacing: 0) {
            Spacer().frame(width: 10)

            Text(space.id)
                .font(.headline)
                .frame(minWidth: 15)
                .fixedSize(horizontal: true, vertical: false)

            Spacer().frame(width: 5)

            HStack(spacing: 2) {
                ForEach(space.windows) { window in
                    WindowView(window: window, space: space)
                }
            }

            Spacer().frame(width: viewModel.widgetSpacing)
        }
        .background(
            isFocused
                ? Color.active
                : isHovered ? Color.noActive : Color.noActive
        )
        .clipShape(
            RoundedRectangle(cornerRadius: viewModel.spaceCornerRadius, style: .continuous)
        )
        .shadow(color: .shadow, radius: 2)
        .transition(.blurReplace)
        .onTapGesture {
            DispatchQueue.main.async {
                viewModel.switchToSpace(space, needWindowFocus: true)
            }
        }
        .animation(.smooth, value: isHovered)
        .onHover { value in
            isHovered = value
        }
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

    /// The body of the window view.
    ///
    /// This view creates a horizontal layout showing the window's application icon
    /// and optionally its title, with proper styling and interactions.
    var body: some View {
        let size: CGFloat = viewModel.windowIconSize
        let sameAppCount = space.windows.count(where: { $0.appName == window.appName })

        let title = sameAppCount > 1 ? window.title : (window.appName ?? "")
        let spaceIsFocused = space.windows.contains { $0.isFocused }
        HStack {
            ZStack {
                if let icon = window.appIcon {
                    Image(nsImage: icon)
                        .resizable()
                        .frame(width: size, height: size)
                        .shadow(color: .iconShadow, radius: 2)
                } else {
                    Image(systemName: "questionmark.circle")
                        .resizable()
                        .frame(width: size, height: size)
                }
            }
            .opacity(spaceIsFocused && !window.isFocused ? 0.5 : 1)
            .transition(.blurReplace)

            if window.isFocused, !title.isEmpty {
                HStack {
                    Text(
                        title.count > 50
                            ? String(title.prefix(50)) + "..."
                            : title
                    )
                    .fixedSize(horizontal: true, vertical: false)
                    .shadow(color: .foregroundShadow, radius: 2)
                    .fontWeight(.semibold)

                    Spacer().frame(width: 5)
                }
                .transition(.blurReplace)
            }
        }
        .padding(.vertical, viewModel.menuBarVerticalPadding)
        .background(isHovered ? .selected : .clear)
        .clipShape(RoundedRectangle(cornerRadius: viewModel.windowCornerRadius, style: .continuous))
        .animation(.smooth, value: isHovered)
        .contentShape(.rect)
        .onTapGesture {
            DispatchQueue.main.async {
                viewModel.switchToSpace(space)
                usleep(100_000)
                viewModel.switchToWindow(window)
            }
        }
        .onHover { value in
            isHovered = value
        }
    }
}
