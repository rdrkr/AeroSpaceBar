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

            Divider()

            // About
            Button(action: {
                showAboutWindow()
                dismiss()
            }, label: {
                Label("About AeroSpaceBar", systemImage: "info.circle")
            })

            Divider()

            // Quit
            Button(action: {
                NSApplication.shared.terminate(nil)
            }, label: {
                Label("Quit AeroSpaceBar", systemImage: "power")
            })
            .keyboardShortcut("q")
        }
        .padding(.vertical, 4)
        .frame(minWidth: 200)
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
