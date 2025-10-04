// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Domain
import SwiftUI

/// A SwiftUI view that provides the menu bar extra content for AeroSpaceBar.
///
/// This view contains menu items for Settings, About, Licensing, and Quit functionality,
/// replacing the previous NSMenu implementation with a SwiftUI-native approach.
/// The view uses `.window` style for MenuBarExtra to allow complete customization
/// while maintaining native macOS menu appearance and behavior.
public struct AppMenuView: View {
    /// The license view model that manages license state and actions.
    @EnvironmentObject private var licenseViewModel: LicenseViewModel

    /// The settings view model that manages application settings.
    @EnvironmentObject private var settingsViewModel: SettingsViewModel

    /// Environment action to open the settings window.
    @Environment(\.openSettings) private var openSettings

    /// Environment action to dismiss the current modal presentation.
    @Environment(\.dismiss) var dismiss

    public init() { }

    public var body: some View {
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

            // Check for Updates
            if settingsViewModel.featureFlags.enableSoftwareUpdates {
                MenuItemView(
                    title: "Check for Updates…",
                    systemImage: "arrow.trianglehead.2.clockwise.rotate.90.circle",
                    keyboardShortcut: "r"
                ) {
                    Task.detached(priority: .userInitiated) {
                        await settingsViewModel.checkForUpdates()
                    }
                    dismiss()
                }
                .tag("app-menu-check-updates-item")
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
            if licenseViewModel.enableLicense, licenseViewModel.licenseInfo.licenseStatus != LicenseStatus.licensed {
                LicenseMenuItemView(
                    licenseInfo: $licenseViewModel.licenseInfo,
                    enableTrialRequest: licenseViewModel.enableTrialRequest
                )
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
