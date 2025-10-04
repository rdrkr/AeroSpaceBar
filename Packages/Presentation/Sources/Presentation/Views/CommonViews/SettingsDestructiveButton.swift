// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// A reusable destructive button component for settings views.
///
/// This component provides a consistent interface for destructive actions in settings,
/// with both a button and descriptive help text to explain the action's consequences.
struct SettingsDestructiveButton: View {
    /// The title text for the destructive button
    let title: LocalizedStringResource

    /// The description text explaining what the destructive action will do
    let description: LocalizedStringResource

    /// The action to perform when the button is pressed
    let action: () -> Void

    /// Creates a new settings destructive button.
    /// - Parameters:
    ///   - title: The title text for the destructive button
    ///   - description: The description text explaining what the destructive action will do
    ///   - action: The action to perform when the button is pressed
    init(
        title: LocalizedStringResource,
        description: LocalizedStringResource,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.description = description
        self.action = action
    }

    var body: some View {
        VStack(alignment: .leading) {
            Button(title) {
                action()
            }
            .foregroundColor(.red)
            .tag("settings-destructive-button")

            Text(description)
                .secondaryText()
                .tag("settings-destructive-description")
        }
        .tag("settings-destructive-button-row")
    }
}

#Preview {
    Form {
        Section {
            SettingsDestructiveButton(
                title: "Delete Group",
                description: "Delete this group and its configuration",
                action: { print("Delete action") }
            )
        }
    }
    .settingsFormStyle()
}
