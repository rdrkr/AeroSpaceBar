// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import AppKit
import Combine
@testable import Domain
import Nimble
@testable import Presentation
import XCTest

/// Tests for GroupsViewModel.
///
/// These tests verify groups configuration management including:
/// - Group CRUD operations
/// - Menu bar app integration
/// - Appearance mode management
/// - Visual properties configuration
@MainActor
final class GroupsViewModelTests: XCTestCase {
    private var viewModel: GroupsViewModel?
    private var cancellables: Set<AnyCancellable>?

    // Mock gateways
    private var mockConfigurationGateway: MockConfigurationGateway?
    private var mockSystemMenuBarGateway: MockSystemMenuBarGateway?
    private var mockFeatureFlagsGateway: MockFeatureFlagsGateway?

    // Real use cases with mock gateways
    private var getShowGroupsUseCase: GetShowGroupsUseCase?
    private var setShowGroupsUseCase: SetShowGroupsUseCase?
    private var getGroupsUseCase: GetGroupsUseCase?
    private var setGroupsUseCase: SetGroupsUseCase?
    private var getMenuBarAppsUseCase: GetMenuBarAppsUseCase?
    private var getFeatureFlagsUseCase: GetFeatureFlagsUseCase?
    private var getGroupsAppearanceModeUseCase: GetGroupsAppearanceModeUseCase?
    private var setGroupsAppearanceModeUseCase: SetGroupsAppearanceModeUseCase?
    private var getSpacesAppearanceModeUseCase: GetSpacesAppearanceModeUseCase?
    private var getGlobalGroupsColorPropertiesUseCase: GetGlobalGroupsColorPropertiesUseCase?
    private var setGlobalGroupsColorPropertiesUseCase: SetGlobalGroupsColorPropertiesUseCase?
    private var getGlobalGroupsGeometricPropertiesUseCase: GetGlobalGroupsGeometricPropertiesUseCase?
    private var setGlobalGroupsGeometricPropertiesUseCase: SetGlobalGroupsGeometricPropertiesUseCase?
    private var getGlobalGroupsEffectPropertiesUseCase: GetGlobalGroupsEffectPropertiesUseCase?
    private var setGlobalGroupsEffectPropertiesUseCase: SetGlobalGroupsEffectPropertiesUseCase?
    private var getGlobalSpacesColorPropertiesUseCase: GetGlobalSpacesColorPropertiesUseCase?
    private var getGlobalSpacesGeometricPropertiesUseCase: GetGlobalSpacesGeometricPropertiesUseCase?
    private var getGlobalSpacesEffectPropertiesUseCase: GetGlobalSpacesEffectPropertiesUseCase?
    private var getThemeModeUseCase: GetThemeModeUseCase?
    private var getThemePresetColorPropertiesUseCase: GetThemePresetColorPropertiesUseCase?
    private var getThemePresetGeometricPropertiesUseCase: GetThemePresetGeometricPropertiesUseCase?
    private var getThemePresetEffectPropertiesUseCase: GetThemePresetEffectPropertiesUseCase?
    private var getMenuBarHeightUseCase: GetMenuBarHeightUseCase?

    // MARK: - Configuration Structure

    /// Configuration object containing all use cases needed for GroupsViewModel.
    private struct GroupsViewModelConfiguration {
        let getShowGroupsUseCase: GetShowGroupsUseCase
        let setShowGroupsUseCase: SetShowGroupsUseCase
        let getGroupsUseCase: GetGroupsUseCase
        let setGroupsUseCase: SetGroupsUseCase
        let getMenuBarAppsUseCase: GetMenuBarAppsUseCase
        let getFeatureFlagsUseCase: GetFeatureFlagsUseCase
        let getGroupsAppearanceModeUseCase: GetGroupsAppearanceModeUseCase
        let setGroupsAppearanceModeUseCase: SetGroupsAppearanceModeUseCase
        let getSpacesAppearanceModeUseCase: GetSpacesAppearanceModeUseCase
        let getGlobalGroupsColorPropertiesUseCase: GetGlobalGroupsColorPropertiesUseCase
        let setGlobalGroupsColorPropertiesUseCase: SetGlobalGroupsColorPropertiesUseCase
        let getGlobalGroupsGeometricPropertiesUseCase: GetGlobalGroupsGeometricPropertiesUseCase
        let setGlobalGroupsGeometricPropertiesUseCase: SetGlobalGroupsGeometricPropertiesUseCase
        let getGlobalGroupsEffectPropertiesUseCase: GetGlobalGroupsEffectPropertiesUseCase
        let setGlobalGroupsEffectPropertiesUseCase: SetGlobalGroupsEffectPropertiesUseCase
        let getGlobalSpacesColorPropertiesUseCase: GetGlobalSpacesColorPropertiesUseCase
        let getGlobalSpacesGeometricPropertiesUseCase: GetGlobalSpacesGeometricPropertiesUseCase
        let getGlobalSpacesEffectPropertiesUseCase: GetGlobalSpacesEffectPropertiesUseCase
        let getThemeModeUseCase: GetThemeModeUseCase
        let getThemePresetColorPropertiesUseCase: GetThemePresetColorPropertiesUseCase
        let getThemePresetGeometricPropertiesUseCase: GetThemePresetGeometricPropertiesUseCase
        let getThemePresetEffectPropertiesUseCase: GetThemePresetEffectPropertiesUseCase
        let getMenuBarHeightUseCase: GetMenuBarHeightUseCase
    }

