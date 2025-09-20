// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Domain
import SwiftUI

/// Displays groups-related settings: group management, configuration, and organization of menu bar applications.
struct GroupsSettingsView: View {
    /// The settings view models
    @EnvironmentObject private var settingsViewModel: SettingsViewModel

    /// The groups view model
    @EnvironmentObject private var groupsViewModel: GroupsViewModel

    /// Whether to show the reset groups confirmation
    @State private var showingResetGroupsConfirmation = false

    /// The associated navigation page
    private let navigationOption: RootNavigationPage = .groups

    var body: some View {
        IntroForm(
            navigationTitle: String(localized: navigationOption.name),
            style: .compact,
            icon: navigationOption.icon,
            title: String(localized: navigationOption.name),
            subtitle: String(localized: LocalizedStringResource(
                """
                Organize menu bar applications into groups for better visual organization,
                including background, border, opacity and more.
                """
            ))
        ) {
            if groupsViewModel.showGroups {
                // Appearance Mode Picker Section
                Section {
                    Picker(
                        LocalizedStringResource("Configuration"),
                        selection: $groupsViewModel.groupsAppearanceMode
                    ) {
                        ForEach(GroupsAppearanceMode.allCases, id: \.self) { mode in
                            Text(mode.displayName)
                                .tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text(LocalizedStringResource("Appearance Mode"))
                } footer: {
                    Text(groupsViewModel.groupsAppearanceMode.description)
                }
                .tag("groups-appearance-mode-section")

                // Global Appearance Configuration Sections (for All Groups and Same as Spaces modes)
                if groupsViewModel.groupsAppearanceMode == .allGroups {
                    VisualSettingsView(
                        entityPrefix: LocalizedStringResource("Group"),
                        visualConfig: $settingsViewModel.globalGroupsVisualConfig,
                        defaultConfig: ConfigurationDefaults.defaultGroupsGlobalVisualConfig,
                        tagPrefix: "groups-global",
                        showForegroundSection: false
                    )
                }

                Section {
                    LazyVStackList(
                        onScrollProxyAvailable: { scrollToElement in
                            // Try to scroll when the LazyVStackList appears
                            if let storedGroupId = settingsViewModel.consumeGroupsScrollPosition() {
                                scrollToElement("group-\(storedGroupId)")
                            }
                        },
                        content: {
                            ForEach(groupsViewModel.groups) { group in
                                LazyVStackListRowItem(
                                    item: group,
                                    itemIndex: group.id,
                                    numberOfItems: groupsViewModel.groups.count,
                                    content: { group in
                                        Text(LocalizedStringResource("Group \(group.id + 1)"))
                                    },
                                    createPage: { group in
                                        AnyNavigationPage(GroupNavigationPage(index: group.id))
                                    },
                                    onRegisterDynamicSubPage: { groupPage in
                                        settingsViewModel.registerDynamicSubPage(groupPage)
                                    },
                                    onNavigateTo: { groupPage in
                                        // Store current group ID for scroll restoration
                                        settingsViewModel.storeGroupsScrollPosition(groupId: groupPage.id)
                                        settingsViewModel.navigateTo(groupPage)
                                    },
                                    onDelete: { groupPage in
                                        deleteGroup(at: groupPage.id)
                                    },
                                    shouldShowDeleteAction: { group in
                                        group.id > 0 // Groups with id > 0 can be deleted
                                    }
                                )
                                .id("group-\(group.id)")
                            }
                        }
                    )
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
                        .disabled(!groupsViewModel.canAddMoreGroups())
                    }
                } footer: {
                    Text(LocalizedStringResource(
                        """
                        Delete a group and its configuration by swipe, or by clicking the
                        group's delete button available in its configuration.
                        """
                    ))
                }

                if !groupsViewModel.groups.isEmpty {
                    Section(LocalizedStringResource("Reset")) {
                        SettingsDestructiveButton(
                            title: LocalizedStringResource("Reset Groups"),
                            description: LocalizedStringResource(
                                "Reset all groups to their default configuration."
                            ),
                            action: { showingResetGroupsConfirmation = true }
                        )
                        .tag("groups-reset-button")
                    }
                    .tag("groups-reset-section")
                }
            }
        } appendToHeader: {
            Toggle(isOn: $groupsViewModel.showGroups) {
                Text(LocalizedStringResource("Groups"))
            }
            .toggleStyle(.switch)
            .tag("groups-show-groups-toggle")
        }
        .animation(.themeEaseInOutFast, value: groupsViewModel.showGroups)
        .animation(.themeEaseInOutFast, value: groupsViewModel.groups.isEmpty)
        .animation(.themeEaseInOutFast, value: groupsViewModel.groupsAppearanceMode)
        .animation(.themeEaseInOutFast, value: groupsViewModel.groups)
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
