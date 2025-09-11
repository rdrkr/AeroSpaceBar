// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Domain
import SwiftUI

/// A detailed view for configuring a specific group.
struct GroupPageView: View {
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    @EnvironmentObject private var groupsViewModel: GroupsViewModel

    let id: Int

    private var group: GroupConfiguration {
        guard id >= 0, id < groupsViewModel.groupsConfiguration.count else {
            // Return a default group if index is out of bounds
            return GroupConfiguration.defaultInstance
        }

        return groupsViewModel.groupsConfiguration[id]
    }

    /// Creates a binding to a specific property of the group configuration.
    /// This generic helper eliminates the need for verbose GroupConfiguration recreations.
    /// - Parameter keyPath: The writable key path to the property
    /// - Returns: A binding to the property that automatically updates the view model
    private func binding<T>(for keyPath: WritableKeyPath<GroupConfiguration, T>) -> Binding<T> {
        Binding(
            get: {
                guard id >= 0, id < groupsViewModel.groupsConfiguration.count else {
                    return GroupConfiguration.defaultInstance[keyPath: keyPath]
                }

                return groupsViewModel.groupsConfiguration[id][keyPath: keyPath]
            },
            set: { newValue in
                guard id >= 0, id < groupsViewModel.groupsConfiguration.count else { return }

                groupsViewModel.groupsConfiguration[id][keyPath: keyPath] = newValue
            }
        )
    }

    private var totalApps: Int {
        groupsViewModel.menuBarApps.count
    }

    private var endIndex: Binding<Int> {
        Binding(
            get: {
                groupsViewModel.groupsConfiguration[id].getEndIndex(menuBarAppsCount: totalApps)
            },
            set: { newEndIndex in
                groupsViewModel.groupsConfiguration[id].setEndIndex(newEndIndex, menuBarAppsCount: totalApps)
            }
        )
    }

    var body: some View {
        Form {
            Section {
                GroupAppRangePicker(
                    startIndex: binding(for: \.startIndex),
                    endIndex: endIndex,
                    totalApps: totalApps
                )
            } header: {
                Text(LocalizedStringResource("Application Range"))
            } footer: {
                Text(LocalizedStringResource(
                    "The group range of applications included in this group, from right to left"
                ))
            }

            Section(LocalizedStringResource("Group Background")) {
                // Background Tint Color
                SettingsColorPicker(
                    title: LocalizedStringResource("Tint Color"),
                    description: LocalizedStringResource("Choose the background tint color for this group"),
                    selectedColor: binding(for: \.backgroundTintColor),
                    supportsOpacity: false
                )

                // Background Opacity
                SettingsSlider(
                    value: binding(for: \.backgroundOpacity),
                    in: 0.0 ... 1.0,
                    defaultValue: GroupConfiguration.defaultInstance.backgroundOpacity,
                    stickiness: 0.05,
                    label: LocalizedStringResource("Opacity"),
                    helpText: LocalizedStringResource("Adjust the background opacity of this group"),
                    displayAsPercentage: true
                )

                // Background Blur Radius
                SettingsSlider(
                    value: binding(for: \.backgroundBlurRadius),
                    in: 0.0 ... 10.0,
                    defaultValue: GroupConfiguration.defaultInstance.backgroundBlurRadius,
                    stickiness: 0.5,
                    label: LocalizedStringResource("Blur"),
                    helpText: LocalizedStringResource("Adjust the background blur radius of this group"),
                    displayAsPoints: true
                )
            }

            Section(LocalizedStringResource("Group Border")) {
                // Border Color
                SettingsColorPicker(
                    title: LocalizedStringResource("Tint Color"),
                    description: LocalizedStringResource("Choose the border tint color for this group"),
                    selectedColor: binding(for: \.borderColor),
                    supportsOpacity: false
                )

                // Border Opacity
                SettingsSlider(
                    value: binding(for: \.borderOpacity),
                    in: 0.0 ... 1.0,
                    defaultValue: GroupConfiguration.defaultInstance.borderOpacity,
                    stickiness: 0.05,
                    label: LocalizedStringResource("Opacity"),
                    helpText: LocalizedStringResource("Adjust the border opacity of this group"),
                    displayAsPercentage: true
                )

                // Border Width
                SettingsSlider(
                    value: binding(for: \.borderWidth),
                    in: 0.0 ... 5.0,
                    defaultValue: GroupConfiguration.defaultInstance.borderWidth,
                    stickiness: 0.25,
                    label: LocalizedStringResource("Width"),
                    helpText: LocalizedStringResource("Adjust the border width of this group"),
                    displayAsPoints: true
                )
            }

            Section(LocalizedStringResource("Group Geometry")) {
                // Corner Radius
                SettingsSlider(
                    value: binding(for: \.cornerRadius),
                    in: 0.0 ... GroupConfiguration.defaultInstance.cornerRadius,
                    defaultValue: GroupConfiguration.defaultInstance.cornerRadius,
                    stickiness: 1.0,
                    label: LocalizedStringResource("Corner Radius"),
                    helpText: LocalizedStringResource("Adjust the corner radius of this group"),
                    displayAsPercentage: true
                )
            }

            if id != 0 {
                Section(LocalizedStringResource("Delete")) {
                    SettingsDestructiveButton(
                        title: LocalizedStringResource("Delete Group"),
                        description: LocalizedStringResource("Delete this group and its configuration"),
                        action: deleteGroup
                    )
                    .tag("group-page-delete-group-button")
                }
            }
        }
        .formStyle(.grouped)
        .padding(.top, -20)
        .navigationTitle("Group \(id + 1)")
    }

    /// Delete this group and navigate back to the groups list
    private func deleteGroup() {
        // First navigate away to avoid state issues
        settingsViewModel.unregisterDynamicSubPage(withId: id)
        settingsViewModel.navigateBackward()

        // Then update the configuration on the next run loop
        DispatchQueue.main.async {
            // Use the view model's method to remove the group
            groupsViewModel.removeGroup(at: id)
        }
    }
}
