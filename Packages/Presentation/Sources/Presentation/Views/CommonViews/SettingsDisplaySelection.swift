// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import AppKit
import Domain
import SwiftUI

/// Settings rows for choosing which displays show a menu bar feature.
///
/// Renders a mode picker followed, in selected-displays mode, by one toggle per connected display.
/// The picker's subtitle asks for a selection only while no connected display is selected.
struct SettingsDisplaySelection: View {
    /// The title text for the mode picker.
    let title: LocalizedStringResource

    /// The subtitle shown while no connected display is selected.
    let emptySelectionMessage: LocalizedStringResource

    /// The binding to the display selection.
    @Binding var configuration: SpacesDisplayConfiguration

    /// The currently connected displays, refreshed when the screen arrangement changes.
    @State private var displays: [ConnectedDisplay] = ConnectedDisplay.current

    /// The persistent identifiers of the connected displays.
    private var connectedDisplayIDs: Set<String> {
        Set(displays.map(\.id))
    }

    /// The saved selections whose displays are not currently connected.
    private var disconnectedDisplayIDs: Set<String> {
        Set(configuration.selectedDisplayIDs).subtracting(connectedDisplayIDs)
    }

    /// Whether selected-displays mode currently matches no connected display.
    private var isSelectionEmpty: Bool {
        configuration.mode == .selected && connectedDisplayIDs.isDisjoint(with: configuration.selectedDisplayIDs)
    }

    /// Creates the display selection rows.
    /// - Parameters:
    ///   - title: The title text for the mode picker.
    ///   - emptySelectionMessage: The subtitle shown while no connected display is selected.
    ///   - configuration: A binding to the display selection.
    init(
        title: LocalizedStringResource,
        emptySelectionMessage: LocalizedStringResource,
        configuration: Binding<SpacesDisplayConfiguration>
    ) {
        self.title = title
        self.emptySelectionMessage = emptySelectionMessage
        _configuration = configuration
    }

    var body: some View {
        Picker(selection: $configuration.mode) {
            Text(LocalizedStringResource("Primary Display")).tag(SpacesDisplayConfiguration.Mode.primary)
            Text(LocalizedStringResource("All Displays")).tag(SpacesDisplayConfiguration.Mode.all)
            Text(LocalizedStringResource("Selected Displays")).tag(SpacesDisplayConfiguration.Mode.selected)
        } label: {
            VStack(alignment: .leading) {
                Text(title)
                    .tag("settings-display-selection-title")
                if isSelectionEmpty {
                    Text(emptySelectionMessage)
                        .secondaryText()
                        .tag("settings-display-selection-description")
                }
            }
        }
        .onReceive(
            NotificationCenter.default.publisher(for: NSApplication.didChangeScreenParametersNotification)
        ) { _ in
            displays = ConnectedDisplay.current
        }

        if configuration.mode == .selected {
            ForEach(displays) { display in
                Toggle(display.name, isOn: selectionBinding(for: display.id))
            }

            if !disconnectedDisplayIDs.isEmpty {
                Text(LocalizedStringResource("Selections for disconnected displays are saved."))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Button(LocalizedStringResource("Forget Disconnected Displays")) {
                    configuration.selectedDisplayIDs.removeAll { !connectedDisplayIDs.contains($0) }
                }
            }
        }
    }

    /// Creates a binding that adds or removes one display from the selection.
    /// - Parameter id: The persistent identifier of the display.
    /// - Returns: A binding reflecting whether the display is selected.
    private func selectionBinding(for id: String) -> Binding<Bool> {
        Binding(
            get: { configuration.selectedDisplayIDs.contains(id) },
            set: { selected in
                configuration.selectedDisplayIDs.removeAll { $0 == id }
                if selected {
                    configuration.selectedDisplayIDs.append(id)
                }
            }
        )
    }
}
