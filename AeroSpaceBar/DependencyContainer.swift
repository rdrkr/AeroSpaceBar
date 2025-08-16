// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import AppKit

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
    private lazy var spacesGateway: SpacesGateway = SpacesRepository(
        iconCache: iconCache,
        getAeroSpacePathUseCase: makeGetAeroSpacePathUseCase()
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

    /// The desktop wallpaper gateway for capturing wallpaper.
    ///
    /// This gateway is lazily initialized and provides dynamic capture of
    /// the desktop wallpaper instead of using user-selected images.
    private lazy var desktopWallpaperGateway: DesktopWallpaperGateway = DesktopWallpaperRepository()

    // MARK: - Public Access

    /// Gets the spaces gateway instance.
    /// - Returns: The spaces gateway protocol implementation
    func getSpacesGateway() -> SpacesGateway {
        spacesGateway
    }

    /// The SettingsViewModel instance.
    private lazy var settingsViewModel: SettingsViewModel = .init(
        getTransparencyUseCase: makeGetTransparencyUseCase(),
        setTransparencyUseCase: makeSetTransparencyUseCase(),
        getFocusWindowOnClickUseCase: makeGetFocusWindowOnClickUseCase(),
        setFocusWindowOnClickUseCase: makeSetFocusWindowOnClickUseCase(),
        getAeroSpacePathUseCase: makeGetAeroSpacePathUseCase(),
        setAeroSpacePathUseCase: makeSetAeroSpaceCustomPathUseCase(),
        getAeroSpaceVersionUseCase: makeGetAeroSpaceVersionUseCase(),
        openAeroSpaceConfigUseCase: makeOpenAeroSpaceConfigUseCase(),
        resetConfigurationUseCase: makeResetConfigurationUseCase(),
        getLogLevelUseCase: makeGetLogLevelUseCase(),
        setLogLevelUseCase: makeSetLogLevelUseCase(),
        getEnablePerformanceMetricsUseCase: makeGetEnablePerformanceMetricsUseCase(),
        setEnablePerformanceMetricsUseCase: makeSetEnablePerformanceMetricsUseCase()
    )

    /// Gets the settings view model instance.
    /// - Returns: The settings view model instance
    func getSettingsViewModel() -> SettingsViewModel {
        settingsViewModel
    }

    /// The SpacesViewModel instance.
    private lazy var spacesViewModel: SpacesViewModel = .init(
        getSpacesUseCase: makeGetSpacesUseCase(),
        setFocusSpaceUseCase: makeSetFocusSpaceUseCase(),
        setFocusWindowUseCase: makeSetFocusWindowUseCase(),
        getAeroSpaceStatusUseCase: makeGetAeroSpaceStatusUseCase(),
        getWallpaperUseCase: makeGetWallpaperUseCase(),
        getMenuBarHeightUseCase: makeGetMenuBarHeightUseCase(),
        getMenuBarVerticalPaddingUseCase: makeGetMenuBarVerticalPaddingUseCase(),
        getMenuBarHorizontalPaddingUseCase: makeGetMenuBarHorizontalPaddingUseCase(),
        getWidgetSpacingUseCase: makeGetWidgetSpacingUseCase(),
        getAnimationDurationUseCase: makeGetAnimationDurationUseCase(),
        getWindowIconSizeUseCase: makeGetWindowIconSizeUseCase(),
        getSpaceCornerRadiusUseCase: makeGetSpaceCornerRadiusUseCase(),
        getWindowCornerRadiusUseCase: makeGetWindowCornerRadiusUseCase()
    )

    /// Gets the spaces view model instance.
    /// - Returns: The spaces view model instance
    func getSpacesViewModel() -> SpacesViewModel {
        spacesViewModel
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

    /// Creates a new GetAeroSpaceVersionUseCase instance.
    /// - Returns: A new GetAeroSpaceVersionUseCase instance
    func makeGetAeroSpaceVersionUseCase() -> GetAeroSpaceVersionUseCase {
        GetAeroSpaceVersionUseCase(configurationGateway: configurationGateway)
    }

    // MARK: - Wallpaper Use Cases

    /// Creates a new GetWallpaperUseCase instance.
    /// - Returns: A new GetWallpaperUseCase instance
    func makeGetWallpaperUseCase() -> GetWallpaperUseCase {
        GetWallpaperUseCase(desktopWallpaperGateway: desktopWallpaperGateway)
    }

    // MARK: - Display Use Cases

    /// Creates a new GetTransparencyUseCase instance.
    /// - Returns: A new GetTransparencyUseCase instance
    func makeGetTransparencyUseCase() -> GetTransparencyUseCase {
        GetTransparencyUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetTransparencyUseCase instance.
    /// - Returns: A new SetTransparencyUseCase instance
    func makeSetTransparencyUseCase() -> SetTransparencyUseCase {
        SetTransparencyUseCase(configurationGateway: configurationGateway)
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

    // MARK: - UI Configuration Use Cases

    /// Creates a new GetMenuBarHeightUseCase instance.
    /// - Returns: A new GetMenuBarHeightUseCase instance
    func makeGetMenuBarHeightUseCase() -> GetMenuBarHeightUseCase {
        GetMenuBarHeightUseCase(desktopWallpaperGateway: desktopWallpaperGateway)
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

    /// Creates a new GetWindowCornerRadiusUseCase instance.
    /// - Returns: A new GetWindowCornerRadiusUseCase instance
    func makeGetWindowCornerRadiusUseCase() -> GetWindowCornerRadiusUseCase {
        GetWindowCornerRadiusUseCase(configurationGateway: configurationGateway)
    }

    /// Creates a new SetWindowCornerRadiusUseCase instance.
    /// - Returns: A new SetWindowCornerRadiusUseCase instance
    func makeSetWindowCornerRadiusUseCase() -> SetWindowCornerRadiusUseCase {
        SetWindowCornerRadiusUseCase(configurationGateway: configurationGateway)
    }
}