    override func setUp() async throws {
        try await super.setUp()
        cancellables = Set<AnyCancellable>()

        // Initialize mock gateways
        // Initialize mock gateways
        mockConfigurationGateway = MockConfigurationGateway()
        mockSystemMenuBarGateway = MockSystemMenuBarGateway()
        mockFeatureFlagsGateway = MockFeatureFlagsGateway(flags: FeatureFlags.defaultFlags())

        // Use guard statements to safely unwrap gateways before initializing use cases
        guard
            let configurationGateway = mockConfigurationGateway,
            let systemMenuBarGateway = mockSystemMenuBarGateway,
            let featureFlagsGateway = mockFeatureFlagsGateway
        else {
            XCTFail("Mock gateways should be initialized")
            return
        }

        // Initialize real use cases with mock gateways
        getShowGroupsUseCase = GetShowGroupsUseCase(configurationGateway: configurationGateway)
        setShowGroupsUseCase = SetShowGroupsUseCase(configurationGateway: configurationGateway)
        getGroupsUseCase = GetGroupsUseCase(configurationGateway: configurationGateway)
        setGroupsUseCase = SetGroupsUseCase(configurationGateway: configurationGateway)
        getMenuBarAppsUseCase = GetMenuBarAppsUseCase(systemMenuBarGateway: systemMenuBarGateway)
        getFeatureFlagsUseCase = GetFeatureFlagsUseCase(gateway: featureFlagsGateway)
        getGroupsAppearanceModeUseCase = GetGroupsAppearanceModeUseCase(configurationGateway: configurationGateway)
        setGroupsAppearanceModeUseCase = SetGroupsAppearanceModeUseCase(configurationGateway: configurationGateway)
        getSpacesAppearanceModeUseCase = GetSpacesAppearanceModeUseCase(configurationGateway: configurationGateway)
        getGlobalGroupsColorPropertiesUseCase =
            GetGlobalGroupsColorPropertiesUseCase(configurationGateway: configurationGateway)
        setGlobalGroupsColorPropertiesUseCase =
            SetGlobalGroupsColorPropertiesUseCase(configurationGateway: configurationGateway)
        getGlobalGroupsGeometricPropertiesUseCase =
            GetGlobalGroupsGeometricPropertiesUseCase(configurationGateway: configurationGateway)
        setGlobalGroupsGeometricPropertiesUseCase =
            SetGlobalGroupsGeometricPropertiesUseCase(configurationGateway: configurationGateway)
        getGlobalGroupsEffectPropertiesUseCase =
            GetGlobalGroupsEffectPropertiesUseCase(configurationGateway: configurationGateway)
        setGlobalGroupsEffectPropertiesUseCase =
            SetGlobalGroupsEffectPropertiesUseCase(configurationGateway: configurationGateway)
        getGlobalSpacesColorPropertiesUseCase =
            GetGlobalSpacesColorPropertiesUseCase(configurationGateway: configurationGateway)
        getGlobalSpacesGeometricPropertiesUseCase =
            GetGlobalSpacesGeometricPropertiesUseCase(configurationGateway: configurationGateway)
        getGlobalSpacesEffectPropertiesUseCase =
            GetGlobalSpacesEffectPropertiesUseCase(configurationGateway: configurationGateway)
        getThemeModeUseCase = GetThemeModeUseCase(configurationGateway: configurationGateway)
        getThemePresetColorPropertiesUseCase =
            GetThemePresetColorPropertiesUseCase(configurationGateway: configurationGateway)
        getThemePresetGeometricPropertiesUseCase =
            GetThemePresetGeometricPropertiesUseCase(configurationGateway: configurationGateway)
        getThemePresetEffectPropertiesUseCase =
            GetThemePresetEffectPropertiesUseCase(configurationGateway: configurationGateway)
        getMenuBarHeightUseCase = GetMenuBarHeightUseCase(systemMenuBarGateway: systemMenuBarGateway)

        // Use guard statements to safely unwrap use cases before creating configuration
        guard
            let getShowGroupsUseCase,
            let setShowGroupsUseCase,
            let getGroupsUseCase,
            let setGroupsUseCase,
            let getMenuBarAppsUseCase,
            let getFeatureFlagsUseCase,
            let getGroupsAppearanceModeUseCase,
            let setGroupsAppearanceModeUseCase,
            let getSpacesAppearanceModeUseCase,
            let getGlobalGroupsColorPropertiesUseCase,
            let setGlobalGroupsColorPropertiesUseCase,
            let getGlobalGroupsGeometricPropertiesUseCase,
            let setGlobalGroupsGeometricPropertiesUseCase,
            let getGlobalGroupsEffectPropertiesUseCase,
            let setGlobalGroupsEffectPropertiesUseCase,
            let getGlobalSpacesColorPropertiesUseCase,
            let getGlobalSpacesGeometricPropertiesUseCase,
            let getGlobalSpacesEffectPropertiesUseCase,
            let getThemeModeUseCase,
            let getThemePresetColorPropertiesUseCase,
            let getThemePresetGeometricPropertiesUseCase,
            let getThemePresetEffectPropertiesUseCase,
            let getMenuBarHeightUseCase
        else {
            XCTFail("Use cases should be initialized")
            return
        }

        let config = GroupsViewModelConfiguration(
            getShowGroupsUseCase: getShowGroupsUseCase,
            setShowGroupsUseCase: setShowGroupsUseCase,
            getGroupsUseCase: getGroupsUseCase,
            setGroupsUseCase: setGroupsUseCase,
            getMenuBarAppsUseCase: getMenuBarAppsUseCase,
            getFeatureFlagsUseCase: getFeatureFlagsUseCase,
            getGroupsAppearanceModeUseCase: getGroupsAppearanceModeUseCase,
            setGroupsAppearanceModeUseCase: setGroupsAppearanceModeUseCase,
            getSpacesAppearanceModeUseCase: getSpacesAppearanceModeUseCase,
            getGlobalGroupsColorPropertiesUseCase: getGlobalGroupsColorPropertiesUseCase,
            setGlobalGroupsColorPropertiesUseCase: setGlobalGroupsColorPropertiesUseCase,
            getGlobalGroupsGeometricPropertiesUseCase: getGlobalGroupsGeometricPropertiesUseCase,
            setGlobalGroupsGeometricPropertiesUseCase: setGlobalGroupsGeometricPropertiesUseCase,
            getGlobalGroupsEffectPropertiesUseCase: getGlobalGroupsEffectPropertiesUseCase,
            setGlobalGroupsEffectPropertiesUseCase: setGlobalGroupsEffectPropertiesUseCase,
            getGlobalSpacesColorPropertiesUseCase: getGlobalSpacesColorPropertiesUseCase,
            getGlobalSpacesGeometricPropertiesUseCase: getGlobalSpacesGeometricPropertiesUseCase,
            getGlobalSpacesEffectPropertiesUseCase: getGlobalSpacesEffectPropertiesUseCase,
            getThemeModeUseCase: getThemeModeUseCase,
            getThemePresetColorPropertiesUseCase: getThemePresetColorPropertiesUseCase,
            getThemePresetGeometricPropertiesUseCase: getThemePresetGeometricPropertiesUseCase,
            getThemePresetEffectPropertiesUseCase: getThemePresetEffectPropertiesUseCase,
            getMenuBarHeightUseCase: getMenuBarHeightUseCase
        )

        createViewModel(with: config)
    }

