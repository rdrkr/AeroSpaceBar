// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
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
    @Published var widgetSpacing: Double

    /// The current groups appearance mode.
    @Published var groupsAppearanceMode: GroupsAppearanceMode {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setGroupsAppearanceModeUseCase.execute(groupsAppearanceMode)
            }
        }
    }

    /// The global background tint color for all groups.
    @Published var groupsGlobalBackgroundTintColor: Color

    /// The global background opacity for all groups.
    @Published var groupsGlobalBackgroundOpacity: Double

    /// The global background blur radius for all groups.
    @Published var groupsGlobalBackgroundBlurRadius: Double

    /// The global border color for all groups.
    @Published var groupsGlobalBorderColor: Color

    /// The global border opacity for all groups.
    @Published var groupsGlobalBorderOpacity: Double

    /// The global border width for all groups.
    @Published var groupsGlobalBorderWidth: Double

    /// The global corner radius for all groups.
    @Published var groupsGlobalCornerRadius: Double

    /// The background opacity level of the space elements (0.1 to 1.0).
    @Published var spaceBackgroundOpacity: Double

    /// The background blur radius for space elements in points.
    @Published var spaceBackgroundBlurRadius: Double

    /// The background tint color for space elements.
    @Published var spaceBackgroundTintColor: Color

    /// The border tint color for space elements.
    @Published var spaceBorderTintColor: Color

    /// The border opacity level of the space elements (0.0 to 1.0).
    @Published var spaceBorderOpacity: Double

    /// The border width of the space elements in points.
    @Published var spaceBorderWidth: Double

    /// The corner radius for spaces in points.
    @Published var spaceCornerRadius: Double

    // MARK: - Dependencies

    private let getShowGroupsUseCase: GetShowGroupsUseCase
    private let setShowGroupsUseCase: SetShowGroupsUseCase
    private let getGroupsConfigurationUseCase: GetGroupsConfigurationUseCase
    private let setGroupsConfigurationUseCase: SetGroupsConfigurationUseCase
    private let getMenuBarAppsUseCase: GetMenuBarAppsUseCase
    private let getFeatureFlagsUseCase: GetFeatureFlagsUseCase
    private let getAnimationDurationUseCase: GetAnimationDurationUseCase
    private let getWidgetSpacingUseCase: GetWidgetSpacingUseCase
    private let getGroupsAppearanceModeUseCase: GetGroupsAppearanceModeUseCase
    private let setGroupsAppearanceModeUseCase: SetGroupsAppearanceModeUseCase
    private let getGroupsGlobalBackgroundTintColorUseCase: GetGroupsGlobalBgTintColorUseCase
    private let getGroupsGlobalBackgroundOpacityUseCase: GetGroupsGlobalBackgroundOpacityUseCase
    private let getGroupsGlobalBackgroundBlurRadiusUseCase: GetGroupsGlobalBgBlurRadiusUseCase
    private let getGroupsGlobalBorderColorUseCase: GetGroupsGlobalBorderColorUseCase
    private let getGroupsGlobalBorderOpacityUseCase: GetGroupsGlobalBorderOpacityUseCase
    private let getGroupsGlobalBorderWidthUseCase: GetGroupsGlobalBorderWidthUseCase
    private let getGroupsGlobalCornerRadiusUseCase: GetGroupsGlobalCornerRadiusUseCase
    private let getSpaceBackgroundOpacityUseCase: GetSpaceBackgroundOpacityUseCase
    private let getSpaceBackgroundBlurRadiusUseCase: GetSpaceBackgroundBlurRadiusUseCase
    private let getSpaceBackgroundTintColorUseCase: GetSpaceBackgroundTintColorUseCase
    private let getSpaceBorderTintColorUseCase: GetSpaceBorderTintColorUseCase
    private let getSpaceBorderOpacityUseCase: GetSpaceBorderOpacityUseCase
    private let getSpaceBorderWidthUseCase: GetSpaceBorderWidthUseCase
    private let getSpaceCornerRadiusUseCase: GetSpaceCornerRadiusUseCase

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
    ///   - getFeatureFlagsUseCase: The use case for getting feature flags
    ///   - getAnimationDurationUseCase: The use case for getting animation duration
    ///   - getWidgetSpacingUseCase: The use case for getting widget spacing
    ///   - getGroupsAppearanceModeUseCase: The use case for getting groups appearance mode
    ///   - setGroupsAppearanceModeUseCase: The use case for setting groups appearance mode
    ///   - getGroupsGlobalBackgroundTintColorUseCase: The use case for getting global background tint color
    ///   - setGroupsGlobalBackgroundTintColorUseCase: The use case for setting global background tint color
    ///   - getGroupsGlobalBackgroundOpacityUseCase: The use case for getting global background opacity
    ///   - setGroupsGlobalBackgroundOpacityUseCase: The use case for setting global background opacity
    ///   - getGroupsGlobalBackgroundBlurRadiusUseCase: The use case for getting global background blur radius
    ///   - setGroupsGlobalBackgroundBlurRadiusUseCase: The use case for setting global background blur radius
    ///   - getGroupsGlobalBorderColorUseCase: The use case for getting global border color
    ///   - setGroupsGlobalBorderColorUseCase: The use case for setting global border color
    ///   - getGroupsGlobalBorderOpacityUseCase: The use case for getting global border opacity
    ///   - setGroupsGlobalBorderOpacityUseCase: The use case for setting global border opacity
    ///   - getGroupsGlobalBorderWidthUseCase: The use case for getting global border width
    ///   - setGroupsGlobalBorderWidthUseCase: The use case for setting global border width
    ///   - getGroupsGlobalCornerRadiusUseCase: The use case for getting global corner radius
    ///   - setGroupsGlobalCornerRadiusUseCase: The use case for setting global corner radius
    init(
        getShowGroupsUseCase: GetShowGroupsUseCase,
        setShowGroupsUseCase: SetShowGroupsUseCase,
        getGroupsConfigurationUseCase: GetGroupsConfigurationUseCase,
        setGroupsConfigurationUseCase: SetGroupsConfigurationUseCase,
        getMenuBarAppsUseCase: GetMenuBarAppsUseCase,
        getFeatureFlagsUseCase: GetFeatureFlagsUseCase,
        getAnimationDurationUseCase: GetAnimationDurationUseCase,
        getWidgetSpacingUseCase: GetWidgetSpacingUseCase,
        getGroupsAppearanceModeUseCase: GetGroupsAppearanceModeUseCase,
        setGroupsAppearanceModeUseCase: SetGroupsAppearanceModeUseCase,
        getGroupsGlobalBackgroundTintColorUseCase: GetGroupsGlobalBgTintColorUseCase,
        getGroupsGlobalBackgroundOpacityUseCase: GetGroupsGlobalBackgroundOpacityUseCase,
        getGroupsGlobalBackgroundBlurRadiusUseCase: GetGroupsGlobalBgBlurRadiusUseCase,
        getGroupsGlobalBorderColorUseCase: GetGroupsGlobalBorderColorUseCase,
        getGroupsGlobalBorderOpacityUseCase: GetGroupsGlobalBorderOpacityUseCase,
        getGroupsGlobalBorderWidthUseCase: GetGroupsGlobalBorderWidthUseCase,
        getGroupsGlobalCornerRadiusUseCase: GetGroupsGlobalCornerRadiusUseCase,
        getSpaceBackgroundOpacityUseCase: GetSpaceBackgroundOpacityUseCase,
        getSpaceBackgroundBlurRadiusUseCase: GetSpaceBackgroundBlurRadiusUseCase,
        getSpaceBackgroundTintColorUseCase: GetSpaceBackgroundTintColorUseCase,
        getSpaceBorderTintColorUseCase: GetSpaceBorderTintColorUseCase,
        getSpaceBorderOpacityUseCase: GetSpaceBorderOpacityUseCase,
        getSpaceBorderWidthUseCase: GetSpaceBorderWidthUseCase,
        getSpaceCornerRadiusUseCase: GetSpaceCornerRadiusUseCase
    ) {
        self.getShowGroupsUseCase = getShowGroupsUseCase
        self.setShowGroupsUseCase = setShowGroupsUseCase
        self.getGroupsConfigurationUseCase = getGroupsConfigurationUseCase
        self.setGroupsConfigurationUseCase = setGroupsConfigurationUseCase
        self.getMenuBarAppsUseCase = getMenuBarAppsUseCase
        self.getFeatureFlagsUseCase = getFeatureFlagsUseCase
        self.getAnimationDurationUseCase = getAnimationDurationUseCase
        self.getWidgetSpacingUseCase = getWidgetSpacingUseCase
        self.getGroupsAppearanceModeUseCase = getGroupsAppearanceModeUseCase
        self.setGroupsAppearanceModeUseCase = setGroupsAppearanceModeUseCase
        self.getGroupsGlobalBackgroundTintColorUseCase = getGroupsGlobalBackgroundTintColorUseCase
        self.getGroupsGlobalBackgroundOpacityUseCase = getGroupsGlobalBackgroundOpacityUseCase
        self.getGroupsGlobalBackgroundBlurRadiusUseCase = getGroupsGlobalBackgroundBlurRadiusUseCase
        self.getGroupsGlobalBorderColorUseCase = getGroupsGlobalBorderColorUseCase
        self.getGroupsGlobalBorderOpacityUseCase = getGroupsGlobalBorderOpacityUseCase
        self.getGroupsGlobalBorderWidthUseCase = getGroupsGlobalBorderWidthUseCase
        self.getGroupsGlobalCornerRadiusUseCase = getGroupsGlobalCornerRadiusUseCase
        self.getSpaceBackgroundOpacityUseCase = getSpaceBackgroundOpacityUseCase
        self.getSpaceBackgroundBlurRadiusUseCase = getSpaceBackgroundBlurRadiusUseCase
        self.getSpaceBackgroundTintColorUseCase = getSpaceBackgroundTintColorUseCase
        self.getSpaceBorderTintColorUseCase = getSpaceBorderTintColorUseCase
        self.getSpaceBorderOpacityUseCase = getSpaceBorderOpacityUseCase
        self.getSpaceBorderWidthUseCase = getSpaceBorderWidthUseCase
        self.getSpaceCornerRadiusUseCase = getSpaceCornerRadiusUseCase

        // Initialize with current values
        showGroups = getShowGroupsUseCase.execute().blockingFirst()
        groupsConfiguration = getGroupsConfigurationUseCase.execute().blockingFirst()
        menuBarApps = getMenuBarAppsUseCase.execute().blockingFirst()
        isGroupsFeatureEnabled = getFeatureFlagsUseCase.execute().blockingFirst().enableGroups
        animationDuration = getAnimationDurationUseCase.execute().blockingFirst()
        widgetSpacing = Double(getWidgetSpacingUseCase.execute().blockingFirst())
        groupsAppearanceMode = getGroupsAppearanceModeUseCase.execute().blockingFirst()
        groupsGlobalBackgroundTintColor = getGroupsGlobalBackgroundTintColorUseCase.execute().blockingFirst()
        groupsGlobalBackgroundOpacity = getGroupsGlobalBackgroundOpacityUseCase.execute().blockingFirst()
        groupsGlobalBackgroundBlurRadius = getGroupsGlobalBackgroundBlurRadiusUseCase.execute().blockingFirst()
        groupsGlobalBorderColor = getGroupsGlobalBorderColorUseCase.execute().blockingFirst()
        groupsGlobalBorderOpacity = getGroupsGlobalBorderOpacityUseCase.execute().blockingFirst()
        groupsGlobalBorderWidth = getGroupsGlobalBorderWidthUseCase.execute().blockingFirst()
        groupsGlobalCornerRadius = getGroupsGlobalCornerRadiusUseCase.execute().blockingFirst()
        spaceBackgroundOpacity = getSpaceBackgroundOpacityUseCase.execute().blockingFirst()
        spaceBackgroundBlurRadius = getSpaceBackgroundBlurRadiusUseCase.execute().blockingFirst()
        spaceBackgroundTintColor = getSpaceBackgroundTintColorUseCase.execute().blockingFirst()
        spaceBorderTintColor = getSpaceBorderTintColorUseCase.execute().blockingFirst()
        spaceBorderOpacity = getSpaceBorderOpacityUseCase.execute().blockingFirst()
        spaceBorderWidth = getSpaceBorderWidthUseCase.execute().blockingFirst()
        spaceCornerRadius = getSpaceCornerRadiusUseCase.execute().blockingFirst()

        // Setup reactive subscriptions
        setupReactiveSubscriptions()
    }

    // MARK: - Public Methods

    /// Finds ranges of apps that are not assigned to any group.
    /// - Parameter totalApps: The total number of menu bar apps
    /// - Returns: Array of ranges representing unassigned app positions
    private func findUnassignedAppRanges(totalApps: Int) -> [Range<Int>] {
        guard totalApps > 0, !groupsConfiguration.isEmpty else { return [] }

        // Create a boolean array to track which apps are assigned (1-based indexing)
        var assigned = Array(repeating: false, count: totalApps + 1)

        // Mark assigned apps for each group
        for group in groupsConfiguration {
            let startIdx = group.startIndex
            let endIdx = group.getEndIndex(menuBarAppsCount: totalApps)

            for appIndex in startIdx ... endIdx {
                if appIndex >= 1, appIndex <= totalApps {
                    assigned[appIndex] = true
                }
            }
        }

        // Find unassigned ranges
        var ranges: [Range<Int>] = []
        var rangeStart: Int?

        for appIndex in 1 ... totalApps {
            if !assigned[appIndex] {
                if rangeStart == nil {
                    rangeStart = appIndex
                }
            } else if let start = rangeStart {
                ranges.append(start ..< appIndex)
                rangeStart = nil
            }
        }

        // Handle case where unassigned range extends to the end
        if let start = rangeStart {
            ranges.append(start ..< (totalApps + 1))
        }

        return ranges
    }

    /// Ensures groups are sorted by startIndex and have correct sequential IDs
    private func normalizeGroupsConfiguration() {
        groupsConfiguration.sort { $0.startIndex < $1.startIndex }
        for index in 0 ..< groupsConfiguration.count {
            groupsConfiguration[index].id = index
        }
    }

    /// Adds a new group by splitting existing groups to make room.
    /// Group 1 always gives up its last app, other groups shift left, new group takes the max position.
    /// - Returns: True if a group was added, false if no space is available
    @discardableResult
    func addNewGroup() -> Bool {
        let totalApps = menuBarApps.count
        guard totalApps > 0, groupsConfiguration.count < totalApps else { return false }

        // Find first unassigned app
        let unassignedRanges = findUnassignedAppRanges(totalApps: totalApps)

        if let firstUnassignedRange = unassignedRanges.first {
            // Priority 1: Fill gaps with unassigned apps
            let targetAppIndex = firstUnassignedRange.lowerBound

            // Create new group
            var newGroup = GroupConfiguration.defaultInstance
            newGroup.startIndex = targetAppIndex
            newGroup.endIndex = targetAppIndex

            // Add to array and normalize
            groupsConfiguration.append(newGroup)
            normalizeGroupsConfiguration()

            return true
        } else {
            // Priority 2: Fallback - take app from first group (original behavior)
            guard !groupsConfiguration.isEmpty else { return false }

            // Sort to ensure we get the rightmost group (lowest startIndex)
            normalizeGroupsConfiguration()
            let rightmostGroup = groupsConfiguration[0]
            let rightmostGroupEndIndex = rightmostGroup.getEndIndex(menuBarAppsCount: totalApps)
            guard rightmostGroupEndIndex > rightmostGroup.startIndex else { return false }

            // Reduce rightmost group by 1 app
            groupsConfiguration[0].endIndex = rightmostGroupEndIndex - 1

            // Create new group with the taken app
            var newGroup = GroupConfiguration.defaultInstance
            newGroup.startIndex = rightmostGroupEndIndex
            newGroup.endIndex = rightmostGroupEndIndex

            // Add to array and normalize
            groupsConfiguration.append(newGroup)
            normalizeGroupsConfiguration()

            return true
        }
    }

    /// Removes a group at the specified id.
    /// - Parameter index: The id of the group to remove
    func removeGroup(at id: Int) {
        groupsConfiguration.removeAll { group in
            group.id == id
        }

        // Normalize after removal
        normalizeGroupsConfiguration()
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
        let totalApps = menuBarApps.count
        guard totalApps > 0, groupsConfiguration.count < totalApps else { return false }

        // Check if there are unassigned apps (Priority 1)
        let unassignedRanges = findUnassignedAppRanges(totalApps: totalApps)
        if !unassignedRanges.isEmpty {
            return true
        }

        // Check if we can take from rightmost group (Priority 2)
        guard !groupsConfiguration.isEmpty else { return false }

        let sortedGroups = groupsConfiguration.sorted { $0.startIndex < $1.startIndex }
        let rightmostGroup = sortedGroups[0]
        let rightmostGroupEndIndex = rightmostGroup.getEndIndex(menuBarAppsCount: totalApps)

        return rightmostGroupEndIndex > rightmostGroup.startIndex
    }

    /// Calculates the minimum start index for a group based on the previous group's end index.
    /// - Parameter groupId: The ID of the group to calculate the minimum start index for
    /// - Returns: The minimum allowed start index for the specified group
    func minimumStartIndex(for groupId: Int) -> Int {
        // For the first group (id = 0), minimum start index is always 1
        guard groupId > 0 else { return 1 }

        // Find the previous group's end index
        let previousGroupId = groupId - 1
        guard previousGroupId < groupsConfiguration.count else { return 1 }

        let previousGroup = groupsConfiguration[previousGroupId]
        let previousEndIndex = previousGroup.getEndIndex(menuBarAppsCount: menuBarApps.count)

        // This group must start at least one position after the previous group ends
        return previousEndIndex + 1
    }

    /// Calculates the maximum end index for a group based on the next group's start index.
    /// - Parameter groupId: The ID of the group to calculate the maximum end index for
    /// - Returns: The maximum allowed end index for the specified group
    func maximumEndIndex(for groupId: Int) -> Int {
        // Find the next group's start index
        let nextGroupId = groupId + 1
        guard nextGroupId < groupsConfiguration.count else {
            // No next group exists, so this group can extend to all apps
            return menuBarApps.count
        }

        let nextGroup = groupsConfiguration[nextGroupId]

        // This group must end at least one position before the next group starts
        return nextGroup.startIndex - 1
    }

    /// Creates a binding to a specific property of a group configuration.
    /// - Parameters:
    ///   - groupId: The ID of the group to create a binding for
    ///   - keyPath: The writable key path to the property
    /// - Returns: A binding to the property that automatically updates the configuration
    func binding<T>(for groupId: Int, keyPath: WritableKeyPath<GroupConfiguration, T>) -> Binding<T> {
        Binding(
            get: {
                guard groupId >= 0, groupId < self.groupsConfiguration.count else {
                    return GroupConfiguration.defaultInstance[keyPath: keyPath]
                }

                return self.groupsConfiguration[groupId][keyPath: keyPath]
            },
            set: { newValue in
                guard groupId >= 0, groupId < self.groupsConfiguration.count else { return }

                self.groupsConfiguration[groupId][keyPath: keyPath] = newValue
            }
        )
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
        setupBasicSubscriptions()
        setupGroupsAppearanceSubscriptions()
        setupSpaceAppearanceSubscriptions()
        setupMenuBarAppsSubscriptions()
    }

    /// Setup subscriptions for basic configuration changes
    private func setupBasicSubscriptions() {
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
            .map { Double($0) }
            .assign(to: \.widgetSpacing, on: self)
            .store(in: &cancellables)

        // Subscribe to groups appearance mode changes
        getGroupsAppearanceModeUseCase.execute()
            .receive(on: DispatchQueue.main)
            .assign(to: \.groupsAppearanceMode, on: self)
            .store(in: &cancellables)
    }

    /// Setup subscriptions for groups global appearance configuration changes
    private func setupGroupsAppearanceSubscriptions() {
        getGroupsGlobalBackgroundTintColorUseCase.execute()
            .receive(on: DispatchQueue.main)
            .assign(to: \.groupsGlobalBackgroundTintColor, on: self)
            .store(in: &cancellables)

        getGroupsGlobalBackgroundOpacityUseCase.execute()
            .receive(on: DispatchQueue.main)
            .assign(to: \.groupsGlobalBackgroundOpacity, on: self)
            .store(in: &cancellables)

        getGroupsGlobalBackgroundBlurRadiusUseCase.execute()
            .receive(on: DispatchQueue.main)
            .assign(to: \.groupsGlobalBackgroundBlurRadius, on: self)
            .store(in: &cancellables)

        getGroupsGlobalBorderColorUseCase.execute()
            .receive(on: DispatchQueue.main)
            .assign(to: \.groupsGlobalBorderColor, on: self)
            .store(in: &cancellables)

        getGroupsGlobalBorderOpacityUseCase.execute()
            .receive(on: DispatchQueue.main)
            .assign(to: \.groupsGlobalBorderOpacity, on: self)
            .store(in: &cancellables)

        getGroupsGlobalBorderWidthUseCase.execute()
            .receive(on: DispatchQueue.main)
            .assign(to: \.groupsGlobalBorderWidth, on: self)
            .store(in: &cancellables)

        getGroupsGlobalCornerRadiusUseCase.execute()
            .receive(on: DispatchQueue.main)
            .assign(to: \.groupsGlobalCornerRadius, on: self)
            .store(in: &cancellables)
    }

    /// Setup subscriptions for space appearance configuration changes
    private func setupSpaceAppearanceSubscriptions() {
        getSpaceBackgroundOpacityUseCase.execute()
            .receive(on: DispatchQueue.main)
            .assign(to: \.spaceBackgroundOpacity, on: self)
            .store(in: &cancellables)

        getSpaceBackgroundBlurRadiusUseCase.execute()
            .receive(on: DispatchQueue.main)
            .assign(to: \.spaceBackgroundBlurRadius, on: self)
            .store(in: &cancellables)

        getSpaceBackgroundTintColorUseCase.execute()
            .receive(on: DispatchQueue.main)
            .assign(to: \.spaceBackgroundTintColor, on: self)
            .store(in: &cancellables)

        getSpaceBorderTintColorUseCase.execute()
            .receive(on: DispatchQueue.main)
            .assign(to: \.spaceBorderTintColor, on: self)
            .store(in: &cancellables)

        getSpaceBorderOpacityUseCase.execute()
            .receive(on: DispatchQueue.main)
            .assign(to: \.spaceBorderOpacity, on: self)
            .store(in: &cancellables)

        getSpaceBorderWidthUseCase.execute()
            .receive(on: DispatchQueue.main)
            .assign(to: \.spaceBorderWidth, on: self)
            .store(in: &cancellables)

        getSpaceCornerRadiusUseCase.execute()
            .receive(on: DispatchQueue.main)
            .assign(to: \.spaceCornerRadius, on: self)
            .store(in: &cancellables)
    }

    /// Setup menu bar apps subscription with change handling
    private func setupMenuBarAppsSubscriptions() {
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
