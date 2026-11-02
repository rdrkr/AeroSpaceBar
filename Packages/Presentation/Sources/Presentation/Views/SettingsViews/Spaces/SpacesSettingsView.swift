// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import AppKit
import Domain
import SwiftUI

/// Displays spaces-related settings: space opacity, space blur radius, window titles, and more.
struct SpacesSettingsView: View {
    /// The settings view model
    @EnvironmentObject private var settingsViewModel: SettingsViewModel

    /// The spaces view model
    @EnvironmentObject private var spacesViewModel: SpacesViewModel

    @State private var displays: [ConnectedDisplay] = ConnectedDisplay.current

    /// Binding that returns `spacesWithAppleButton` for reads and writes back to `allSpaces`.
    private var spacesWithAppleButtonBinding: Binding<[Domain.Space]> {
        Binding(
            get: { spacesViewModel.spacesWithAppleButton },
            set: { spacesViewModel.allSpaces = $0.filter { $0.id != Space.appleButtonId } }
        )
    }

    private var connectedDisplayIDs: Set<String> {
        Set(displays.map(\.id))
    }

    private var disconnectedDisplayIDs: Set<String> {
        Set(settingsViewModel.spacesDisplayConfiguration.selectedDisplayIDs).subtracting(connectedDisplayIDs)
    }

    private func selectionBinding(for id: String) -> Binding<Bool> {
        Binding(
            get: { settingsViewModel.spacesDisplayConfiguration.selectedDisplayIDs.contains(id) },
            set: { selected in
                var configuration = settingsViewModel.spacesDisplayConfiguration
                configuration.selectedDisplayIDs.removeAll { $0 == id }
                if selected {
                    configuration.selectedDisplayIDs.append(id)
                }
                settingsViewModel.spacesDisplayConfiguration = configuration
            }
        )
    }

    var body: some View {
        VisualSettingsContainerView(
            navigationPage: .spaces,
            appearanceMode: $spacesViewModel.spacesAppearanceMode,
            entities: spacesWithAppleButtonBinding,
            globalColorProperties: $spacesViewModel.globalSpacesColorProperties,
            globalGeometricProperties: $spacesViewModel.globalSpacesGeometricProperties,
            globalEffectProperties: $spacesViewModel.globalSpacesEffectProperties,
            themeMode: spacesViewModel.themeMode,
            themePresetColorProperties: $spacesViewModel.themePresetColorProperties,
            themePresetGeometricProperties: $spacesViewModel.themePresetGeometricProperties,
            themePresetEffectProperties: $spacesViewModel.themePresetEffectProperties,
            createNavigationPage: { (space: Domain.Space) in
                AnyNavigationPage(SpaceNavigationPage(spaceId: space.id))
            },
            onRegisterDynamicSubPage: settingsViewModel.registerDynamicSubPage,
            onNavigateTo: settingsViewModel.navigateTo,
            onResetEntities: {
                Task {
                    withAnimation(.themeEaseInOutFast) {
                        Task {
                            await spacesViewModel.resetSpacesToDefaults()
                        }
                    }
                }
            },
            shouldShowEntitiesList: {
                spacesViewModel.spacesAppearanceMode == .perSpace &&
                    spacesViewModel.themeMode.isColorCustomizable
            },
            prepend: {
                Section {
                    Picker(
                        LocalizedStringResource("Show Spaces On"),
                        selection: $settingsViewModel.spacesDisplayConfiguration.mode
                    ) {
                        Text(LocalizedStringResource("Primary Display")).tag(SpacesDisplayConfiguration.Mode.primary)
                        Text(LocalizedStringResource("All Displays")).tag(SpacesDisplayConfiguration.Mode.all)
                        Text(LocalizedStringResource("Selected Displays")).tag(SpacesDisplayConfiguration.Mode.selected)
                    }

                    if settingsViewModel.spacesDisplayConfiguration.mode == .selected {
                        ForEach(displays) { display in
                            Toggle(display.name, isOn: selectionBinding(for: display.id))
                        }

                        if connectedDisplayIDs.isDisjoint(
                            with: settingsViewModel.spacesDisplayConfiguration.selectedDisplayIDs
                        ) {
                            Text(LocalizedStringResource("Choose at least one connected display to show spaces."))
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }

                        if !disconnectedDisplayIDs.isEmpty {
                            Text(LocalizedStringResource("Selections for disconnected displays are saved."))
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            Button(LocalizedStringResource("Forget Disconnected Displays")) {
                                var configuration = settingsViewModel.spacesDisplayConfiguration
                                configuration.selectedDisplayIDs.removeAll { !connectedDisplayIDs.contains($0) }
                                settingsViewModel.spacesDisplayConfiguration = configuration
                            }
                        }
                    }

                    SettingsToggle(
                        title: LocalizedStringResource("Show Window Title"),
                        description: LocalizedStringResource("Display window title next to icons in the widget."),
                        isOn: $spacesViewModel.showWindowTitles
                    )

                    SettingsMultiSelectMenu(
                        title: LocalizedStringResource("Hide Spaces"),
                        description: LocalizedStringResource(
                            "Select spaces to exclude from the menu bar interface."
                        ),
                        options: spacesViewModel.allSpaces.map(\.id),
                        selection: $spacesViewModel.hiddenSpaces
                    )
                    .tag("advanced-hide-spaces-menu")

                    SettingsToggle(
                        title: LocalizedStringResource("Show Empty Spaces"),
                        description: LocalizedStringResource(
                            "Display spaces that contain no windows in the interface."
                        ),
                        isOn: $spacesViewModel.showEmptySpaces
                    )
                    .tag("advanced-show-empty-spaces-toggle")

                    SettingsToggle(
                        title: LocalizedStringResource("Show Apple Button as Space"),
                        description: LocalizedStringResource(
                            "Render a background behind the macOS Apple menu icon using the spaces visual system."
                        ),
                        isOn: $spacesViewModel.showAppleButtonAsSpace
                    )
                    .tag("advanced-show-apple-button-as-space-toggle")
                }
            }
        )
        .onReceive(
            NotificationCenter.default.publisher(for: NSApplication.didChangeScreenParametersNotification)
        ) { _ in
            displays = ConnectedDisplay.current
        }
    }
}

#Preview {
    SpacesSettingsView().environmentObject(DependencyContainer.shared.getSettingsViewModel())
}
