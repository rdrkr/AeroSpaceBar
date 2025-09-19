// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import AppKit
import Domain
import Service

/// Dependency injection container for managing service dependencies.
///
/// This class provides a centralized container for managing all service dependencies
/// in the application. It uses lazy initialization to ensure services are only created
/// when needed and provides a clean interface for accessing dependencies.
/// It runs on the main actor for thread safety.

@MainActor
final class DependencyContainer {
    /// The shared instance of the dependency container.
    static let shared = DependencyContainer()

    /// Private initializer to enforce singleton pattern.

    private init() { }

    // MARK: - Services

    /// The spaces gateway for managing AeroSpace interactions.
    ///
    /// This service is lazily initialized and provides access to spaces data
    /// and window management functionality.
    private lazy var spacesGateway: SpacesGateway = AeroSpaceRepository(
        iconCache: iconCache,
        getAeroSpacePathUseCase: makeGetAeroSpacePathUseCase(),
        getAeroSpaceConfigPathUseCase: makeGetAeroSpaceConfigPathUseCase(),
        getOptimizedPerformanceEnabledUseCase: makeGetOptimizedPerformanceEnabledUseCase(),
        getShowEmptySpacesUseCase: makeGetShowEmptySpacesUseCase()
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
        getShowGroupsUseCase: makeGetShowGroupsUseCase()
    )

    /// The SettingsViewModel instance.
    private lazy var settingsViewModel: SettingsViewModel = .init(
        getFocusWindowOnClickUseCase: makeGetFocusWindowOnClickUseCase(),
        setFocusWindowOnClickUseCase: makeSetFocusWindowOnClickUseCase(),
        getShowEmptySpacesUseCase: makeGetShowEmptySpacesUseCase(),
        setShowEmptySpacesUseCase: makeSetShowEmptySpacesUseCase(),
        getShowWindowTitlesUseCase: makeGetShowWindowTitlesUseCase(),
        setShowWindowTitlesUseCase: makeSetShowWindowTitlesUseCase(),
        getMenuBarAppsUseCase: makeGetMenuBarAppsUseCase(),
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
        getAnimationDurationUseCase: makeGetAnimationDurationUseCase(),
        getSpacesVisualConfigUseCase: makeGetSpacesVisualConfigUseCase(),
        setSpacesVisualConfigUseCase: makeSetSpacesVisualConfigUseCase(),
        getSpacesAppearanceModeUseCase: makeGetSpacesAppearanceModeUseCase(),
        setSpacesAppearanceModeUseCase: makeSetSpacesAppearanceModeUseCase(),
        getGlobalSpacesVisualConfigUseCase: makeGetGlobalSpacesVisualConfigUseCase(),
        setGlobalSpacesVisualConfigUseCase: makeSetGlobalSpacesVisualConfigUseCase(),
        getGroupsUseCase: makeGetGroupsUseCase(),
        setGroupsUseCase: makeSetGroupsUseCase(),
        getGroupsAppearanceModeUseCase: makeGetGroupsAppearanceModeUseCase(),
        setGroupsAppearanceModeUseCase: makeSetGroupsAppearanceModeUseCase(),
        getGlobalGroupsVisualConfigUseCase: makeGetGlobalGroupsVisualConfigUseCase(),
        setGlobalGroupsVisualConfigUseCase: makeSetGlobalGroupsVisualConfigUseCase()
    )

