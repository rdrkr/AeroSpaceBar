// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import AppKit
import Data
import Domain

// Dependency injection container for managing service dependencies.
//
// This class provides a centralized container for managing all service dependencies
// in the application. It uses lazy initialization to ensure services are only created
// when needed and provides a clean interface for accessing dependencies.
// It runs on the main actor for thread safety.

@MainActor
public final class DependencyContainer {
    /// The shared instance of the dependency container.
    public static let shared = DependencyContainer()

    // Private initializer to enforce singleton pattern.

    private init() { }

    // MARK: - Repositories

    /// The spaces gateway for managing AeroSpace interactions.
    ///
    /// This service is lazily initialized and provides access to spaces data
    /// and window management functionality.
    private lazy var spacesGateway: SpacesGateway = AeroSpaceRepository(
        iconCache: iconCache,
        getAeroSpacePathUseCase: makeGetAeroSpacePathUseCase(),
        getAeroSpaceConfigPathUseCase: makeGetAeroSpaceConfigPathUseCase(),
        getOptimizedPerformanceEnabledUseCase: makeGetOptimizedPerformanceEnabledUseCase(),
        getSpacesColorPropertiesUseCase: makeGetSpacesColorPropertiesUseCase()
    )

    /// The configuration gateway for managing application settings.
    ///
    /// This service is lazily initialized and provides access to configuration
    /// settings and user preferences.
    private lazy var configurationGateway: ConfigurationGateway = ConfigurationRepository()

    /// The icon cache gateway for storing application icons.
    ///
    /// This service is lazily initialized and provides cached access to
    /// application icons for improved performance.
    private lazy var iconCache: IconCache = .init()

    /// The system menu bar gateway for capturing wallpaper and tracking menu bar state.
    ///
    /// This gateway is lazily initialized and provides dynamic capture of
    /// the desktop wallpaper and monitoring of menu bar visibility and height.
    private lazy var systemMenuBarGateway: SystemMenuBarGateway = SystemMenuBarRepository(
        getShowGroupsUseCase: makeGetShowGroupsUseCase(),
        getHasAskedForScreenCapturePermissionsUseCase: makeGetHasAskedForScreenCapturePermissionsUseCase(),
        setHasAskedForScreenCapturePermissionsUseCase: makeSetHasAskedForScreenCapturePermissionsUseCase()
    )

    /// The keyboard shortcuts gateway for monitoring keyboard events.
    ///
    /// This gateway is lazily initialized and provides monitoring of
    /// keyboard shortcuts and key press states.
    private lazy var keyboardShortcutsGateway: KeyboardShortcutsGateway = KeyboardShortcutsRepository()

    /// The AppViewModel instance.
    private lazy var appViewModel: AppViewModel = .init(
        getGlobeKeyPressStateUseCase: makeGetGlobeKeyPressStateUseCase()
    )

    /// The SettingsViewModel instance.
    private lazy var settingsViewModel: SettingsViewModel = .init(
        getMenuBarAppsUseCase: makeGetMenuBarAppsUseCase(),
        getScreenCapturePermissionGrantedUseCase: makeGetScreenCapturePermissionGrantedUseCase(),
        requestScreenCapturePermissionsUseCase: makeRequestScreenCapturePermissionsUseCase(),
        getAeroSpacePathUseCase: makeGetAeroSpacePathUseCase(),
        setAeroSpacePathUseCase: makeSetAeroSpaceCustomPathUseCase(),
        getAeroSpaceVersionUseCase: makeGetAeroSpaceVersionUseCase(),
        openAeroSpaceConfigUseCase: makeOpenAeroSpaceConfigUseCase(),
        resetConfigurationUseCase: makeResetConfigurationUseCase(),
        getLogLevelUseCase: makeGetLogLevelUseCase(),
        setLogLevelUseCase: makeSetLogLevelUseCase(),
        getEnablePerformanceMetricsUseCase: makeGetEnablePerformanceMetricsUseCase(),
        setEnablePerformanceMetricsUseCase: makeSetEnablePerformanceMetricsUseCase(),
        getOptimizedPerformanceEnabledUseCase: makeGetOptimizedPerformanceEnabledUseCase(),
        setOptimizedPerformanceEnabledUseCase: makeSetOptimizedPerformanceEnabledUseCase(),
        getFeatureFlagsUseCase: makeGetFeatureFlagsUseCase(),
        getEnableLicensingUseCase: makeGetEnableLicensingUseCase(),
        getEnableTrialRequestUseCase: makeGetEnableTrialRequestUseCase(),
        getConfigFilePathUseCase: makeGetConfigFilePathUseCase(),
        setConfigFilePathUseCase: makeSetConfigFilePathUseCase(),
        openConfigFileUseCase: makeOpenConfigFileUseCase(),
        getThemeModeUseCase: makeGetThemeModeUseCase(),
        setThemeModeUseCase: makeSetThemeModeUseCase(),
        getThemePresetColorPropertiesUseCase: makeGetThemePresetColorPropertiesUseCase(),
        setThemePresetColorPropertiesUseCase: makeSetThemePresetColorPropertiesUseCase(),
        getAutomaticCheckForUpdatesEnabledUseCase: makeGetAutomaticCheckForUpdatesEnabledUseCase(),
        setAutomaticCheckForUpdatesEnabledUseCase: makeSetAutomaticCheckForUpdatesEnabledUseCase(),
        getAutomaticDownloadUpdatesEnabledUseCase: makeGetAutomaticDownloadUpdatesEnabledUseCase(),
        setAutomaticDownloadUpdatesEnabledUseCase: makeSetAutomaticDownloadUpdatesEnabledUseCase(),
        getLastUpdateCheckDateUseCase: makeGetLastUpdateCheckDateUseCase(),
        checkForUpdatesUseCase: makeCheckForUpdatesUseCase()
    )

