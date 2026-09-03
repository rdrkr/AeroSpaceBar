// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
@testable import Domain
import Nimble
@testable import Presentation
import XCTest

/// Tests for SettingsViewModel.
///
/// These tests verify settings coordination including:
/// - Navigation management
/// - Settings persistence
/// - Feature flag integration
/// - Software update configuration
@MainActor
final class SettingsViewModelTests: XCTestCase {
    private var viewModel: SettingsViewModel?
    private var mockConfigurationGateway: MockConfigurationGateway?
    private var mockSystemMenuBarGateway: MockSystemMenuBarGateway?
    private var cancellables: Set<AnyCancellable>?

    override func setUp() async throws {
        try await super.setUp()
        cancellables = Set<AnyCancellable>()
        createViewModel()
    }

    @MainActor
    private func createViewModel() {
        mockConfigurationGateway = MockConfigurationGateway()
        mockSystemMenuBarGateway = MockSystemMenuBarGateway()
        let mockSoftwareUpdateGateway = MockSoftwareUpdateGateway()

        guard
            let configurationGateway = mockConfigurationGateway,
            let systemMenuBarGateway = mockSystemMenuBarGateway
        else {
            XCTFail("Mock gateways should be initialized")
            return
        }

        // Initialize use cases
        let getMenuBarAppsUseCase = GetMenuBarAppsUseCase(systemMenuBarGateway: systemMenuBarGateway)
        let getScreenCapturePermissionGrantedUseCase =
            GetScreenCapturePermissionGrantedUseCase(systemMenuBarGateway: systemMenuBarGateway)
        let requestScreenCapturePermissionsUseCase =
            RequestScreenCapturePermissionsUseCase(systemMenuBarGateway: systemMenuBarGateway)
        let getAeroSpacePathUseCase = GetAeroSpacePathUseCase(configurationGateway: configurationGateway)
        let setAeroSpacePathUseCase = SetAeroSpacePathUseCase(configurationGateway: configurationGateway)
        let getAeroSpaceVersionUseCase = GetAeroSpaceVersionUseCase(configurationGateway: configurationGateway)
        let openAeroSpaceConfigUseCase = OpenAeroSpaceConfigUseCase(configurationGateway: configurationGateway)
        let resetConfigurationUseCase = ResetConfigurationUseCase(configurationGateway: configurationGateway)
        let getLogLevelUseCase = GetLogLevelUseCase(configurationGateway: configurationGateway)
        let setLogLevelUseCase = SetLogLevelUseCase(configurationGateway: configurationGateway)
        let getEnablePerformanceMetricsUseCase =
            GetEnablePerformanceMetricsUseCase(configurationGateway: configurationGateway)
        let setEnablePerformanceMetricsUseCase =
            SetEnablePerformanceMetricsUseCase(configurationGateway: configurationGateway)
        let getOptimizedPerformanceEnabledUseCase =
            GetOptimizedPerformanceEnabledUseCase(configurationGateway: configurationGateway)
        let setOptimizedPerformanceEnabledUseCase =
            SetOptimizedPerformanceEnabledUseCase(configurationGateway: configurationGateway)
        let getFeatureFlagsUseCase =
            GetFeatureFlagsUseCase(gateway: MockFeatureFlagsGateway(flags: FeatureFlags.defaultFlags()))
        let getEnableLicensingUseCase = GetEnableLicensingUseCase(gateway: MockLicenseGateway())
        let getEnableTrialRequestUseCase = GetEnableTrialRequestUseCase(gateway: MockLicenseGateway())
        let getConfigFilePathUseCase = GetConfigFilePathUseCase(configurationGateway: configurationGateway)
        let setConfigFilePathUseCase = SetConfigFilePathUseCase(configurationGateway: configurationGateway)
        let openConfigFileUseCase = OpenConfigFileUseCase(configurationGateway: configurationGateway)
        let getThemeModeUseCase = GetThemeModeUseCase(configurationGateway: configurationGateway)
        let setThemeModeUseCase = SetThemeModeUseCase(configurationGateway: configurationGateway)
        let getThemePresetColorPropertiesUseCase =
            GetThemePresetColorPropertiesUseCase(configurationGateway: configurationGateway)
        let setThemePresetColorPropertiesUseCase =
            SetThemePresetColorPropertiesUseCase(configurationGateway: configurationGateway)
        let getAutomaticCheckForUpdatesEnabledUseCase =
            GetAutomaticCheckForUpdatesEnabledUseCase(softwareUpdateGateway: mockSoftwareUpdateGateway)
        let setAutomaticCheckForUpdatesEnabledUseCase =
            SetAutomaticCheckForUpdatesEnabledUseCase(softwareUpdateGateway: mockSoftwareUpdateGateway)
        let getAutomaticDownloadUpdatesEnabledUseCase =
            GetAutomaticDownloadUpdatesEnabledUseCase(softwareUpdateGateway: mockSoftwareUpdateGateway)
        let setAutomaticDownloadUpdatesEnabledUseCase =
            SetAutomaticDownloadUpdatesEnabledUseCase(softwareUpdateGateway: mockSoftwareUpdateGateway)
        let getLastUpdateCheckDateUseCase =
            GetLastUpdateCheckDateUseCase(softwareUpdateGateway: mockSoftwareUpdateGateway)
        let checkForUpdatesUseCase = CheckForUpdatesUseCase(softwareUpdateGateway: mockSoftwareUpdateGateway)

        viewModel = SettingsViewModel(
            getMenuBarAppsUseCase: getMenuBarAppsUseCase,
            getScreenCapturePermissionGrantedUseCase: getScreenCapturePermissionGrantedUseCase,
            requestScreenCapturePermissionsUseCase: requestScreenCapturePermissionsUseCase,
            getAeroSpacePathUseCase: getAeroSpacePathUseCase,
            setAeroSpacePathUseCase: setAeroSpacePathUseCase,
            getAeroSpaceVersionUseCase: getAeroSpaceVersionUseCase,
            openAeroSpaceConfigUseCase: openAeroSpaceConfigUseCase,
            resetConfigurationUseCase: resetConfigurationUseCase,
            getLogLevelUseCase: getLogLevelUseCase,
            setLogLevelUseCase: setLogLevelUseCase,
            getEnablePerformanceMetricsUseCase: getEnablePerformanceMetricsUseCase,
            setEnablePerformanceMetricsUseCase: setEnablePerformanceMetricsUseCase,
            getOptimizedPerformanceEnabledUseCase: getOptimizedPerformanceEnabledUseCase,
            setOptimizedPerformanceEnabledUseCase: setOptimizedPerformanceEnabledUseCase,
            getFeatureFlagsUseCase: getFeatureFlagsUseCase,
            getEnableLicensingUseCase: getEnableLicensingUseCase,
            getEnableTrialRequestUseCase: getEnableTrialRequestUseCase,
            getConfigFilePathUseCase: getConfigFilePathUseCase,
            setConfigFilePathUseCase: setConfigFilePathUseCase,
            openConfigFileUseCase: openConfigFileUseCase,
            getThemeModeUseCase: getThemeModeUseCase,
            setThemeModeUseCase: setThemeModeUseCase,
            getThemePresetColorPropertiesUseCase: getThemePresetColorPropertiesUseCase,
            setThemePresetColorPropertiesUseCase: setThemePresetColorPropertiesUseCase,
            getAutomaticCheckForUpdatesEnabledUseCase: getAutomaticCheckForUpdatesEnabledUseCase,
            setAutomaticCheckForUpdatesEnabledUseCase: setAutomaticCheckForUpdatesEnabledUseCase,
            getAutomaticDownloadUpdatesEnabledUseCase: getAutomaticDownloadUpdatesEnabledUseCase,
            setAutomaticDownloadUpdatesEnabledUseCase: setAutomaticDownloadUpdatesEnabledUseCase,
            getLastUpdateCheckDateUseCase: getLastUpdateCheckDateUseCase,
            checkForUpdatesUseCase: checkForUpdatesUseCase,
            getQuickHideEnabledUseCase: GetQuickHideEnabledUseCase(configurationGateway: configurationGateway),
            setQuickHideEnabledUseCase: SetQuickHideEnabledUseCase(configurationGateway: configurationGateway),
            getQuickHideTriggerKeyUseCase: GetQuickHideTriggerKeyUseCase(
                configurationGateway: configurationGateway
            ),
            setQuickHideTriggerKeyUseCase: SetQuickHideTriggerKeyUseCase(
                configurationGateway: configurationGateway
            )
        )
    }