    /// The SpacesViewModel instance.
    private lazy var spacesViewModel: SpacesViewModel = .init(
        getSpacesUseCase: makeGetSpacesUseCase(),
        setFocusSpaceUseCase: makeSetFocusSpaceUseCase(),
        setFocusWindowUseCase: makeSetFocusWindowUseCase(),
        getAeroSpaceStatusUseCase: makeGetAeroSpaceStatusUseCase(),
        startAeroSpaceUseCase: makeStartAeroSpaceUseCase(),
        getShowWindowTitlesUseCase: makeGetShowWindowTitlesUseCase(),
        getFocusWindowOnClickUseCase: makeGetFocusWindowOnClickUseCase(),
        getWallpaperUseCase: makeGetWallpaperUseCase(),
        getMenuBarVisibilityUseCase: makeGetMenuBarVisibilityUseCase(),
        getMenuBarHeightUseCase: makeGetMenuBarHeightUseCase(),
        getMenuBarVerticalPaddingUseCase: makeGetMenuBarVerticalPaddingUseCase(),
        getMenuBarHorizontalPaddingUseCase: makeGetMenuBarHorizontalPaddingUseCase(),
        getWidgetSpacingUseCase: makeGetWidgetSpacingUseCase(),
        getAnimationDurationUseCase: makeGetAnimationDurationUseCase(),
        getWindowIconSizeUseCase: makeGetWindowIconSizeUseCase(),
        getFeatureFlagsUseCase: makeGetFeatureFlagsUseCase(),
        getSpacesAppearanceModeUseCase: makeGetSpacesAppearanceModeUseCase(),
        getGlobalSpacesVisualConfigUseCase: makeGetGlobalSpacesVisualConfigUseCase()
    )

    /// The LicensingViewModel instance.
    private lazy var licensingViewModel: LicensingViewModel = .init(
        getLicenseStatusUseCase: makeGetLicenseStatusUseCase(),
        activateLicenseUseCase: makeActivateLicenseUseCase(),
        openCheckoutUseCase: makeOpenCheckoutUseCase(),
        startTrialUseCase: makeStartTrialUseCase(),
        deactivateLicenseUseCase: makeDeactivateLicenseUseCase(),
        getFeatureFlagsUseCase: makeGetFeatureFlagsUseCase()
    )

    /// The GroupsViewModel instance.
    private lazy var groupsViewModel: GroupsViewModel = .init(
        getShowGroupsUseCase: makeGetShowGroupsUseCase(),
        setShowGroupsUseCase: makeSetShowGroupsUseCase(),
        getGroupsUseCase: makeGetGroupsUseCase(),
        setGroupsUseCase: makeSetGroupsUseCase(),
        getMenuBarAppsUseCase: makeGetMenuBarAppsUseCase(),
        getFeatureFlagsUseCase: makeGetFeatureFlagsUseCase(),
        getAnimationDurationUseCase: makeGetAnimationDurationUseCase(),
        getWidgetSpacingUseCase: makeGetWidgetSpacingUseCase(),
        getMenuBarVerticalPaddingUseCase: makeGetMenuBarVerticalPaddingUseCase(),
        getWindowIconSizeUseCase: makeGetWindowIconSizeUseCase(),
        getGroupsAppearanceModeUseCase: makeGetGroupsAppearanceModeUseCase(),
        setGroupsAppearanceModeUseCase: makeSetGroupsAppearanceModeUseCase(),
        getGlobalGroupsVisualConfigUseCase: makeGetGlobalGroupsVisualConfigUseCase(),
        getGlobalSpacesVisualConfigUseCase: makeGetGlobalSpacesVisualConfigUseCase()
    )

    /// The licensing gateway for managing application licensing.
    #if DEBUG
        private lazy var licensingGateway: LicensingGateway = LicensingRepository(
            featureFlagsGateway: featureFlagsGateway
        )
    #else
        private lazy var licensingGateway: LicensingGateway = LicensingRepository()
    #endif

    /// The feature flags gateway for managing development feature toggles.
    ///
    /// This gateway is only available in debug builds and provides access to
    /// feature flags for controlling experimental and development features.
    private lazy var featureFlagsGateway: FeatureFlagsGateway = FeatureFlagsRepository()

    #if DEBUG
        /// The DeveloperSettingsViewModel instance for managing developer settings.
        private lazy var developerSettingsViewModel: DeveloperSettingsViewModel = .init(
            getFeatureFlagsUseCase: makeGetFeatureFlagsUseCase(),
            setFeatureFlagsUseCase: makeSetFeatureFlagsUseCase(),
            deactivateLicenseUseCase: makeDeactivateLicenseUseCase()
        )
    #endif

