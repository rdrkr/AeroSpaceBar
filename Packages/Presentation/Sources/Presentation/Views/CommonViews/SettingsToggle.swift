// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// A reusable settings row with a toggle switch.
///
/// This component provides a consistent interface for settings that can be toggled on or off,
/// with both a title and descriptive text to explain the setting's purpose.
struct SettingsToggle: View {
    /// The title text for the setting
    let title: LocalizedStringResource

    /// The description text explaining what the setting does
    let description: LocalizedStringResource

    /// The binding to the boolean value that controls the toggle state
    @Binding var isOn: Bool

    /// Creates a new settings toggle.
    /// - Parameters:
    ///   - title: The title text for the setting
    ///   - description: The description text explaining what the setting does
    ///   - isOn: A binding to the boolean value that controls the toggle state
    init(
        title: LocalizedStringResource,
        description: LocalizedStringResource,
        isOn: Binding<Bool>
    ) {
        self.title = title
        self.description = description
        _isOn = isOn
    }

    var body: some View {
        Toggle(isOn: $isOn) {
            VStack(alignment: .leading) {
                Text(title)
                    .tag("settings-toggle-title")
                Text(description)
                    .secondaryText()
                    .tag("settings-toggle-description")
            }
        }
        .toggleStyle(.switch)
        .tag("settings-toggle-row")
    }
}

#Preview {
    Form {
        Section {
            SettingsToggle(
                title: "Show Window Titles",
                description: "Display window titles next to icons in the widget.",
                isOn: .constant(true)
            )
        }
    }
    .settingsFormStyle()
}