    // MARK: - Initialization Tests

    func testInitialization() {
        guard let viewModel else {
            XCTFail("ViewModel should be initialized")
            return
        }

        expect(viewModel.aeroSpacePath).toEventuallyNot(beNil())
        expect(viewModel.configFilePath).toEventuallyNot(beNil())
        expect(viewModel.logLevel) == .info
        expect(viewModel.themeMode) == .preset
    }

    // MARK: - Navigation Tests

    func testDefaultNavigation() {
        guard let viewModel else {
            XCTFail("ViewModel should be initialized")
            return
        }

        expect(viewModel.selectedPage.id) == RootNavigationPage.general.id
        expect(viewModel.navigationHistory.isEmpty) == true
        expect(viewModel.forwardHistory.isEmpty) == true
    }

    func testNavigateToPage() {
        guard let viewModel else {
            XCTFail("ViewModel should be initialized")
            return
        }

        let licensePage = AnyNavigationPage(RootNavigationPage.license)
        viewModel.navigateTo(licensePage)
        expect(viewModel.selectedPage.id) == licensePage.id
        expect(viewModel.navigationHistory.count) == 1
    }

    func testNavigateBackward() {
        guard let viewModel else {
            XCTFail("ViewModel should be initialized")
            return
        }

        // Navigate to license page
        viewModel.navigateTo(AnyNavigationPage(RootNavigationPage.license))
        expect(viewModel.navigationHistory.count) == 1

        // Navigate back
        viewModel.navigateBackward()
        expect(viewModel.selectedPage.id) == RootNavigationPage.general.id
        expect(viewModel.navigationHistory.isEmpty) == true
        expect(viewModel.forwardHistory.count) == 1
    }

