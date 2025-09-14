// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import AppKit
import Combine
import Domain
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
public final class ConfigurationRepository: ConfigurationGateway, @unchecked Sendable {
    /// Cancellables for publisher subscriptions.
    private var cancellables = Set<AnyCancellable>()

    /// Subject for showing window titles.
    private let showWindowTitlesSubject = CurrentValueSubject<Bool, Never>(
        ConfigurationDefaults.showWindowTitles
    )

    /// Subject for AeroSpace path.
    private let aeroSpacePathSubject = CurrentValueSubject<String, Never>(
        ConfigurationDefaults.aeroSpacePath
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

    private let spaceBackgroundOpacitySubject = CurrentValueSubject<Double, Never>(
        ConfigurationDefaults.spaceBackgroundOpacity
    )

    private let spaceBackgroundBlurRadiusSubject = CurrentValueSubject<Double, Never>(
        ConfigurationDefaults.spaceBackgroundBlurRadius
    )

    private let spaceBackgroundTintColorSubject = CurrentValueSubject<Color, Never>(
        ConfigurationDefaults.spaceBackgroundTintColor
    )

    private let spaceForegroundColorSubject = CurrentValueSubject<Color, Never>(
        ConfigurationDefaults.spaceForegroundColor
    )

    private let spaceBorderTintColorSubject = CurrentValueSubject<Color, Never>(
        ConfigurationDefaults.spaceBorderTintColor
    )

    private let spaceBorderOpacitySubject = CurrentValueSubject<Double, Never>(
        ConfigurationDefaults.spaceBorderOpacity
    )

    private let spaceBorderWidthSubject = CurrentValueSubject<Double, Never>(
        ConfigurationDefaults.spaceBorderWidth
    )

    private let menuBarVerticalPaddingSubject = CurrentValueSubject<Double, Never>(
        ConfigurationDefaults.menuBarVerticalPadding
    )

    private let menuBarHorizontalPaddingSubject = CurrentValueSubject<Double, Never>(
        ConfigurationDefaults.menuBarHorizontalPadding
    )

    private let widgetSpacingSubject = CurrentValueSubject<Double, Never>(
        ConfigurationDefaults.widgetSpacing
    )

    private let animationDurationSubject = CurrentValueSubject<Double, Never>(
        ConfigurationDefaults.animationDuration
    )

    private let windowIconSizeSubject = CurrentValueSubject<Double, Never>(
        ConfigurationDefaults.windowIconSize
    )

    private let spaceCornerRadiusSubject = CurrentValueSubject<Double, Never>(
        ConfigurationDefaults.spaceCornerRadius
    )

    private let groupsConfigurationSubject = CurrentValueSubject<[Domain.Group], Never>(
        ConfigurationDefaults.groupsConfiguration
    )

    private let groupsAppearanceModeSubject = CurrentValueSubject<GroupsAppearanceMode, Never>(
        ConfigurationDefaults.groupsAppearanceMode
    )

    private let groupsGlobalBackgroundTintColorSubject = CurrentValueSubject<Color, Never>(
        ConfigurationDefaults.groupsGlobalBackgroundTintColor
    )

    private let groupsGlobalBackgroundOpacitySubject = CurrentValueSubject<Double, Never>(
        ConfigurationDefaults.groupsGlobalBackgroundOpacity
    )

    private let groupsGlobalBgBlurRadiusSubject = CurrentValueSubject<Double, Never>(
        ConfigurationDefaults.groupsGlobalBackgroundBlurRadius
    )

    private let groupsGlobalBorderColorSubject = CurrentValueSubject<Color, Never>(
        ConfigurationDefaults.groupsGlobalBorderColor
    )

    private let groupsGlobalBorderOpacitySubject = CurrentValueSubject<Double, Never>(
        ConfigurationDefaults.groupsGlobalBorderOpacity
    )

    private let groupsGlobalBorderWidthSubject = CurrentValueSubject<Double, Never>(
        ConfigurationDefaults.groupsGlobalBorderWidth
    )

    private let groupsGlobalCornerRadiusSubject = CurrentValueSubject<Double, Never>(
        ConfigurationDefaults.groupsGlobalCornerRadius
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

    // MARK: - UI Configuration Publishers

    public var spaceBackgroundOpacityPublisher: AnyPublisher<Double, Never> {
        spaceBackgroundOpacitySubject.eraseToAnyPublisher()
    }

    public var spaceBackgroundBlurRadiusPublisher: AnyPublisher<Double, Never> {
        spaceBackgroundBlurRadiusSubject.eraseToAnyPublisher()
    }

    public var spaceBackgroundTintColorPublisher: AnyPublisher<Color, Never> {
        spaceBackgroundTintColorSubject.eraseToAnyPublisher()
    }

    public var spaceForegroundColorPublisher: AnyPublisher<Color, Never> {
        spaceForegroundColorSubject.eraseToAnyPublisher()
    }

    public var spaceBorderTintColorPublisher: AnyPublisher<Color, Never> {
        spaceBorderTintColorSubject.eraseToAnyPublisher()
    }

    public var spaceBorderOpacityPublisher: AnyPublisher<Double, Never> {
        spaceBorderOpacitySubject.eraseToAnyPublisher()
    }

    public var spaceBorderWidthPublisher: AnyPublisher<Double, Never> {
        spaceBorderWidthSubject.eraseToAnyPublisher()
    }

    public var menuBarVerticalPaddingPublisher: AnyPublisher<Double, Never> {
        menuBarVerticalPaddingSubject.eraseToAnyPublisher()
    }

    public var menuBarHorizontalPaddingPublisher: AnyPublisher<Double, Never> {
        menuBarHorizontalPaddingSubject.eraseToAnyPublisher()
    }

    public var widgetSpacingPublisher: AnyPublisher<Double, Never> {
        widgetSpacingSubject.eraseToAnyPublisher()
    }

    public var animationDurationPublisher: AnyPublisher<Double, Never> {
        animationDurationSubject.eraseToAnyPublisher()
    }

    public var windowIconSizePublisher: AnyPublisher<Double, Never> {
        windowIconSizeSubject.eraseToAnyPublisher()
    }

    public var spaceCornerRadiusPublisher: AnyPublisher<Double, Never> {
        spaceCornerRadiusSubject.eraseToAnyPublisher()
    }

    public var groupsConfigurationPublisher: AnyPublisher<[Domain.Group], Never> {
        groupsConfigurationSubject.eraseToAnyPublisher()
    }

    public var groupsAppearanceModePublisher: AnyPublisher<GroupsAppearanceMode, Never> {
        groupsAppearanceModeSubject.eraseToAnyPublisher()
    }

    public var groupsGlobalBackgroundTintColorPublisher: AnyPublisher<Color, Never> {
        groupsGlobalBackgroundTintColorSubject.eraseToAnyPublisher()
    }

    public var groupsGlobalBackgroundOpacityPublisher: AnyPublisher<Double, Never> {
        groupsGlobalBackgroundOpacitySubject.eraseToAnyPublisher()
    }

    public var groupsGlobalBgBlurRadiusPublisher: AnyPublisher<Double, Never> {
        groupsGlobalBgBlurRadiusSubject.eraseToAnyPublisher()
    }

    public var groupsGlobalBorderColorPublisher: AnyPublisher<Color, Never> {
        groupsGlobalBorderColorSubject.eraseToAnyPublisher()
    }

    public var groupsGlobalBorderOpacityPublisher: AnyPublisher<Double, Never> {
        groupsGlobalBorderOpacitySubject.eraseToAnyPublisher()
    }

    public var groupsGlobalBorderWidthPublisher: AnyPublisher<Double, Never> {
        groupsGlobalBorderWidthSubject.eraseToAnyPublisher()
    }

    public var groupsGlobalCornerRadiusPublisher: AnyPublisher<Double, Never> {
        groupsGlobalCornerRadiusSubject.eraseToAnyPublisher()
    }

    /// Initializer for the configuration gateway.
    public init() {
        // Setup observers for the configuration repository
        setupObservers()

        // Initialize with current values from UserDefaults
        loadInitialValues()
    }

    // MARK: - Private Helper Methods

    /// Load initial values from UserDefaults and emit to subjects.
    private func loadInitialValues() {
        loadApplicationSettings()
        loadUIConfigurationSettings()
    }

    /// Load application settings from UserDefaults.
    private func loadApplicationSettings() {
        // Load boolean settings with proper default fallback
        let showTitles = UserDefaults.standard.object(forKey: UserDefaultsKeys.showWindowTitles.rawValue) as? Bool
            ?? showWindowTitlesSubject.value
        showWindowTitlesSubject.send(showTitles)

        // Load AeroSpace path with validation and auto-detection
        let resolvedPath = resolveAeroSpacePath()
        aeroSpacePathSubject.send(resolvedPath)

        // Load other boolean settings
        let spaceBackgroundOpacity = UserDefaults.standard
            .object(forKey: UserDefaultsKeys.spaceBackgroundOpacity.rawValue) as? Double
            ?? spaceBackgroundOpacitySubject.value
        spaceBackgroundOpacitySubject.send(spaceBackgroundOpacity)

        let spaceBackgroundBlurRadius = UserDefaults.standard
            .object(forKey: UserDefaultsKeys.spaceBackgroundBlurRadius.rawValue) as? Double
            ?? spaceBackgroundBlurRadiusSubject.value
        spaceBackgroundBlurRadiusSubject.send(spaceBackgroundBlurRadius)

        let spaceBackgroundTintColor = loadColorFromUserDefaults(
            key: UserDefaultsKeys.spaceBackgroundTintColor.rawValue,
            defaultValue: spaceBackgroundTintColorSubject.value
        )
        spaceBackgroundTintColorSubject.send(spaceBackgroundTintColor)

        let spaceForegroundColor = loadColorFromUserDefaults(
            key: UserDefaultsKeys.spaceForegroundColor.rawValue,
            defaultValue: spaceForegroundColorSubject.value
        )
        spaceForegroundColorSubject.send(spaceForegroundColor)

        let spaceBorderTintColor = loadColorFromUserDefaults(
            key: UserDefaultsKeys.spaceBorderTintColor.rawValue,
            defaultValue: spaceBorderTintColorSubject.value
        )
        spaceBorderTintColorSubject.send(spaceBorderTintColor)

        let spaceBorderOpacity = UserDefaults.standard
            .object(forKey: UserDefaultsKeys.spaceBorderOpacity.rawValue) as? Double
            ?? spaceBorderOpacitySubject.value
        spaceBorderOpacitySubject.send(spaceBorderOpacity)

        let spaceBorderWidth = UserDefaults.standard
            .object(forKey: UserDefaultsKeys.spaceBorderWidth.rawValue) as? Double
            ?? spaceBorderWidthSubject.value
        spaceBorderWidthSubject.send(spaceBorderWidth)

        let focusWindowOnClick = UserDefaults.standard
            .object(forKey: UserDefaultsKeys.focusWindowOnClick.rawValue) as? Bool
            ?? focusWindowOnClickSubject.value
        focusWindowOnClickSubject.send(focusWindowOnClick)

        let showEmptySpaces = UserDefaults.standard
            .object(forKey: UserDefaultsKeys.showEmptySpaces.rawValue) as? Bool
            ?? showEmptySpacesSubject.value
        showEmptySpacesSubject.send(showEmptySpaces)

        let showGroups = UserDefaults.standard
            .object(forKey: UserDefaultsKeys.showGroups.rawValue) as? Bool
            ?? showGroupsSubject.value
        showGroupsSubject.send(showGroups)

        let enablePerformanceMetrics = UserDefaults.standard
            .object(forKey: UserDefaultsKeys.enablePerformanceMetrics.rawValue) as? Bool
            ?? enablePerformanceMetricsSubject.value
        enablePerformanceMetricsSubject.send(enablePerformanceMetrics)

        let isOptimizedPerformanceEnabled = UserDefaults.standard
            .object(forKey: UserDefaultsKeys.isOptimizedPerformanceEnabled.rawValue) as? Bool
            ?? isOptimizedPerformanceEnabledSubject.value
        isOptimizedPerformanceEnabledSubject.send(isOptimizedPerformanceEnabled)

        let logLevelRaw = UserDefaults.standard.string(forKey: UserDefaultsKeys.logLevel.rawValue)
        let logLevel = Logger.Level(rawValue: logLevelRaw ?? "") ?? logLevelSubject.value
        logLevelSubject.send(logLevel)
    }

    /// Load UI configuration settings from UserDefaults.
    private func loadUIConfigurationSettings() {
        let menuBarVerticalPadding = UserDefaults.standard
            .object(forKey: UserDefaultsKeys.menuBarVerticalPadding.rawValue) as? Double
            ?? menuBarVerticalPaddingSubject.value
        menuBarVerticalPaddingSubject.send(menuBarVerticalPadding)

        let menuBarHorizontalPadding = UserDefaults.standard
            .object(forKey: UserDefaultsKeys.menuBarHorizontalPadding.rawValue) as? Double
            ?? menuBarHorizontalPaddingSubject.value
        menuBarHorizontalPaddingSubject.send(menuBarHorizontalPadding)

        let widgetSpacing = UserDefaults.standard.object(forKey: UserDefaultsKeys.widgetSpacing.rawValue) as? Double
            ?? widgetSpacingSubject.value
        widgetSpacingSubject.send(widgetSpacing)

        let animationDuration = UserDefaults.standard
            .object(forKey: UserDefaultsKeys.animationDuration.rawValue) as? Double
            ?? animationDurationSubject.value
        animationDurationSubject.send(animationDuration)

        let windowIconSize = UserDefaults.standard.object(forKey: UserDefaultsKeys.windowIconSize.rawValue) as? Double
            ?? windowIconSizeSubject.value
        windowIconSizeSubject.send(windowIconSize)

        let spaceCornerRadius = UserDefaults.standard
            .object(forKey: UserDefaultsKeys.spaceCornerRadius.rawValue) as? Double
            ?? spaceCornerRadiusSubject.value
        spaceCornerRadiusSubject.send(spaceCornerRadius)

        let groupsConfiguration = loadGroupsConfiguration() ?? groupsConfigurationSubject.value
        groupsConfigurationSubject.send(groupsConfiguration)

        let groupsAppearanceMode = loadGroupsAppearanceMode() ?? groupsAppearanceModeSubject.value
        groupsAppearanceModeSubject.send(groupsAppearanceMode)

        let groupsGlobalBackgroundTintColor = loadColorFromUserDefaults(
            key: UserDefaultsKeys.groupsGlobalBackgroundTintColor.rawValue,
            defaultValue: groupsGlobalBackgroundTintColorSubject.value
        )
        groupsGlobalBackgroundTintColorSubject.send(groupsGlobalBackgroundTintColor)

        let groupsGlobalBackgroundOpacity = UserDefaults.standard
            .object(forKey: UserDefaultsKeys.groupsGlobalBackgroundOpacity.rawValue) as? Double
            ?? groupsGlobalBackgroundOpacitySubject.value
        groupsGlobalBackgroundOpacitySubject.send(groupsGlobalBackgroundOpacity)

        let groupsGlobalBackgroundBlurRadius = UserDefaults.standard
            .object(forKey: UserDefaultsKeys.groupsGlobalBackgroundBlurRadius.rawValue) as? Double
            ?? groupsGlobalBgBlurRadiusSubject.value
        groupsGlobalBgBlurRadiusSubject.send(groupsGlobalBackgroundBlurRadius)

        let groupsGlobalBorderColor = loadColorFromUserDefaults(
            key: UserDefaultsKeys.groupsGlobalBorderColor.rawValue,
            defaultValue: groupsGlobalBorderColorSubject.value
        )
        groupsGlobalBorderColorSubject.send(groupsGlobalBorderColor)

        let groupsGlobalBorderOpacity = UserDefaults.standard
            .object(forKey: UserDefaultsKeys.groupsGlobalBorderOpacity.rawValue) as? Double
            ?? groupsGlobalBorderOpacitySubject.value
        groupsGlobalBorderOpacitySubject.send(groupsGlobalBorderOpacity)

        let groupsGlobalBorderWidth = UserDefaults.standard
            .object(forKey: UserDefaultsKeys.groupsGlobalBorderWidth.rawValue) as? Double
            ?? groupsGlobalBorderWidthSubject.value
        groupsGlobalBorderWidthSubject.send(groupsGlobalBorderWidth)

        let groupsGlobalCornerRadius = UserDefaults.standard
            .object(forKey: UserDefaultsKeys.groupsGlobalCornerRadius.rawValue) as? Double
            ?? groupsGlobalCornerRadiusSubject.value
        groupsGlobalCornerRadiusSubject.send(groupsGlobalCornerRadius)
    }

    /// Resolves the AeroSpace path following the expected initialization logic.
    /// - Returns: A valid AeroSpace path or empty string if not found
    private func resolveAeroSpacePath() -> String {
        if
            let storedPath = UserDefaults.standard.string(forKey: UserDefaultsKeys.aeroSpaceCustomPath.rawValue),
            !storedPath.isEmpty
        {
            if FileManager.default.isExecutableFile(atPath: storedPath) {
                Logger.info("Using stored AeroSpace path: \(storedPath)", category: Logger.config)
                return storedPath
            }
        }

        let candidates = [
            "/opt/homebrew/bin/aerospace",
            "/usr/local/bin/aerospace"
        ]

        for candidate in candidates where FileManager.default.isExecutableFile(atPath: candidate) {
            UserDefaults.standard.set(candidate, forKey: UserDefaultsKeys.aeroSpaceCustomPath.rawValue)
            Logger.info("Auto-detected AeroSpace at: \(candidate)", category: Logger.config)
            return candidate
        }

        Logger.info("No AeroSpace executable found, using default path", category: Logger.config)
        return ConfigurationDefaults.aeroSpacePath
    }

    /// Sets whether to show window titles and emits update.
    public func setShowWindowTitles(_ value: Bool) async {
        if value == showWindowTitlesSubject.value { return }

        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.showWindowTitles.rawValue)
        showWindowTitlesSubject.send(value)
    }

    /// Sets the AeroSpace path and emits update.
    public func setAeroSpacePath(_ path: String) async {
        if path == aeroSpacePathSubject.value { return }

        UserDefaults.standard.set(path, forKey: UserDefaultsKeys.aeroSpaceCustomPath.rawValue)

        let resolvedPath = path.isEmpty ? resolveAeroSpacePath() : path
        aeroSpacePathSubject.send(resolvedPath)
    }

    /// Sets whether to focus window on click and emits update.
    public func setFocusWindowOnClick(_ value: Bool) async {
        if value == focusWindowOnClickSubject.value { return }

        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.focusWindowOnClick.rawValue)
        focusWindowOnClickSubject.send(value)
    }

