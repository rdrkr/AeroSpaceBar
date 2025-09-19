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
                await setShowGroupsUseCase.execute(value: showGroups)
            }
        }
    }

    /// The current group configuration.
    @Published var groups: [Domain.Group] {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setGroupsUseCase.execute(value: groups)
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

    /// The vertical padding for menu bar UI layout.
    @Published var menuBarVerticalPadding: Double

    /// The size of window icons in the interface.
    @Published var windowIconSize: Double

    /// The current groups appearance mode.
    @Published var groupsAppearanceMode: GroupsAppearanceMode {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setGroupsAppearanceModeUseCase.execute(mode: groupsAppearanceMode)
            }
        }
    }

    /// Consolidated global groups visual configuration.
    @Published var globalGroupsVisualConfig: VisualContainer

    /// Consolidated global space visual configuration.
    @Published var globalSpacesVisualConfig: VisualContainer

    // MARK: - Computed Properties for UI Compatibility

    /// The global background tint color for all groups.
    var groupsGlobalBackgroundTintColor: Color {
        globalGroupsVisualConfig.backgroundTintColor
    }

    /// The global background opacity for all groups.
    var groupsGlobalBackgroundOpacity: Double {
        globalGroupsVisualConfig.backgroundOpacity
    }

    /// The global background blur radius for all groups.
    var groupsGlobalBackgroundBlurRadius: Double {
        globalGroupsVisualConfig.backgroundBlurRadius
    }

    /// The global border color for all groups.
    var groupsGlobalBorderColor: Color {
        globalGroupsVisualConfig.borderTintColor
    }

    /// The global border opacity for all groups.
    var groupsGlobalBorderOpacity: Double {
        globalGroupsVisualConfig.borderOpacity
    }

    /// The global border width for all groups.
    var groupsGlobalBorderWidth: Double {
        globalGroupsVisualConfig.borderWidth
    }

    /// The global corner radius for all groups.
    var groupsGlobalCornerRadius: Double {
        globalGroupsVisualConfig.cornerRadius
    }

    /// The background opacity level of the space elements.
    var spaceBackgroundOpacity: Double {
        globalSpacesVisualConfig.backgroundOpacity
    }

    /// The background blur radius for space elements in points.
    var spaceBackgroundBlurRadius: Double {
        globalSpacesVisualConfig.backgroundBlurRadius
    }

    /// The background tint color for space elements.
    var spaceBackgroundTintColor: Color {
        globalSpacesVisualConfig.backgroundTintColor
    }

    /// The border tint color for space elements.
    var spaceBorderTintColor: Color {
        globalSpacesVisualConfig.borderTintColor
    }

    /// The border opacity level of the space elements.
    var spaceBorderOpacity: Double {
        globalSpacesVisualConfig.borderOpacity
    }

    /// The border width of the space elements in points.
    var spaceBorderWidth: Double {
        globalSpacesVisualConfig.borderWidth
    }

    /// The corner radius for spaces in points.
    var spaceCornerRadius: Double {
        globalSpacesVisualConfig.cornerRadius
    }

    // MARK: - Dependencies

    private let getShowGroupsUseCase: GetShowGroupsUseCase
    private let setShowGroupsUseCase: SetShowGroupsUseCase
    private let getGroupsUseCase: GetGroupsUseCase
    private let setGroupsUseCase: SetGroupsUseCase
    private let getMenuBarAppsUseCase: GetMenuBarAppsUseCase
    private let getFeatureFlagsUseCase: GetFeatureFlagsUseCase
    private let getAnimationDurationUseCase: GetAnimationDurationUseCase
    private let getWidgetSpacingUseCase: GetWidgetSpacingUseCase
    private let getMenuBarVerticalPaddingUseCase: GetMenuBarVerticalPaddingUseCase
    private let getWindowIconSizeUseCase: GetWindowIconSizeUseCase
    private let getGroupsAppearanceModeUseCase: GetGroupsAppearanceModeUseCase
    private let setGroupsAppearanceModeUseCase: SetGroupsAppearanceModeUseCase
    private let getGlobalGroupsVisualConfigUseCase: GetGlobalGroupsVisualConfigUseCase
    private let getGlobalSpacesVisualConfigUseCase: GetGlobalSpacesVisualConfigUseCase

    /// Cancellable subscriptions for Combine publishers.
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initialization

    /// Initializes the groups view model with dependencies.
    /// - Parameters:
    ///   - getShowGroupsUseCase: The use case for getting show groups setting
    ///   - setShowGroupsUseCase: The use case for setting show groups setting
    ///   - getGroupsUseCase: The use case for getting group configuration
    ///   - setGroupsUseCase: The use case for setting group configuration
    ///   - getMenuBarAppsUseCase: The use case for getting menu bar apps
    ///   - getFeatureFlagsUseCase: The use case for getting feature flags
    ///   - getAnimationDurationUseCase: The use case for getting animation duration
    ///   - getWidgetSpacingUseCase: The use case for getting widget spacing
    ///   - getMenuBarVerticalPaddingUseCase: The use case for getting menu bar vertical padding
    ///   - getWindowIconSizeUseCase: The use case for getting window icon size
    ///   - getGroupsAppearanceModeUseCase: The use case for getting groups appearance mode
    ///   - setGroupsAppearanceModeUseCase: The use case for setting groups appearance mode
    ///   - getGlobalGroupsVisualConfigUseCase: The use case for getting global groups visual configuration
    ///   - getGlobalSpacesVisualConfigUseCase: The use case for getting global space visual configuration
    init(
        getShowGroupsUseCase: GetShowGroupsUseCase,
        setShowGroupsUseCase: SetShowGroupsUseCase,
        getGroupsUseCase: GetGroupsUseCase,
        setGroupsUseCase: SetGroupsUseCase,
        getMenuBarAppsUseCase: GetMenuBarAppsUseCase,
        getFeatureFlagsUseCase: GetFeatureFlagsUseCase,
        getAnimationDurationUseCase: GetAnimationDurationUseCase,
        getWidgetSpacingUseCase: GetWidgetSpacingUseCase,
        getMenuBarVerticalPaddingUseCase: GetMenuBarVerticalPaddingUseCase,
        getWindowIconSizeUseCase: GetWindowIconSizeUseCase,
        getGroupsAppearanceModeUseCase: GetGroupsAppearanceModeUseCase,
        setGroupsAppearanceModeUseCase: SetGroupsAppearanceModeUseCase,
        getGlobalGroupsVisualConfigUseCase: GetGlobalGroupsVisualConfigUseCase,
        getGlobalSpacesVisualConfigUseCase: GetGlobalSpacesVisualConfigUseCase
    ) {
        self.getShowGroupsUseCase = getShowGroupsUseCase
        self.setShowGroupsUseCase = setShowGroupsUseCase
        self.getGroupsUseCase = getGroupsUseCase
        self.setGroupsUseCase = setGroupsUseCase
        self.getMenuBarAppsUseCase = getMenuBarAppsUseCase
        self.getFeatureFlagsUseCase = getFeatureFlagsUseCase
        self.getAnimationDurationUseCase = getAnimationDurationUseCase
        self.getWidgetSpacingUseCase = getWidgetSpacingUseCase
        self.getMenuBarVerticalPaddingUseCase = getMenuBarVerticalPaddingUseCase
        self.getWindowIconSizeUseCase = getWindowIconSizeUseCase
        self.getGroupsAppearanceModeUseCase = getGroupsAppearanceModeUseCase
        self.setGroupsAppearanceModeUseCase = setGroupsAppearanceModeUseCase
        self.getGlobalGroupsVisualConfigUseCase = getGlobalGroupsVisualConfigUseCase
        self.getGlobalSpacesVisualConfigUseCase = getGlobalSpacesVisualConfigUseCase

        // Initialize with current values
        showGroups = getShowGroupsUseCase.execute().blockingFirst()
        groups = getGroupsUseCase.execute().blockingFirst()
        menuBarApps = getMenuBarAppsUseCase.execute().blockingFirst()
        isGroupsFeatureEnabled = getFeatureFlagsUseCase.execute().blockingFirst().enableGroups
        animationDuration = getAnimationDurationUseCase.execute().blockingFirst()
        widgetSpacing = getWidgetSpacingUseCase.execute().blockingFirst()
        menuBarVerticalPadding = getMenuBarVerticalPaddingUseCase.execute().blockingFirst()
        windowIconSize = getWindowIconSizeUseCase.execute().blockingFirst()
        groupsAppearanceMode = getGroupsAppearanceModeUseCase.execute().blockingFirst()
        globalGroupsVisualConfig = getGlobalGroupsVisualConfigUseCase.execute().blockingFirst()
        globalSpacesVisualConfig = getGlobalSpacesVisualConfigUseCase.execute().blockingFirst()

        // Setup reactive subscriptions
        setupReactiveSubscriptions()
    }

    // MARK: - Public Methods

    /// Finds ranges of apps that are not assigned to any group.
    /// - Parameter totalApps: The total number of menu bar apps
    /// - Returns: Array of ranges representing unassigned app positions
    private func findUnassignedAppRanges(totalApps: Int) -> [Range<Int>] {
        guard totalApps > 0, !groups.isEmpty else { return [] }

        // Create a boolean array to track which apps are assigned (1-based indexing)
        var assigned = Array(repeating: false, count: totalApps + 1)

        // Mark assigned apps for each group
        for group in groups {
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
        groups.sort { $0.startIndex < $1.startIndex }
        for index in 0 ..< groups.count {
            groups[index].id = index
        }
    }

    /// Adds a new group by splitting existing groups to make room.
    /// Group 1 always gives up its last app, other groups shift left, new group takes the max position.
    /// - Returns: True if a group was added, false if no space is available
    @discardableResult
    func addNewGroup() -> Bool {
        let totalApps = menuBarApps.count
        guard totalApps > 0, groups.count < totalApps else { return false }

        // Find first unassigned app
        let unassignedRanges = findUnassignedAppRanges(totalApps: totalApps)

        if let firstUnassignedRange = unassignedRanges.first {
            // Priority 1: Fill gaps with unassigned apps
            let targetAppIndex = firstUnassignedRange.lowerBound

            // Create new group
            var newGroup = Group.defaultInstance
            newGroup.startIndex = targetAppIndex
            newGroup.endIndex = targetAppIndex

            // Add to array and normalize
            groups.append(newGroup)
            normalizeGroupsConfiguration()

            return true
        } else {
            // Priority 2: Fallback - take app from first group (original behavior)
            guard !groups.isEmpty else { return false }

            // Sort to ensure we get the rightmost group (lowest startIndex)
            normalizeGroupsConfiguration()
            let rightmostGroup = groups[0]
            let rightmostGroupEndIndex = rightmostGroup.getEndIndex(menuBarAppsCount: totalApps)
            guard rightmostGroupEndIndex > rightmostGroup.startIndex else { return false }

            // Reduce rightmost group by 1 app
            groups[0].endIndex = rightmostGroupEndIndex - 1

            // Create new group with the taken app
            var newGroup = Group.defaultInstance
            newGroup.startIndex = rightmostGroupEndIndex
            newGroup.endIndex = rightmostGroupEndIndex

            // Add to array and normalize
            groups.append(newGroup)
            normalizeGroupsConfiguration()

            return true
        }
    }

    /// Removes a group at the specified id.
    /// - Parameter index: The id of the group to remove
    func removeGroup(at id: Int) {
        groups.removeAll { group in
            group.id == id
        }

        // Normalize after removal
        normalizeGroupsConfiguration()
    }

    /// Resets the group configuration to default values from ConfigurationDefaults.
    func resetGroupsToDefaults() {
        Task { @MainActor in
            // Update local state first to ensure immediate UI update
            groups = ConfigurationDefaults.groups
            // Then persist the change
            await setGroupsUseCase.execute(value: ConfigurationDefaults.groups)
        }
    }

    /// Determines if more groups can be added.
    /// - Returns: True if more groups can be added, false otherwise
    func canAddMoreGroups() -> Bool {
        let totalApps = menuBarApps.count
        guard totalApps > 0, groups.count < totalApps else { return false }

        // Check if there are unassigned apps (Priority 1)
        let unassignedRanges = findUnassignedAppRanges(totalApps: totalApps)
        if !unassignedRanges.isEmpty {
            return true
        }

        // Check if we can take from rightmost group (Priority 2)
        guard !groups.isEmpty else { return false }

        let sortedGroups = groups.sorted { $0.startIndex < $1.startIndex }
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
        guard previousGroupId < groups.count else { return 1 }

        let previousGroup = groups[previousGroupId]
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
        guard nextGroupId < groups.count else {
            // No next group exists, so this group can extend to all apps
            return menuBarApps.count
        }

        let nextGroup = groups[nextGroupId]

        // This group must end at least one position before the next group starts
        return nextGroup.startIndex - 1
    }

    // MARK: - Private Helper Methods

    /// Updates group configurations when the menu bar apps count changes.
    /// - Parameters:
    ///   - oldCount: The previous number of menu bar apps
    ///   - newCount: The new number of menu bar apps
    private func updateGroupConfigurationsForMenuBarAppsChange(oldCount: Int, newCount: Int) {
        guard !groups.isEmpty else { return }

        var updatedGroups = groups

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

        groups = updatedGroups
    }

    // MARK: - Private Methods

    /// Setup reactive subscriptions to configuration and menu bar apps.
    private func setupReactiveSubscriptions() {
        setupBasicSubscriptions()
        setupGroupsAppearanceSubscriptions()
        setupMenuBarAppsSubscriptions()
    }

    /// Setup subscriptions for basic configuration changes
    private func setupBasicSubscriptions() {
        // Subscribe to configuration changes
        getShowGroupsUseCase.execute()
            .receive(on: DispatchQueue.main)
            .assign(to: \.showGroups, on: self)
            .store(in: &cancellables)

        getGroupsUseCase.execute()
            .receive(on: DispatchQueue.main)
            .assign(to: \.groups, on: self)
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

        // Subscribe to menu bar vertical padding changes
        getMenuBarVerticalPaddingUseCase.execute()
            .receive(on: DispatchQueue.main)
            .map { Double($0) }
            .assign(to: \.menuBarVerticalPadding, on: self)
            .store(in: &cancellables)

        // Subscribe to window icon size changes
        getWindowIconSizeUseCase.execute()
            .receive(on: DispatchQueue.main)
            .map { Double($0) }
            .assign(to: \.windowIconSize, on: self)
            .store(in: &cancellables)

        // Subscribe to groups appearance mode changes
        getGroupsAppearanceModeUseCase.execute()
            .receive(on: DispatchQueue.main)
            .assign(to: \.groupsAppearanceMode, on: self)
            .store(in: &cancellables)
    }

    /// Setup subscriptions for groups global appearance configuration changes
    private func setupGroupsAppearanceSubscriptions() {
        getGlobalGroupsVisualConfigUseCase.execute()
            .receive(on: DispatchQueue.main)
            .assign(to: \.globalGroupsVisualConfig, on: self)
            .store(in: &cancellables)

        getGlobalSpacesVisualConfigUseCase.execute()
            .receive(on: DispatchQueue.main)
            .assign(to: \.globalSpacesVisualConfig, on: self)
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