    private func createViewModel(with config: GroupsViewModelConfiguration) {
        // The Apple Button and foreground-overlay use cases are built here rather
        // than threaded through the configuration struct, which predates them.
        guard
            let configurationGateway = mockConfigurationGateway,
            let systemMenuBarGateway = mockSystemMenuBarGateway
        else {
            XCTFail("Mock gateways should be initialized")
            return
        }

        viewModel = GroupsViewModel(
            getShowGroupsUseCase: config.getShowGroupsUseCase,
            setShowGroupsUseCase: config.setShowGroupsUseCase,
            getGroupsUseCase: config.getGroupsUseCase,
            setGroupsUseCase: config.setGroupsUseCase,
            getMenuBarAppsUseCase: config.getMenuBarAppsUseCase,
            getFeatureFlagsUseCase: config.getFeatureFlagsUseCase,
            getGroupsAppearanceModeUseCase: config.getGroupsAppearanceModeUseCase,
            setGroupsAppearanceModeUseCase: config.setGroupsAppearanceModeUseCase,
            getSpacesAppearanceModeUseCase: config.getSpacesAppearanceModeUseCase,
            getGlobalGroupsColorPropertiesUseCase: config.getGlobalGroupsColorPropertiesUseCase,
            setGlobalGroupsColorPropertiesUseCase: config.setGlobalGroupsColorPropertiesUseCase,
            getGlobalGroupsGeometricPropertiesUseCase: config.getGlobalGroupsGeometricPropertiesUseCase,
            setGlobalGroupsGeometricPropertiesUseCase: config.setGlobalGroupsGeometricPropertiesUseCase,
            getGlobalGroupsEffectPropertiesUseCase: config.getGlobalGroupsEffectPropertiesUseCase,
            setGlobalGroupsEffectPropertiesUseCase: config.setGlobalGroupsEffectPropertiesUseCase,
            getGlobalSpacesColorPropertiesUseCase: config.getGlobalSpacesColorPropertiesUseCase,
            getGlobalSpacesGeometricPropertiesUseCase: config.getGlobalSpacesGeometricPropertiesUseCase,
            getGlobalSpacesEffectPropertiesUseCase: config.getGlobalSpacesEffectPropertiesUseCase,
            getThemeModeUseCase: config.getThemeModeUseCase,
            getThemePresetColorPropertiesUseCase: config.getThemePresetColorPropertiesUseCase,
            getThemePresetGeometricPropertiesUseCase: config.getThemePresetGeometricPropertiesUseCase,
            getThemePresetEffectPropertiesUseCase: config.getThemePresetEffectPropertiesUseCase,
            getMenuBarHeightUseCase: config.getMenuBarHeightUseCase,
            getShowAppleButtonAsSpaceUseCase: GetShowAppleButtonAsSpaceUseCase(
                configurationGateway: configurationGateway
            ),
            getAppleButtonFrameUseCase: GetAppleButtonFrameUseCase(systemMenuBarGateway: systemMenuBarGateway),
            getAppleButtonColorPropertiesUseCase: GetAppleButtonColorPropertiesUseCase(
                configurationGateway: configurationGateway
            ),
            getAppleButtonGeometricPropertiesUseCase: GetAppleButtonGeometricPropertiesUseCase(
                configurationGateway: configurationGateway
            ),
            getAppleButtonEffectPropertiesUseCase: GetAppleButtonEffectPropertiesUseCase(
                configurationGateway: configurationGateway
            ),
            getShowForegroundOverlayUseCase: GetShowForegroundOverlayUseCase(
                configurationGateway: configurationGateway
            ),
            setShowForegroundOverlayUseCase: SetShowForegroundOverlayUseCase(
                configurationGateway: configurationGateway
            )
        )
    }