    /// Sets whether to show empty spaces and emits update.
    public func setShowEmptySpaces(_ value: Bool) async {
        if value == showEmptySpacesSubject.value { return }

        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.showEmptySpaces.rawValue)
        showEmptySpacesSubject.send(value)
    }

    /// Sets whether to show groups and emits update.
    public func setShowGroups(_ value: Bool) async {
        if value == showGroupsSubject.value { return }

        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.showGroups.rawValue)
        showGroupsSubject.send(value)
    }

    /// Sets whether performance metrics are enabled and emits update.
    public func setEnablePerformanceMetrics(_ value: Bool) async {
        if value == enablePerformanceMetricsSubject.value { return }

        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.enablePerformanceMetrics.rawValue)
        enablePerformanceMetricsSubject.send(value)
    }

    /// Sets whether optimized performance is enabled and emits update.
    public func setIsOptimizedPerformanceEnabled(_ value: Bool) async {
        if value == isOptimizedPerformanceEnabledSubject.value { return }

        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.isOptimizedPerformanceEnabled.rawValue)
        isOptimizedPerformanceEnabledSubject.send(value)
    }

    /// Sets the log level and emits update.
    public func setLogLevel(_ level: Logger.Level) async {
        if level == logLevelSubject.value { return }

        UserDefaults.standard.set(level.rawValue, forKey: UserDefaultsKeys.logLevel.rawValue)
        logLevelSubject.send(level)
    }

    // MARK: - UI Configuration Async Setters

    /// Sets the space background opacity level and emits update.
    public func setSpaceBackgroundOpacity(_ value: Double) async {
        if value == spaceBackgroundOpacitySubject.value { return }

        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.spaceBackgroundOpacity.rawValue)
        spaceBackgroundOpacitySubject.send(value)
    }

    /// Sets the space background blur radius and emits update.
    public func setSpaceBackgroundBlurRadius(_ value: Double) async {
        if value == spaceBackgroundBlurRadiusSubject.value { return }

        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.spaceBackgroundBlurRadius.rawValue)
        spaceBackgroundBlurRadiusSubject.send(value)
    }

    /// Sets the space background tint color and emits update.
    public func setSpaceBackgroundTintColor(_ value: Color) async {
        if value == spaceBackgroundTintColorSubject.value { return }

        saveColorToUserDefaults(color: value, key: UserDefaultsKeys.spaceBackgroundTintColor.rawValue)
        spaceBackgroundTintColorSubject.send(value)
    }

    /// Sets the space foreground color and emits update.
    public func setSpaceForegroundColor(_ value: Color) async {
        if value == spaceForegroundColorSubject.value { return }

        saveColorToUserDefaults(color: value, key: UserDefaultsKeys.spaceForegroundColor.rawValue)
        spaceForegroundColorSubject.send(value)
    }

    /// Sets the space border tint color and emits update.
    public func setSpaceBorderTintColor(_ value: Color) async {
        if value == spaceBorderTintColorSubject.value { return }

        saveColorToUserDefaults(color: value, key: UserDefaultsKeys.spaceBorderTintColor.rawValue)
        spaceBorderTintColorSubject.send(value)
    }

    /// Sets the space border opacity and emits update.
    public func setSpaceBorderOpacity(_ value: Double) async {
        if value == spaceBorderOpacitySubject.value { return }

        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.spaceBorderOpacity.rawValue)
        spaceBorderOpacitySubject.send(value)
    }

    /// Sets the space border width and emits update.
    public func setSpaceBorderWidth(_ value: Double) async {
        if value == spaceBorderWidthSubject.value { return }

        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.spaceBorderWidth.rawValue)
        spaceBorderWidthSubject.send(value)
    }

    /// Sets the vertical padding for the menu bar interface in points.
    public func setMenuBarVerticalPadding(_ value: Double) async {
        if value == menuBarVerticalPaddingSubject.value { return }

        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.menuBarVerticalPadding.rawValue)
        menuBarVerticalPaddingSubject.send(value)
    }

    /// Sets the horizontal padding for the menu bar interface in points.
    public func setMenuBarHorizontalPadding(_ value: Double) async {
        if value == menuBarHorizontalPaddingSubject.value { return }

        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.menuBarHorizontalPadding.rawValue)
        menuBarHorizontalPaddingSubject.send(value)
    }

    /// Sets the spacing between widgets in the menu bar in points.
    public func setWidgetSpacing(_ value: Double) async {
        if value == widgetSpacingSubject.value { return }

        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.widgetSpacing.rawValue)
        widgetSpacingSubject.send(value)
    }

    /// Sets the animation duration in seconds.
    public func setAnimationDuration(_ value: Double) async {
        if value == animationDurationSubject.value { return }

        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.animationDuration.rawValue)
        animationDurationSubject.send(value)
    }

    /// Sets the size of window icons in points.
    public func setWindowIconSize(_ value: Double) async {
        if value == windowIconSizeSubject.value { return }

        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.windowIconSize.rawValue)
        windowIconSizeSubject.send(value)
    }

    /// Sets the corner radius for space elements in points.
    public func setSpaceCornerRadius(_ value: Double) async {
        if value == spaceCornerRadiusSubject.value { return }

        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.spaceCornerRadius.rawValue)
        spaceCornerRadiusSubject.send(value)
    }

    /// Sets the group configuration for menu bar applications and emits update.
    public func setGroupsConfiguration(_ value: [Domain.Group]) async {
        if value == groupsConfigurationSubject.value { return }

        saveGroupsConfiguration(value)
        groupsConfigurationSubject.send(value)
    }

    /// Sets the groups appearance mode and emits update.
    public func setGroupsAppearanceMode(_ value: GroupsAppearanceMode) async {
        if value == groupsAppearanceModeSubject.value { return }

        saveGroupsAppearanceMode(value)
        groupsAppearanceModeSubject.send(value)
    }

    /// Sets the groups global background tint color and emits update.
    public func setGroupsGlobalBackgroundTintColor(_ value: Color) async {
        if value == groupsGlobalBackgroundTintColorSubject.value { return }
        saveColorToUserDefaults(color: value, key: UserDefaultsKeys.groupsGlobalBackgroundTintColor.rawValue)
        groupsGlobalBackgroundTintColorSubject.send(value)
    }

    /// Sets the groups global background opacity and emits update.
    public func setGroupsGlobalBackgroundOpacity(_ value: Double) async {
        if value == groupsGlobalBackgroundOpacitySubject.value { return }
        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.groupsGlobalBackgroundOpacity.rawValue)
        groupsGlobalBackgroundOpacitySubject.send(value)
    }

    /// Sets the groups global background blur radius and emits update.
    public func setGroupsGlobalBackgroundBlurRadius(_ value: Double) async {
        if value == groupsGlobalBgBlurRadiusSubject.value { return }
        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.groupsGlobalBackgroundBlurRadius.rawValue)
        groupsGlobalBgBlurRadiusSubject.send(value)
    }

    /// Sets the groups global border color and emits update.
    public func setGroupsGlobalBorderColor(_ value: Color) async {
        if value == groupsGlobalBorderColorSubject.value { return }
        saveColorToUserDefaults(color: value, key: UserDefaultsKeys.groupsGlobalBorderColor.rawValue)
        groupsGlobalBorderColorSubject.send(value)
    }

    /// Sets the groups global border opacity and emits update.
    public func setGroupsGlobalBorderOpacity(_ value: Double) async {
        if value == groupsGlobalBorderOpacitySubject.value { return }
        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.groupsGlobalBorderOpacity.rawValue)
        groupsGlobalBorderOpacitySubject.send(value)
    }

    /// Sets the groups global border width and emits update.
    public func setGroupsGlobalBorderWidth(_ value: Double) async {
        if value == groupsGlobalBorderWidthSubject.value { return }
        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.groupsGlobalBorderWidth.rawValue)
        groupsGlobalBorderWidthSubject.send(value)
    }

    /// Sets the groups global corner radius and emits update.
    public func setGroupsGlobalCornerRadius(_ value: Double) async {
        if value == groupsGlobalCornerRadiusSubject.value { return }
        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.groupsGlobalCornerRadius.rawValue)
        groupsGlobalCornerRadiusSubject.send(value)
    }

    // MARK: - AeroSpace Integration

    /// Sets up observers for the configuration repository.
    private func setupObservers() {
        aeroSpacePathPublisher
            .sink { [weak self] path in
                let version = self?.getAeroSpaceVersion(at: path)
                self?.currentAeroSpaceVersionSubject.send(version)
            }
            .store(in: &cancellables)
    }

    /// Gets the version of the AeroSpace binary at the specified path.
    /// - Parameter path: The path to check for AeroSpace version
    /// - Returns: The version string if found, nil otherwise
    private func getAeroSpaceVersion(at path: String) -> String? {
        if path.isEmpty { return nil }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: path)
        process.arguments = ["--version"]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        do {
            try process.run()
            process.waitUntilExit()

            if process.terminationStatus == 0 {
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                if let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
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
                                Logger.info("AeroSpace version detected: \(versionNumber)", category: Logger.config)
                                return versionNumber
                            }
                        }
                    }
                }
            }
        } catch {
            Logger.warning("Failed to get AeroSpace version: \(error.localizedDescription)", category: Logger.config)
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
        let resolvedURL = if let path = cliPath, !path.isEmpty {
            URL(fileURLWithPath: path)
        } else {
            URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent(".aerospace.toml")
        }

        return resolvedURL
    }

    /// Ask AeroSpace CLI for the effective config path
    private func fetchAeroSpaceConfigPathFromCLI() async -> String? {
        let executablePath = aeroSpacePathSubject.value
        return await withCheckedContinuation { continuation in
            Task.detached {
                do {
                    let cli = AeroSpaceCLIClient(executablePath: executablePath)
                    let data = try cli.execute(arguments: ["config", "--config-path"])
                    let pathString = String(data: data, encoding: .utf8)?
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    continuation.resume(returning: pathString)
                } catch {
                    Logger.error(
                        "Failed to obtain AeroSpace config path from CLI",
                        error: error,
                        category: Logger.config
                    )
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    /// Resets all configuration settings to their default values.
    public func resetToDefaults() async {
        for item in UserDefaultsKeys.allCases {
            UserDefaults.standard.removeObject(forKey: item.rawValue)
        }

        // Reset all subjects to default values
        await setShowWindowTitles(ConfigurationDefaults.showWindowTitles)
        await setAeroSpacePath(ConfigurationDefaults.aeroSpacePath)
        await setSpaceBackgroundOpacity(ConfigurationDefaults.spaceBackgroundOpacity)
        await setSpaceBackgroundBlurRadius(ConfigurationDefaults.spaceBackgroundBlurRadius)
        await setSpaceBackgroundTintColor(ConfigurationDefaults.spaceBackgroundTintColor)
        await setSpaceForegroundColor(ConfigurationDefaults.spaceForegroundColor)
        await setSpaceBorderTintColor(ConfigurationDefaults.spaceBorderTintColor)
        await setSpaceBorderOpacity(ConfigurationDefaults.spaceBorderOpacity)
        await setFocusWindowOnClick(ConfigurationDefaults.focusWindowOnClick)
        await setShowEmptySpaces(ConfigurationDefaults.showEmptySpaces)
        await setEnablePerformanceMetrics(ConfigurationDefaults.enablePerformanceMetrics)
        await setIsOptimizedPerformanceEnabled(ConfigurationDefaults.isOptimizedPerformanceEnabled)
        await setLogLevel(ConfigurationDefaults.logLevel)

        // Reset UI configuration subjects
        menuBarVerticalPaddingSubject.send(ConfigurationDefaults.menuBarVerticalPadding)
        menuBarHorizontalPaddingSubject.send(ConfigurationDefaults.menuBarHorizontalPadding)
        await setWidgetSpacing(ConfigurationDefaults.widgetSpacing)
        await setAnimationDuration(ConfigurationDefaults.animationDuration)
        await setWindowIconSize(ConfigurationDefaults.windowIconSize)
        await setSpaceCornerRadius(ConfigurationDefaults.spaceCornerRadius)
        await setShowGroups(ConfigurationDefaults.showGroups)
        await setGroupsConfiguration(ConfigurationDefaults.groupsConfiguration)
        await setGroupsAppearanceMode(ConfigurationDefaults.groupsAppearanceMode)
        await setGroupsGlobalBackgroundTintColor(ConfigurationDefaults.groupsGlobalBackgroundTintColor)
        await setGroupsGlobalBackgroundOpacity(ConfigurationDefaults.groupsGlobalBackgroundOpacity)
        await setGroupsGlobalBackgroundBlurRadius(ConfigurationDefaults.groupsGlobalBackgroundBlurRadius)
        await setGroupsGlobalBorderColor(ConfigurationDefaults.groupsGlobalBorderColor)
        await setGroupsGlobalBorderOpacity(ConfigurationDefaults.groupsGlobalBorderOpacity)
        await setGroupsGlobalBorderWidth(ConfigurationDefaults.groupsGlobalBorderWidth)
        await setGroupsGlobalCornerRadius(ConfigurationDefaults.groupsGlobalCornerRadius)

        Logger.info("Configuration reset to defaults", category: Logger.config)
    }

    // MARK: - Color Serialization Helpers

    /// Loads a Color from UserDefaults with a default fallback.
    /// - Parameters:
    ///   - key: The UserDefaults key
    ///   - defaultValue: The default value to use if not found
    /// - Returns: The loaded Color or the default value
    private func loadColorFromUserDefaults(key: String, defaultValue: Color) -> Color {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return defaultValue
        }

        do {
            let decoder = JSONDecoder()
            let colorComponents = try decoder.decode(ColorComponents.self, from: data)
            return Color(
                .sRGB,
                red: colorComponents.red,
                green: colorComponents.green,
                blue: colorComponents.blue,
                opacity: colorComponents.alpha
            )
        } catch {
            Logger.warning("Failed to decode color from UserDefaults for key \(key): \(error)", category: Logger.config)
            return defaultValue
        }
    }

    /// Saves a Color to UserDefaults by encoding its components.
    /// - Parameters:
    ///   - color: The Color to save
    ///   - key: The UserDefaults key
    private func saveColorToUserDefaults(color: Color, key: String) {
        let resolved = color.resolve(in: EnvironmentValues())
        let colorComponents = ColorComponents(
            red: Double(resolved.red),
            green: Double(resolved.green),
            blue: Double(resolved.blue),
            alpha: Double(resolved.opacity)
        )

        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(colorComponents)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            Logger.error("Failed to encode color to UserDefaults for key \(key): \(error)", category: Logger.config)
        }
    }

    /// Loads a GroupConfiguration from UserDefaults using TOML format.
    /// - Returns: The GroupConfiguration if found, nil otherwise
    private func loadGroupsConfiguration() -> [Domain.Group]? {
        guard let data = UserDefaults.standard.data(forKey: UserDefaultsKeys.groupsConfiguration.rawValue) else {
            return nil
        }

        do {
            // Convert Data to String for TOML parsing
            guard let tomlString = String(data: data, encoding: .utf8) else {
                Logger.warning("Failed to convert Data to String for TOML parsing", category: Logger.config)
                return nil
            }

            let decoder = TOMLDecoder()
            let wrapper = try decoder.decode(GroupsConfigurationWrapper.self, from: tomlString)
            return wrapper.groups
        } catch {
            Logger.warning(
                "Failed to decode GroupConfiguration from UserDefaults using TOML: \(error)",
                category: Logger.config
            )
            return nil
        }
    }

    /// Saves a GroupConfiguration to UserDefaults using TOML format.
    /// - Parameter configuration: The GroupConfiguration to save
    private func saveGroupsConfiguration(_ configuration: [Domain.Group]) {
        do {
            let encoder = TOMLEncoder()
            let wrapper = GroupsConfigurationWrapper(groups: configuration)
            let tomlString = try encoder.encode(wrapper)
            guard let data = tomlString.data(using: String.Encoding.utf8) else {
                Logger.error("Failed to convert TOML string to Data", category: Logger.config)
                return
            }

            UserDefaults.standard.set(data, forKey: UserDefaultsKeys.groupsConfiguration.rawValue)
        } catch {
            Logger.error(
                "Failed to encode GroupConfiguration to UserDefaults using TOML: \(error)",
                category: Logger.config
            )
        }
    }

    /// Loads the groups appearance mode from UserDefaults.
    /// - Returns: The groups appearance mode if found, nil otherwise
    private func loadGroupsAppearanceMode() -> GroupsAppearanceMode? {
        guard let rawValue = UserDefaults.standard.string(forKey: UserDefaultsKeys.groupsAppearanceMode.rawValue) else {
            return nil
        }

        return GroupsAppearanceMode(rawValue: rawValue)
    }

    /// Saves the groups appearance mode to UserDefaults.
    /// - Parameter mode: The groups appearance mode to save
    private func saveGroupsAppearanceMode(_ mode: GroupsAppearanceMode) {
        UserDefaults.standard.set(mode.rawValue, forKey: UserDefaultsKeys.groupsAppearanceMode.rawValue)
    }
}

/// Wrapper struct for TOML encoding of groups configuration array.
private struct GroupsConfigurationWrapper: Codable {
    let groups: [Domain.Group]
}

/// Helper struct for Color serialization to UserDefaults.
private struct ColorComponents: Codable {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double
}
