// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// A reusable settings row with a color picker.
///
/// This component provides a consistent interface for settings that allow users to select colors,
/// with both a title and descriptive text to explain the setting's purpose.
struct SettingsColorPicker: View {
    /// The title text for the color setting
    let title: LocalizedStringResource

    /// The description text explaining what the color setting affects
    let description: LocalizedStringResource

    /// The accessibility label for the color picker
    let accessibilityLabel: String

    /// The binding to the selected color value
    @Binding var selectedColor: Color

    /// Whether the color picker supports opacity selection
    let supportsOpacity: Bool

    /// Creates a new settings color picker.
    /// - Parameters:
    ///   - title: The title text for the color setting
    ///   - description: The description text explaining what the color setting affects
    ///   - selectedColor: A binding to the selected color value
    ///   - supportsOpacity: Whether the color picker supports opacity selection (defaults to false)
    init(
        title: LocalizedStringResource,
        description: LocalizedStringResource,
        selectedColor: Binding<Color>,
        supportsOpacity: Bool = false
    ) {
        self.title = title
        self.description = description
        accessibilityLabel = String(localized: title)
        _selectedColor = selectedColor
        self.supportsOpacity = supportsOpacity
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .tag("settings-color-title")
                    Text(description)
                        .secondaryText()
                        .tag("settings-color-description")
                }

                Spacer()

                ColorPicker(
                    accessibilityLabel,
                    selection: $selectedColor,
                    supportsOpacity: supportsOpacity
                )
                .labelsHidden()
                .tag("settings-color-picker")
            }
        }
        .tag("settings-color-row")
    }
}

#Preview {
    Form {
        Section {
            SettingsColorPicker(
                title: "Background Color",
                description: "Choose the background color for elements",
                selectedColor: .constant(.blue)
            )
        }
    }
    .settingsFormStyle()
}
