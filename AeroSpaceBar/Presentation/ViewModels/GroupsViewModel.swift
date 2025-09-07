// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation
import SwiftUI

/// A view model that manages group configuration for menu bar applications.
///
/// This class coordinates the grouping of menu bar applications, allowing users
/// to organize apps into groups for better visual organization in the menu bar.
@MainActor
final class GroupsViewModel: ObservableObject {
    // MARK: - Published Properties

    /// Whether to show groups in the interface.
    @Published var showGroups: Bool {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setShowGroupsUseCase.execute(showGroups)
            }
        }
    }

    /// The current group configuration.
    @Published var groupsConfiguration: [GroupConfiguration] {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setGroupsConfigurationUseCase.execute(groupsConfiguration)
            }
        }
    }

    /// The current list of menu bar applications.
    @Published var menuBarApps: [MenuBarApp]

    /// Whether groups functionality is enabled via feature flags.
    @Published var isGroupsFeatureEnabled: Bool

    /// The animation duration for UI transitions.
    @Published var animationDuration: Double

    /// The widget spacing for UI layout.
    @Published var widgetSpacing: CGFloat

    // MARK: - Dependencies

    private let getShowGroupsUseCase: GetShowGroupsUseCase
    private let setShowGroupsUseCase: SetShowGroupsUseCase
    private let getGroupsConfigurationUseCase: GetGroupsConfigurationUseCase
    private let setGroupsConfigurationUseCase: SetGroupsConfigurationUseCase
    private let getMenuBarAppsUseCase: GetMenuBarAppsUseCase
    private let getFeatureFlagsUseCase: GetFeatureFlagsUseCase
    private let getAnimationDurationUseCase: GetAnimationDurationUseCase
    private let getWidgetSpacingUseCase: GetWidgetSpacingUseCase

    /// Cancellable subscriptions for Combine publishers.
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initialization

    /// Initializes the groups view model with dependencies.
    /// - Parameters:
    ///   - getShowGroupsUseCase: The use case for getting show groups setting
    ///   - setShowGroupsUseCase: The use case for setting show groups setting
    ///   - getGroupsConfigurationUseCase: The use case for getting group configuration
    ///   - setGroupsConfigurationUseCase: The use case for setting group configuration
    ///   - getMenuBarAppsUseCase: The use case for getting menu bar apps
    ///   - getWidgetSpacingUseCase: The use case for getting widget spacing
    init(
        getShowGroupsUseCase: GetShowGroupsUseCase,
        setShowGroupsUseCase: SetShowGroupsUseCase,
        getGroupsConfigurationUseCase: GetGroupsConfigurationUseCase,
        setGroupsConfigurationUseCase: SetGroupsConfigurationUseCase,
        getMenuBarAppsUseCase: GetMenuBarAppsUseCase,
        getFeatureFlagsUseCase: GetFeatureFlagsUseCase,
        getAnimationDurationUseCase: GetAnimationDurationUseCase,
        getWidgetSpacingUseCase: GetWidgetSpacingUseCase
    ) {
        self.getShowGroupsUseCase = getShowGroupsUseCase
        self.setShowGroupsUseCase = setShowGroupsUseCase
        self.getGroupsConfigurationUseCase = getGroupsConfigurationUseCase
        self.setGroupsConfigurationUseCase = setGroupsConfigurationUseCase
        self.getMenuBarAppsUseCase = getMenuBarAppsUseCase
        self.getFeatureFlagsUseCase = getFeatureFlagsUseCase
        self.getAnimationDurationUseCase = getAnimationDurationUseCase
        self.getWidgetSpacingUseCase = getWidgetSpacingUseCase

        // Initialize with current values
        showGroups = getShowGroupsUseCase.execute().blockingFirst()
        groupsConfiguration = getGroupsConfigurationUseCase.execute().blockingFirst()
        menuBarApps = getMenuBarAppsUseCase.execute().blockingFirst()
        isGroupsFeatureEnabled = getFeatureFlagsUseCase.execute().blockingFirst().enableGroups
        animationDuration = getAnimationDurationUseCase.execute().blockingFirst()
        widgetSpacing = CGFloat(getWidgetSpacingUseCase.execute().blockingFirst())

        // Setup reactive subscriptions
        setupReactiveSubscriptions()
    }

    // MARK: - Public Methods

    /// Adds a new group by splitting existing groups to make room.
    /// Group 1 always gives up its last app, other groups shift left, new group takes the max position.
    /// - Returns: True if a group was added, false if no space is available
    @discardableResult
    func addNewGroup() -> Bool {
        let totalApps = menuBarApps.count
        guard totalApps > 0, groupsConfiguration.count < totalApps else { return false }

        // If no groups exist, create the first group covering all apps
        if groupsConfiguration.isEmpty {
            var newGroup = GroupConfiguration.defaultInstance
            newGroup.id = 0
            newGroup.startIndex = 1
            newGroup.endIndex = totalApps
            groupsConfiguration.append(newGroup)
            return true
        }

        // Ensure Group 1 has at least 2 apps to give up one
        let firstGroup = groupsConfiguration[0]
        let firstGroupEndIndex = firstGroup.getEndIndex(menuBarAppsCount: totalApps)
        guard firstGroupEndIndex > firstGroup.startIndex else { return false }

        // Create a new configuration array
        var newGroups: [GroupConfiguration] = []

        // Step 1: Update Group 1 - reduce its end index by 1
        var updatedFirstGroup = firstGroup
        updatedFirstGroup.endIndex = firstGroupEndIndex - 1
        newGroups.append(updatedFirstGroup)

        // Step 2: Shift all other existing groups left by 1 position
        for groupIndex in 1 ..< groupsConfiguration.count {
            var existingGroup = groupsConfiguration[groupIndex]

            existingGroup.startIndex -= 1
            if existingGroup.endIndex != -1 {
                existingGroup.endIndex -= 1
            }

            newGroups.append(existingGroup)
        }

        // Step 3: Add the new group at the max position
        var newGroup = GroupConfiguration.defaultInstance
        newGroup.id = groupsConfiguration.count
        newGroup.startIndex = totalApps
        newGroup.endIndex = totalApps
        newGroups.append(newGroup)

        // Replace the entire configuration
        groupsConfiguration = newGroups
        return true
    }

    /// Removes a group at the specified id.
    /// - Parameter index: The id of the group to remove
    func removeGroup(at id: Int) {
        groupsConfiguration.removeAll { group in
            group.id == id
        }
    }

    /// Resets the group configuration to default values from ConfigurationDefaults.
    func resetGroupsToDefaults() {
        Task { @MainActor in
            // Update local state first to ensure immediate UI update
            groupsConfiguration = ConfigurationDefaults.groupsConfiguration
            // Then persist the change
            await setGroupsConfigurationUseCase.execute(ConfigurationDefaults.groupsConfiguration)
        }
    }

    /// Determines if more groups can be added.
    /// - Returns: True if more groups can be added, false otherwise
    func canAddMoreGroups() -> Bool {
        groupsConfiguration.count < menuBarApps.count && !menuBarApps.isEmpty
    }

    // MARK: - Private Helper Methods

    /// Updates group configurations when the menu bar apps count changes.
    /// - Parameters:
    ///   - oldCount: The previous number of menu bar apps
    ///   - newCount: The new number of menu bar apps
    private func updateGroupConfigurationsForMenuBarAppsChange(oldCount: Int, newCount: Int) {
        guard !groupsConfiguration.isEmpty else { return }

        var updatedGroups = groupsConfiguration

        for groupIndex in 0 ..< updatedGroups.count {
            let group = updatedGroups[groupIndex]

            // Update groups that had endIndex equal to the old count
            if group.endIndex == oldCount {
                updatedGroups[groupIndex].endIndex = newCount
            }
            // If the group's end index is greater than the new count, cap it
            else if group.endIndex > newCount {
                updatedGroups[groupIndex].endIndex = newCount
            }
        }

        // Remove groups that are now invalid (startIndex > newCount)
        updatedGroups.removeAll { group in
            group.startIndex > newCount
        }

        groupsConfiguration = updatedGroups
    }

    // MARK: - Private Methods

    /// Setup reactive subscriptions to configuration and menu bar apps.
    private func setupReactiveSubscriptions() {
        // Subscribe to configuration changes
        getShowGroupsUseCase.execute()
            .receive(on: DispatchQueue.main)
            .assign(to: \.showGroups, on: self)
            .store(in: &cancellables)

        getGroupsConfigurationUseCase.execute()
            .receive(on: DispatchQueue.main)
            .assign(to: \.groupsConfiguration, on: self)
            .store(in: &cancellables)

        // Subscribe to menu bar apps changes
        getMenuBarAppsUseCase.execute()
            .receive(on: DispatchQueue.main)
            .assign(to: \.menuBarApps, on: self)
            .store(in: &cancellables)

        // Subscribe to feature flags changes
        getFeatureFlagsUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] featureFlags in
                if self?.isGroupsFeatureEnabled != featureFlags.enableGroups {
                    self?.isGroupsFeatureEnabled = featureFlags.enableGroups
                }
            }
            .store(in: &cancellables)

        // Subscribe to animation duration changes
        getAnimationDurationUseCase.execute()
            .receive(on: DispatchQueue.main)
            .assign(to: \.animationDuration, on: self)
            .store(in: &cancellables)

        // Subscribe to widget spacing changes
        getWidgetSpacingUseCase.execute()
            .receive(on: DispatchQueue.main)
            .map { CGFloat($0) }
            .assign(to: \.widgetSpacing, on: self)
            .store(in: &cancellables)

        // Handle menu bar apps changes and update group configurations accordingly
        getMenuBarAppsUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newMenuBarApps in
                guard let self else { return }

                let oldCount = menuBarApps.count
                let newCount = newMenuBarApps.count

                menuBarApps = newMenuBarApps

                // Update group configurations when menu bar apps count changes
                if oldCount != newCount {
                    updateGroupConfigurationsForMenuBarAppsChange(
                        oldCount: oldCount,
                        newCount: newCount
                    )
                }
            }
            .store(in: &cancellables)
    }
}
