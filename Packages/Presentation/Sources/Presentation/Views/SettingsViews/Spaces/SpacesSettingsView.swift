// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Domain
import SwiftUI

/// Displays spaces-related settings: space opacity, space blur radius, window titles, and more.
struct SpacesSettingsView: View {
    /// The settings view model
    @EnvironmentObject private var settingsViewModel: SettingsViewModel

    /// The spaces view model
    @EnvironmentObject private var spacesViewModel: SpacesViewModel

    /// Binding that returns `spacesWithAppleButton` for reads and writes back to `allSpaces`.
    private var spacesWithAppleButtonBinding: Binding<[Domain.Space]> {
        Binding(
            get: { spacesViewModel.spacesWithAppleButton },
            set: { spacesViewModel.allSpaces = $0.filter { $0.id != Space.appleButtonId } }
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
    }
}

#Preview {
    SpacesSettingsView().environmentObject(DependencyContainer.shared.getSettingsViewModel())
}
