// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Domain
import SwiftUI

/// Displays groups-related settings: group management, configuration, and organization of menu bar applications.
struct GroupsSettingsView: View {
    /// The settings view models
    @EnvironmentObject private var settingsViewModel: SettingsViewModel

    /// The groups view model
    @EnvironmentObject private var groupsViewModel: GroupsViewModel

    var body: some View {
        VisualSettingsContainerView(
            navigationPage: .groups,
            isFeatureEnabled: $groupsViewModel.showGroups,
            appearanceMode: $groupsViewModel.groupsAppearanceMode,
            availableAppearanceModes: $groupsViewModel.availableGroupsAppearanceModes,
            entities: $groupsViewModel.groups,
            globalColorProperties: $groupsViewModel.globalGroupsColorProperties,
            globalGeometricProperties: $groupsViewModel.globalGroupsGeometricProperties,
            globalEffectProperties: $groupsViewModel.globalGroupsEffectProperties,
            themeMode: groupsViewModel.themeMode,
            themePresetColorProperties: $groupsViewModel.themePresetColorProperties,
            createNavigationPage: { group in
                AnyNavigationPage(GroupNavigationPage(index: group.id))
            },
            onRegisterDynamicSubPage: settingsViewModel.registerDynamicSubPage,
            onNavigateTo: settingsViewModel.navigateTo,
            onAddEntity: groupsViewModel.addNewGroup,
            onDeleteEntity: deleteGroup,
            onResetEntities: resetGroups,
            canAddMoreEntities: groupsViewModel.canAddMoreGroups,
            onFeatureDisabled: {
                settingsViewModel.removeAllSubPagesOfType { page in
                    page.parentPage?.id == RootNavigationPage.groups.id
                }
            },
            prepend: {
                foregroundOverlaySection
            }
        )
    }

    /// The foreground overlay toggle section with description and note.
    private var foregroundOverlaySection: some View {
        Section {
            SettingsToggle(
                title: LocalizedStringResource("Foreground Color Overlay"),
                description: LocalizedStringResource(
                    "Tints menu bar icons with a colored overlay."
                ),
                isOn: $groupsViewModel.showForegroundOverlay
            )
            .tag("groups-foreground-overlay-toggle")
        } footer: {
            Text(
                LocalizedStringResource(
                    "Note: may not produce accurate results for all color combinations."
                )
            )
        }
    }

    /// Delete a group and renumber the remaining groups.
    private func deleteGroup(at group: Domain.Group) {
        settingsViewModel.unregisterDynamicSubPage(withId: group.id)
        groupsViewModel.removeGroup(at: group.id)
    }

    /// Reset all groups.
    private func resetGroups() {
        settingsViewModel.removeAllSubPagesOfType { page in
            page.parentPage?.id == RootNavigationPage.groups.id
        }

        Task {
            withAnimation(.themeEaseInOutFast) {
                Task {
                    await groupsViewModel.resetGroupsToDefaults()
                }
            }
        }
    }
}

#Preview {
    GroupsSettingsView()
        .frame(width: 600, height: 500)
}
