// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import AppKit
internal import AsyncFileMonitor
import Combine
import Domain
import Foundation
import SwiftUI
internal import TOMLKit

/// Repository for managing application configuration and settings.
///
/// This gateway provides centralized access to application configuration,
/// including UI constants, external dependencies, refresh intervals,
/// and user preferences. It uses reactive patterns with Combine publishers
/// to emit updates when configuration values change.
/// This is the data layer implementation of the ConfigurationGateway.
@MainActor
public final class ConfigurationRepository: ConfigurationGateway {
    /// Cancellables for publisher subscriptions.
    private var cancellables = Set<AnyCancellable>()

    /// File monitor for watching configuration file changes.
    private var fileMonitor: Task<Void, Never>?

    /// Flag to prevent recursive updates during file monitoring.
    private var isUpdatingFromFile = false

    /// Timestamp of last save operation to prevent loading immediately after save.
    private var lastSaveTimestamp: Date?

    /// Time interval to ignore file changes after a save (in seconds).
    private let saveDebounceInterval: TimeInterval = 1.0

    /// Subject for showing window titles.
    private let showWindowTitlesSubject = CurrentValueSubject<Bool, Never>(
        ConfigurationDefaults.showWindowTitles
    )

    /// Subject for AeroSpace path.
    private let aeroSpacePathSubject = CurrentValueSubject<String, Never>(
        ""
    )

    /// Subject for config file path.
    private let configFilePathSubject = CurrentValueSubject<String, Never>(
        ConfigurationDefaults.configFilePath
    )

