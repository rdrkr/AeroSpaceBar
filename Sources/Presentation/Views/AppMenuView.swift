// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Domain
import SwiftUI

/// A SwiftUI view that provides the menu bar extra content for AeroSpaceBar.
///
/// This view contains menu items for Settings, About, Licensing, and Quit functionality,
/// replacing the previous NSMenu implementation with a SwiftUI-native approach.
/// The view uses `.window` style for MenuBarExtra to allow complete customization
/// while maintaining native macOS menu appearance and behavior.
struct AppMenuView: View {
    /// The license view model that manages license state and actions.
    @EnvironmentObject private var viewModel: LicenseViewModel

    /// Environment action to open the settings window.
    @Environment(\.openSettings) private var openSettings

    /// Environment action to dismiss the current modal presentation.
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            // Settings
            MenuItemView(
                title: "Settings...",
                systemImage: "gear",
                keyboardShortcut: ","
            ) {
                openSettings()
                dismiss()
            }
            .tag("app-menu-settings-item")

            MenuDivider(identifier: "1")

            // About
            MenuItemView(
                title: "About AeroSpaceBar",
                systemImage: "info.circle"
            ) {
                showAboutWindow()
                dismiss()
            }

            // Quit
            MenuDivider(identifier: "2")

            MenuItemView(
                title: "Quit AeroSpaceBar",
                systemImage: "power",
                keyboardShortcut: "q"
            ) {
                NSApplication.shared.terminate(nil)
            }

            // License
            if viewModel.enableLicense, viewModel.licenseInfo.licenseStatus != LicenseStatus.licensed {
                LicenseMenuItemView(licenseInfo: $viewModel.licenseInfo)
                    .tag("app-menu-license-item")
            }
        }
        .padding(5)
        .frame(width: 220)
        .tag("app-menu-view")
    }

    // MARK: - Actions

    /// Shows the About window for the application.
    ///
    /// This method posts a notification that is handled by the AppDelegate to display
    /// the About window. The notification-based approach is used to maintain separation
    /// between the menu UI and window management logic.
    ///
    /// - Note: In a future refactor, this could be moved to a SwiftUI WindowGroup
    ///         for more direct SwiftUI-native window management.
    private func showAboutWindow() {
        NotificationCenter.default.post(name: .showAboutWindow, object: nil)
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let showAboutWindow = Notification.Name("showAboutWindow")
}

#Preview {
    AppMenuView()
}
