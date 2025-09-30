// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// The main application entry point for AeroSpaceBar.
///
/// This app provides a menu bar interface for managing AeroSpace workspaces and windows.
/// It displays a visual representation of spaces and their associated windows in the menu bar area.
@main
struct AeroSpaceBarApp: App {
    /// The application delegate that manages the menu bar panel and app lifecycle.
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    /// The app view model for managing app-level state.
    @StateObject private var appViewModel = DependencyContainer.shared.getAppViewModel()

    /// The main scene configuration for the application.
    ///
    /// This creates no scenes since the main interface
    /// is displayed in the menu bar panel rather than a traditional window.
    var body: some Scene {
        MenuBarExtra {
            AppMenuView()
                .environmentObject(DependencyContainer.shared.getLicenseViewModel())
        } label: {
            Image(appViewModel.isGlobeKeyPressed ? "AppGlyphGlobe" : "AppGlyph")
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .environmentObject(DependencyContainer.shared.getSettingsViewModel())
                .environmentObject(DependencyContainer.shared.getSpacesViewModel())
                .environmentObject(DependencyContainer.shared.getGroupsViewModel())
                .environmentObject(DependencyContainer.shared.getLicenseViewModel())
        }
    }
}
