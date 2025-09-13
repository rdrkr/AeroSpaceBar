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
        getSpaceBackgroundOpacityUseCase: makeGetSpaceBackgroundOpacityUseCase(),
        setSpaceBackgroundOpacityUseCase: makeSetSpaceBackgroundOpacityUseCase(),
        getSpaceBackgroundBlurRadiusUseCase: makeGetSpaceBackgroundBlurRadiusUseCase(),
        setSpaceBackgroundBlurRadiusUseCase: makeSetSpaceBackgroundBlurRadiusUseCase(),
        getSpaceBackgroundTintColorUseCase: makeGetSpaceBackgroundTintColorUseCase(),
        setSpaceBackgroundTintColorUseCase: makeSetSpaceBackgroundTintColorUseCase(),
        getSpaceForegroundColorUseCase: makeGetSpaceForegroundColorUseCase(),
        setSpaceForegroundColorUseCase: makeSetSpaceForegroundColorUseCase(),
        getSpaceBorderTintColorUseCase: makeGetSpaceBorderTintColorUseCase(),
        setSpaceBorderTintColorUseCase: makeSetSpaceBorderTintColorUseCase(),
        getSpaceBorderOpacityUseCase: makeGetSpaceBorderOpacityUseCase(),
        setSpaceBorderOpacityUseCase: makeSetSpaceBorderOpacityUseCase(),
        getSpaceBorderWidthUseCase: makeGetSpaceBorderWidthUseCase(),
        setSpaceBorderWidthUseCase: makeSetSpaceBorderWidthUseCase(),
        getFocusWindowOnClickUseCase: makeGetFocusWindowOnClickUseCase(),
        setFocusWindowOnClickUseCase: makeSetFocusWindowOnClickUseCase(),
        getShowEmptySpacesUseCase: makeGetShowEmptySpacesUseCase(),
        setShowEmptySpacesUseCase: makeSetShowEmptySpacesUseCase(),
        getShowWindowTitlesUseCase: makeGetShowWindowTitlesUseCase(),
        setShowWindowTitlesUseCase: makeSetShowWindowTitlesUseCase(),
        getSpaceCornerRadiusUseCase: makeGetSpaceCornerRadiusUseCase(),
        setSpaceCornerRadiusUseCase: makeSetSpaceCornerRadiusUseCase(),
        getGroupsGlobalBackgroundTintColorUseCase: makeGetGroupsGlobalBgTintColorUseCase(),
        setGroupsGlobalBackgroundTintColorUseCase: makeSetGroupsGlobalBgTintColorUseCase(),
        getGroupsGlobalBackgroundOpacityUseCase: makeGetGroupsGlobalBackgroundOpacityUseCase(),
        setGroupsGlobalBackgroundOpacityUseCase: makeSetGroupsGlobalBackgroundOpacityUseCase(),
        getGroupsGlobalBackgroundBlurRadiusUseCase: makeGetGroupsGlobalBgBlurRadiusUseCase(),
        setGroupsGlobalBackgroundBlurRadiusUseCase: makeSetGroupsGlobalBgBlurRadiusUseCase(),
        getGroupsGlobalBorderColorUseCase: makeGetGroupsGlobalBorderColorUseCase(),
        setGroupsGlobalBorderColorUseCase: makeSetGroupsGlobalBorderColorUseCase(),
        getGroupsGlobalBorderOpacityUseCase: makeGetGroupsGlobalBorderOpacityUseCase(),
        setGroupsGlobalBorderOpacityUseCase: makeSetGroupsGlobalBorderOpacityUseCase(),
        getGroupsGlobalBorderWidthUseCase: makeGetGroupsGlobalBorderWidthUseCase(),
        setGroupsGlobalBorderWidthUseCase: makeSetGroupsGlobalBorderWidthUseCase(),
        getGroupsGlobalCornerRadiusUseCase: makeGetGroupsGlobalCornerRadiusUseCase(),
        setGroupsGlobalCornerRadiusUseCase: makeSetGroupsGlobalCornerRadiusUseCase(),
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
        getAnimationDurationUseCase: makeGetAnimationDurationUseCase()
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
        getSpaceCornerRadiusUseCase: makeGetSpaceCornerRadiusUseCase(),
        getSpaceBackgroundOpacityUseCase: makeGetSpaceBackgroundOpacityUseCase(),
        getSpaceBackgroundBlurRadiusUseCase: makeGetSpaceBackgroundBlurRadiusUseCase(),
        getSpaceBackgroundTintColorUseCase: makeGetSpaceBackgroundTintColorUseCase(),
        getSpaceForegroundColorUseCase: makeGetSpaceForegroundColorUseCase(),
        getSpaceBorderTintColorUseCase: makeGetSpaceBorderTintColorUseCase(),
        getSpaceBorderOpacityUseCase: makeGetSpaceBorderOpacityUseCase(),
        getSpaceBorderWidthUseCase: makeGetSpaceBorderWidthUseCase(),
        getFeatureFlagsUseCase: makeGetFeatureFlagsUseCase()
    )

    /// The GroupsViewModel instance.
    private lazy var groupsViewModel: GroupsViewModel = .init(
        getShowGroupsUseCase: makeGetShowGroupsUseCase(),
        setShowGroupsUseCase: makeSetShowGroupsUseCase(),
        getGroupsConfigurationUseCase: makeGetGroupsConfigurationUseCase(),
        setGroupsConfigurationUseCase: makeSetGroupsConfigurationUseCase(),
        getMenuBarAppsUseCase: makeGetMenuBarAppsUseCase(),
        getFeatureFlagsUseCase: makeGetFeatureFlagsUseCase(),
        getAnimationDurationUseCase: makeGetAnimationDurationUseCase(),
        getWidgetSpacingUseCase: makeGetWidgetSpacingUseCase(),
        getGroupsAppearanceModeUseCase: makeGetGroupsAppearanceModeUseCase(),
        setGroupsAppearanceModeUseCase: makeSetGroupsAppearanceModeUseCase(),
        getGroupsGlobalBackgroundTintColorUseCase: makeGetGroupsGlobalBgTintColorUseCase(),
        getGroupsGlobalBackgroundOpacityUseCase: makeGetGroupsGlobalBackgroundOpacityUseCase(),
        getGroupsGlobalBackgroundBlurRadiusUseCase: makeGetGroupsGlobalBgBlurRadiusUseCase(),
        getGroupsGlobalBorderColorUseCase: makeGetGroupsGlobalBorderColorUseCase(),
        getGroupsGlobalBorderOpacityUseCase: makeGetGroupsGlobalBorderOpacityUseCase(),
        getGroupsGlobalBorderWidthUseCase: makeGetGroupsGlobalBorderWidthUseCase(),
        getGroupsGlobalCornerRadiusUseCase: makeGetGroupsGlobalCornerRadiusUseCase(),
        getSpaceBackgroundOpacityUseCase: makeGetSpaceBackgroundOpacityUseCase(),
        getSpaceBackgroundBlurRadiusUseCase: makeGetSpaceBackgroundBlurRadiusUseCase(),
        getSpaceBackgroundTintColorUseCase: makeGetSpaceBackgroundTintColorUseCase(),
        getSpaceBorderTintColorUseCase: makeGetSpaceBorderTintColorUseCase(),
        getSpaceBorderOpacityUseCase: makeGetSpaceBorderOpacityUseCase(),
        getSpaceBorderWidthUseCase: makeGetSpaceBorderWidthUseCase(),
        getSpaceCornerRadiusUseCase: makeGetSpaceCornerRadiusUseCase()
    )

    /// The feature flags gateway for managing development feature toggles.
    ///
    /// This gateway is only available in debug builds and provides access to
    /// feature flags for controlling experimental and development features.
    private lazy var featureFlagsGateway: FeatureFlagsGateway = FeatureFlagsRepository()

    #if DEBUG
        /// The DeveloperSettingsViewModel instance for managing developer settings.
        private lazy var developerSettingsViewModel: DeveloperSettingsViewModel = .init(
            getFeatureFlagsUseCase: makeGetFeatureFlagsUseCase(),
            setFeatureFlagsUseCase: makeSetFeatureFlagsUseCase()
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

    /// Creates a new GetSpaceBackgroundOpacityUseCase instance.
    /// - Returns: A new GetSpaceBackgroundOpacityUseCase instance
    func makeGetSpaceBackgroundOpacityUseCase() -> GetSpaceBackgroundOpacityUseCase {
        GetSpaceBackgroundOpacityUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetSpaceBackgroundOpacityUseCase instance.
    /// - Returns: A new SetSpaceBackgroundOpacityUseCase instance
    func makeSetSpaceBackgroundOpacityUseCase() -> SetSpaceBackgroundOpacityUseCase {
        SetSpaceBackgroundOpacityUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new GetSpaceBackgroundBlurRadiusUseCase instance.
    /// - Returns: A new GetSpaceBackgroundBlurRadiusUseCase instance
    func makeGetSpaceBackgroundBlurRadiusUseCase() -> GetSpaceBackgroundBlurRadiusUseCase {
        GetSpaceBackgroundBlurRadiusUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetSpaceBackgroundBlurRadiusUseCase instance.
    /// - Returns: A new SetSpaceBackgroundBlurRadiusUseCase instance
    func makeSetSpaceBackgroundBlurRadiusUseCase() -> SetSpaceBackgroundBlurRadiusUseCase {
        SetSpaceBackgroundBlurRadiusUseCase(configurationGateway: configurationGateway)
    }

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

    /// Creates a new GetGroupsConfigurationUseCase instance.
    /// - Returns: A new GetGroupsConfigurationUseCase instance
    func makeGetGroupsConfigurationUseCase() -> GetGroupsConfigurationUseCase {
        GetGroupsConfigurationUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetGroupsConfigurationUseCase instance.
    /// - Returns: A new SetGroupsConfigurationUseCase instance
    func makeSetGroupsConfigurationUseCase() -> SetGroupsConfigurationUseCase {
        SetGroupsConfigurationUseCase(configurationGateway: configurationGateway)
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

    /// Creates a new GetGroupsGlobalBgTintColorUseCase instance.
    /// - Returns: A new GetGroupsGlobalBgTintColorUseCase instance
    func makeGetGroupsGlobalBgTintColorUseCase() -> GetGroupsGlobalBgTintColorUseCase {
        GetGroupsGlobalBgTintColorUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetGroupsGlobalBgTintColorUseCase instance.
    /// - Returns: A new SetGroupsGlobalBgTintColorUseCase instance
    func makeSetGroupsGlobalBgTintColorUseCase() -> SetGroupsGlobalBgTintColorUseCase {
        SetGroupsGlobalBgTintColorUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new GetGroupsGlobalBackgroundOpacityUseCase instance.
    /// - Returns: A new GetGroupsGlobalBackgroundOpacityUseCase instance
    func makeGetGroupsGlobalBackgroundOpacityUseCase() -> GetGroupsGlobalBackgroundOpacityUseCase {
        GetGroupsGlobalBackgroundOpacityUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetGroupsGlobalBackgroundOpacityUseCase instance.
    /// - Returns: A new SetGroupsGlobalBackgroundOpacityUseCase instance
    func makeSetGroupsGlobalBackgroundOpacityUseCase() -> SetGroupsGlobalBackgroundOpacityUseCase {
        SetGroupsGlobalBackgroundOpacityUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new GetGroupsGlobalBgBlurRadiusUseCase instance.
    /// - Returns: A new GetGroupsGlobalBgBlurRadiusUseCase instance
    func makeGetGroupsGlobalBgBlurRadiusUseCase() -> GetGroupsGlobalBgBlurRadiusUseCase {
        GetGroupsGlobalBgBlurRadiusUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetGroupsGlobalBgBlurRadiusUseCase instance.
    /// - Returns: A new SetGroupsGlobalBgBlurRadiusUseCase instance
    func makeSetGroupsGlobalBgBlurRadiusUseCase() -> SetGroupsGlobalBgBlurRadiusUseCase {
        SetGroupsGlobalBgBlurRadiusUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new GetGroupsGlobalBorderColorUseCase instance.
    /// - Returns: A new GetGroupsGlobalBorderColorUseCase instance
    func makeGetGroupsGlobalBorderColorUseCase() -> GetGroupsGlobalBorderColorUseCase {
        GetGroupsGlobalBorderColorUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetGroupsGlobalBorderColorUseCase instance.
    /// - Returns: A new SetGroupsGlobalBorderColorUseCase instance
    func makeSetGroupsGlobalBorderColorUseCase() -> SetGroupsGlobalBorderColorUseCase {
        SetGroupsGlobalBorderColorUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new GetGroupsGlobalBorderOpacityUseCase instance.
    /// - Returns: A new GetGroupsGlobalBorderOpacityUseCase instance
    func makeGetGroupsGlobalBorderOpacityUseCase() -> GetGroupsGlobalBorderOpacityUseCase {
        GetGroupsGlobalBorderOpacityUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetGroupsGlobalBorderOpacityUseCase instance.
    /// - Returns: A new SetGroupsGlobalBorderOpacityUseCase instance
    func makeSetGroupsGlobalBorderOpacityUseCase() -> SetGroupsGlobalBorderOpacityUseCase {
        SetGroupsGlobalBorderOpacityUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new GetGroupsGlobalBorderWidthUseCase instance.
    /// - Returns: A new GetGroupsGlobalBorderWidthUseCase instance
    func makeGetGroupsGlobalBorderWidthUseCase() -> GetGroupsGlobalBorderWidthUseCase {
        GetGroupsGlobalBorderWidthUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetGroupsGlobalBorderWidthUseCase instance.
    /// - Returns: A new SetGroupsGlobalBorderWidthUseCase instance
    func makeSetGroupsGlobalBorderWidthUseCase() -> SetGroupsGlobalBorderWidthUseCase {
        SetGroupsGlobalBorderWidthUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new GetGroupsGlobalCornerRadiusUseCase instance.
    /// - Returns: A new GetGroupsGlobalCornerRadiusUseCase instance
    func makeGetGroupsGlobalCornerRadiusUseCase() -> GetGroupsGlobalCornerRadiusUseCase {
        GetGroupsGlobalCornerRadiusUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetGroupsGlobalCornerRadiusUseCase instance.
    /// - Returns: A new SetGroupsGlobalCornerRadiusUseCase instance
    func makeSetGroupsGlobalCornerRadiusUseCase() -> SetGroupsGlobalCornerRadiusUseCase {
        SetGroupsGlobalCornerRadiusUseCase(configurationGateway: configurationGateway)
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

    /// Creates a new GetSpaceCornerRadiusUseCase instance.
    /// - Returns: A new GetSpaceCornerRadiusUseCase instance
    func makeGetSpaceCornerRadiusUseCase() -> GetSpaceCornerRadiusUseCase {
        GetSpaceCornerRadiusUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetSpaceCornerRadiusUseCase instance.
    /// - Returns: A new SetSpaceCornerRadiusUseCase instance
    func makeSetSpaceCornerRadiusUseCase() -> SetSpaceCornerRadiusUseCase {
        SetSpaceCornerRadiusUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new GetSpaceBackgroundTintColorUseCase instance.
    /// - Returns: A new GetSpaceBackgroundTintColorUseCase instance
    func makeGetSpaceBackgroundTintColorUseCase() -> GetSpaceBackgroundTintColorUseCase {
        GetSpaceBackgroundTintColorUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetSpaceBackgroundTintColorUseCase instance.
    /// - Returns: A new SetSpaceBackgroundTintColorUseCase instance
    func makeSetSpaceBackgroundTintColorUseCase() -> SetSpaceBackgroundTintColorUseCase {
        SetSpaceBackgroundTintColorUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new GetSpaceForegroundColorUseCase instance.
    /// - Returns: A new GetSpaceForegroundColorUseCase instance
    func makeGetSpaceForegroundColorUseCase() -> GetSpaceForegroundColorUseCase {
        GetSpaceForegroundColorUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetSpaceForegroundColorUseCase instance.
    /// - Returns: A new SetSpaceForegroundColorUseCase instance
    func makeSetSpaceForegroundColorUseCase() -> SetSpaceForegroundColorUseCase {
        SetSpaceForegroundColorUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new GetSpaceBorderTintColorUseCase instance.
    /// - Returns: A new GetSpaceBorderTintColorUseCase instance
    func makeGetSpaceBorderTintColorUseCase() -> GetSpaceBorderTintColorUseCase {
        GetSpaceBorderTintColorUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetSpaceBorderTintColorUseCase instance.
    /// - Returns: A new SetSpaceBorderTintColorUseCase instance
    func makeSetSpaceBorderTintColorUseCase() -> SetSpaceBorderTintColorUseCase {
        SetSpaceBorderTintColorUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new GetSpaceBorderOpacityUseCase instance.
    /// - Returns: A new GetSpaceBorderOpacityUseCase instance
    func makeGetSpaceBorderOpacityUseCase() -> GetSpaceBorderOpacityUseCase {
        GetSpaceBorderOpacityUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetSpaceBorderOpacityUseCase instance.
    /// - Returns: A new SetSpaceBorderOpacityUseCase instance
    func makeSetSpaceBorderOpacityUseCase() -> SetSpaceBorderOpacityUseCase {
        SetSpaceBorderOpacityUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new GetSpaceBorderWidthUseCase instance.
    /// - Returns: A new GetSpaceBorderWidthUseCase instance
    func makeGetSpaceBorderWidthUseCase() -> GetSpaceBorderWidthUseCase {
        GetSpaceBorderWidthUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetSpaceBorderWidthUseCase instance.
    /// - Returns: A new SetSpaceBorderWidthUseCase instance
    func makeSetSpaceBorderWidthUseCase() -> SetSpaceBorderWidthUseCase {
        SetSpaceBorderWidthUseCase(configurationGateway: configurationGateway)
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