    /// The SpacesViewModel instance.
    private lazy var spacesViewModel: SpacesViewModel = .init(
        getSpacesUseCase: makeGetSpacesUseCase(),
        setFocusSpaceUseCase: makeSetFocusSpaceUseCase(),
        setFocusWindowUseCase: makeSetFocusWindowUseCase(),
        getAeroSpaceStatusUseCase: makeGetAeroSpaceStatusUseCase(),
        startAeroSpaceUseCase: makeStartAeroSpaceUseCase(),
        getShowWindowTitlesUseCase: makeGetShowWindowTitlesUseCase(),
        setShowWindowTitlesUseCase: makeSetShowWindowTitlesUseCase(),
        getFocusWindowOnClickUseCase: makeGetFocusWindowOnClickUseCase(),
        setFocusWindowOnClickUseCase: makeSetFocusWindowOnClickUseCase(),
        getShowEmptySpacesUseCase: makeGetShowEmptySpacesUseCase(),
        setShowEmptySpacesUseCase: makeSetShowEmptySpacesUseCase(),
        getWallpaperUseCase: makeGetWallpaperUseCase(),
        getMenuBarVisibilityUseCase: makeGetMenuBarVisibilityUseCase(),
        getMenuBarHeightUseCase: makeGetMenuBarHeightUseCase(),
        getFeatureFlagsUseCase: makeGetFeatureFlagsUseCase(),
        getSpacesAppearanceModeUseCase: makeGetSpacesAppearanceModeUseCase(),
        setSpacesAppearanceModeUseCase: makeSetSpacesAppearanceModeUseCase(),
        getGlobalSpacesColorPropertiesUseCase: makeGetGlobalSpacesColorPropertiesUseCase(),
        setGlobalSpacesColorPropertiesUseCase: makeSetGlobalSpacesColorPropertiesUseCase(),
        getGlobalSpacesGeometricPropertiesUseCase: makeGetGlobalSpacesGeometricPropertiesUseCase(),
        setGlobalSpacesGeometricPropertiesUseCase: makeSetGlobalSpacesGeometricPropertiesUseCase(),
        getGlobalSpacesEffectPropertiesUseCase: makeGetGlobalSpacesEffectPropertiesUseCase(),
        setGlobalSpacesEffectPropertiesUseCase: makeSetGlobalSpacesEffectPropertiesUseCase(),
        getSpacesColorPropertiesUseCase: makeGetSpacesColorPropertiesUseCase(),
        setSpacesColorPropertiesUseCase: makeSetSpacesColorPropertiesUseCase(),
        getSpacesGeometricPropertiesUseCase: makeGetSpacesGeometricPropertiesUseCase(),
        setSpacesGeometricPropertiesUseCase: makeSetSpacesGeometricPropertiesUseCase(),
        getSpacesEffectPropertiesUseCase: makeGetSpacesEffectPropertiesUseCase(),
        setSpacesEffectPropertiesUseCase: makeSetSpacesEffectPropertiesUseCase(),
        getThemeModeUseCase: makeGetThemeModeUseCase(),
        getThemePresetColorPropertiesUseCase: makeGetThemePresetColorPropertiesUseCase(),
        getThemePresetGeometricPropertiesUseCase: makeGetThemePresetGeometricPropertiesUseCase(),
        setThemePresetGeometricPropertiesUseCase: makeSetThemePresetGeometricPropertiesUseCase(),
        getThemePresetEffectPropertiesUseCase: makeGetThemePresetEffectPropertiesUseCase(),
        setThemePresetEffectPropertiesUseCase: makeSetThemePresetEffectPropertiesUseCase(),
        getGlobeKeyPressStateUseCase: makeGetGlobeKeyPressStateUseCase()
    )

    /// The LicenseViewModel instance.
    private lazy var licenseViewModel: LicenseViewModel = .init(
        getLicenseInfoUseCase: makeGetLicenseInfoUseCase(),
        activateLicenseUseCase: makeActivateLicenseUseCase(),
        openCheckoutUseCase: makeOpenCheckoutUseCase(),
        deactivateLicenseUseCase: makeDeactivateLicenseUseCase(),
        getEnableLicensingUseCase: makeGetEnableLicensingUseCase(),
        getEnableTrialRequestUseCase: makeGetEnableTrialRequestUseCase(),
        setUserNameUseCase: makeSetUserNameUseCase(),
        setProfileImageDataUseCase: makeSetProfileImageDataUseCase(),
        hasTrialBeenUsedUseCase: makeHasTrialBeenUsedUseCase()
    )