    // MARK: - Initialization Tests

    func testInitialization() {
        guard let viewModel else {
            fail("ViewModel not initialized")
            return
        }

        expect(viewModel.showGroups) == true
        expect(viewModel.groups) == Group.singleGroup
        expect(viewModel.isGroupsFeatureEnabled) == true
    }

    // MARK: - Show Groups Tests

    func testShowGroupsUpdates() async {
        guard let mockConfigurationGateway else {
            XCTFail("Mock configuration gateway should be initialized")
            return
        }

        guard let viewModel else {
            XCTFail("ViewModel should be initialized")
            return
        }

        viewModel.showGroups = false
        try? await Task.sleep(for: .milliseconds(100))
        expect(mockConfigurationGateway.lastShowGroups) == false
    }

    // MARK: - Groups Configuration Tests

    func testGroupsUpdates() async {
        guard let mockConfigurationGateway else {
            XCTFail("Mock configuration gateway should be initialized")
            return
        }

        guard let viewModel else {
            XCTFail("ViewModel should be initialized")
            return
        }

        let newGroups = [
            Group(
                id: 1,
                startIndex: 1,
                endIndex: 5,
                colorProperties: ConfigurationDefaults.groupsGlobalColorProperties,
                geometricProperties: GeometricProperties(),
                effectProperties: EffectProperties()
            )
        ]
        viewModel.groups = newGroups
        try? await Task.sleep(for: .milliseconds(100))
        expect(mockConfigurationGateway.lastGroups.count) == 1
    }

