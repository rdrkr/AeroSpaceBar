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
            globalVisualConfig: $groupsViewModel.globalGroupsVisualConfig,
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
                // When groups feature is disabled, remove all group pages from navigation history
                settingsViewModel.removeAllSubPagesOfType { page in
                    // Check if this is a GroupNavigationPage by checking if it has .groups as parent
                    page.parentPage?.id == RootNavigationPage.groups.id
                }
            }
        )
    }

    /// Delete a group and renumber the remaining groups
    private func deleteGroup(at group: Domain.Group) {
        // Unregister the specific group page from navigation
        settingsViewModel.unregisterDynamicSubPage(withId: group.id)

        // Use the view model to remove the group
        groupsViewModel.removeGroup(at: group.id)
    }

    /// Reset all groups
    private func resetGroups() {
        // Remove all group pages from navigation history before resetting
        settingsViewModel.removeAllSubPagesOfType { page in
            // Check if this is a GroupNavigationPage by checking if it has .groups as parent
            page.parentPage?.id == RootNavigationPage.groups.id
        }

        // Reset groups configuration and visual settings via GroupsViewModel
        Task {
            await groupsViewModel.resetGroupsToDefaults()
        }
    }
}

#Preview {
    GroupsSettingsView()
        .frame(width: 600, height: 500)
}
