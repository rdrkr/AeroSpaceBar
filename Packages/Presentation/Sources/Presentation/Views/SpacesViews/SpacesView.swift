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
    @State private var monitoredWallpaperVisibility = false

    /// Whether the wallpaper should be monitored for visibility changes.
    @State private var shouldMonitorWallpaperVisibility = true

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
        viewModel.globalSpacesGeometricProperties.cornerRadius
    }

    /// Computed property for whether to show window titles
    private var showWindowTitles: Bool {
        viewModel.showWindowTitles
    }

    /// Whether the view should be hidden based on Quick Hide trigger key + mouse hover combination, menu bar
    /// visibility, or AeroSpace status.
    private var shouldHideView: Bool {
        !viewModel.isSpacesEnabled ||
            (viewModel.isQuickHideEnabled && isMouseHovering && viewModel.isQuickHideTriggerKeyPressed) ||
            !viewModel.isMenuBarVisible ||
            !viewModel.isAeroSpaceRunning
    }

    /// Whether the wallpaper should be visible (faded in)
    private var isWallpaperVisible: Bool {
        shouldMonitorWallpaperVisibility ? monitoredWallpaperVisibility : true
    }

    /// The body of the spaces view.
    ///
    /// This view creates a horizontal layout of spaces with their associated windows,
    /// using the captured desktop wallpaper as background.
    var body: some View {
        Group {
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
                            globalColorProperties: viewModel.globalSpacesColorProperties,
                            globalGeometricProperties: viewModel.globalSpacesGeometricProperties,
                            globalEffectProperties: viewModel.globalSpacesEffectProperties,
                            themeMode: viewModel.themeMode,
                            themePresetColorProperties: viewModel.themePresetColorProperties,
                            themePresetGeometricProperties: viewModel.themePresetGeometricProperties,
                            themePresetEffectProperties: viewModel.themePresetEffectProperties,
                            onSwitchToSpace: viewModel.switchToSpace,
                            onSwitchToWindow: viewModel.switchToWindow
                        )
                        .offset(y: (isWallpaperVisible && !shouldHideView) ? 0 : -menuBarHeight)
                        .tag("spaces-container")
                    }
                    .cornerRadius(cornerRadius)
                    .opacity((isWallpaperVisible && !shouldHideView) ? 1.0 : 0.0)
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
        .animation(.themeEaseInOutFast, value: shouldMonitorWallpaperVisibility)
        .animation(.themeEaseInOutFast, value: monitoredWallpaperVisibility)
        .animation(.themeEaseInOutFast, value: shouldHideView)
        .animation(.themeEaseInOutFast, value: viewModel.isMenuBarVisible)
        .animation(.themeEaseInOutFast, value: viewModel.spacesAppearanceMode)
        .animation(.themeEaseInOutFast, value: viewModel.themeMode)
        .animation(.themeEaseInOutFast, value: showWindowTitles)
        .animation(.themeEaseInOutFast, value: spaces)
        .padding(.leading, ConfigurationDefaults.menuBarHorizontalPadding)
        .onHover { hovering in
            isMouseHovering = hovering
        }
        .onChange(of: viewModel.wallpaper) { oldWallpaper, newWallpaper in
            handleWallpaperChange(
                oldWallpaper: oldWallpaper,
                newWallpaper: newWallpaper,
                spaces: viewModel.spaces
            )
        }
        .onChange(of: viewModel.spaces) { _, newSpaces in
            handleWallpaperChange(
                oldWallpaper: viewModel.wallpaper,
                newWallpaper: viewModel.wallpaper,
                spaces: newSpaces
            )
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
        oldWallpaper: NSImage?,
        newWallpaper: NSImage?,
        spaces: [Space]
    ) {
        if newWallpaper != nil, !spaces.isEmpty {
            // Fade in wallpaper when spaces are available and image is loaded
            if !monitoredWallpaperVisibility {
                monitoredWallpaperVisibility = true
                // Spaces animation only tracks the first time wallpaper is available.
                shouldMonitorWallpaperVisibility = false
            }
            // Fade out and back in when image is loaded and spaces are available
            else if oldWallpaper != newWallpaper, monitoredWallpaperVisibility {
                monitoredWallpaperVisibility = false

                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(0.2))
                    monitoredWallpaperVisibility = true
                }
            }
        }
    }
}

#Preview {
    SpacesView()
        .environmentObject(DependencyContainer.shared.getSpacesViewModel())
}