    // MARK: - Appearance Mode Tests

    func testGroupsAppearanceModeUpdates() async {
        guard let mockConfigurationGateway else {
            XCTFail("Mock configuration gateway should be initialized")
            return
        }

        guard let viewModel else {
            XCTFail("ViewModel should be initialized")
            return
        }

        viewModel.groupsAppearanceMode = .allGroups
        try? await Task.sleep(for: .milliseconds(100))
        expect(mockConfigurationGateway.lastGroupsAppearanceMode) == .allGroups
    }

    func testMenuBarAppsChange_ToEmpty_ShouldNotRemoveGroups() async {
        guard let mockSystemMenuBarGateway, let mockConfigurationGateway else {
            XCTFail("Mock gateways should be initialized")
            return
        }

        guard let viewModel else {
            XCTFail("ViewModel should be initialized")
            return
        }

        // Given: Initial apps and groups are set
        let app1 = MenuBarApp(id: "1", frame: .zero)
        let app2 = MenuBarApp(id: "2", frame: .zero)
        mockSystemMenuBarGateway.setMenuBarApps([app1, app2])

        // Wait for apps update
        try? await Task.sleep(for: .milliseconds(100))

        let initialGroups = [
            Group(
                id: 1,
                startIndex: 1,
                endIndex: 2,
                colorProperties: ConfigurationDefaults.groupsGlobalColorProperties,
                geometricProperties: GeometricProperties(),
                effectProperties: EffectProperties()
            )
        ]
        viewModel.groups = initialGroups

        // Wait for initial update to propagate
        try? await Task.sleep(for: .milliseconds(100))
        expect(mockConfigurationGateway.lastGroups.count) == 1

        // When: Menu bar apps become empty (simulating transient state)
        mockSystemMenuBarGateway.setMenuBarApps([])

        // Wait for update to propagate
        try? await Task.sleep(for: .milliseconds(100))

        // Then: Groups should NOT be removed/cleared
        // The bug is that they ARE cleared, so this assertion should fail before the fix
        expect(viewModel.groups.isEmpty) == false
        expect(mockConfigurationGateway.lastGroups.isEmpty) == false
    }

    // MARK: - Memory Management

    func testGroupsViewModelIsDeallocatedWhenReleased() async throws {
        // Given a view model whose reactive subscriptions are stored in its own
        // `cancellables`
        weak var weakViewModel: GroupsViewModel?
        weakViewModel = viewModel

        // When every strong reference is dropped
        cancellables = nil
        mockConfigurationGateway = nil
        mockSystemMenuBarGateway = nil
        mockFeatureFlagsGateway = nil
        getShowGroupsUseCase = nil
        setShowGroupsUseCase = nil
        getGroupsUseCase = nil
        setGroupsUseCase = nil
        getMenuBarAppsUseCase = nil
        getFeatureFlagsUseCase = nil
        getGroupsAppearanceModeUseCase = nil
        setGroupsAppearanceModeUseCase = nil
        getSpacesAppearanceModeUseCase = nil
        getGlobalGroupsColorPropertiesUseCase = nil
        setGlobalGroupsColorPropertiesUseCase = nil
        getGlobalGroupsGeometricPropertiesUseCase = nil
        setGlobalGroupsGeometricPropertiesUseCase = nil
        getGlobalGroupsEffectPropertiesUseCase = nil
        setGlobalGroupsEffectPropertiesUseCase = nil
        getGlobalSpacesColorPropertiesUseCase = nil
        getGlobalSpacesGeometricPropertiesUseCase = nil
        getGlobalSpacesEffectPropertiesUseCase = nil
        getThemeModeUseCase = nil
        getThemePresetColorPropertiesUseCase = nil
        getThemePresetGeometricPropertiesUseCase = nil
        getThemePresetEffectPropertiesUseCase = nil
        getMenuBarHeightUseCase = nil
        viewModel = nil

        // Let the detached tasks the `didSet` observers spawned run to completion;
        // they hold `self` until they finish, unlike a genuine retain cycle.
        try await Task.sleep(for: .milliseconds(500))

        // Then it deallocates: the subscriptions capture `self` weakly, so storing
        // them on the view model does not form a retain cycle
        expect(weakViewModel).to(beNil())
    }
}

// MARK: - Mock Gateways
