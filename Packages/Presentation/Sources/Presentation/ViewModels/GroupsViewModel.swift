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
public final class GroupsViewModel: ObservableObject {
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

    /// The current groups appearance mode.
    @Published var groupsAppearanceMode: GroupsAppearanceMode {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setGroupsAppearanceModeUseCase.execute(mode: groupsAppearanceMode)
            }
        }
    }

    /// The current spaces appearance mode (used to restrict groups appearance mode).
    @Published var spacesAppearanceMode: SpacesAppearanceMode

    /// Returns the available groups appearance modes based on the current spaces appearance mode.
    /// When spaces are in per-space mode, match-spaces option is not available.
    @Published var availableGroupsAppearanceModes: [GroupsAppearanceMode]

    /// Consolidated global groups color properties.
    @Published var globalGroupsColorProperties: ColorProperties {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setGlobalGroupsColorPropertiesUseCase.execute(value: globalGroupsColorProperties)
            }
        }
    }

    /// Global geometric properties for groups.
    @Published var globalGroupsGeometricProperties: GeometricProperties {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setGlobalGroupsGeometricPropertiesUseCase.execute(value: globalGroupsGeometricProperties)
            }
        }
    }

    /// Global effect properties for groups.
    @Published var globalGroupsEffectProperties: EffectProperties {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setGlobalGroupsEffectPropertiesUseCase.execute(value: globalGroupsEffectProperties)
            }
        }
    }

    /// Consolidated global space color properties.
    @Published var globalSpacesColorProperties: ColorProperties

    /// Global geometric properties for spaces.
    @Published var globalSpacesGeometricProperties: GeometricProperties

    /// Global effect properties for spaces.
    @Published var globalSpacesEffectProperties: EffectProperties

    /// The current theme mode.
    @Published var themeMode: ThemeMode

    /// The current theme preset.
    @Published var themePresetColorProperties: ThemePresetColorProperties

    /// The current theme preset geometric properties.
    @Published var themePresetGeometricProperties: GeometricProperties

    /// The current theme preset effect properties.
    @Published var themePresetEffectProperties: EffectProperties

    /// The current menu bar height.
    @Published var menuBarHeight: Double

    // MARK: - Dependencies

    private let getShowGroupsUseCase: GetShowGroupsUseCase
    private let setShowGroupsUseCase: SetShowGroupsUseCase
    private let getGroupsUseCase: GetGroupsUseCase
    private let setGroupsUseCase: SetGroupsUseCase
    private let getMenuBarAppsUseCase: GetMenuBarAppsUseCase
    private let getFeatureFlagsUseCase: GetFeatureFlagsUseCase
    private let getGroupsAppearanceModeUseCase: GetGroupsAppearanceModeUseCase
    private let setGroupsAppearanceModeUseCase: SetGroupsAppearanceModeUseCase
    private let getSpacesAppearanceModeUseCase: GetSpacesAppearanceModeUseCase
    private let getGlobalGroupsColorPropertiesUseCase: GetGlobalGroupsColorPropertiesUseCase
    private let setGlobalGroupsColorPropertiesUseCase: SetGlobalGroupsColorPropertiesUseCase
    private let getGlobalGroupsGeometricPropertiesUseCase: GetGlobalGroupsGeometricPropertiesUseCase
    private let setGlobalGroupsGeometricPropertiesUseCase: SetGlobalGroupsGeometricPropertiesUseCase
    private let getGlobalGroupsEffectPropertiesUseCase: GetGlobalGroupsEffectPropertiesUseCase
    private let setGlobalGroupsEffectPropertiesUseCase: SetGlobalGroupsEffectPropertiesUseCase
    private let getGlobalSpacesColorPropertiesUseCase: GetGlobalSpacesColorPropertiesUseCase
    private let getGlobalSpacesGeometricPropertiesUseCase: GetGlobalSpacesGeometricPropertiesUseCase
    private let getGlobalSpacesEffectPropertiesUseCase: GetGlobalSpacesEffectPropertiesUseCase
    private let getThemeModeUseCase: GetThemeModeUseCase
    private let getThemePresetColorPropertiesUseCase: GetThemePresetColorPropertiesUseCase
    private let getThemePresetGeometricPropertiesUseCase: GetThemePresetGeometricPropertiesUseCase
    private let getThemePresetEffectPropertiesUseCase: GetThemePresetEffectPropertiesUseCase
    private let getMenuBarHeightUseCase: GetMenuBarHeightUseCase

    /// Cancellable subscriptions for Combine publishers.
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Private Constants

    /// All cases of GroupsAppearanceMode without matchSpaces.
    private static let restrictedGroupsAppearanceMode = GroupsAppearanceMode.allCases.filter {
        $0 != .matchSpaces
    }

    // MARK: - Initialization

    /// Initializes the groups view model with dependencies.
    /// - Parameters:
    ///   - getShowGroupsUseCase: The use case for getting show groups setting
    ///   - setShowGroupsUseCase: The use case for setting show groups setting
    ///   - getGroupsUseCase: The use case for getting group configuration
    ///   - setGroupsUseCase: The use case for setting group configuration
    ///   - getMenuBarAppsUseCase: The use case for getting menu bar apps
    ///   - getFeatureFlagsUseCase: The use case for getting feature flags
    ///   - getGroupsAppearanceModeUseCase: The use case for getting groups appearance mode
    ///   - setGroupsAppearanceModeUseCase: The use case for setting groups appearance mode
    ///   - getSpacesAppearanceModeUseCase: The use case for getting spaces appearance mode
    ///   - getGlobalGroupsColorPropertiesUseCase: The use case for getting global groups color properties
    ///   - getGlobalSpacesColorPropertiesUseCase: The use case for getting global space color properties
    ///   - getThemeModeUseCase: The use case for getting theme mode
    ///   - getThemePresetColorPropertiesUseCase: The use case for getting theme preset
    ///   - getThemePresetGeometricPropertiesUseCase: The use case for getting theme preset geometric properties
    ///   - getMenuBarHeightUseCase: Use case for getting menu bar height
    init(
        getShowGroupsUseCase: GetShowGroupsUseCase,
        setShowGroupsUseCase: SetShowGroupsUseCase,
        getGroupsUseCase: GetGroupsUseCase,
        setGroupsUseCase: SetGroupsUseCase,
        getMenuBarAppsUseCase: GetMenuBarAppsUseCase,
        getFeatureFlagsUseCase: GetFeatureFlagsUseCase,
        getGroupsAppearanceModeUseCase: GetGroupsAppearanceModeUseCase,
        setGroupsAppearanceModeUseCase: SetGroupsAppearanceModeUseCase,
        getSpacesAppearanceModeUseCase: GetSpacesAppearanceModeUseCase,
        getGlobalGroupsColorPropertiesUseCase: GetGlobalGroupsColorPropertiesUseCase,
        setGlobalGroupsColorPropertiesUseCase: SetGlobalGroupsColorPropertiesUseCase,
        getGlobalGroupsGeometricPropertiesUseCase: GetGlobalGroupsGeometricPropertiesUseCase,
        setGlobalGroupsGeometricPropertiesUseCase: SetGlobalGroupsGeometricPropertiesUseCase,
        getGlobalGroupsEffectPropertiesUseCase: GetGlobalGroupsEffectPropertiesUseCase,
        setGlobalGroupsEffectPropertiesUseCase: SetGlobalGroupsEffectPropertiesUseCase,
        getGlobalSpacesColorPropertiesUseCase: GetGlobalSpacesColorPropertiesUseCase,
        getGlobalSpacesGeometricPropertiesUseCase: GetGlobalSpacesGeometricPropertiesUseCase,
        getGlobalSpacesEffectPropertiesUseCase: GetGlobalSpacesEffectPropertiesUseCase,
        getThemeModeUseCase: GetThemeModeUseCase,
        getThemePresetColorPropertiesUseCase: GetThemePresetColorPropertiesUseCase,
        getThemePresetGeometricPropertiesUseCase: GetThemePresetGeometricPropertiesUseCase,
        getThemePresetEffectPropertiesUseCase: GetThemePresetEffectPropertiesUseCase,
        getMenuBarHeightUseCase: GetMenuBarHeightUseCase
    ) {
        self.getShowGroupsUseCase = getShowGroupsUseCase
        self.setShowGroupsUseCase = setShowGroupsUseCase
        self.getGroupsUseCase = getGroupsUseCase
        self.setGroupsUseCase = setGroupsUseCase
        self.getMenuBarAppsUseCase = getMenuBarAppsUseCase
        self.getFeatureFlagsUseCase = getFeatureFlagsUseCase
        self.getGroupsAppearanceModeUseCase = getGroupsAppearanceModeUseCase
        self.setGroupsAppearanceModeUseCase = setGroupsAppearanceModeUseCase
        self.getSpacesAppearanceModeUseCase = getSpacesAppearanceModeUseCase
        self.getGlobalGroupsColorPropertiesUseCase = getGlobalGroupsColorPropertiesUseCase
        self.setGlobalGroupsColorPropertiesUseCase = setGlobalGroupsColorPropertiesUseCase
        self.getGlobalGroupsGeometricPropertiesUseCase = getGlobalGroupsGeometricPropertiesUseCase
        self.setGlobalGroupsGeometricPropertiesUseCase = setGlobalGroupsGeometricPropertiesUseCase
        self.getGlobalGroupsEffectPropertiesUseCase = getGlobalGroupsEffectPropertiesUseCase
        self.setGlobalGroupsEffectPropertiesUseCase = setGlobalGroupsEffectPropertiesUseCase
        self.getGlobalSpacesColorPropertiesUseCase = getGlobalSpacesColorPropertiesUseCase
        self.getGlobalSpacesGeometricPropertiesUseCase = getGlobalSpacesGeometricPropertiesUseCase
        self.getGlobalSpacesEffectPropertiesUseCase = getGlobalSpacesEffectPropertiesUseCase
        self.getThemeModeUseCase = getThemeModeUseCase
        self.getThemePresetColorPropertiesUseCase = getThemePresetColorPropertiesUseCase
        self.getThemePresetGeometricPropertiesUseCase = getThemePresetGeometricPropertiesUseCase
        self.getThemePresetEffectPropertiesUseCase = getThemePresetEffectPropertiesUseCase
        self.getMenuBarHeightUseCase = getMenuBarHeightUseCase

        // Initialize with current values
        showGroups = getShowGroupsUseCase.execute().blockingFirst()
        groups = getGroupsUseCase.execute().blockingFirst()
        menuBarApps = getMenuBarAppsUseCase.execute().blockingFirst()
        isGroupsFeatureEnabled = getFeatureFlagsUseCase.execute().blockingFirst().enableGroups
        spacesAppearanceMode = getSpacesAppearanceModeUseCase.execute().blockingFirst()
        groupsAppearanceMode = getGroupsAppearanceModeUseCase.execute().blockingFirst()
        globalGroupsColorProperties = getGlobalGroupsColorPropertiesUseCase.execute().blockingFirst()
        globalGroupsGeometricProperties = getGlobalGroupsGeometricPropertiesUseCase.execute().blockingFirst()
        globalGroupsEffectProperties = getGlobalGroupsEffectPropertiesUseCase.execute().blockingFirst()
        globalSpacesColorProperties = getGlobalSpacesColorPropertiesUseCase.execute().blockingFirst()
        globalSpacesGeometricProperties = getGlobalSpacesGeometricPropertiesUseCase.execute().blockingFirst()
        globalSpacesEffectProperties = getGlobalSpacesEffectPropertiesUseCase.execute().blockingFirst()
        themeMode = getThemeModeUseCase.execute().blockingFirst()
        themePresetColorProperties = getThemePresetColorPropertiesUseCase.execute().blockingFirst()
        themePresetGeometricProperties = getThemePresetGeometricPropertiesUseCase.execute().blockingFirst()
        themePresetEffectProperties = getThemePresetEffectPropertiesUseCase.execute().blockingFirst()
        menuBarHeight = getMenuBarHeightUseCase.execute().blockingFirst()

        availableGroupsAppearanceModes = GroupsAppearanceMode.allCases
        if spacesAppearanceMode == .perSpace {
            availableGroupsAppearanceModes = GroupsViewModel.restrictedGroupsAppearanceMode
        }

        setupReactiveSubscriptions()
    }

    // MARK: - Public Methods

    /// Validates and potentially restricts the groups appearance mode based on spaces appearance mode.
    /// When spaces are in per-space mode, groups cannot use "Match to Spaces" mode.
    /// - Parameter proposedMode: The desired groups appearance mode
    /// - Returns: The validated appearance mode (fallback to .allGroups if restricted)
    private func validateGroupsAppearanceMode(_ proposedMode: GroupsAppearanceMode) -> GroupsAppearanceMode {
        // If spaces are in per-space mode, restrict groups to .allGroups or .perGroup only
        if spacesAppearanceMode == .perSpace, proposedMode == .matchSpaces {
            return .allGroups // Fallback to all groups mode
        }

        return proposedMode
    }

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
    func addNewGroup() {
        let totalApps = menuBarApps.count
        guard groups.count < totalApps else { return }

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

            return
        } else {
            // Priority 2: Fallback - take app from first group (original behavior)
            guard !groups.isEmpty else { return }

            // Sort to ensure we get the rightmost group (lowest startIndex)
            normalizeGroupsConfiguration()
            let rightmostGroup = groups[0]
            let rightmostGroupEndIndex = rightmostGroup.getEndIndex(menuBarAppsCount: totalApps)
            guard rightmostGroupEndIndex > rightmostGroup.startIndex else { return }

            // Reduce rightmost group by 1 app
            groups[0].endIndex = rightmostGroupEndIndex - 1

            // Create new group with the taken app
            var newGroup = Group.defaultInstance
            newGroup.startIndex = rightmostGroupEndIndex
            newGroup.endIndex = rightmostGroupEndIndex

            // Add to array and normalize
            groups.append(newGroup)
            normalizeGroupsConfiguration()
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

    /// Resets the groups configuration to default values from ConfigurationDefaults.
    func resetGroupsToDefaults() async {
        await setGroupsUseCase.execute(value: ConfigurationDefaults.groups)
        await setGroupsAppearanceModeUseCase.execute(mode: ConfigurationDefaults.groupsAppearanceMode)

        await setGlobalGroupsColorPropertiesUseCase.execute(
            value: ConfigurationDefaults.groupsGlobalColorProperties
        )
        await setGlobalGroupsGeometricPropertiesUseCase.execute(
            value: ConfigurationDefaults.groupsGlobalGeometricProperties
        )
        await setGlobalGroupsEffectPropertiesUseCase.execute(
            value: ConfigurationDefaults.groupsGlobalEffectProperties
        )
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
            .assign(to: \.showGroups, on: self)
            .store(in: &cancellables)

        getGroupsUseCase.execute()
            .assign(to: \.groups, on: self)
            .store(in: &cancellables)

        // Subscribe to menu bar apps changes
        getMenuBarAppsUseCase.execute()
            .assign(to: \.menuBarApps, on: self)
            .store(in: &cancellables)

        // Subscribe to feature flags changes
        getFeatureFlagsUseCase.execute()
            .sink { [weak self] featureFlags in
                if self?.isGroupsFeatureEnabled != featureFlags.enableGroups {
                    self?.isGroupsFeatureEnabled = featureFlags.enableGroups
                }
            }
            .store(in: &cancellables)
    }

    /// Setup subscriptions for groups global appearance configuration changes
    private func setupGroupsAppearanceSubscriptions() {
        // Subscribe to groups appearance mode changes
        getGroupsAppearanceModeUseCase.execute()
            .assign(to: \.groupsAppearanceMode, on: self)
            .store(in: &cancellables)

        // Subscribe to spaces appearance mode changes
        getSpacesAppearanceModeUseCase.execute()
            .sink { [weak self] spacesAppearanceMode in
                guard let self else { return }

                // If spaces switched to per-space mode and groups are in matchSpaces mode,
                // automatically switch groups to allGroups mode
                if
                    spacesAppearanceMode == .perSpace,
                    availableGroupsAppearanceModes != GroupsViewModel.restrictedGroupsAppearanceMode
                {
                    availableGroupsAppearanceModes = GroupsViewModel.restrictedGroupsAppearanceMode

                    if !availableGroupsAppearanceModes.contains(groupsAppearanceMode) {
                        groupsAppearanceMode = .allGroups
                    }
                } else {
                    availableGroupsAppearanceModes = GroupsAppearanceMode.allCases
                }

                if self.spacesAppearanceMode != spacesAppearanceMode {
                    self.spacesAppearanceMode = spacesAppearanceMode
                }
            }
            .store(in: &cancellables)

        getGlobalGroupsColorPropertiesUseCase.execute()
            .assign(to: \.globalGroupsColorProperties, on: self)
            .store(in: &cancellables)

        getGlobalGroupsGeometricPropertiesUseCase.execute()
            .assign(to: \.globalGroupsGeometricProperties, on: self)
            .store(in: &cancellables)

        getGlobalGroupsEffectPropertiesUseCase.execute()
            .assign(to: \.globalGroupsEffectProperties, on: self)
            .store(in: &cancellables)

        getGlobalSpacesColorPropertiesUseCase.execute()
            .assign(to: \.globalSpacesColorProperties, on: self)
            .store(in: &cancellables)

        getGlobalSpacesGeometricPropertiesUseCase.execute()
            .assign(to: \.globalSpacesGeometricProperties, on: self)
            .store(in: &cancellables)

        getGlobalSpacesEffectPropertiesUseCase.execute()
            .assign(to: \.globalSpacesEffectProperties, on: self)
            .store(in: &cancellables)

        getThemeModeUseCase.execute()
            .assign(to: \.themeMode, on: self)
            .store(in: &cancellables)

        getThemePresetColorPropertiesUseCase.execute()
            .assign(to: \.themePresetColorProperties, on: self)
            .store(in: &cancellables)

        getThemePresetGeometricPropertiesUseCase.execute()
            .assign(to: \.themePresetGeometricProperties, on: self)
            .store(in: &cancellables)

        getThemePresetEffectPropertiesUseCase.execute()
            .assign(to: \.themePresetEffectProperties, on: self)
            .store(in: &cancellables)

        getMenuBarHeightUseCase.execute()
            .assign(to: \.menuBarHeight, on: self)
            .store(in: &cancellables)
    }

    /// Setup menu bar apps subscription with change handling
    private func setupMenuBarAppsSubscriptions() {
        getMenuBarAppsUseCase.execute()
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
