// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// Displays groups-related settings: group management, configuration, and organization of menu bar applications.
struct GroupsSettingsView: View {
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    @EnvironmentObject private var groupsViewModel: GroupsViewModel

    /// Whether to show the reset groups confirmation
    @State private var showingResetGroupsConfirmation = false

    /// The current navigation option
    private let navigationOption: RootNavigationPage = .groups

    /// The current group configuration
    private var groups: [GroupConfiguration] {
        groupsViewModel.groupsConfiguration
    }

    /// Whether we can add more groups (not every app has its own group)
    private var canAddMoreGroups: Bool {
        groupsViewModel.canAddMoreGroups()
    }

    var body: some View {
        IntroForm(
            navigationTitle: String(localized: navigationOption.name),
            style: .compact,
            image: Image(systemName: navigationOption.symbolName),
            title: String(localized: navigationOption.name),
            subtitle: String(localized: LocalizedStringResource(
                """
                Organize menu bar applications into groups for better visual organization,
                including background, border, opacity and more.
                """
            ))
        ) {
            if groupsViewModel.showGroups {
                Section {
                    List {
                        ForEach(Array(groups.enumerated()), id: \.element.id) { index, _ in
                            GroupSettingsListRowView(
                                groupId: index,
                                onRegisterDynamicSubPage: { groupPage in
                                    settingsViewModel.registerDynamicSubPage(groupPage)
                                },
                                onNavigateTo: { groupPage in
                                    settingsViewModel.navigateTo(groupPage)
                                },
                                onDelete: {
                                    deleteGroup(at: index)
                                }
                            )
                        }
                    }
                    .environment(\.defaultMinListHeaderHeight, 45)
                    .environment(\.defaultMinListRowHeight, 50)
                } header: {
                    HStack {
                        Text(LocalizedStringResource("Groups"))
                        Spacer()
                        Button {
                            groupsViewModel.addNewGroup()
                        } label: {
                            Image(systemName: "plus.circle")
                        }
                        .buttonStyle(.plain)
                        .disabled(!canAddMoreGroups)
                    }
                } footer: {
                    Text(LocalizedStringResource(
                        """
                        Delete a group and its configuration by swipe, or by clicking the
                        group's delete button available in its configuration
                        """
                    ))
                }
                .transition(.opacity.combined(with: .move(edge: .top)))

                if !groups.isEmpty {
                    Section(LocalizedStringResource("Reset")) {
                        SettingsDestructiveButton(
                            title: LocalizedStringResource("Reset Groups"),
                            description: LocalizedStringResource(
                                "Reset all groups to their default configuration"
                            ),
                            action: { showingResetGroupsConfirmation = true }
                        )
                        .tag("groups-reset-button")
                    }
                    .tag("groups-reset-section")
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        } appendToHeader: {
            Toggle(isOn: $groupsViewModel.showGroups) {
                Text(LocalizedStringResource("Groups"))
            }
            .toggleStyle(.switch)
            .tag("groups-show-groups-toggle")
        }
        .animation(.themeSmoothFast, value: groupsViewModel.showGroups)
        .animation(.themeSmoothFast, value: groups.isEmpty)
        .onChange(of: groupsViewModel.showGroups) { _, isEnabled in
            if !isEnabled {
                // When groups feature is disabled, remove all group pages from navigation history
                settingsViewModel.removeAllSubPagesOfType { page in
                    // Check if this is a GroupNavigationPage by checking if it has .groups as parent
                    page.parentPage?.id == RootNavigationPage.groups.id
                }
            }
        }
        .alert(
            String(localized: LocalizedStringResource("Reset Groups")),
            isPresented: $showingResetGroupsConfirmation
        ) {
            Button(LocalizedStringResource("Cancel"), role: .cancel) { }
            Button(LocalizedStringResource("Reset"), role: .destructive) {
                resetGroups()
            }
        } message: {
            Text(LocalizedStringResource(
                """
                Are you sure you want to reset all groups to their default configuration? \
                This action cannot be undone.
                """
            ))
        }
    }

    /// Delete a group and renumber the remaining groups
    private func deleteGroup(at index: Int) {
        // Unregister the specific group page from navigation
        settingsViewModel.unregisterDynamicSubPage(withId: index)

        // Use the view model to remove the group
        groupsViewModel.removeGroup(at: index)
    }

    /// Reset all groups
    private func resetGroups() {
        // Remove all group pages from navigation history before resetting
        settingsViewModel.removeAllSubPagesOfType { page in
            // Check if this is a GroupNavigationPage by checking if it has .groups as parent
            page.parentPage?.id == RootNavigationPage.groups.id
        }

        // Use the view model to reset to defaults
        groupsViewModel.resetGroupsToDefaults()
    }
}

#Preview {
    GroupsSettingsView()
        .frame(width: 600, height: 500)
}