    /// The GroupsViewModel instance.
    private lazy var groupsViewModel: GroupsViewModel = .init(
        getShowGroupsUseCase: makeGetShowGroupsUseCase(),
        setShowGroupsUseCase: makeSetShowGroupsUseCase(),
        getGroupsUseCase: makeGetGroupsUseCase(),
        setGroupsUseCase: makeSetGroupsUseCase(),
        getMenuBarAppsUseCase: makeGetMenuBarAppsUseCase(),
        getFeatureFlagsUseCase: makeGetFeatureFlagsUseCase(),
        getGroupsAppearanceModeUseCase: makeGetGroupsAppearanceModeUseCase(),
        setGroupsAppearanceModeUseCase: makeSetGroupsAppearanceModeUseCase(),
        getSpacesAppearanceModeUseCase: makeGetSpacesAppearanceModeUseCase(),
        getGlobalGroupsColorPropertiesUseCase: makeGetGlobalGroupsColorPropertiesUseCase(),
        setGlobalGroupsColorPropertiesUseCase: makeSetGlobalGroupsColorPropertiesUseCase(),
        getGlobalGroupsGeometricPropertiesUseCase: makeGetGlobalGroupsGeometricPropertiesUseCase(),
        setGlobalGroupsGeometricPropertiesUseCase: makeSetGlobalGroupsGeometricPropertiesUseCase(),
        getGlobalGroupsEffectPropertiesUseCase: makeGetGlobalGroupsEffectPropertiesUseCase(),
        setGlobalGroupsEffectPropertiesUseCase: makeSetGlobalGroupsEffectPropertiesUseCase(),
        getGlobalSpacesColorPropertiesUseCase: makeGetGlobalSpacesColorPropertiesUseCase(),
        getGlobalSpacesGeometricPropertiesUseCase: makeGetGlobalSpacesGeometricPropertiesUseCase(),
        getGlobalSpacesEffectPropertiesUseCase: makeGetGlobalSpacesEffectPropertiesUseCase(),
        getThemeModeUseCase: makeGetThemeModeUseCase(),
        getThemePresetColorPropertiesUseCase: makeGetThemePresetColorPropertiesUseCase(),
        getThemePresetGeometricPropertiesUseCase: makeGetThemePresetGeometricPropertiesUseCase(),
        getThemePresetEffectPropertiesUseCase: makeGetThemePresetEffectPropertiesUseCase(),
        getMenuBarHeightUseCase: makeGetMenuBarHeightUseCase()
    )

    /// The license gateway for managing application license.
    private lazy var licenseGateway: LicenseGateway = LemonSqueezyLicenseRepository()

    /// The feature flags gateway for managing development feature toggles.
    ///
    /// This gateway is only available in debug builds and provides access to
    /// feature flags for controlling experimental and development features.
    private lazy var featureFlagsGateway: FeatureFlagsGateway = FeatureFlagsRepository(
        getLicenseInfoUseCase: makeGetLicenseInfoUseCase(),
        getEnableLicensingUseCase: makeGetEnableLicensingUseCase()
    )

    /// The software update gateway for managing application updates.
    ///
    /// This gateway provides access to update checking and automatic update settings.
    private lazy var softwareUpdateGateway: SoftwareUpdateGateway = SparkleSoftwareUpdateRepository()

    #if DEBUG
        /// The DeveloperSettingsViewModel instance for managing developer settings.
        private lazy var developerSettingsViewModel: DeveloperSettingsViewModel = .init(
            getFeatureFlagsUseCase: makeGetFeatureFlagsUseCase(),
            setFeatureFlagsUseCase: makeSetFeatureFlagsUseCase(),
            getEnableLicensingUseCase: makeGetEnableLicensingUseCase(),
            setEnableLicensingUseCase: makeSetEnableLicensingUseCase(),
            getEnableTrialRequestUseCase: makeGetEnableTrialRequestUseCase(),
            setEnableTrialRequestUseCase: makeSetEnableTrialRequestUseCase(),
            getMockActiveLicenseUseCase: makeGetMockActiveLicenseUseCase(),
            setMockActiveLicenseUseCase: makeSetMockActiveLicenseUseCase(),
            getCheckoutEnvironmentUseCase: makeGetCheckoutEnvironmentUseCase(),
            setCheckoutEnvironmentUseCase: makeSetCheckoutEnvironmentUseCase(),
            getLicenseInfoUseCase: makeGetLicenseInfoUseCase(),
            resetLicenseFeatureFlagsUseCase: makeResetLicenseFeatureFlagsUseCase(),
            getHasAskedForScreenCapturePermissionsUseCase: makeGetHasAskedForScreenCapturePermissionsUseCase()
        )
    #endif

    // MARK: - Public Access

    /// Gets the spaces gateway instance.
    /// - Returns: The spaces gateway protocol implementation
    func getSpacesGateway() -> SpacesGateway {
        spacesGateway
    }

    /// Gets the app view model instance.
    /// - Returns: The app view model instance
    public func getAppViewModel() -> AppViewModel {
        appViewModel
    }

    /// Gets the settings view model instance.
    /// - Returns: The settings view model instance
    public func getSettingsViewModel() -> SettingsViewModel {
        settingsViewModel
    }

    /// Gets the spaces view model instance.
    /// - Returns: The spaces view model instance
    public func getSpacesViewModel() -> SpacesViewModel {
        spacesViewModel
    }

    /// Gets the groups view model instance.
    /// - Returns: The groups view model instance
    public func getGroupsViewModel() -> GroupsViewModel {
        groupsViewModel
    }

    /// Gets the license view model instance.
    /// - Returns: The license view model instance
    public func getLicenseViewModel() -> LicenseViewModel {
        licenseViewModel
    }

    // MARK: - Spaces Use Cases

    /// Creates a new GetSpacesUseCase instance.
    /// - Returns: A new GetSpacesUseCase instance
    func makeGetSpacesUseCase() -> GetSpacesUseCase {
        GetSpacesUseCase(spacesGateway: spacesGateway)
    }

    /// Creates a new SetFocusSpaceUseCase instance.
    /// - Returns: A new SetFocusSpaceUseCase instance
    func makeSetFocusSpaceUseCase() -> SetFocusSpaceUseCase {
        SetFocusSpaceUseCase(spacesGateway: spacesGateway)
    }

    /// Creates a new SetFocusWindowUseCase instance.
    /// - Returns: A new SetFocusWindowUseCase instance
    func makeSetFocusWindowUseCase() -> SetFocusWindowUseCase {
        SetFocusWindowUseCase(spacesGateway: spacesGateway)
    }

