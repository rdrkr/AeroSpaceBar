// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Domain
import SwiftUI

/// Displays spaces-related settings: space opacity, space blur radius, window titles, and more.
struct SpacesSettingsView: View {
    /// The settings view model
    @EnvironmentObject private var settingsViewModel: SettingsViewModel

    /// The spaces view model
    @EnvironmentObject private var spacesViewModel: SpacesViewModel

    var body: some View {
        VisualSettingsContainerView(
            navigationPage: .spaces,
            appearanceMode: $spacesViewModel.spacesAppearanceMode,
            entities: $spacesViewModel.allSpaces,
            globalVisualConfig: $spacesViewModel.globalSpacesVisualConfig,
            createNavigationPage: { (space: Domain.Space) in
                AnyNavigationPage(SpaceNavigationPage(spaceId: space.id))
            },
            onRegisterDynamicSubPage: settingsViewModel.registerDynamicSubPage,
            onNavigateTo: settingsViewModel.navigateTo,
            onResetEntities: {
                Task {
                    await spacesViewModel.resetSpacesToDefaults()
                }
            },
            shouldShowEntitiesList: {
                spacesViewModel.spacesAppearanceMode == .perSpace
            },
            prepend: {
                Section {
                    SettingsToggle(
                        title: LocalizedStringResource("Show Window Title"),
                        description: LocalizedStringResource("Display window title next to icons in the widget."),
                        isOn: $spacesViewModel.showWindowTitles
                    )

                    SettingsToggle(
                        title: LocalizedStringResource("Show Empty Spaces"),
                        description: LocalizedStringResource(
                            "Display spaces that contain no windows in the interface."
                        ),
                        isOn: $spacesViewModel.showEmptySpaces
                    )
                    .tag("advanced-show-empty-spaces-toggle")
                }
            }
        )
    }
}

#Preview {
    SpacesSettingsView().environmentObject(DependencyContainer.shared.getSettingsViewModel())
}
