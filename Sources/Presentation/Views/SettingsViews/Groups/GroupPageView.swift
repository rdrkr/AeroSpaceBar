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
    private var group: Domain.Group {
        guard id >= 0, id < groupsViewModel.groups.count else {
            // Return a default group if index is out of bounds
            return Domain.Group.defaultInstance
        }

        return groupsViewModel.groups[id]
    }

    /// Creates a binding to a specific property of the group configuration.
    /// This is a convenience wrapper around the view model's binding method.
    /// - Parameter keyPath: The writable key path to the property
    /// - Returns: A binding to the property that automatically updates the view model
    private func binding<T>(for keyPath: WritableKeyPath<Domain.Group, T>) -> Binding<T> {
        groupsViewModel.binding(for: id, keyPath: keyPath)
    }

    /// Creates a binding to a specific property of the visual configuration.
    /// - Parameter keyPath: The writable key path to the visual config property
    /// - Returns: A binding to the property that automatically updates the view model
    private func visualBinding<T>(for keyPath: WritableKeyPath<VisualContainer, T>) -> Binding<T> {
        Binding(
            get: {
                group.visualConfig[keyPath: keyPath]
            },
            set: { newValue in
                var updatedConfig = group.visualConfig
                updatedConfig[keyPath: keyPath] = newValue
                groupsViewModel.updateGroupVisualConfig(for: id, visualConfig: updatedConfig)
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

    /// A binding to the group's end index, handling special cases like "all apps" indicator.
    private var endIndex: Binding<Int> {
        Binding(
            get: {
                groupsViewModel.groups[id].getEndIndex(menuBarAppsCount: totalApps)
            },
            set: { newEndIndex in
                groupsViewModel.groups[id].setEndIndex(newEndIndex, menuBarAppsCount: totalApps)
            }
        )
    }

    /// The main body of the group configuration view.
    var body: some View {
        Form {
            Section {
                GroupAppRangePicker(
                    startIndex: binding(for: \.startIndex),
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

            if groupsViewModel.groupsAppearanceMode == .perApp {
                Section(LocalizedStringResource("Group Background")) {
                    // Background Tint Color
                    SettingsColorPicker(
                        title: LocalizedStringResource("Tint Color"),
                        description: LocalizedStringResource("Choose the background tint color for this group"),
                        selectedColor: visualBinding(for: \.backgroundTintColor),
                        supportsOpacity: false
                    )

                    // Background Opacity
                    SettingsSlider(
                        value: visualBinding(for: \.backgroundOpacity),
                        in: 0.0 ... 1.0,
                        defaultValue: Group.defaultInstance.visualConfig.backgroundOpacity,
                        stickiness: 0.05,
                        label: LocalizedStringResource("Opacity"),
                        helpText: LocalizedStringResource("Adjust the background opacity of this group"),
                        displayAsPercentage: true
                    )

                    // Background Blur Radius
                    SettingsSlider(
                        value: visualBinding(for: \.backgroundBlurRadius),
                        in: 0.0 ... 10.0,
                        defaultValue: Group.defaultInstance.visualConfig.backgroundBlurRadius,
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
                        selectedColor: visualBinding(for: \.borderTintColor),
                        supportsOpacity: false
                    )

                    // Border Opacity
                    SettingsSlider(
                        value: visualBinding(for: \.borderOpacity),
                        in: 0.0 ... 1.0,
                        defaultValue: Group.defaultInstance.visualConfig.borderOpacity,
                        stickiness: 0.05,
                        label: LocalizedStringResource("Opacity"),
                        helpText: LocalizedStringResource("Adjust the border opacity of this group"),
                        displayAsPercentage: true
                    )

                    // Border Width
                    SettingsSlider(
                        value: visualBinding(for: \.borderWidth),
                        in: 0.0 ... 5.0,
                        defaultValue: Group.defaultInstance.visualConfig.borderWidth,
                        stickiness: 0.25,
                        label: LocalizedStringResource("Width"),
                        helpText: LocalizedStringResource("Adjust the border width of this group"),
                        displayAsPoints: true
                    )
                }

                Section(LocalizedStringResource("Group Geometry")) {
                    // Corner Radius
                    SettingsSlider(
                        value: visualBinding(for: \.cornerRadius),
                        in: 0.0 ... Group.defaultInstance.visualConfig.cornerRadius,
                        defaultValue: Group.defaultInstance.visualConfig.cornerRadius,
                        stickiness: 1.0,
                        label: LocalizedStringResource("Corner Radius"),
                        helpText: LocalizedStringResource("Adjust the corner radius of this group"),
                        displayAsPercentage: true
                    )
                }
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
        DispatchQueue.main.async {
            // Use the view model's method to remove the group
            groupsViewModel.removeGroup(at: id)
        }
    }
}