    /// Creates a new GetAeroSpaceStatusUseCase instance.
    /// - Returns: A new GetAeroSpaceStatusUseCase instance
    func makeGetAeroSpaceStatusUseCase() -> GetAeroSpaceStatusUseCase {
        GetAeroSpaceStatusUseCase(spacesGateway: spacesGateway)
    }

    /// Creates a new StartAeroSpaceUseCase instance.
    /// - Returns: A new StartAeroSpaceUseCase instance
    func makeStartAeroSpaceUseCase() -> StartAeroSpaceUseCase {
        StartAeroSpaceUseCase(spacesGateway: spacesGateway)
    }

    /// Creates a new GetAeroSpaceVersionUseCase instance.
    /// - Returns: A new GetAeroSpaceVersionUseCase instance
    func makeGetAeroSpaceVersionUseCase() -> GetAeroSpaceVersionUseCase {
        GetAeroSpaceVersionUseCase(configurationGateway: configurationGateway)
    }

    // MARK: - Wallpaper Use Cases

    /// Creates a new GetWallpaperUseCase instance.
    /// - Returns: A new GetWallpaperUseCase instance
    func makeGetWallpaperUseCase() -> GetWallpaperUseCase {
        GetWallpaperUseCase(systemMenuBarGateway: systemMenuBarGateway)
    }

    /// Creates a new GetMenuBarAppsUseCase instance.
    /// - Returns: A new GetMenuBarAppsUseCase instance
    func makeGetMenuBarAppsUseCase() -> GetMenuBarAppsUseCase {
        GetMenuBarAppsUseCase(systemMenuBarGateway: systemMenuBarGateway)
    }

    /// Creates a new GetScreenCapturePermissionGrantedUseCase instance.
    /// - Returns: A new GetScreenCapturePermissionGrantedUseCase instance
    func makeGetScreenCapturePermissionGrantedUseCase() -> GetScreenCapturePermissionGrantedUseCase {
        GetScreenCapturePermissionGrantedUseCase(systemMenuBarGateway: systemMenuBarGateway)
    }

    /// Creates a new RequestScreenCapturePermissionsUseCase instance.
    /// - Returns: A new RequestScreenCapturePermissionsUseCase instance
    func makeRequestScreenCapturePermissionsUseCase() -> RequestScreenCapturePermissionsUseCase {
        RequestScreenCapturePermissionsUseCase(systemMenuBarGateway: systemMenuBarGateway)
    }

    // MARK: - Display Use Cases

