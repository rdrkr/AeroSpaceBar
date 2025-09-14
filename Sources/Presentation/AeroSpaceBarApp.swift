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

    /// The main scene configuration for the application.
    ///
    /// This creates no scenes since the main interface
    /// is displayed in the menu bar panel rather than a traditional window.
    var body: some Scene {
        #if DEBUG
            WindowGroup {
                SettingsView()
                    .environmentObject(DependencyContainer.shared.getSettingsViewModel())
                    .environmentObject(DependencyContainer.shared.getGroupsViewModel())
                    .environmentObject(DependencyContainer.shared.getLicensingViewModel())
            }
            .windowResizability(.contentMinSize)
        #endif

        MenuBarExtra {
            AppMenuView()
                .environmentObject(DependencyContainer.shared.getLicensingViewModel())
        } label: {
            Image("AppGlyph")
        }

        Settings {
            SettingsView()
                .environmentObject(DependencyContainer.shared.getSettingsViewModel())
                .environmentObject(DependencyContainer.shared.getGroupsViewModel())
                .environmentObject(DependencyContainer.shared.getLicensingViewModel())
        }
    }
}
