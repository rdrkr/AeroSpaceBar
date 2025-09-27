// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import AppKit
import Domain
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

    /// Standard open settings view action.
    @Environment(\.openSettings) private var openSettings

    /// Whether the wallpaper should be visible (faded in).
    @State private var isWallpaperVisible = false

    /// Whether the mouse is currently over the SpacesView.
    @State private var isMouseHovering = false

    // MARK: - Computed Properties

    /// Computed property for wallpaper to avoid repeated access
    private var wallpaper: NSImage? {
        viewModel.wallpaper
    }

    /// Computed property for spaces to avoid repeated access
    private var spaces: [Space] {
        viewModel.spaces
    }

    /// Computed property for menu bar height
    private var menuBarHeight: Double {
        viewModel.menuBarHeight
    }

    /// Computed property for window corner radius
    private var cornerRadius: Double {
        viewModel.globalSpacesVisualConfig.cornerRadius
    }

    /// Computed property for whether to show window titles
    private var showWindowTitles: Bool {
        viewModel.showWindowTitles
    }

    /// Whether the view should be hidden based on globe key + mouse hover combination, menu bar visibility, or
    /// AeroSpace status
    private var shouldHideView: Bool {
        !viewModel.isSpacesEnabled ||
            (isMouseHovering && viewModel.isGlobeKeyPressed) ||
            !viewModel.isMenuBarVisible ||
            !viewModel.isAeroSpaceRunning
    }

    /// The body of the spaces view.
    ///
    /// This view creates a horizontal layout of spaces with their associated windows,
    /// using the captured desktop wallpaper as background.
    var body: some View {
        HStack(spacing: ConfigurationDefaults.widgetSpacing) {
            ZStack(alignment: .leading) {
                // Use captured desktop wallpaper as background
                if let originalWallpaper = wallpaper {
                    Group {
                        WallpaperBackgroundView(
                            wallpaper: originalWallpaper
                        )

                        SpacesContainerView(
                            spaces: spaces,
                            showWindowTitles: showWindowTitles,
                            focusWindowOnClick: viewModel.focusWindowOnClick,
                            appearanceMode: viewModel.spacesAppearanceMode,
                            globalVisualConfiguration: viewModel.globalSpacesVisualConfig,
                            onSwitchToSpace: { space, needWindowFocus in
                                viewModel.switchToSpace(space, needWindowFocus: needWindowFocus)
                            },
                            onSwitchToWindow: { window in
                                viewModel.switchToWindow(window)
                            }
                        )
                        .offset(y: (isWallpaperVisible && !shouldHideView) ? 0 : -menuBarHeight)
                        .tag("spaces-container")
                    }
                    .cornerRadius(cornerRadius)
                    .opacity((isWallpaperVisible && !shouldHideView) ? 1.0 : 0.0)
                    .animation(.themeSmoothFast, value: isWallpaperVisible)
                    .animation(.themeSmoothFast, value: shouldHideView)
                    .animation(.themeSmoothFast, value: viewModel.isMenuBarVisible)
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
        .animation(.themeEaseInOutFast, value: showWindowTitles)
        .animation(.themeEaseInOutFast, value: spaces)
        .padding(.leading, ConfigurationDefaults.menuBarHorizontalPadding)
        .onHover { hovering in
            isMouseHovering = hovering
        }
        .onChange(of: viewModel.wallpaper) { _, newWallpaper in
            handleWallpaperChange(wallpaper: newWallpaper, spaces: viewModel.spaces)
        }
        .onChange(of: viewModel.spaces) { _, newSpaces in
            handleWallpaperChange(wallpaper: viewModel.wallpaper, spaces: newSpaces)
        }
        .onAppear {
            #if DEBUG
                openSettings()
            #endif
        }
        .tag("spaces-main-view")
    }

    // MARK: - Private Methods

    /// Handles wallpaper and spaces changes to manage wallpaper visibility
    private func handleWallpaperChange(
        wallpaper: NSImage?,
        spaces: [Space]
    ) {
        if wallpaper != nil, !spaces.isEmpty {
            // Fade in wallpaper when spaces are available and image is loaded
            if !isWallpaperVisible {
                isWallpaperVisible = true
            }
        }
    }
}

#Preview {
    SpacesView()
        .environmentObject(DependencyContainer.shared.getSpacesViewModel())
}