    // MARK: - Public Access

    /// Gets the spaces gateway instance.
    /// - Returns: The spaces gateway protocol implementation
    func getSpacesGateway() -> SpacesGateway {
        spacesGateway
    }

    /// Gets the settings view model instance.
    /// - Returns: The settings view model instance
    func getSettingsViewModel() -> SettingsViewModel {
        settingsViewModel
    }

    /// Gets the spaces view model instance.
    /// - Returns: The spaces view model instance
    func getSpacesViewModel() -> SpacesViewModel {
        spacesViewModel
    }

    /// Gets the groups view model instance.
    /// - Returns: The groups view model instance
    func getGroupsViewModel() -> GroupsViewModel {
        groupsViewModel
    }

    /// Gets the licensing view model instance.
    /// - Returns: The licensing view model instance
    func getLicensingViewModel() -> LicensingViewModel {
        licensingViewModel
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
    /// Creates a new GetSpacesVisualConfigUseCase instance.
    /// - Returns: A new GetSpacesVisualConfigUseCase instance
    func makeGetSpacesVisualConfigUseCase() -> GetSpacesVisualConfigUseCase {
        GetSpacesVisualConfigUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetSpacesVisualConfigUseCase instance.
    /// - Returns: A new SetSpacesVisualConfigUseCase instance
    func makeSetSpacesVisualConfigUseCase() -> SetSpacesVisualConfigUseCase {
        SetSpacesVisualConfigUseCase(configurationGateway: configurationGateway)
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

    /// Creates a new GetGlobalSpacesVisualConfigUseCase instance.
    /// - Returns: A new GetGlobalSpacesVisualConfigUseCase instance
    func makeGetGlobalSpacesVisualConfigUseCase() -> GetGlobalSpacesVisualConfigUseCase {
        GetGlobalSpacesVisualConfigUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetGlobalSpacesVisualConfigUseCase instance.
    /// - Returns: A new SetGlobalSpacesVisualConfigUseCase instance
    func makeSetGlobalSpacesVisualConfigUseCase() -> SetGlobalSpacesVisualConfigUseCase {
        SetGlobalSpacesVisualConfigUseCase(configurationGateway: configurationGateway)
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

    /// Creates a new GetGlobalGroupsVisualConfigUseCase instance.
    /// - Returns: A new GetGlobalGroupsVisualConfigUseCase instance
    func makeGetGlobalGroupsVisualConfigUseCase() -> GetGlobalGroupsVisualConfigUseCase {
        GetGlobalGroupsVisualConfigUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetGlobalGroupsVisualConfigUseCase instance.
    /// - Returns: A new SetGlobalGroupsVisualConfigUseCase instance
    func makeSetGlobalGroupsVisualConfigUseCase() -> SetGlobalGroupsVisualConfigUseCase {
        SetGlobalGroupsVisualConfigUseCase(configurationGateway: configurationGateway)
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

    /// Creates a new GetMenuBarVerticalPaddingUseCase instance.
    /// - Returns: A new GetMenuBarVerticalPaddingUseCase instance
    func makeGetMenuBarVerticalPaddingUseCase() -> GetMenuBarVerticalPaddingUseCase {
        GetMenuBarVerticalPaddingUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetMenuBarVerticalPaddingUseCase instance.
    /// - Returns: A new SetMenuBarVerticalPaddingUseCase instance
    func makeSetMenuBarVerticalPaddingUseCase() -> SetMenuBarVerticalPaddingUseCase {
        SetMenuBarVerticalPaddingUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new GetMenuBarHorizontalPaddingUseCase instance.
    /// - Returns: A new GetMenuBarHorizontalPaddingUseCase instance
    func makeGetMenuBarHorizontalPaddingUseCase() -> GetMenuBarHorizontalPaddingUseCase {
        GetMenuBarHorizontalPaddingUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetMenuBarHorizontalPaddingUseCase instance.
    /// - Returns: A new SetMenuBarHorizontalPaddingUseCase instance
    func makeSetMenuBarHorizontalPaddingUseCase() -> SetMenuBarHorizontalPaddingUseCase {
        SetMenuBarHorizontalPaddingUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new GetWidgetSpacingUseCase instance.
    /// - Returns: A new GetWidgetSpacingUseCase instance
    func makeGetWidgetSpacingUseCase() -> GetWidgetSpacingUseCase {
        GetWidgetSpacingUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetWidgetSpacingUseCase instance.
    /// - Returns: A new SetWidgetSpacingUseCase instance
    func makeSetWidgetSpacingUseCase() -> SetWidgetSpacingUseCase {
        SetWidgetSpacingUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new GetAnimationDurationUseCase instance.
    /// - Returns: A new GetAnimationDurationUseCase instance
    func makeGetAnimationDurationUseCase() -> GetAnimationDurationUseCase {
        GetAnimationDurationUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetAnimationDurationUseCase instance.
    /// - Returns: A new SetAnimationDurationUseCase instance
    func makeSetAnimationDurationUseCase() -> SetAnimationDurationUseCase {
        SetAnimationDurationUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new GetWindowIconSizeUseCase instance.
    /// - Returns: A new GetWindowIconSizeUseCase instance
    func makeGetWindowIconSizeUseCase() -> GetWindowIconSizeUseCase {
        GetWindowIconSizeUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetWindowIconSizeUseCase instance.
    /// - Returns: A new SetWindowIconSizeUseCase instance
    func makeSetWindowIconSizeUseCase() -> SetWindowIconSizeUseCase {
        SetWindowIconSizeUseCase(configurationGateway: configurationGateway)
    }

    // MARK: - System State Use Cases

    /// Creates a new GetMenuBarVisibilityUseCase instance.
    /// - Returns: A new GetMenuBarVisibilityUseCase instance
    func makeGetMenuBarVisibilityUseCase() -> GetMenuBarVisibilityUseCase {
        GetMenuBarVisibilityUseCase(systemMenuBarGateway: systemMenuBarGateway)
    }

    // MARK: - Feature Flags Use Cases

    /// Creates a new GetFeatureFlagsUseCase instance.
    /// - Returns: A new GetFeatureFlagsUseCase instance
    func makeGetFeatureFlagsUseCase() -> GetFeatureFlagsUseCase {
        GetFeatureFlagsUseCase(gateway: featureFlagsGateway)
    }

    // MARK: - Licensing Use Cases

    /// Creates a new GetLicenseStatusUseCase instance.
    /// - Returns: A new GetLicenseStatusUseCase instance
    func makeGetLicenseStatusUseCase() -> GetLicenseStatusUseCase {
        GetLicenseStatusUseCase(licensingGateway: licensingGateway)
    }

    /// Creates a new ActivateLicenseUseCase instance.
    /// - Returns: A new ActivateLicenseUseCase instance
    func makeActivateLicenseUseCase() -> ActivateLicenseUseCase {
        ActivateLicenseUseCase(licensingGateway: licensingGateway)
    }

    /// Creates a new OpenCheckoutUseCase instance.
    /// - Returns: A new OpenCheckoutUseCase instance
    func makeOpenCheckoutUseCase() -> OpenCheckoutUseCase {
        OpenCheckoutUseCase(licensingGateway: licensingGateway)
    }

    /// Creates a new StartTrialUseCase instance.
    /// - Returns: A new StartTrialUseCase instance
    func makeStartTrialUseCase() -> StartTrialUseCase {
        StartTrialUseCase(licensingGateway: licensingGateway)
    }

    /// Creates a new DeactivateLicenseUseCase instance.
    /// - Returns: A new DeactivateLicenseUseCase instance
    func makeDeactivateLicenseUseCase() -> DeactivateLicenseUseCase {
        DeactivateLicenseUseCase(licensingGateway: licensingGateway)
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
