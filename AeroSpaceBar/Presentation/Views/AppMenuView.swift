// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// A SwiftUI view that provides the menu bar extra content for AeroSpaceBar.
///
/// This view contains menu items for Settings, About, and Quit functionality,
/// replacing the previous NSMenu implementation with a SwiftUI-native approach.
struct AppMenuView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Settings
            SettingsLink()
                .keyboardShortcut(",")
                .tag("app-menu-settings-link")

            Divider()
                .tag("app-menu-divider-1")

            // About
            Button(action: {
                showAboutWindow()
                dismiss()
            }, label: {
                Label(LocalizedStringResource("About AeroSpaceBar"), systemImage: "info.circle")
            })
            .tag("app-menu-about-button")

            Divider()
                .tag("app-menu-divider-2")

            // Quit
            Button(action: {
                NSApplication.shared.terminate(nil)
            }, label: {
                Label(LocalizedStringResource("Quit AeroSpaceBar"), systemImage: "power")
            })
            .keyboardShortcut("q")
            .tag("app-menu-quit-button")
        }
        .padding(.vertical, 4)
        .frame(minWidth: 200)
        .tag("app-menu-view")
    }

    // MARK: - Actions

    private func showAboutWindow() {
        // This will be handled by the AppDelegate for now
        // In a future refactor, this could be moved to a SwiftUI WindowGroup
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
