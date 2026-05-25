// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// A reusable settings row with a multi-select menu dropdown.
///
/// This component provides a consistent interface for settings that allow selecting
/// multiple options from a list, with both a title and descriptive text to explain
/// the setting's purpose. The menu displays toggles for each option and shows
/// a summary of the current selection.
struct SettingsMultiSelectMenu: View {
    /// The title text for the setting.
    let title: LocalizedStringResource

    /// The description text explaining what the setting does.
    let description: LocalizedStringResource

    /// The available options to choose from.
    let options: [String]

    /// The binding to the set of currently selected option values.
    @Binding var selection: Set<String>

    /// A display summary of the current selection.
    ///
    /// Returns "None" when no options are selected, "All" when all options
    /// are selected, or a comma-separated list of selected items.
    private var selectionSummary: String {
        if selection.isEmpty {
            String(localized: "None")
        } else if options.count == selection.count {
            String(localized: "All")
        } else {
            options.filter { selection.contains($0) }.joined(separator: ", ")
        }
    }

    /// Creates a new multi-select menu setting.
    /// - Parameters:
    ///   - title: The title text for the setting
    ///   - description: The description text explaining what the setting does
    ///   - options: The available options to choose from
    ///   - selection: A binding to the set of currently selected option values
    init(
        title: LocalizedStringResource,
        description: LocalizedStringResource,
        options: [String],
        selection: Binding<Set<String>>
    ) {
        self.title = title
        self.description = description
        self.options = options
        _selection = selection
    }

    var body: some View {
        LabeledContent {
            Menu {
                ForEach(options, id: \.self) { option in
                    Toggle(option, isOn: toggleBinding(for: option))
                }
            } label: {
                Text(selectionSummary)
                    .frame(minWidth: 60, alignment: .trailing)
            }
            .menuStyle(.borderlessButton)
            .fixedSize()
        } label: {
            VStack(alignment: .leading) {
                Text(title)
                    .tag("settings-multi-select-title")
                Text(description)
                    .secondaryText()
                    .tag("settings-multi-select-description")
            }
        }
        .tag("settings-multi-select-row")
    }

    /// Creates a `Binding<Bool>` for a specific option, toggling its membership in the selection set.
    /// - Parameter option: The option value to create a binding for
    /// - Returns: A binding that adds/removes the option from the selection set
    private func toggleBinding(for option: String) -> Binding<Bool> {
        Binding<Bool>(
            get: { selection.contains(option) },
            set: { isSelected in
                if isSelected {
                    selection.insert(option)
                } else {
                    selection.remove(option)
                }
            }
        )
    }
}

#Preview {
    Form {
        Section {
            SettingsMultiSelectMenu(
                title: "Hide Spaces",
                description: "Select spaces to hide from the menu bar interface.",
                options: ["1", "2", "3", "H"],
                selection: .constant(Set(["2", "H"]))
            )
        }
    }
    .settingsFormStyle()
}
