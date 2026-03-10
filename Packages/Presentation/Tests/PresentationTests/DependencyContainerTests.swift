// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Nimble
@testable import Presentation
import XCTest

@MainActor
final class DependencyContainerTests: XCTestCase {
    private var container: DependencyContainer?

    override func setUp() async throws {
        try await super.setUp()
        container = DependencyContainer.shared
    }

    override func tearDown() async throws {
        container = nil
        try await super.tearDown()
    }

    // MARK: - Singleton Tests

    func testDependencyContainerSingleton() {
        // Given DependencyContainer class
        // When accessing shared instance
        let instance1 = DependencyContainer.shared
        let instance2 = DependencyContainer.shared

        // Then should return same instance
        expect(instance1) === instance2
    }

    // MARK: - ViewModel Getter Tests

    func testGetAppViewModel() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When getting AppViewModel
        let viewModel = container.getAppViewModel()

        // Then should return valid instance
        expect(viewModel).toNot(beNil())
    }

    func testGetSettingsViewModel() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When getting SettingsViewModel
        let viewModel = container.getSettingsViewModel()

        // Then should return valid instance
        expect(viewModel).toNot(beNil())
    }

    func testGetSpacesViewModel() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When getting SpacesViewModel
        let viewModel = container.getSpacesViewModel()

        // Then should return valid instance
        expect(viewModel).toNot(beNil())
    }

    func testGetGroupsViewModel() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When getting GroupsViewModel
        let viewModel = container.getGroupsViewModel()

        // Then should return valid instance
        expect(viewModel).toNot(beNil())
    }

    func testGetLicenseViewModel() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When getting LicenseViewModel
        let viewModel = container.getLicenseViewModel()

        // Then should return valid instance
        expect(viewModel).toNot(beNil())
    }

    func testViewModelsSingleton() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When getting same ViewModel twice
        let viewModel1 = container.getAppViewModel()
        let viewModel2 = container.getAppViewModel()

        // Then should return same instance (lazy singleton)
        expect(viewModel1) === viewModel2
    }

    // MARK: - Spaces Use Case Factory Tests

    func testMakeGetSpacesUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating GetSpacesUseCase
        let useCase = container.makeGetSpacesUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeSetFocusSpaceUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating SetFocusSpaceUseCase
        let useCase = container.makeSetFocusSpaceUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeSetFocusWindowUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating SetFocusWindowUseCase
        let useCase = container.makeSetFocusWindowUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeGetAeroSpaceStatusUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating GetAeroSpaceStatusUseCase
        let useCase = container.makeGetAeroSpaceStatusUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeStartAeroSpaceUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating StartAeroSpaceUseCase
        let useCase = container.makeStartAeroSpaceUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeGetAeroSpaceVersionUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating GetAeroSpaceVersionUseCase
        let useCase = container.makeGetAeroSpaceVersionUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    // MARK: - Wallpaper Use Case Factory Tests

    func testMakeGetWallpaperUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating GetWallpaperUseCase
        let useCase = container.makeGetWallpaperUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeGetMenuBarAppsUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating GetMenuBarAppsUseCase
        let useCase = container.makeGetMenuBarAppsUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeGetScreenCapturePermissionGrantedUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating GetScreenCapturePermissionGrantedUseCase
        let useCase = container.makeGetScreenCapturePermissionGrantedUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeRequestScreenCapturePermissionsUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating RequestScreenCapturePermissionsUseCase
        let useCase = container.makeRequestScreenCapturePermissionsUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    // MARK: - Display Use Case Factory Tests

    func testMakeGetFocusWindowOnClickUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating GetFocusWindowOnClickUseCase
        let useCase = container.makeGetFocusWindowOnClickUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeSetFocusWindowOnClickUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating SetFocusWindowOnClickUseCase
        let useCase = container.makeSetFocusWindowOnClickUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeGetShowEmptySpacesUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating GetShowEmptySpacesUseCase
        let useCase = container.makeGetShowEmptySpacesUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeSetShowEmptySpacesUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating SetShowEmptySpacesUseCase
        let useCase = container.makeSetShowEmptySpacesUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeGetShowGroupsUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating GetShowGroupsUseCase
        let useCase = container.makeGetShowGroupsUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeSetShowGroupsUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating SetShowGroupsUseCase
        let useCase = container.makeSetShowGroupsUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    // MARK: - Spaces Visual Properties Use Case Factory Tests

    func testMakeGetSpacesColorPropertiesUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating GetSpacesColorPropertiesUseCase
        let useCase = container.makeGetSpacesColorPropertiesUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeSetSpacesColorPropertiesUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating SetSpacesColorPropertiesUseCase
        let useCase = container.makeSetSpacesColorPropertiesUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeGetSpacesGeometricPropertiesUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating GetSpacesGeometricPropertiesUseCase
        let useCase = container.makeGetSpacesGeometricPropertiesUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeSetSpacesGeometricPropertiesUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating SetSpacesGeometricPropertiesUseCase
        let useCase = container.makeSetSpacesGeometricPropertiesUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeGetSpacesAppearanceModeUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating GetSpacesAppearanceModeUseCase
        let useCase = container.makeGetSpacesAppearanceModeUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeSetSpacesAppearanceModeUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating SetSpacesAppearanceModeUseCase
        let useCase = container.makeSetSpacesAppearanceModeUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeGetGlobalSpacesColorPropertiesUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating GetGlobalSpacesColorPropertiesUseCase
        let useCase = container.makeGetGlobalSpacesColorPropertiesUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeSetGlobalSpacesColorPropertiesUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating SetGlobalSpacesColorPropertiesUseCase
        let useCase = container.makeSetGlobalSpacesColorPropertiesUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeGetGlobalSpacesGeometricPropertiesUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating GetGlobalSpacesGeometricPropertiesUseCase
        let useCase = container.makeGetGlobalSpacesGeometricPropertiesUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeSetGlobalSpacesGeometricPropertiesUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating SetGlobalSpacesGeometricPropertiesUseCase
        let useCase = container.makeSetGlobalSpacesGeometricPropertiesUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeGetSpacesEffectPropertiesUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating GetSpacesEffectPropertiesUseCase
        let useCase = container.makeGetSpacesEffectPropertiesUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeSetSpacesEffectPropertiesUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating SetSpacesEffectPropertiesUseCase
        let useCase = container.makeSetSpacesEffectPropertiesUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeGetGlobalSpacesEffectPropertiesUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating GetGlobalSpacesEffectPropertiesUseCase
        let useCase = container.makeGetGlobalSpacesEffectPropertiesUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeSetGlobalSpacesEffectPropertiesUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating SetGlobalSpacesEffectPropertiesUseCase
        let useCase = container.makeSetGlobalSpacesEffectPropertiesUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    // MARK: - Groups Use Case Factory Tests

    func testMakeGetGroupsUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating GetGroupsUseCase
        let useCase = container.makeGetGroupsUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeSetGroupsUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating SetGroupsUseCase
        let useCase = container.makeSetGroupsUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeGetGroupsAppearanceModeUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating GetGroupsAppearanceModeUseCase
        let useCase = container.makeGetGroupsAppearanceModeUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeSetGroupsAppearanceModeUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating SetGroupsAppearanceModeUseCase
        let useCase = container.makeSetGroupsAppearanceModeUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeGetGlobalGroupsColorPropertiesUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating GetGlobalGroupsColorPropertiesUseCase
        let useCase = container.makeGetGlobalGroupsColorPropertiesUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeSetGlobalGroupsColorPropertiesUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating SetGlobalGroupsColorPropertiesUseCase
        let useCase = container.makeSetGlobalGroupsColorPropertiesUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeGetGlobalGroupsGeometricPropertiesUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating GetGlobalGroupsGeometricPropertiesUseCase
        let useCase = container.makeGetGlobalGroupsGeometricPropertiesUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeSetGlobalGroupsGeometricPropertiesUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating SetGlobalGroupsGeometricPropertiesUseCase
        let useCase = container.makeSetGlobalGroupsGeometricPropertiesUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeGetGlobalGroupsEffectPropertiesUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating GetGlobalGroupsEffectPropertiesUseCase
        let useCase = container.makeGetGlobalGroupsEffectPropertiesUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeSetGlobalGroupsEffectPropertiesUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating SetGlobalGroupsEffectPropertiesUseCase
        let useCase = container.makeSetGlobalGroupsEffectPropertiesUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    // MARK: - Theme Use Case Factory Tests

    func testMakeGetThemeModeUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating GetThemeModeUseCase
        let useCase = container.makeGetThemeModeUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeSetThemeModeUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating SetThemeModeUseCase
        let useCase = container.makeSetThemeModeUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeGetThemePresetColorPropertiesUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating GetThemePresetColorPropertiesUseCase
        let useCase = container.makeGetThemePresetColorPropertiesUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeSetThemePresetColorPropertiesUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating SetThemePresetColorPropertiesUseCase
        let useCase = container.makeSetThemePresetColorPropertiesUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeGetThemePresetGeometricPropertiesUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating GetThemePresetGeometricPropertiesUseCase
        let useCase = container.makeGetThemePresetGeometricPropertiesUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeSetThemePresetGeometricPropertiesUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating SetThemePresetGeometricPropertiesUseCase
        let useCase = container.makeSetThemePresetGeometricPropertiesUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeGetThemePresetEffectPropertiesUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating GetThemePresetEffectPropertiesUseCase
        let useCase = container.makeGetThemePresetEffectPropertiesUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeSetThemePresetEffectPropertiesUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating SetThemePresetEffectPropertiesUseCase
        let useCase = container.makeSetThemePresetEffectPropertiesUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    // MARK: - AeroSpace Use Case Factory Tests

    func testMakeGetAeroSpacePathUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating GetAeroSpacePathUseCase
        let useCase = container.makeGetAeroSpacePathUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeSetAeroSpaceCustomPathUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating SetAeroSpacePathUseCase
        let useCase = container.makeSetAeroSpaceCustomPathUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeOpenAeroSpaceConfigUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating OpenAeroSpaceConfigUseCase
        let useCase = container.makeOpenAeroSpaceConfigUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeGetAeroSpaceConfigPathUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating GetAeroSpaceConfigPathUseCase
        let useCase = container.makeGetAeroSpaceConfigPathUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeResetConfigurationUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating ResetConfigurationUseCase
        let useCase = container.makeResetConfigurationUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeGetConfigFilePathUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating GetConfigFilePathUseCase
        let useCase = container.makeGetConfigFilePathUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeSetConfigFilePathUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating SetConfigFilePathUseCase
        let useCase = container.makeSetConfigFilePathUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeOpenConfigFileUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating OpenConfigFileUseCase
        let useCase = container.makeOpenConfigFileUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeGetHasAskedForScreenCapturePermissionsUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating GetHasAskedForScreenCapturePermissionsUseCase
        let useCase = container.makeGetHasAskedForScreenCapturePermissionsUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeSetHasAskedForScreenCapturePermissionsUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating SetHasAskedForScreenCapturePermissionsUseCase
        let useCase = container.makeSetHasAskedForScreenCapturePermissionsUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    // MARK: - System Use Case Factory Tests

    func testMakeGetEnablePerformanceMetricsUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating GetEnablePerformanceMetricsUseCase
        let useCase = container.makeGetEnablePerformanceMetricsUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeSetEnablePerformanceMetricsUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating SetEnablePerformanceMetricsUseCase
        let useCase = container.makeSetEnablePerformanceMetricsUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeGetOptimizedPerformanceEnabledUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating GetOptimizedPerformanceEnabledUseCase
        let useCase = container.makeGetOptimizedPerformanceEnabledUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeSetOptimizedPerformanceEnabledUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating SetOptimizedPerformanceEnabledUseCase
        let useCase = container.makeSetOptimizedPerformanceEnabledUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeGetLogLevelUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating GetLogLevelUseCase
        let useCase = container.makeGetLogLevelUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeSetLogLevelUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating SetLogLevelUseCase
        let useCase = container.makeSetLogLevelUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeGetShowWindowTitlesUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating GetShowWindowTitlesUseCase
        let useCase = container.makeGetShowWindowTitlesUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeSetShowWindowTitlesUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating SetShowWindowTitlesUseCase
        let useCase = container.makeSetShowWindowTitlesUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    // MARK: - UI Configuration Use Case Factory Tests

    func testMakeGetMenuBarHeightUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating GetMenuBarHeightUseCase
        let useCase = container.makeGetMenuBarHeightUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    // MARK: - System State Use Case Factory Tests

    func testMakeGetMenuBarVisibilityUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating GetMenuBarVisibilityUseCase
        let useCase = container.makeGetMenuBarVisibilityUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    // MARK: - Keyboard Shortcuts Use Case Factory Tests

    func testMakeGetQuickHideTriggerKeyPressStateUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating GetQuickHideTriggerKeyPressStateUseCase
        let useCase = container.makeGetQuickHideTriggerKeyPressStateUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    // MARK: - Feature Flags Use Case Factory Tests

    func testMakeGetFeatureFlagsUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating GetFeatureFlagsUseCase
        let useCase = container.makeGetFeatureFlagsUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    // MARK: - License Feature Flags Use Case Factory Tests

    func testMakeGetEnableLicensingUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating GetEnableLicensingUseCase
        let useCase = container.makeGetEnableLicensingUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeSetEnableLicensingUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating SetEnableLicensingUseCase
        let useCase = container.makeSetEnableLicensingUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeGetEnableTrialRequestUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating GetEnableTrialRequestUseCase
        let useCase = container.makeGetEnableTrialRequestUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeSetEnableTrialRequestUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating SetEnableTrialRequestUseCase
        let useCase = container.makeSetEnableTrialRequestUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeResetLicenseFeatureFlagsUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating ResetLicenseFeatureFlagsUseCase
        let useCase = container.makeResetLicenseFeatureFlagsUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    // MARK: - License Use Case Factory Tests

    func testMakeGetLicenseInfoUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating GetLicenseInfoUseCase
        let useCase = container.makeGetLicenseInfoUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeActivateLicenseUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating ActivateLicenseUseCase
        let useCase = container.makeActivateLicenseUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeOpenCheckoutUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating OpenCheckoutUseCase
        let useCase = container.makeOpenCheckoutUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeDeactivateLicenseUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating DeactivateLicenseUseCase
        let useCase = container.makeDeactivateLicenseUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeSetUserNameUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating SetUserNameUseCase
        let useCase = container.makeSetUserNameUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeSetProfileImageDataUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating SetProfileImageDataUseCase
        let useCase = container.makeSetProfileImageDataUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeHasTrialBeenUsedUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating HasTrialBeenUsedUseCase
        let useCase = container.makeHasTrialBeenUsedUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    // MARK: - Software Update Use Case Factory Tests

    func testMakeGetAutomaticCheckForUpdatesEnabledUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating GetAutomaticCheckForUpdatesEnabledUseCase
        let useCase = container.makeGetAutomaticCheckForUpdatesEnabledUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeSetAutomaticCheckForUpdatesEnabledUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating SetAutomaticCheckForUpdatesEnabledUseCase
        let useCase = container.makeSetAutomaticCheckForUpdatesEnabledUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeGetAutomaticDownloadUpdatesEnabledUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating GetAutomaticDownloadUpdatesEnabledUseCase
        let useCase = container.makeGetAutomaticDownloadUpdatesEnabledUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeSetAutomaticDownloadUpdatesEnabledUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating SetAutomaticDownloadUpdatesEnabledUseCase
        let useCase = container.makeSetAutomaticDownloadUpdatesEnabledUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeGetLastUpdateCheckDateUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating GetLastUpdateCheckDateUseCase
        let useCase = container.makeGetLastUpdateCheckDateUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }

    func testMakeCheckForUpdatesUseCase() {
        guard let container else {
            fail("Container not initialized")
            return
        }

        // When creating CheckForUpdatesUseCase
        let useCase = container.makeCheckForUpdatesUseCase()

        // Then should return valid instance
        expect(useCase).toNot(beNil())
    }
}