    /// Creates a new GetFocusWindowOnClickUseCase instance.
    /// - Returns: A new GetFocusWindowOnClickUseCase instance
    func makeGetFocusWindowOnClickUseCase() -> GetFocusWindowOnClickUseCase {
        GetFocusWindowOnClickUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetFocusWindowOnClickUseCase instance.
    /// - Returns: A new SetFocusWindowOnClickUseCase instance
    func makeSetFocusWindowOnClickUseCase() -> SetFocusWindowOnClickUseCase {
        SetFocusWindowOnClickUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new GetShowEmptySpacesUseCase instance.
    /// - Returns: A new GetShowEmptySpacesUseCase instance
    func makeGetShowEmptySpacesUseCase() -> GetShowEmptySpacesUseCase {
        GetShowEmptySpacesUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetShowEmptySpacesUseCase instance.
    /// - Returns: A new SetShowEmptySpacesUseCase instance
    func makeSetShowEmptySpacesUseCase() -> SetShowEmptySpacesUseCase {
        SetShowEmptySpacesUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new GetShowGroupsUseCase instance.
    /// - Returns: A new GetShowGroupsUseCase instance
    func makeGetShowGroupsUseCase() -> GetShowGroupsUseCase {
        GetShowGroupsUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetShowGroupsUseCase instance.
    /// - Returns: A new SetShowGroupsUseCase instance
    func makeSetShowGroupsUseCase() -> SetShowGroupsUseCase {
        SetShowGroupsUseCase(configurationGateway: configurationGateway)
    }

    //////////
    /// Creates a new GetSpacesColorPropertiesUseCase instance.
    /// - Returns: A new GetSpacesColorPropertiesUseCase instance
    func makeGetSpacesColorPropertiesUseCase() -> GetSpacesColorPropertiesUseCase {
        GetSpacesColorPropertiesUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetSpacesColorPropertiesUseCase instance.
    /// - Returns: A new SetSpacesColorPropertiesUseCase instance
    func makeSetSpacesColorPropertiesUseCase() -> SetSpacesColorPropertiesUseCase {
        SetSpacesColorPropertiesUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new GetSpacesGeometricPropertiesUseCase instance.
    /// - Returns: A new GetSpacesGeometricPropertiesUseCase instance
    func makeGetSpacesGeometricPropertiesUseCase() -> GetSpacesGeometricPropertiesUseCase {
        GetSpacesGeometricPropertiesUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetSpacesGeometricPropertiesUseCase instance.
    /// - Returns: A new SetSpacesGeometricPropertiesUseCase instance
    func makeSetSpacesGeometricPropertiesUseCase() -> SetSpacesGeometricPropertiesUseCase {
        SetSpacesGeometricPropertiesUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new GetSpacesAppearanceModeUseCase instance.
    /// - Returns: A new GetSpacesAppearanceModeUseCase instance
    func makeGetSpacesAppearanceModeUseCase() -> GetSpacesAppearanceModeUseCase {
        GetSpacesAppearanceModeUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetSpacesAppearanceModeUseCase instance.
    /// - Returns: A new SetSpacesAppearanceModeUseCase instance
    func makeSetSpacesAppearanceModeUseCase() -> SetSpacesAppearanceModeUseCase {
        SetSpacesAppearanceModeUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new GetGlobalSpacesColorPropertiesUseCase instance.
    /// - Returns: A new GetGlobalSpacesColorPropertiesUseCase instance
    func makeGetGlobalSpacesColorPropertiesUseCase() -> GetGlobalSpacesColorPropertiesUseCase {
        GetGlobalSpacesColorPropertiesUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetGlobalSpacesColorPropertiesUseCase instance.
    /// - Returns: A new SetGlobalSpacesColorPropertiesUseCase instance
    func makeSetGlobalSpacesColorPropertiesUseCase() -> SetGlobalSpacesColorPropertiesUseCase {
        SetGlobalSpacesColorPropertiesUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new GetGlobalSpacesGeometricPropertiesUseCase instance.
    /// - Returns: A new GetGlobalSpacesGeometricPropertiesUseCase instance
    func makeGetGlobalSpacesGeometricPropertiesUseCase() -> GetGlobalSpacesGeometricPropertiesUseCase {
        GetGlobalSpacesGeometricPropertiesUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetGlobalSpacesGeometricPropertiesUseCase instance.
    /// - Returns: A new SetGlobalSpacesGeometricPropertiesUseCase instance
    func makeSetGlobalSpacesGeometricPropertiesUseCase() -> SetGlobalSpacesGeometricPropertiesUseCase {
        SetGlobalSpacesGeometricPropertiesUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new GetSpacesEffectPropertiesUseCase instance.
    /// - Returns: A new GetSpacesEffectPropertiesUseCase instance
    func makeGetSpacesEffectPropertiesUseCase() -> GetSpacesEffectPropertiesUseCase {
        GetSpacesEffectPropertiesUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetSpacesEffectPropertiesUseCase instance.
    /// - Returns: A new SetSpacesEffectPropertiesUseCase instance
    func makeSetSpacesEffectPropertiesUseCase() -> SetSpacesEffectPropertiesUseCase {
        SetSpacesEffectPropertiesUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new GetGlobalSpacesEffectPropertiesUseCase instance.
    /// - Returns: A new GetGlobalSpacesEffectPropertiesUseCase instance
    func makeGetGlobalSpacesEffectPropertiesUseCase() -> GetGlobalSpacesEffectPropertiesUseCase {
        GetGlobalSpacesEffectPropertiesUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetGlobalSpacesEffectPropertiesUseCase instance.
    /// - Returns: A new SetGlobalSpacesEffectPropertiesUseCase instance
    func makeSetGlobalSpacesEffectPropertiesUseCase() -> SetGlobalSpacesEffectPropertiesUseCase {
        SetGlobalSpacesEffectPropertiesUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new GetGroupsUseCase instance.
    /// - Returns: A new GetGroupsUseCase instance
    func makeGetGroupsUseCase() -> GetGroupsUseCase {
        GetGroupsUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetGroupsUseCase instance.
    /// - Returns: A new SetGroupsUseCase instance
    func makeSetGroupsUseCase() -> SetGroupsUseCase {
        SetGroupsUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new GetGroupsAppearanceModeUseCase instance.
    /// - Returns: A new GetGroupsAppearanceModeUseCase instance
    func makeGetGroupsAppearanceModeUseCase() -> GetGroupsAppearanceModeUseCase {
        GetGroupsAppearanceModeUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetGroupsAppearanceModeUseCase instance.
    /// - Returns: A new SetGroupsAppearanceModeUseCase instance
    func makeSetGroupsAppearanceModeUseCase() -> SetGroupsAppearanceModeUseCase {
        SetGroupsAppearanceModeUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new GetGlobalGroupsColorPropertiesUseCase instance.
    /// - Returns: A new GetGlobalGroupsColorPropertiesUseCase instance
    func makeGetGlobalGroupsColorPropertiesUseCase() -> GetGlobalGroupsColorPropertiesUseCase {
        GetGlobalGroupsColorPropertiesUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetGlobalGroupsColorPropertiesUseCase instance.
    /// - Returns: A new SetGlobalGroupsColorPropertiesUseCase instance
    func makeSetGlobalGroupsColorPropertiesUseCase() -> SetGlobalGroupsColorPropertiesUseCase {
        SetGlobalGroupsColorPropertiesUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new GetGlobalGroupsGeometricPropertiesUseCase instance.
    /// - Returns: A new GetGlobalGroupsGeometricPropertiesUseCase instance
    func makeGetGlobalGroupsGeometricPropertiesUseCase() -> GetGlobalGroupsGeometricPropertiesUseCase {
        GetGlobalGroupsGeometricPropertiesUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetGlobalGroupsGeometricPropertiesUseCase instance.
    /// - Returns: A new SetGlobalGroupsGeometricPropertiesUseCase instance
    func makeSetGlobalGroupsGeometricPropertiesUseCase() -> SetGlobalGroupsGeometricPropertiesUseCase {
        SetGlobalGroupsGeometricPropertiesUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new GetGlobalGroupsEffectPropertiesUseCase instance.
    /// - Returns: A new GetGlobalGroupsEffectPropertiesUseCase instance
    func makeGetGlobalGroupsEffectPropertiesUseCase() -> GetGlobalGroupsEffectPropertiesUseCase {
        GetGlobalGroupsEffectPropertiesUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetGlobalGroupsEffectPropertiesUseCase instance.
    /// - Returns: A new SetGlobalGroupsEffectPropertiesUseCase instance
    func makeSetGlobalGroupsEffectPropertiesUseCase() -> SetGlobalGroupsEffectPropertiesUseCase {
        SetGlobalGroupsEffectPropertiesUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new GetThemeModeUseCase instance.
    /// - Returns: A new GetThemeModeUseCase instance
    func makeGetThemeModeUseCase() -> GetThemeModeUseCase {
        GetThemeModeUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetThemeModeUseCase instance.
    /// - Returns: A new SetThemeModeUseCase instance
    func makeSetThemeModeUseCase() -> SetThemeModeUseCase {
        SetThemeModeUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new GetThemePresetColorPropertiesUseCase instance.
    /// - Returns: A new GetThemePresetColorPropertiesUseCase instance
    func makeGetThemePresetColorPropertiesUseCase() -> GetThemePresetColorPropertiesUseCase {
        GetThemePresetColorPropertiesUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetThemePresetColorPropertiesUseCase instance.
    /// - Returns: A new SetThemePresetColorPropertiesUseCase instance
    func makeSetThemePresetColorPropertiesUseCase() -> SetThemePresetColorPropertiesUseCase {
        SetThemePresetColorPropertiesUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new GetThemePresetGeometricPropertiesUseCase instance.
    /// - Returns: A new GetThemePresetGeometricPropertiesUseCase instance
    func makeGetThemePresetGeometricPropertiesUseCase() -> GetThemePresetGeometricPropertiesUseCase {
        GetThemePresetGeometricPropertiesUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetThemePresetGeometricPropertiesUseCase instance.
    /// - Returns: A new SetThemePresetGeometricPropertiesUseCase instance
    func makeSetThemePresetGeometricPropertiesUseCase() -> SetThemePresetGeometricPropertiesUseCase {
        SetThemePresetGeometricPropertiesUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new GetThemePresetEffectPropertiesUseCase instance.
    /// - Returns: A new GetThemePresetEffectPropertiesUseCase instance
    func makeGetThemePresetEffectPropertiesUseCase() -> GetThemePresetEffectPropertiesUseCase {
        GetThemePresetEffectPropertiesUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetThemePresetEffectPropertiesUseCase instance.
    /// - Returns: A new SetThemePresetEffectPropertiesUseCase instance
    func makeSetThemePresetEffectPropertiesUseCase() -> SetThemePresetEffectPropertiesUseCase {
        SetThemePresetEffectPropertiesUseCase(configurationGateway: configurationGateway)
    }

    // MARK: - AeroSpace Use Cases

    /// Creates a new GetAeroSpacePathUseCase instance.
    /// - Returns: A new GetAeroSpacePathUseCase instance
    func makeGetAeroSpacePathUseCase() -> GetAeroSpacePathUseCase {
        GetAeroSpacePathUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetAeroSpacePathUseCase instance.
    /// - Returns: A new SetAeroSpacePathUseCase instance
    func makeSetAeroSpaceCustomPathUseCase() -> SetAeroSpacePathUseCase {
        SetAeroSpacePathUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new OpenAeroSpaceConfigUseCase instance.
    /// - Returns: A new OpenAeroSpaceConfigUseCase instance
    func makeOpenAeroSpaceConfigUseCase() -> OpenAeroSpaceConfigUseCase {
        OpenAeroSpaceConfigUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new GetAeroSpaceConfigPathUseCase instance.
    /// - Returns: A new GetAeroSpaceConfigPathUseCase instance
    func makeGetAeroSpaceConfigPathUseCase() -> GetAeroSpaceConfigPathUseCase {
        GetAeroSpaceConfigPathUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new ResetConfigurationUseCase instance.
    /// - Returns: A new ResetConfigurationUseCase instance
    func makeResetConfigurationUseCase() -> ResetConfigurationUseCase {
        ResetConfigurationUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new GetConfigFilePathUseCase instance.
    /// - Returns: A new GetConfigFilePathUseCase instance
    func makeGetConfigFilePathUseCase() -> GetConfigFilePathUseCase {
        GetConfigFilePathUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetConfigFilePathUseCase instance.
    /// - Returns: A new SetConfigFilePathUseCase instance
    func makeSetConfigFilePathUseCase() -> SetConfigFilePathUseCase {
        SetConfigFilePathUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new OpenConfigFileUseCase instance.
    /// - Returns: A new OpenConfigFileUseCase instance
    func makeOpenConfigFileUseCase() -> OpenConfigFileUseCase {
        OpenConfigFileUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new GetHasAskedForScreenCapturePermissionsUseCase instance.
    /// - Returns: A new GetHasAskedForScreenCapturePermissionsUseCase instance
    func makeGetHasAskedForScreenCapturePermissionsUseCase() -> GetHasAskedForScreenCapturePermissionsUseCase {
        GetHasAskedForScreenCapturePermissionsUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetHasAskedForScreenCapturePermissionsUseCase instance.
    /// - Returns: A new SetHasAskedForScreenCapturePermissionsUseCase instance
    func makeSetHasAskedForScreenCapturePermissionsUseCase() -> SetHasAskedForScreenCapturePermissionsUseCase {
        SetHasAskedForScreenCapturePermissionsUseCase(configurationGateway: configurationGateway)
    }

    // MARK: - System Use Cases

    /// Creates a new GetEnablePerformanceMetricsUseCase instance.
    /// - Returns: A new GetEnablePerformanceMetricsUseCase instance
    func makeGetEnablePerformanceMetricsUseCase() -> GetEnablePerformanceMetricsUseCase {
        GetEnablePerformanceMetricsUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetEnablePerformanceMetricsUseCase instance.
    /// - Returns: A new SetEnablePerformanceMetricsUseCase instance
    func makeSetEnablePerformanceMetricsUseCase() -> SetEnablePerformanceMetricsUseCase {
        SetEnablePerformanceMetricsUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new GetOptimizedPerformanceEnabledUseCase instance.
    /// - Returns: A new GetOptimizedPerformanceEnabledUseCase instance
    func makeGetOptimizedPerformanceEnabledUseCase() -> GetOptimizedPerformanceEnabledUseCase {
        GetOptimizedPerformanceEnabledUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetOptimizedPerformanceEnabledUseCase instance.
    /// - Returns: A new SetOptimizedPerformanceEnabledUseCase instance
    func makeSetOptimizedPerformanceEnabledUseCase() -> SetOptimizedPerformanceEnabledUseCase {
        SetOptimizedPerformanceEnabledUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new GetLogLevelUseCase instance.
    /// - Returns: A new GetLogLevelUseCase instance
    func makeGetLogLevelUseCase() -> GetLogLevelUseCase {
        GetLogLevelUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetLogLevelUseCase instance.
    /// - Returns: A new SetLogLevelUseCase instance
    func makeSetLogLevelUseCase() -> SetLogLevelUseCase {
        SetLogLevelUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new GetShowWindowTitlesUseCase instance.
    /// - Returns: A new GetShowWindowTitlesUseCase instance
    func makeGetShowWindowTitlesUseCase() -> GetShowWindowTitlesUseCase {
        GetShowWindowTitlesUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetShowWindowTitlesUseCase instance.
    /// - Returns: A new SetShowWindowTitlesUseCase instance
    func makeSetShowWindowTitlesUseCase() -> SetShowWindowTitlesUseCase {
        SetShowWindowTitlesUseCase(configurationGateway: configurationGateway)
    }

    // MARK: - UI Configuration Use Cases

    /// Creates a new GetMenuBarHeightUseCase instance.
    /// - Returns: A new GetMenuBarHeightUseCase instance
    func makeGetMenuBarHeightUseCase() -> GetMenuBarHeightUseCase {
        GetMenuBarHeightUseCase(systemMenuBarGateway: systemMenuBarGateway)
    }

    // MARK: - System State Use Cases

    /// Creates a new GetMenuBarVisibilityUseCase instance.
    /// - Returns: A new GetMenuBarVisibilityUseCase instance
    func makeGetMenuBarVisibilityUseCase() -> GetMenuBarVisibilityUseCase {
        GetMenuBarVisibilityUseCase(systemMenuBarGateway: systemMenuBarGateway)
    }

    // MARK: - Keyboard Shortcuts Use Cases

    /// Creates a new GetGlobeKeyPressStateUseCase instance.
    /// - Returns: A new GetGlobeKeyPressStateUseCase instance
    func makeGetGlobeKeyPressStateUseCase() -> GetGlobeKeyPressStateUseCase {
        GetGlobeKeyPressStateUseCase(keyboardShortcutsGateway: keyboardShortcutsGateway)
    }

    // MARK: - Feature Flags Use Cases

    /// Creates a new GetFeatureFlagsUseCase instance.
    /// - Returns: A new GetFeatureFlagsUseCase instance
    func makeGetFeatureFlagsUseCase() -> GetFeatureFlagsUseCase {
        GetFeatureFlagsUseCase(gateway: featureFlagsGateway)
    }

    // MARK: - License Feature Flags Use Cases

    /// Creates a new GetEnableLicensingUseCase instance.
    /// - Returns: A new GetEnableLicensingUseCase instance
    func makeGetEnableLicensingUseCase() -> GetEnableLicensingUseCase {
        GetEnableLicensingUseCase(gateway: licenseGateway)
    }

    /// Creates a new SetEnableLicensingUseCase instance.
    /// - Returns: A new SetEnableLicensingUseCase instance
    func makeSetEnableLicensingUseCase() -> SetEnableLicensingUseCase {
        SetEnableLicensingUseCase(gateway: licenseGateway)
    }

    /// Creates a new GetEnableTrialRequestUseCase instance.
    /// - Returns: A new GetEnableTrialRequestUseCase instance
    func makeGetEnableTrialRequestUseCase() -> GetEnableTrialRequestUseCase {
        GetEnableTrialRequestUseCase(gateway: licenseGateway)
    }

    /// Creates a new SetEnableTrialRequestUseCase instance.
    /// - Returns: A new SetEnableTrialRequestUseCase instance
    func makeSetEnableTrialRequestUseCase() -> SetEnableTrialRequestUseCase {
        SetEnableTrialRequestUseCase(gateway: licenseGateway)
    }

    #if DEBUG
        /// Creates a new GetMockActiveLicenseUseCase instance (DEBUG builds only).
        /// - Returns: A new GetMockActiveLicenseUseCase instance
        func makeGetMockActiveLicenseUseCase() -> GetMockActiveLicenseUseCase {
            GetMockActiveLicenseUseCase(gateway: licenseGateway)
        }

        /// Creates a new SetMockActiveLicenseUseCase instance (DEBUG builds only).
        /// - Returns: A new SetMockActiveLicenseUseCase instance
        func makeSetMockActiveLicenseUseCase() -> SetMockActiveLicenseUseCase {
            SetMockActiveLicenseUseCase(gateway: licenseGateway)
        }

        /// Creates a new GetCheckoutEnvironmentUseCase instance (DEBUG builds only).
        /// - Returns: A new GetCheckoutEnvironmentUseCase instance
        func makeGetCheckoutEnvironmentUseCase() -> GetCheckoutEnvironmentUseCase {
            GetCheckoutEnvironmentUseCase(licenseGateway: licenseGateway)
        }

        /// Creates a new SetCheckoutEnvironmentUseCase instance (DEBUG builds only).
        /// - Returns: A new SetCheckoutEnvironmentUseCase instance
        func makeSetCheckoutEnvironmentUseCase() -> SetCheckoutEnvironmentUseCase {
            SetCheckoutEnvironmentUseCase(licenseGateway: licenseGateway)
        }
    #endif

    /// Creates a new ResetLicenseFeatureFlagsUseCase instance.
    /// - Returns: A new ResetLicenseFeatureFlagsUseCase instance
    func makeResetLicenseFeatureFlagsUseCase() -> ResetLicenseFeatureFlagsUseCase {
        ResetLicenseFeatureFlagsUseCase(gateway: licenseGateway)
    }

    // MARK: - License Use Cases

    /// Creates a new GetLicenseInfoUseCase instance.
    /// - Returns: A new GetLicenseInfoUseCase instance
    func makeGetLicenseInfoUseCase() -> GetLicenseInfoUseCase {
        GetLicenseInfoUseCase(licenseGateway: licenseGateway)
    }

    /// Creates a new ActivateLicenseUseCase instance.
    /// - Returns: A new ActivateLicenseUseCase instance
    func makeActivateLicenseUseCase() -> ActivateLicenseUseCase {
        ActivateLicenseUseCase(licenseGateway: licenseGateway)
    }

    /// Creates a new OpenCheckoutUseCase instance.
    /// - Returns: A new OpenCheckoutUseCase instance
    func makeOpenCheckoutUseCase() -> OpenCheckoutUseCase {
        OpenCheckoutUseCase(licenseGateway: licenseGateway)
    }

    /// Creates a new DeactivateLicenseUseCase instance.
    /// - Returns: A new DeactivateLicenseUseCase instance
    func makeDeactivateLicenseUseCase() -> DeactivateLicenseUseCase {
        DeactivateLicenseUseCase(licenseGateway: licenseGateway)
    }

    /// Creates a new SetUserNameUseCase instance.
    /// - Returns: A new SetUserNameUseCase instance
    func makeSetUserNameUseCase() -> SetUserNameUseCase {
        SetUserNameUseCase(licenseGateway: licenseGateway)
    }

    /// Creates a new SetProfileImageDataUseCase instance.
    /// - Returns: A new SetProfileImageDataUseCase instance
    func makeSetProfileImageDataUseCase() -> SetProfileImageDataUseCase {
        SetProfileImageDataUseCase(licenseGateway: licenseGateway)
    }

    /// Creates a new HasTrialBeenUsedUseCase instance.
    /// - Returns: A new HasTrialBeenUsedUseCase instance
    func makeHasTrialBeenUsedUseCase() -> HasTrialBeenUsedUseCase {
        HasTrialBeenUsedUseCase(licenseGateway: licenseGateway)
    }

    // MARK: - Software Update Use Cases

    /// Creates a new GetAutomaticCheckForUpdatesEnabledUseCase instance.
    /// - Returns: A new GetAutomaticCheckForUpdatesEnabledUseCase instance
    func makeGetAutomaticCheckForUpdatesEnabledUseCase() -> GetAutomaticCheckForUpdatesEnabledUseCase {
        GetAutomaticCheckForUpdatesEnabledUseCase(softwareUpdateGateway: softwareUpdateGateway)
    }

    /// Creates a new SetAutomaticCheckForUpdatesEnabledUseCase instance.
    /// - Returns: A new SetAutomaticCheckForUpdatesEnabledUseCase instance
    func makeSetAutomaticCheckForUpdatesEnabledUseCase() -> SetAutomaticCheckForUpdatesEnabledUseCase {
        SetAutomaticCheckForUpdatesEnabledUseCase(softwareUpdateGateway: softwareUpdateGateway)
    }

    /// Creates a new GetAutomaticDownloadUpdatesEnabledUseCase instance.
    /// - Returns: A new GetAutomaticDownloadUpdatesEnabledUseCase instance
    func makeGetAutomaticDownloadUpdatesEnabledUseCase() -> GetAutomaticDownloadUpdatesEnabledUseCase {
        GetAutomaticDownloadUpdatesEnabledUseCase(softwareUpdateGateway: softwareUpdateGateway)
    }

    /// Creates a new SetAutomaticDownloadUpdatesEnabledUseCase instance.
    /// - Returns: A new SetAutomaticDownloadUpdatesEnabledUseCase instance
    func makeSetAutomaticDownloadUpdatesEnabledUseCase() -> SetAutomaticDownloadUpdatesEnabledUseCase {
        SetAutomaticDownloadUpdatesEnabledUseCase(softwareUpdateGateway: softwareUpdateGateway)
    }

    /// Creates a new GetLastUpdateCheckDateUseCase instance.
    /// - Returns: A new GetLastUpdateCheckDateUseCase instance
    func makeGetLastUpdateCheckDateUseCase() -> GetLastUpdateCheckDateUseCase {
        GetLastUpdateCheckDateUseCase(softwareUpdateGateway: softwareUpdateGateway)
    }

    /// Creates a new CheckForUpdatesUseCase instance.
    /// - Returns: A new CheckForUpdatesUseCase instance
    func makeCheckForUpdatesUseCase() -> CheckForUpdatesUseCase {
        CheckForUpdatesUseCase(softwareUpdateGateway: softwareUpdateGateway)
    }

    #if DEBUG
        /// Creates a new SetFeatureFlagsUseCase instance.
        /// - Returns: A new SetFeatureFlagsUseCase instance
        func makeSetFeatureFlagsUseCase() -> SetFeatureFlagsUseCase {
            SetFeatureFlagsUseCase(gateway: featureFlagsGateway)
        }

        /// Creates a new DeveloperSettingsViewModel instance.
        /// - Returns: A new DeveloperSettingsViewModel instance
        func getDeveloperSettingsViewModel() -> DeveloperSettingsViewModel {
            developerSettingsViewModel
        }
    #endif
}
