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

    /// Whether to show the Apple Button as a space background.
    @Published var showAppleButtonAsSpace: Bool

    /// The detected Apple Button (Apple menu icon) frame.
    @Published var appleButtonFrame: CGRect

    /// The color properties for the Apple Button space element (per-space mode).
    @Published var appleButtonColorProperties: ColorProperties

    /// The geometric properties for the Apple Button space element (per-space mode).
    @Published var appleButtonGeometricProperties: GeometricProperties

    /// The effect properties for the Apple Button space element (per-space mode).
    @Published var appleButtonEffectProperties: EffectProperties

    /// Whether the foreground color overlay is enabled.
    @Published var showForegroundOverlay: Bool {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setShowForegroundOverlayUseCase.execute(value: showForegroundOverlay)
            }
        }
    }

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
    private let getShowAppleButtonAsSpaceUseCase: GetShowAppleButtonAsSpaceUseCase
    private let getAppleButtonFrameUseCase: GetAppleButtonFrameUseCase
    private let getAppleButtonColorPropertiesUseCase: GetAppleButtonColorPropertiesUseCase
    private let getAppleButtonGeometricPropertiesUseCase: GetAppleButtonGeometricPropertiesUseCase
    private let getAppleButtonEffectPropertiesUseCase: GetAppleButtonEffectPropertiesUseCase
    private let getShowForegroundOverlayUseCase: GetShowForegroundOverlayUseCase
    private let setShowForegroundOverlayUseCase: SetShowForegroundOverlayUseCase

    /// Cancellable subscriptions for Combine publishers.
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Private Constants

    /// All cases of GroupsAppearanceMode without matchSpaces.
    private static let restrictedGroupsAppearanceMode = GroupsAppearanceMode.allCases
        .filter { $0 != .matchSpaces }

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
    ///   - getShowAppleButtonAsSpaceUseCase: Use case for getting show Apple Button as space setting
    ///   - getAppleButtonFrameUseCase: Use case for getting Apple Button frame
    ///   - getAppleButtonColorPropertiesUseCase: Use case for getting Apple Button color properties
    ///   - getAppleButtonGeometricPropertiesUseCase: Use case for getting Apple Button geometric properties
    ///   - getAppleButtonEffectPropertiesUseCase: Use case for getting Apple Button effect properties
    ///   - getShowForegroundOverlayUseCase: Use case for getting show foreground overlay setting
    ///   - setShowForegroundOverlayUseCase: Use case for setting show foreground overlay setting
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
        getMenuBarHeightUseCase: GetMenuBarHeightUseCase,
        getShowAppleButtonAsSpaceUseCase: GetShowAppleButtonAsSpaceUseCase,
        getAppleButtonFrameUseCase: GetAppleButtonFrameUseCase,
        getAppleButtonColorPropertiesUseCase: GetAppleButtonColorPropertiesUseCase,
        getAppleButtonGeometricPropertiesUseCase: GetAppleButtonGeometricPropertiesUseCase,
        getAppleButtonEffectPropertiesUseCase: GetAppleButtonEffectPropertiesUseCase,
        getShowForegroundOverlayUseCase: GetShowForegroundOverlayUseCase,
        setShowForegroundOverlayUseCase: SetShowForegroundOverlayUseCase
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
        self.getShowAppleButtonAsSpaceUseCase = getShowAppleButtonAsSpaceUseCase
        self.getAppleButtonFrameUseCase = getAppleButtonFrameUseCase
        self.getAppleButtonColorPropertiesUseCase = getAppleButtonColorPropertiesUseCase
        self.getAppleButtonGeometricPropertiesUseCase = getAppleButtonGeometricPropertiesUseCase
        self.getAppleButtonEffectPropertiesUseCase = getAppleButtonEffectPropertiesUseCase
        self.getShowForegroundOverlayUseCase = getShowForegroundOverlayUseCase
        self.setShowForegroundOverlayUseCase = setShowForegroundOverlayUseCase

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
        showAppleButtonAsSpace = getShowAppleButtonAsSpaceUseCase.execute().blockingFirst()
        appleButtonFrame = getAppleButtonFrameUseCase.execute().blockingFirst()
        appleButtonColorProperties = getAppleButtonColorPropertiesUseCase.execute().blockingFirst()
        appleButtonGeometricProperties = getAppleButtonGeometricPropertiesUseCase.execute().blockingFirst()
        appleButtonEffectProperties = getAppleButtonEffectPropertiesUseCase.execute().blockingFirst()
        showForegroundOverlay = getShowForegroundOverlayUseCase.execute().blockingFirst()

        availableGroupsAppearanceModes = GroupsAppearanceMode.allCases
        if spacesAppearanceMode == .perSpace {
            availableGroupsAppearanceModes = Self.restrictedGroupsAppearanceMode
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
        }
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
        await setShowForegroundOverlayUseCase.execute(
            value: ConfigurationDefaults.showForegroundOverlay
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
        // If newCount is 0, it might be a transient state (e.g. app launch or rapid updates).
        // We should not wipe out groups in this case.
        guard newCount > 0 else { return }

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
            .sink { [weak self] newValue in
                self?.showGroups = newValue
            }
            .store(in: &cancellables)

        getGroupsUseCase.execute()
            .sink { [weak self] newValue in
                self?.groups = newValue
            }
            .store(in: &cancellables)

        // Subscribe to menu bar apps changes
        getMenuBarAppsUseCase.execute()
            .sink { [weak self] newValue in
                self?.menuBarApps = newValue
            }
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
            .sink { [weak self] newValue in
                self?.groupsAppearanceMode = newValue
            }
            .store(in: &cancellables)

        // Subscribe to spaces appearance mode changes
        getSpacesAppearanceModeUseCase.execute()
            .sink { [weak self] spacesAppearanceMode in
                guard let self else { return }

                // If spaces switched to per-space mode and groups are in matchSpaces mode,
                // automatically switch groups to allGroups mode
                if
                    spacesAppearanceMode == .perSpace,
                    availableGroupsAppearanceModes != Self.restrictedGroupsAppearanceMode
                {
                    availableGroupsAppearanceModes = Self.restrictedGroupsAppearanceMode

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
            .sink { [weak self] newValue in
                self?.globalGroupsColorProperties = newValue
            }
            .store(in: &cancellables)

        getGlobalGroupsGeometricPropertiesUseCase.execute()
            .sink { [weak self] newValue in
                self?.globalGroupsGeometricProperties = newValue
            }
            .store(in: &cancellables)

        getGlobalGroupsEffectPropertiesUseCase.execute()
            .sink { [weak self] newValue in
                self?.globalGroupsEffectProperties = newValue
            }
            .store(in: &cancellables)

        getGlobalSpacesColorPropertiesUseCase.execute()
            .sink { [weak self] newValue in
                self?.globalSpacesColorProperties = newValue
            }
            .store(in: &cancellables)

        getGlobalSpacesGeometricPropertiesUseCase.execute()
            .sink { [weak self] newValue in
                self?.globalSpacesGeometricProperties = newValue
            }
            .store(in: &cancellables)

        getGlobalSpacesEffectPropertiesUseCase.execute()
            .sink { [weak self] newValue in
                self?.globalSpacesEffectProperties = newValue
            }
            .store(in: &cancellables)

        getThemeModeUseCase.execute()
            .sink { [weak self] newValue in
                self?.themeMode = newValue
            }
            .store(in: &cancellables)

        getThemePresetColorPropertiesUseCase.execute()
            .sink { [weak self] newValue in
                self?.themePresetColorProperties = newValue
            }
            .store(in: &cancellables)

        getThemePresetGeometricPropertiesUseCase.execute()
            .sink { [weak self] newValue in
                self?.themePresetGeometricProperties = newValue
            }
            .store(in: &cancellables)

        getThemePresetEffectPropertiesUseCase.execute()
            .sink { [weak self] newValue in
                self?.themePresetEffectProperties = newValue
            }
            .store(in: &cancellables)

        getMenuBarHeightUseCase.execute()
            .sink { [weak self] newValue in
                self?.menuBarHeight = newValue
            }
            .store(in: &cancellables)

        getShowAppleButtonAsSpaceUseCase.execute()
            .sink { [weak self] newValue in
                self?.showAppleButtonAsSpace = newValue
            }
            .store(in: &cancellables)

        getAppleButtonFrameUseCase.execute()
            .sink { [weak self] newValue in
                self?.appleButtonFrame = newValue
            }
            .store(in: &cancellables)

        getAppleButtonColorPropertiesUseCase.execute()
            .sink { [weak self] newValue in
                self?.appleButtonColorProperties = newValue
            }
            .store(in: &cancellables)

        getAppleButtonGeometricPropertiesUseCase.execute()
            .sink { [weak self] newValue in
                self?.appleButtonGeometricProperties = newValue
            }
            .store(in: &cancellables)

        getAppleButtonEffectPropertiesUseCase.execute()
            .sink { [weak self] newValue in
                self?.appleButtonEffectProperties = newValue
            }
            .store(in: &cancellables)

        getShowForegroundOverlayUseCase.execute()
            .sink { [weak self] value in
                if self?.showForegroundOverlay != value {
                    self?.showForegroundOverlay = value
                }
            }
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