    /// Subject for tracking whether user has been asked for screen capture permissions.
    private let hasAskedForScreenCapturePermissionsSubject = CurrentValueSubject<Bool, Never>(
        UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasAskedForScreenCapturePermissions.rawValue)
    )

    /// Subject for current AeroSpace version.
    private let currentAeroSpaceVersionSubject = CurrentValueSubject<String?, Never>(
        nil
    )

    /// Subject for focus window on click.
    private let focusWindowOnClickSubject = CurrentValueSubject<Bool, Never>(
        ConfigurationDefaults.focusWindowOnClick
    )

    /// Subject for show empty spaces.
    private let showEmptySpacesSubject = CurrentValueSubject<Bool, Never>(
        ConfigurationDefaults.showEmptySpaces
    )

    /// Subject for show groups.
    private let showGroupsSubject = CurrentValueSubject<Bool, Never>(
        ConfigurationDefaults.showGroups
    )

    /// Subject for enable performance metrics.
    private let enablePerformanceMetricsSubject = CurrentValueSubject<Bool, Never>(
        ConfigurationDefaults.enablePerformanceMetrics
    )

    /// Subject for optimized performance flag.
    private let isOptimizedPerformanceEnabledSubject = CurrentValueSubject<Bool, Never>(
        ConfigurationDefaults.isOptimizedPerformanceEnabled
    )

    /// Subject for log level.
    private let logLevelSubject = CurrentValueSubject<Logger.Level, Never>(
        ConfigurationDefaults.logLevel
    )

    // MARK: - UI Configuration Subjects

    private let spacesColorPropertiesSubject = CurrentValueSubject<[ColorProperties], Never>(
        ConfigurationDefaults.spacesColorProperties
    )

    private let spacesGeometricPropertiesSubject = CurrentValueSubject<[GeometricProperties], Never>(
        ConfigurationDefaults.spacesGeometricProperties
    )

    private let spacesEffectPropertiesSubject = CurrentValueSubject<[EffectProperties], Never>(
        ConfigurationDefaults.spacesEffectProperties
    )

    private let spacesAppearanceModeSubject = CurrentValueSubject<SpacesAppearanceMode, Never>(
        ConfigurationDefaults.spacesAppearanceMode
    )

    private let globalSpacesColorPropertiesSubject = CurrentValueSubject<ColorProperties, Never>(
        ConfigurationDefaults.spaceColorProperties
    )

    private let globalSpacesGeometricPropertiesSubject = CurrentValueSubject<GeometricProperties, Never>(
        ConfigurationDefaults.spaceGeometricProperties
    )

    private let globalSpacesEffectPropertiesSubject = CurrentValueSubject<EffectProperties, Never>(
        ConfigurationDefaults.spaceEffectProperties
    )

    private let groupsSubject = CurrentValueSubject<[Domain.Group], Never>(
        ConfigurationDefaults.groups
    )

    private let groupsAppearanceModeSubject = CurrentValueSubject<GroupsAppearanceMode, Never>(
        ConfigurationDefaults.groupsAppearanceMode
    )

    private let globalGroupsColorPropertiesSubject = CurrentValueSubject<ColorProperties, Never>(
        ConfigurationDefaults.groupsGlobalColorProperties
    )

    private let globalGroupsGeometricPropertiesSubject = CurrentValueSubject<GeometricProperties, Never>(
        ConfigurationDefaults.groupsGlobalGeometricProperties
    )

    private let globalGroupsEffectPropertiesSubject = CurrentValueSubject<EffectProperties, Never>(
        ConfigurationDefaults.groupsGlobalEffectProperties
    )

    private let themeModeSubject = CurrentValueSubject<ThemeMode, Never>(
        ConfigurationDefaults.themeMode
    )

    private let themePresetColorPropertiesSubject = CurrentValueSubject<ThemePresetColorProperties, Never>(
        ConfigurationDefaults.themePresetColorProperties
    )

    private let themePresetGeometricPropertiesSubject = CurrentValueSubject<GeometricProperties, Never>(
        ConfigurationDefaults.themePresetGeometricProperties
    )

    private let themePresetEffectPropertiesSubject = CurrentValueSubject<EffectProperties, Never>(
        ConfigurationDefaults.themePresetEffectProperties
    )

    // MARK: - Publishers

    public var showWindowTitlesPublisher: AnyPublisher<Bool, Never> {
        showWindowTitlesSubject.eraseToAnyPublisher()
    }

    public var aeroSpacePathPublisher: AnyPublisher<String, Never> {
        aeroSpacePathSubject.eraseToAnyPublisher()
    }

    public var currentAeroSpaceVersionPublisher: AnyPublisher<String?, Never> {
        currentAeroSpaceVersionSubject.eraseToAnyPublisher()
    }

    public var focusWindowOnClickPublisher: AnyPublisher<Bool, Never> {
        focusWindowOnClickSubject.eraseToAnyPublisher()
    }

    public var showEmptySpacesPublisher: AnyPublisher<Bool, Never> {
        showEmptySpacesSubject.eraseToAnyPublisher()
    }

    public var showGroupsPublisher: AnyPublisher<Bool, Never> {
        showGroupsSubject.eraseToAnyPublisher()
    }

    public var enablePerformanceMetricsPublisher: AnyPublisher<Bool, Never> {
        enablePerformanceMetricsSubject.eraseToAnyPublisher()
    }

    public var isOptimizedPerformanceEnabledPublisher: AnyPublisher<Bool, Never> {
        isOptimizedPerformanceEnabledSubject.eraseToAnyPublisher()
    }

    public var logLevelPublisher: AnyPublisher<Logger.Level, Never> {
        logLevelSubject.eraseToAnyPublisher()
    }

    public var configFilePathPublisher: AnyPublisher<String, Never> {
        configFilePathSubject.eraseToAnyPublisher()
    }

    public var hasAskedForScreenCapturePermissionsPublisher: AnyPublisher<Bool, Never> {
        hasAskedForScreenCapturePermissionsSubject.eraseToAnyPublisher()
    }

    // MARK: - UI Configuration Publishers

    public var globalSpacesColorPropertiesPublisher: AnyPublisher<ColorProperties, Never> {
        globalSpacesColorPropertiesSubject.eraseToAnyPublisher()
    }

    public var globalSpacesGeometricPropertiesPublisher: AnyPublisher<GeometricProperties, Never> {
        globalSpacesGeometricPropertiesSubject.eraseToAnyPublisher()
    }

    public var globalSpacesEffectPropertiesPublisher: AnyPublisher<EffectProperties, Never> {
        globalSpacesEffectPropertiesSubject.eraseToAnyPublisher()
    }

    public var spacesColorPropertiesPublisher: AnyPublisher<[ColorProperties], Never> {
        spacesColorPropertiesSubject.eraseToAnyPublisher()
    }

    public var spacesGeometricPropertiesPublisher: AnyPublisher<[GeometricProperties], Never> {
        spacesGeometricPropertiesSubject.eraseToAnyPublisher()
    }

    public var spacesEffectPropertiesPublisher: AnyPublisher<[EffectProperties], Never> {
        spacesEffectPropertiesSubject.eraseToAnyPublisher()
    }

    public var spacesAppearanceModePublisher: AnyPublisher<SpacesAppearanceMode, Never> {
        spacesAppearanceModeSubject.eraseToAnyPublisher()
    }

    public var groupsPublisher: AnyPublisher<[Domain.Group], Never> {
        groupsSubject.eraseToAnyPublisher()
    }

    public var groupsAppearanceModePublisher: AnyPublisher<GroupsAppearanceMode, Never> {
        groupsAppearanceModeSubject.eraseToAnyPublisher()
    }

    public var globalGroupsColorPropertiesPublisher: AnyPublisher<ColorProperties, Never> {
        globalGroupsColorPropertiesSubject.eraseToAnyPublisher()
    }

    public var globalGroupsGeometricPropertiesPublisher: AnyPublisher<GeometricProperties, Never> {
        globalGroupsGeometricPropertiesSubject.eraseToAnyPublisher()
    }

    public var globalGroupsEffectPropertiesPublisher: AnyPublisher<EffectProperties, Never> {
        globalGroupsEffectPropertiesSubject.eraseToAnyPublisher()
    }

    public var themeModePublisher: AnyPublisher<ThemeMode, Never> {
        themeModeSubject.eraseToAnyPublisher()
    }

    public var themePresetColorPropertiesPublisher: AnyPublisher<ThemePresetColorProperties, Never> {
        themePresetColorPropertiesSubject.eraseToAnyPublisher()
    }

    public var themePresetGeometricPropertiesPublisher: AnyPublisher<GeometricProperties, Never> {
        themePresetGeometricPropertiesSubject.eraseToAnyPublisher()
    }

    public var themePresetEffectPropertiesPublisher: AnyPublisher<EffectProperties, Never> {
        themePresetEffectPropertiesSubject.eraseToAnyPublisher()
    }

    private var advancedSettings: AdvancedSettings<RequiredMode> {
        get {
            AdvancedSettings<RequiredMode>(
                focusWindowOnClick: focusWindowOnClickSubject.value,
                enablePerformanceMetrics: enablePerformanceMetricsSubject.value,
                isOptimizedPerformanceEnabled: isOptimizedPerformanceEnabledSubject.value,
                logLevel: logLevelSubject.value.rawValue
            )
        }

        set {
            focusWindowOnClickSubject.send(newValue.focusWindowOnClick)
            enablePerformanceMetricsSubject.send(newValue.enablePerformanceMetrics)
            isOptimizedPerformanceEnabledSubject.send(newValue.isOptimizedPerformanceEnabled)
            logLevelSubject.send(
                Logger.Level.allCases.first(
                    where: { $0.rawValue == newValue.logLevel }
                ) ?? ConfigurationDefaults.logLevel
            )
        }
    }

    private var generalSettings: GeneralSettings<RequiredMode> {
        get {
            GeneralSettings<RequiredMode>(
                showWindowTitles: showWindowTitlesSubject.value,
                aeroSpacePath: aeroSpacePathSubject.value,
                themeMode: themeModeSubject.value,
                themePresetColorProperties: themePresetColorPropertiesSubject.value,
                themePresetGeometricProperties: themePresetGeometricPropertiesSubject.value,
                themePresetEffectProperties: themePresetEffectPropertiesSubject.value
            )
        }

        set {
            showWindowTitlesSubject.send(newValue.showWindowTitles)
            aeroSpacePathSubject.send(newValue.aeroSpacePath)
            themeModeSubject.send(newValue.themeMode)
            themePresetColorPropertiesSubject.send(newValue.themePresetColorProperties)
            themePresetGeometricPropertiesSubject.send(newValue.themePresetGeometricProperties)
            themePresetEffectPropertiesSubject.send(newValue.themePresetEffectProperties)
        }
    }

    private var groupsSettings: GroupsSettings<RequiredMode> {
        get {
            GroupsSettings<RequiredMode>(
                showGroups: showGroupsSubject.value,
                groups: groupsSubject.value,
                groupsAppearanceMode: groupsAppearanceModeSubject.value.rawValue,
                globalGroupsColorProperties: globalGroupsColorPropertiesSubject.value,
                globalGroupsGeometricProperties: globalGroupsGeometricPropertiesSubject.value,
                globalGroupsEffectProperties: globalGroupsEffectPropertiesSubject.value
            )
        }

        set {
            showGroupsSubject.send(newValue.showGroups)
            groupsSubject.send(newValue.groups)
            groupsAppearanceModeSubject.send(
                GroupsAppearanceMode.allCases.first(
                    where: { $0.rawValue == newValue.groupsAppearanceMode }
                ) ?? ConfigurationDefaults.groupsAppearanceMode
            )
            globalGroupsColorPropertiesSubject.send(newValue.globalGroupsColorProperties)
            globalGroupsGeometricPropertiesSubject.send(newValue.globalGroupsGeometricProperties)
            globalGroupsEffectPropertiesSubject.send(newValue.globalGroupsEffectProperties)
        }
    }

    private var spacesSettings: SpacesSettings<RequiredMode> {
        get {
            SpacesSettings<RequiredMode>(
                showEmptySpaces: showEmptySpacesSubject.value,
                spacesColorProperties: spacesColorPropertiesSubject.value,
                spacesGeometricProperties: spacesGeometricPropertiesSubject.value,
                spacesEffectProperties: spacesEffectPropertiesSubject.value,
                spacesAppearanceMode: spacesAppearanceModeSubject.value.rawValue,
                globalSpacesColorProperties: globalSpacesColorPropertiesSubject.value,
                globalSpacesGeometricProperties: globalSpacesGeometricPropertiesSubject.value,
                globalSpacesEffectProperties: globalSpacesEffectPropertiesSubject.value
            )
        }

        set {
            showEmptySpacesSubject.send(newValue.showEmptySpaces)
            spacesColorPropertiesSubject.send(newValue.spacesColorProperties)
            spacesGeometricPropertiesSubject.send(newValue.spacesGeometricProperties)
            spacesEffectPropertiesSubject.send(newValue.spacesEffectProperties)
            spacesAppearanceModeSubject.send(
                SpacesAppearanceMode.allCases.first(
                    where: { $0.rawValue == newValue.spacesAppearanceMode }
                ) ?? ConfigurationDefaults.spacesAppearanceMode
            )
            globalSpacesColorPropertiesSubject.send(newValue.globalSpacesColorProperties)
            globalSpacesGeometricPropertiesSubject.send(newValue.globalSpacesGeometricProperties)
            globalSpacesEffectPropertiesSubject.send(newValue.globalSpacesEffectProperties)
        }
    }

    private var configurationData: ConfigurationData<RequiredMode> {
        get {
            ConfigurationData(
                general: generalSettings,
                spaces: spacesSettings,
                groups: groupsSettings,
                advanced: advancedSettings
            )
        }

        set {
            generalSettings = newValue.general
            spacesSettings = newValue.spaces
            groupsSettings = newValue.groups
            advancedSettings = newValue.advanced
        }
    }

    /// Initializer for the configuration gateway.
    public init() {
        setupObservers()

        loadInitialAeroSpaceConfiguration()
        loadApplicationSettings()

        // Setup file monitoring
        setupFileMonitoring()
    }

    deinit {
        fileMonitor?.cancel()
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Private Helper Methods

    /// Load initial configuration values and emit to subjects.
    /// This includes checking paths and setting up default configurations.
    private func loadInitialAeroSpaceConfiguration() {
        // Set AeroSpace path using auto-detection
        let resolvedPath = resolveAeroSpacePath()
        aeroSpacePathSubject.send(resolvedPath)
    }

    /// Load application settings from TOML configuration.
    private func loadApplicationSettings() {
        // Load config file path from UserDefaults (needed to bootstrap TOML loading)
        let configPath = UserDefaults.standard.string(forKey: UserDefaultsKeys.configFilePath.rawValue)
            ?? ConfigurationDefaults.configFilePath
        configFilePathSubject.send(configPath)

        // Load configuration from TOML file
        loadUIConfigurationSettings()
        ensureConfigurationFileExists()

        Task {
            loadConfigurationFromFile()
        }
    }

    /// Load UI configuration settings with defaults fallback.
    private func loadUIConfigurationSettings() {
        // Initialize with defaults - TOML file loading will override these if present
        spacesColorPropertiesSubject.send(ConfigurationDefaults.spacesColorProperties)
        spacesGeometricPropertiesSubject.send(ConfigurationDefaults.spacesGeometricProperties)
        spacesEffectPropertiesSubject.send(ConfigurationDefaults.spacesEffectProperties)
        spacesAppearanceModeSubject.send(ConfigurationDefaults.spacesAppearanceMode)
        globalSpacesColorPropertiesSubject.send(ConfigurationDefaults.spaceColorProperties)
        globalSpacesGeometricPropertiesSubject.send(ConfigurationDefaults.spaceGeometricProperties)
        globalSpacesEffectPropertiesSubject.send(ConfigurationDefaults.spaceEffectProperties)
        groupsSubject.send(ConfigurationDefaults.groups)
        groupsAppearanceModeSubject.send(ConfigurationDefaults.groupsAppearanceMode)
        globalGroupsColorPropertiesSubject.send(ConfigurationDefaults.groupsGlobalColorProperties)
        globalGroupsGeometricPropertiesSubject.send(ConfigurationDefaults.groupsGlobalGeometricProperties)
        globalGroupsEffectPropertiesSubject.send(ConfigurationDefaults.groupsGlobalEffectProperties)
        themeModeSubject.send(ConfigurationDefaults.themeMode)
        themePresetColorPropertiesSubject.send(ConfigurationDefaults.themePresetColorProperties)
        themePresetGeometricPropertiesSubject.send(ConfigurationDefaults.themePresetGeometricProperties)
        themePresetEffectPropertiesSubject.send(ConfigurationDefaults.themePresetEffectProperties)
    }

    /// Resolves the AeroSpace path following the expected initialization logic.
    /// - Returns: A valid AeroSpace path or empty string if not found
    private func resolveAeroSpacePath() -> String {
        let defaultPath = "/opt/homebrew/bin/aerospace"
        let candidates = [
            defaultPath,
            "/usr/local/bin/aerospace"
        ]

        for candidate in candidates where FileManager.default.isExecutableFile(atPath: candidate) {
            Logger.info("Auto-detected AeroSpace at: \(candidate)", category: Logger.config)
            return candidate
        }

        Logger.info("No AeroSpace executable found, using default path", category: Logger.config)
        return defaultPath
    }

    /// Sets whether to show window titles and emits update.
    public func setShowWindowTitles(_ value: Bool) {
        if value == showWindowTitlesSubject.value { return }

        Logger.debug(
            "setShowWindowTitles(\(value)) called, isUpdatingFromFile: \(isUpdatingFromFile)",
            category: Logger.config
        )
        showWindowTitlesSubject.send(value)
        Task {
            if !isUpdatingFromFile {
                Logger.debug("Saving configuration to file after setShowWindowTitles", category: Logger.config)
                saveConfigurationToFile()
            }
        }
    }

    /// Sets the AeroSpace path and emits update.
    public func setAeroSpacePath(_ path: String) {
        if path == aeroSpacePathSubject.value { return }

        let resolvedPath = path.isEmpty ? resolveAeroSpacePath() : path
        aeroSpacePathSubject.send(resolvedPath)
        Task {
            if !isUpdatingFromFile {
                saveConfigurationToFile()
            }
        }
    }

    /// Sets whether to focus window on click and emits update.
    public func setFocusWindowOnClick(_ value: Bool) {
        if value == focusWindowOnClickSubject.value { return }

        focusWindowOnClickSubject.send(value)
        Task {
            if !isUpdatingFromFile {
                saveConfigurationToFile()
            }
        }
    }

    /// Sets whether to show empty spaces and emits update.
    public func setShowEmptySpaces(_ value: Bool) {
        if value == showEmptySpacesSubject.value { return }

        showEmptySpacesSubject.send(value)
        Task {
            if !isUpdatingFromFile {
                saveConfigurationToFile()
            }
        }
    }

    /// Sets whether to show groups and emits update.
    public func setShowGroups(_ value: Bool) {
        if value == showGroupsSubject.value { return }

        showGroupsSubject.send(value)
        Task {
            if !isUpdatingFromFile {
                saveConfigurationToFile()
            }
        }
    }

    /// Sets whether performance metrics are enabled and emits update.
    public func setEnablePerformanceMetrics(_ value: Bool) {
        if value == enablePerformanceMetricsSubject.value { return }

        enablePerformanceMetricsSubject.send(value)
        Task {
            if !isUpdatingFromFile {
                saveConfigurationToFile()
            }
        }
    }

    /// Sets whether optimized performance is enabled and emits update.
    public func setIsOptimizedPerformanceEnabled(_ value: Bool) {
        if value == isOptimizedPerformanceEnabledSubject.value { return }

        isOptimizedPerformanceEnabledSubject.send(value)
        Task {
            if !isUpdatingFromFile {
                saveConfigurationToFile()
            }
        }
    }

    /// Sets the log level and emits update.
    public func setLogLevel(_ level: Logger.Level) {
        if level == logLevelSubject.value { return }

        logLevelSubject.send(level)
        Task {
            if !isUpdatingFromFile {
                saveConfigurationToFile()
            }
        }
    }

    /// Sets the config file path and emits update.
    public func setConfigFilePath(_ path: String) {
        if path == configFilePathSubject.value { return }

        UserDefaults.standard.set(path, forKey: UserDefaultsKeys.configFilePath.rawValue)
        configFilePathSubject.send(path)

        // Restart file monitoring with new path
        setupFileMonitoring()
    }

    /// Sets whether the user has been asked for screen capture permissions.
    public func setHasAskedForScreenCapturePermissions(_ value: Bool) {
        if value == hasAskedForScreenCapturePermissionsSubject.value { return }

        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.hasAskedForScreenCapturePermissions.rawValue)
        hasAskedForScreenCapturePermissionsSubject.send(value)
    }

    // MARK: - UI Configuration Async Setters

    /// Sets the vertical padding for the menu bar interface in points.

    /// Sets the spaces configuration and emits update.
    public func setSpacesColorProperties(_ value: [ColorProperties]) {
        if value == spacesColorPropertiesSubject.value { return }

        spacesColorPropertiesSubject.send(value)
        Task {
            if !isUpdatingFromFile {
                saveConfigurationToFile()
            }
        }
    }

    /// Sets the spaces geometric properties and emits update.
    public func setSpacesGeometricProperties(_ value: [GeometricProperties]) {
        if value == spacesGeometricPropertiesSubject.value { return }

        spacesGeometricPropertiesSubject.send(value)
        Task {
            if !isUpdatingFromFile {
                saveConfigurationToFile()
            }
        }
    }

    /// Sets the spaces effect properties and emits update.
    public func setSpacesEffectProperties(_ value: [EffectProperties]) {
        if value == spacesEffectPropertiesSubject.value { return }

        spacesEffectPropertiesSubject.send(value)
        Task {
            if !isUpdatingFromFile {
                saveConfigurationToFile()
            }
        }
    }

    /// Sets the spaces appearance mode and emits update.
    public func setSpacesAppearanceMode(_ value: SpacesAppearanceMode) {
        if value == spacesAppearanceModeSubject.value { return }

        spacesAppearanceModeSubject.send(value)
        Task {
            if !isUpdatingFromFile {
                saveConfigurationToFile()
            }
        }
    }

    /// Sets the global space color properties and emits update.
    public func setGlobalSpacesColorProperties(_ value: ColorProperties) {
        if value == globalSpacesColorPropertiesSubject.value { return }

        globalSpacesColorPropertiesSubject.send(value)
        Task {
            if !isUpdatingFromFile {
                saveConfigurationToFile()
            }
        }
    }

    /// Sets the global space geometric properties and emits update.
    public func setGlobalSpacesGeometricProperties(_ value: GeometricProperties) {
        if value == globalSpacesGeometricPropertiesSubject.value { return }

        globalSpacesGeometricPropertiesSubject.send(value)
        Task {
            if !isUpdatingFromFile {
                saveConfigurationToFile()
            }
        }
    }

    /// Sets the global space effect properties and emits update.
    public func setGlobalSpacesEffectProperties(_ value: EffectProperties) {
        if value == globalSpacesEffectPropertiesSubject.value { return }

        globalSpacesEffectPropertiesSubject.send(value)
        Task {
            if !isUpdatingFromFile {
                saveConfigurationToFile()
            }
        }
    }

    /// Sets the group configuration for menu bar applications and emits update.
    public func setGroups(_ value: [Domain.Group]) {
        if value == groupsSubject.value { return }

        groupsSubject.send(value)
        Task {
            if !isUpdatingFromFile {
                saveConfigurationToFile()
            }
        }
    }

    /// Sets the groups appearance mode and emits update.
    public func setGroupsAppearanceMode(_ value: GroupsAppearanceMode) {
        if value == groupsAppearanceModeSubject.value { return }

        groupsAppearanceModeSubject.send(value)
        Task {
            if !isUpdatingFromFile {
                saveConfigurationToFile()
            }
        }
    }

    /// Sets the global groups color properties and emits update.
    public func setGlobalGroupsColorProperties(_ value: ColorProperties) {
        if value == globalGroupsColorPropertiesSubject.value { return }

        globalGroupsColorPropertiesSubject.send(value)
        Task {
            if !isUpdatingFromFile {
                saveConfigurationToFile()
            }
        }
    }

    /// Sets the global groups geometric properties and emits update.
    public func setGlobalGroupsGeometricProperties(_ value: GeometricProperties) {
        if value == globalGroupsGeometricPropertiesSubject.value { return }

        globalGroupsGeometricPropertiesSubject.send(value)
        Task {
            if !isUpdatingFromFile {
                saveConfigurationToFile()
            }
        }
    }

    /// Sets the global groups effect properties and emits update.
    public func setGlobalGroupsEffectProperties(_ value: EffectProperties) {
        if value == globalGroupsEffectPropertiesSubject.value { return }

        globalGroupsEffectPropertiesSubject.send(value)
        Task {
            if !isUpdatingFromFile {
                saveConfigurationToFile()
            }
        }
    }

    /// Sets the theme mode and emits update.
    public func setThemeMode(_ value: ThemeMode) {
        if value == themeModeSubject.value { return }

        themeModeSubject.send(value)
        Task {
            if !isUpdatingFromFile {
                saveConfigurationToFile()
            }
        }
    }

    /// Sets the theme preset and emits update.
    public func setThemePresetColorProperties(_ value: ThemePresetColorProperties) {
        if value == themePresetColorPropertiesSubject.value { return }

        themePresetColorPropertiesSubject.send(value)
        Task {
            if !isUpdatingFromFile {
                saveConfigurationToFile()
            }
        }
    }

    /// Sets the theme preset geometric properties and emits update.
    public func setThemePresetGeometricProperties(_ value: GeometricProperties) {
        if value == themePresetGeometricPropertiesSubject.value { return }

        themePresetGeometricPropertiesSubject.send(value)
        Task {
            if !isUpdatingFromFile {
                saveConfigurationToFile()
            }
        }
    }

    /// Sets the theme preset effect properties and emits update.
    public func setThemePresetEffectProperties(_ value: EffectProperties) {
        if value == themePresetEffectPropertiesSubject.value { return }

        themePresetEffectPropertiesSubject.send(value)
        Task {
            if !isUpdatingFromFile {
                saveConfigurationToFile()
            }
        }
    }

    // MARK: - AeroSpace Integration

    /// Sets up observers for the configuration repository.
    private func setupObservers() {
        aeroSpacePathPublisher
            .sink { [weak self] path in
                Task { @MainActor [weak self] in
                    let version = await self?.getAeroSpaceVersion(at: path)
                    self?.currentAeroSpaceVersionSubject.send(version)
                }
            }
            .store(in: &cancellables)
    }

    /// Gets the version of the AeroSpace binary at the specified path.
    /// - Parameter path: The path to check for AeroSpace version
    /// - Returns: The version string if found, nil otherwise
    private func getAeroSpaceVersion(at path: String) async -> String? {
        if path.isEmpty { return nil }

        do {
            let cli = AeroSpaceCLIClient(executablePath: path)
            let data = try await cli.execute(arguments: ["--version"])

            if
                let output = String(data: data, encoding: .utf8)?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            {
                // Extract just the CLI client version from the first line
                let lines = output.components(separatedBy: .newlines)
                if let firstLine = lines.first {
                    // Look for "aerospace CLI client version: " and extract what follows
                    let prefix = "aerospace CLI client version: "
                    if firstLine.hasPrefix(prefix) {
                        let fullVersion = String(firstLine.dropFirst(prefix.count))
                        // Extract only the version number (before the SHA)
                        let components = fullVersion.components(separatedBy: " ")
                        if let versionNumber = components.first {
                            Logger.info(
                                "AeroSpace version detected: \(versionNumber)",
                                category: Logger.config
                            )
                            return versionNumber
                        }
                    }
                }
            }
        } catch {
            Logger.warning(
                "Failed to get AeroSpace version: \(error.localizedDescription)",
                category: Logger.config
            )
        }

        return nil
    }

    /// Opens the AeroSpace configuration file.
    /// If no config file exists, creates a default one.
    public func openAeroSpaceConfig() async {
        let configPath = await getAeroSpaceConfigPath()
        NSWorkspace.shared.open(configPath)
    }

    /// Gets the AeroSpace configuration file path, creating a default one if needed
    public func getAeroSpaceConfigPath() async -> URL {
        let cliPath = await fetchAeroSpaceConfigPathFromCLI()
        return if let path = cliPath, !path.isEmpty {
            URL(fileURLWithPath: path)
        } else {
            URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent(".aerospace.toml")
        }
    }

    /// Gets the configuration file path.
    public func getConfigFilePath() -> String {
        configFilePathSubject.value
    }

    /// Opens the configuration file.
    public func openConfigFile() {
        let configPath = getConfigFilePath()
        NSWorkspace.shared.open(URL(fileURLWithPath: configPath))
    }

    /// Ask AeroSpace CLI for the effective config path
    private func fetchAeroSpaceConfigPathFromCLI() async -> String? {
        let executablePath = aeroSpacePathSubject.value
        do {
            let cli = AeroSpaceCLIClient(executablePath: executablePath)
            let data = try await cli.execute(arguments: ["config", "--config-path"])
            return String(data: data, encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            Logger.error(
                "Failed to obtain AeroSpace config path from CLI",
                error: error,
                category: Logger.config
            )
            return nil
        }
    }

    /// Resets all configuration settings to their default values.
    public func resetToDefaults() {
        // Reset all subjects to default values without triggering file saves
        isUpdatingFromFile = true

        setConfigFilePath(ConfigurationDefaults.configFilePath)
        setHasAskedForScreenCapturePermissions(false)
        loadInitialAeroSpaceConfiguration()
        showWindowTitlesSubject.send(ConfigurationDefaults.showWindowTitles)
        focusWindowOnClickSubject.send(ConfigurationDefaults.focusWindowOnClick)
        showEmptySpacesSubject.send(ConfigurationDefaults.showEmptySpaces)
        showGroupsSubject.send(ConfigurationDefaults.showGroups)
        enablePerformanceMetricsSubject.send(ConfigurationDefaults.enablePerformanceMetrics)
        isOptimizedPerformanceEnabledSubject.send(ConfigurationDefaults.isOptimizedPerformanceEnabled)
        logLevelSubject.send(ConfigurationDefaults.logLevel)

        // Reset UI configuration subjects
        spacesColorPropertiesSubject.send(ConfigurationDefaults.spacesColorProperties)
        spacesGeometricPropertiesSubject.send(ConfigurationDefaults.spacesGeometricProperties)
        spacesEffectPropertiesSubject.send(ConfigurationDefaults.spacesEffectProperties)
        spacesAppearanceModeSubject.send(ConfigurationDefaults.spacesAppearanceMode)
        globalSpacesColorPropertiesSubject.send(ConfigurationDefaults.spaceColorProperties)
        globalSpacesGeometricPropertiesSubject.send(ConfigurationDefaults.spaceGeometricProperties)
        globalSpacesEffectPropertiesSubject.send(ConfigurationDefaults.spaceEffectProperties)
        groupsSubject.send(ConfigurationDefaults.groups)
        groupsAppearanceModeSubject.send(ConfigurationDefaults.groupsAppearanceMode)
        globalGroupsColorPropertiesSubject.send(ConfigurationDefaults.groupsGlobalColorProperties)
        globalGroupsGeometricPropertiesSubject.send(ConfigurationDefaults.groupsGlobalGeometricProperties)
        globalGroupsEffectPropertiesSubject.send(ConfigurationDefaults.groupsGlobalEffectProperties)
        themeModeSubject.send(ConfigurationDefaults.themeMode)
        themePresetColorPropertiesSubject.send(ConfigurationDefaults.themePresetColorProperties)
        themePresetGeometricPropertiesSubject.send(ConfigurationDefaults.themePresetGeometricProperties)
        themePresetEffectPropertiesSubject.send(ConfigurationDefaults.themePresetEffectProperties)

        isUpdatingFromFile = false

        // Save the reset configuration to file
        Task {
            saveConfigurationToFile()
        }

        Logger.info("Configuration reset to defaults", category: Logger.config)
    }

    // MARK: - File Management

    /// Ensures the configuration file and directory exist.
    private func ensureConfigurationFileExists() {
        let configPath = configFilePathSubject.value
        let url = URL(fileURLWithPath: configPath)

        // Create directory if it doesn't exist
        let directory = url.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        // Create file if it doesn't exist
        if !FileManager.default.fileExists(atPath: configPath) {
            saveConfigurationToFile()
        }
    }

    /// Sets up file system monitoring for the configuration file.
    private func setupFileMonitoring() {
        let configPath = configFilePathSubject.value
        let url = URL(fileURLWithPath: configPath)

        // Create directory if it doesn't exist
        let directory = url.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        // Create file if it doesn't exist
        if !FileManager.default.fileExists(atPath: configPath) {
            Task {
                createDefaultConfigFile(at: configPath)
            }
        }

        // Cancel existing monitor if any
        fileMonitor?.cancel()

        // Start monitoring using AsyncFileMonitor
        fileMonitor = Task { @MainActor [weak self] in
            let eventStream = FolderContentMonitor.makeStream(url: directory, latency: 0.5)
            for await event in eventStream
                where event.change.contains(.isFile) &&
                event.filename == url.lastPathComponent
            {
                Logger.debug("Configuration file change detected, triggering reload", category: Logger.config)
                self?.loadConfigurationFromFile()
            }
        }

        Logger.info("Started monitoring configuration file: \(url.path)", category: Logger.config)
    }

    /// Creates a default configuration file with current settings.
    private func createDefaultConfigFile(at _: String) {
        saveConfigurationToFile()
    }

    /// Loads configuration from the TOML file.
    private func loadConfigurationFromFile() {
        Task { @MainActor [weak self] in
            guard let self else { return }

            // Check if we recently saved - if so, ignore this load to prevent feedback loop
            if
                let lastSave = lastSaveTimestamp,
                Date().timeIntervalSince(lastSave) < saveDebounceInterval
            {
                Logger.debug(
                    "Ignoring file load - recent save detected (debouncing)",
                    category: Logger.config
                )
                return
            }

            Logger.debug("loadConfigurationFromFile() called", category: Logger.config)
            isUpdatingFromFile = true
            defer { isUpdatingFromFile = false }

            let configPath = configFilePathSubject.value

            let fileExists = await Task.detached {
                FileManager.default.fileExists(atPath: configPath)
            }
            .value

            guard fileExists else {
                Logger.info("Config file does not exist, using defaults: \\(configPath)", category: Logger.config)
                return
            }

            do {
                let data = try await Task.detached {
                    try Data(contentsOf: URL(fileURLWithPath: configPath))
                }
                .value

                guard let tomlString = String(data: data, encoding: .utf8) else {
                    Logger.warning("Failed to read config file as UTF-8: \\(configPath)", category: Logger.config)
                    return
                }

                configurationData = try TOMLDecoder().decode(
                    type: ConfigurationData<OptionalMode>.self,
                    from: tomlString,
                    defaultValue: configurationData
                )

                Logger.info("Configuration loaded from file: \\(configPath)", category: Logger.config)
            } catch {
                Logger.warning("Failed to load configuration from file: \\(error)", category: Logger.config)
            }
        }
    }

    /// Saves current configuration to the TOML file.
    private func saveConfigurationToFile() {
        Task { @MainActor [weak self] in
            guard let self else { return }

            // Update timestamp to debounce subsequent loads
            lastSaveTimestamp = Date()

            let configPath = configFilePathSubject.value
            let url = URL(fileURLWithPath: configPath)
            let directory = url.deletingLastPathComponent()
            let configData = configurationData

            do {
                // Create directory if needed
                try await Task.detached {
                    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                }
                .value

                // Encode and annotate
                let tomlString = try TOMLEncoder().encode(configData)
                let annotatedTomlString = addEnumComments(to: tomlString)

                // Write file
                try await Task.detached {
                    try annotatedTomlString.write(to: url, atomically: true, encoding: String.Encoding.utf8)
                }
                .value

                Logger.info("Configuration saved to file: \\(configPath)", category: Logger.config)
            } catch {
                Logger.error("Failed to save configuration to file: \\(error)", category: Logger.config)
            }
        }
    }

    /// Adds helpful comments to TOML string for enum values and configuration guidance.
    private func addEnumComments(to tomlString: String) -> String {
        var annotatedString = tomlString

        // Add header comment
        let header = """
        # AeroSpaceBar Configuration File
        # This file stores all your settings in TOML format.
        # Changes are automatically saved when modified through the UI.
        # You can edit this file directly - changes will be reflected immediately.


        """

        // Generate enum comments dynamically using generics
        let enumCommentMappings: [(String, String)] = [
            ("[spaces]", generateSectionComment(
                "Spaces appearance mode",
                for: SpacesAppearanceMode.self,
                key: "appearance-mode"
            )),
            ("[groups]", generateSectionComment(
                "Groups appearance mode",
                for: GroupsAppearanceMode.self,
                key: "appearance-mode"
            )),
            ("log-level =", generateEnumComment(for: Logger.Level.self))
        ]

        for (pattern, comment) in enumCommentMappings {
            if let range = annotatedString.range(of: pattern) {
                if pattern.hasPrefix("["), pattern.hasSuffix("]") {
                    // For section headers, add comment after the section
                    let endIndex = annotatedString.lineRange(for: range).upperBound
                    annotatedString.insert(contentsOf: comment + "\n", at: endIndex)
                } else {
                    // For regular keys, add comment before the line
                    let insertIndex = annotatedString.lineRange(for: range).lowerBound
                    annotatedString.insert(contentsOf: comment + "\n", at: insertIndex)
                }
            }
        }

        return header + annotatedString
    }

    /// Generates a comment string for an enum type that conforms to CaseIterable and RawRepresentable.
    /// - Parameter enumType: The enum type to generate comments for
    /// - Returns: A formatted comment string with all possible enum values
    private func generateEnumComment<T: CaseIterable & RawRepresentable>(
        for enumType: T.Type
    ) -> String where T.RawValue == String {
        let values = enumType.allCases.map { "\"\($0.rawValue)\"" }.joined(separator: ", ")
        return "# Supported values: \(values)"
    }

    /// Generates a section-specific comment for an enum type.
    /// - Parameters:
    ///   - description: Description of what the enum controls
    ///   - enumType: The enum type to generate comments for
    ///   - key: The TOML key name for this enum
    /// - Returns: A formatted comment string with description and all possible enum values
    private func generateSectionComment<T: CaseIterable & RawRepresentable>(
        _ description: String,
        for enumType: T.Type,
        key: String
    ) -> String where T.RawValue == String {
        let values = enumType.allCases.map { "\"\($0.rawValue)\"" }.joined(separator: ", ")
        return "# \(description): \(key) = <value>\n# Supported values: \(values)"
    }
}

internal extension TOMLDecoder {
    /// Specialized decode method that uses the OptionalType protocol decode function.
    /// - Parameters:
    ///   - type: The concrete OptionType type
    ///   - tomlString: The TOML formatted string to decode
    ///   - defaultValue: The type instance for default values
    /// - Returns: The decoded type instance
    func decode<T: OptionalType>(
        type _: T.Type,
        from tomlString: String,
        defaultValue: T.RequiredVariant
    ) throws -> T.RequiredVariant {
        try T.decode(
            from: TOMLDecoder().decode(T.OptionalVariant.self, from: TOMLTable(string: tomlString)),
            defaultValue: defaultValue
        )
    }
}