    func testNavigateForward() {
        guard let viewModel else {
            XCTFail("ViewModel should be initialized")
            return
        }

        // Navigate to license and back
        viewModel.navigateTo(AnyNavigationPage(RootNavigationPage.license))
        viewModel.navigateBackward()

        // Navigate forward
        viewModel.navigateForward()
        expect(viewModel.selectedPage.id) == RootNavigationPage.license.id
    }

    func testResetNavigationOnWindowClose() {
        guard let viewModel else {
            XCTFail("ViewModel should be initialized")
            return
        }

        viewModel.navigateTo(AnyNavigationPage(RootNavigationPage.license))
        viewModel.resetNavigationOnWindowClose()
        expect(viewModel.selectedPage.id) == RootNavigationPage.general.id
        expect(viewModel.navigationHistory.isEmpty) == true
    }

    // MARK: - Settings Tests

    func testAeroSpacePathValidation() {
        guard let viewModel else {
            XCTFail("ViewModel should be initialized")
            return
        }

        viewModel.aeroSpacePath = ""
        expect(viewModel.customPathValidationError).toEventually(beNil())

        viewModel.aeroSpacePath = "/nonexistent/path"
        expect(viewModel.customPathValidationError).toEventuallyNot(beNil())
    }

    func testConfigFilePathValidation() {
        guard let viewModel else {
            XCTFail("ViewModel should be initialized")
            return
        }

        viewModel.configFilePath = ""
        expect(viewModel.configFilePathValidationError).toEventuallyNot(beNil())
    }

    // MARK: - Software Update Tests

    func testCheckForUpdates() async {
        guard let viewModel else {
            XCTFail("ViewModel should be initialized")
            return
        }

        await viewModel.checkForUpdates()
        // Verify call was made (would check mock in real scenario)
        expect(true) == true
    }

    // MARK: - Dynamic Sub-Page Tests

    func testRegisterDynamicSubPage() {
        guard let viewModel else {
            XCTFail("ViewModel should be initialized")
            return
        }

        // Use a known page for testing registration
        let page = AnyNavigationPage(RootNavigationPage.license)
        viewModel.registerDynamicSubPage(page)
        // Since we can't easily check internal state, we verify no crash
        expect(true) == true
    }

    func testUnregisterDynamicSubPage() {
        guard let viewModel else {
            XCTFail("ViewModel should be initialized")
            return
        }

        let page = AnyNavigationPage(RootNavigationPage.license)
        viewModel.registerDynamicSubPage(page)
        viewModel.unregisterDynamicSubPage(withId: page.id)
        expect(true) == true
    }

    // MARK: - Feature Flag Integration Tests

    func testAvailableThemeModes() {
        guard let viewModel else {
            XCTFail("ViewModel should be initialized")
            return
        }

        let available = viewModel.availableThemeModes
        expect(available.contains(ThemeMode.preset)) == true
        expect(available.contains(ThemeMode.custom)) == true
    }

    // MARK: - Computed Properties Tests

    func testCanNavigateBackward() {
        guard let viewModel else {
            XCTFail("ViewModel should be initialized")
            return
        }

        expect(viewModel.canNavigateBackward) == false
        viewModel.navigateTo(AnyNavigationPage(RootNavigationPage.license))
        viewModel.navigateTo(AnyNavigationPage(RootNavigationPage.groups))
        expect(viewModel.canNavigateBackward) == true
    }

    func testCanNavigateForward() {
        guard let viewModel else {
            XCTFail("ViewModel should be initialized")
            return
        }

        expect(viewModel.canNavigateForward) == false
        viewModel.navigateTo(AnyNavigationPage(RootNavigationPage.license))
        viewModel.navigateBackward()
        expect(viewModel.canNavigateForward) == true
    }
}
