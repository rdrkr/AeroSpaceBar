// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Domain
import SwiftUI

/// A detailed view for configuring a specific group.
///
/// This view provides a comprehensive interface for customizing group settings including:
/// - Application range selection with constraints
/// - Background appearance (color, opacity, blur)
/// - Border styling (color, opacity, width)
/// - Geometry configuration (corner radius)
/// - Group deletion (for non-primary groups)
struct GroupPageView: View {
    /// The settings view model for navigation management.
    @EnvironmentObject private var settingsViewModel: SettingsViewModel

    /// The groups view model for group configuration management.
    @EnvironmentObject private var groupsViewModel: GroupsViewModel

    /// The unique identifier of the group being configured.
    let id: Int

    /// The current group configuration for this group ID.
    /// Returns a default instance if the ID is out of bounds.
    private var group: Binding<Domain.Group> {
        Binding(
            get: {
                guard id >= 0, id < groupsViewModel.groups.count else {
                    // Return a default group if index is out of bounds
                    return Domain.Group.defaultInstance
                }

                return groupsViewModel.groups[id]
            },
            set: { newGroup in
                groupsViewModel.groups[id] = newGroup
            }
        )
    }

    /// A binding to the group's end index, handling special cases like "all apps" indicator.
    private var endIndex: Binding<Int> {
        Binding(
            get: {
                group.wrappedValue.getEndIndex(menuBarAppsCount: totalApps)
            },
            set: { newEndIndex in
                group.wrappedValue.setEndIndex(newEndIndex, menuBarAppsCount: totalApps)
            }
        )
    }

    /// The total number of menu bar applications currently available.
    private var totalApps: Int {
        groupsViewModel.menuBarApps.count
    }

    /// The minimum start index for this group based on the previous group's constraints.
    private var minimumStartIndex: Int {
        groupsViewModel.minimumStartIndex(for: id)
    }

    /// The maximum end index for this group based on the next group's constraints.
    private var maximumEndIndex: Int {
        groupsViewModel.maximumEndIndex(for: id)
    }

    /// The main body of the group configuration view.
    var body: some View {
        Form {
            Section {
                GroupAppRangePicker(
                    startIndex: group.startIndex,
                    endIndex: endIndex,
                    totalApps: totalApps,
                    minimumStartIndex: minimumStartIndex,
                    maximumEndIndex: maximumEndIndex
                )
            } header: {
                Text(LocalizedStringResource("Application Range"))
            } footer: {
                Text(LocalizedStringResource(
                    "The group range of applications included in this group, from right to left."
                ))
            }

            if groupsViewModel.groupsAppearanceMode == .perGroup {
                VisualSettingsView(
                    metadata: Domain.Group.metadata,
                    visualConfig: group.visualConfig
                )
            }

            if id != 0 {
                Section(LocalizedStringResource("Delete")) {
                    SettingsDestructiveButton(
                        title: LocalizedStringResource("Delete Group"),
                        description: LocalizedStringResource("Delete this group and its configuration."),
                        action: deleteGroup
                    )
                    .tag("group-page-delete-group-button")
                }
            }
        }
        .settingsFormStyle()
        .navigationTitle("Group \(id + 1)")
    }

    /// Deletes this group and navigates back to the groups list.
    private func deleteGroup() {
        // First navigate away to avoid state issues
        settingsViewModel.unregisterDynamicSubPage(withId: id)
        settingsViewModel.navigateBackward()

        // Then update the configuration on the next run loop
        Task { @MainActor in
            // Use the view model's method to remove the group
            groupsViewModel.removeGroup(at: id)
        }
    }
}
