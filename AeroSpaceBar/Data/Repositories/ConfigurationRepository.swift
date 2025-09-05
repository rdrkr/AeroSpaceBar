// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import AppKit
import Combine
import SwiftUI

/// Repository for managing application configuration and settings.
///
/// This gateway provides centralized access to application configuration,
/// including UI constants, external dependencies, refresh intervals,
/// and user preferences. It uses reactive patterns with Combine publishers
/// to emit updates when configuration values change.
/// This is the data layer implementation of the ConfigurationGateway.
@MainActor
final class ConfigurationRepository: ConfigurationGateway {
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

    private let spaceBackgroundBlurRadiusSubject = CurrentValueSubject<CGFloat, Never>(
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

    private let spaceBorderWidthSubject = CurrentValueSubject<CGFloat, Never>(
        ConfigurationDefaults.spaceBorderWidth
    )

    private let menuBarVerticalPaddingSubject = CurrentValueSubject<CGFloat, Never>(
        ConfigurationDefaults.menuBarVerticalPadding
    )

    private let menuBarHorizontalPaddingSubject = CurrentValueSubject<CGFloat, Never>(
        ConfigurationDefaults.menuBarHorizontalPadding
    )

    private let widgetSpacingSubject = CurrentValueSubject<CGFloat, Never>(
        ConfigurationDefaults.widgetSpacing
    )

    private let animationDurationSubject = CurrentValueSubject<Double, Never>(
        ConfigurationDefaults.animationDuration
    )

    private let windowIconSizeSubject = CurrentValueSubject<CGFloat, Never>(
        ConfigurationDefaults.windowIconSize
    )

    private let spaceCornerRadiusSubject = CurrentValueSubject<CGFloat, Never>(
        ConfigurationDefaults.spaceCornerRadius
    )

    // MARK: - Publishers

    var showWindowTitlesPublisher: AnyPublisher<Bool, Never> {
        showWindowTitlesSubject.eraseToAnyPublisher()
    }

    var aeroSpacePathPublisher: AnyPublisher<String, Never> {
        aeroSpacePathSubject.eraseToAnyPublisher()
    }

    var currentAeroSpaceVersionPublisher: AnyPublisher<String?, Never> {
        currentAeroSpaceVersionSubject.eraseToAnyPublisher()
    }

    var focusWindowOnClickPublisher: AnyPublisher<Bool, Never> {
        focusWindowOnClickSubject.eraseToAnyPublisher()
    }

    var showEmptySpacesPublisher: AnyPublisher<Bool, Never> {
        showEmptySpacesSubject.eraseToAnyPublisher()
    }

    var enablePerformanceMetricsPublisher: AnyPublisher<Bool, Never> {
        enablePerformanceMetricsSubject.eraseToAnyPublisher()
    }

    var isOptimizedPerformanceEnabledPublisher: AnyPublisher<Bool, Never> {
        isOptimizedPerformanceEnabledSubject.eraseToAnyPublisher()
    }

    var logLevelPublisher: AnyPublisher<Logger.Level, Never> {
        logLevelSubject.eraseToAnyPublisher()
    }

    // MARK: - UI Configuration Publishers

    var spaceBackgroundOpacityPublisher: AnyPublisher<Double, Never> {
        spaceBackgroundOpacitySubject.eraseToAnyPublisher()
    }

    var spaceBackgroundBlurRadiusPublisher: AnyPublisher<CGFloat, Never> {
        spaceBackgroundBlurRadiusSubject.eraseToAnyPublisher()
    }

    var spaceBackgroundTintColorPublisher: AnyPublisher<Color, Never> {
        spaceBackgroundTintColorSubject.eraseToAnyPublisher()
    }

    var spaceForegroundColorPublisher: AnyPublisher<Color, Never> {
        spaceForegroundColorSubject.eraseToAnyPublisher()
    }

    var spaceBorderTintColorPublisher: AnyPublisher<Color, Never> {
        spaceBorderTintColorSubject.eraseToAnyPublisher()
    }

    var spaceBorderOpacityPublisher: AnyPublisher<Double, Never> {
        spaceBorderOpacitySubject.eraseToAnyPublisher()
    }

    var spaceBorderWidthPublisher: AnyPublisher<CGFloat, Never> {
        spaceBorderWidthSubject.eraseToAnyPublisher()
    }

    var menuBarVerticalPaddingPublisher: AnyPublisher<CGFloat, Never> {
        menuBarVerticalPaddingSubject.eraseToAnyPublisher()
    }

    var menuBarHorizontalPaddingPublisher: AnyPublisher<CGFloat, Never> {
        menuBarHorizontalPaddingSubject.eraseToAnyPublisher()
    }

    var widgetSpacingPublisher: AnyPublisher<CGFloat, Never> {
        widgetSpacingSubject.eraseToAnyPublisher()
    }

    var animationDurationPublisher: AnyPublisher<Double, Never> {
        animationDurationSubject.eraseToAnyPublisher()
    }

    var windowIconSizePublisher: AnyPublisher<CGFloat, Never> {
        windowIconSizeSubject.eraseToAnyPublisher()
    }

    var spaceCornerRadiusPublisher: AnyPublisher<CGFloat, Never> {
        spaceCornerRadiusSubject.eraseToAnyPublisher()
    }

    /// Initializer for the configuration gateway.
    init() {
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
            .object(forKey: UserDefaultsKeys.spaceBackgroundBlurRadius.rawValue) as? CGFloat
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
            .object(forKey: UserDefaultsKeys.spaceBorderWidth.rawValue) as? CGFloat
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
            .object(forKey: UserDefaultsKeys.menuBarVerticalPadding.rawValue) as? CGFloat
            ?? menuBarVerticalPaddingSubject.value
        menuBarVerticalPaddingSubject.send(menuBarVerticalPadding)

        let menuBarHorizontalPadding = UserDefaults.standard
            .object(forKey: UserDefaultsKeys.menuBarHorizontalPadding.rawValue) as? CGFloat
            ?? menuBarHorizontalPaddingSubject.value
        menuBarHorizontalPaddingSubject.send(menuBarHorizontalPadding)

        let widgetSpacing = UserDefaults.standard.object(forKey: UserDefaultsKeys.widgetSpacing.rawValue) as? CGFloat
            ?? widgetSpacingSubject.value
        widgetSpacingSubject.send(widgetSpacing)

        let animationDuration = UserDefaults.standard
            .object(forKey: UserDefaultsKeys.animationDuration.rawValue) as? Double
            ?? animationDurationSubject.value
        animationDurationSubject.send(animationDuration)

        let windowIconSize = UserDefaults.standard.object(forKey: UserDefaultsKeys.windowIconSize.rawValue) as? CGFloat
            ?? windowIconSizeSubject.value
        windowIconSizeSubject.send(windowIconSize)

        let spaceCornerRadius = UserDefaults.standard
            .object(forKey: UserDefaultsKeys.spaceCornerRadius.rawValue) as? CGFloat
            ?? spaceCornerRadiusSubject.value
        spaceCornerRadiusSubject.send(spaceCornerRadius)
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
    func setShowWindowTitles(_ value: Bool) async {
        if value == showWindowTitlesSubject.value { return }

        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.showWindowTitles.rawValue)
        showWindowTitlesSubject.send(value)
    }

    /// Sets the AeroSpace path and emits update.
    func setAeroSpacePath(_ path: String) async {
        if path == aeroSpacePathSubject.value { return }

        UserDefaults.standard.set(path, forKey: UserDefaultsKeys.aeroSpaceCustomPath.rawValue)

        let resolvedPath = path.isEmpty ? resolveAeroSpacePath() : path
        aeroSpacePathSubject.send(resolvedPath)
    }

    /// Sets whether to focus window on click and emits update.
    func setFocusWindowOnClick(_ value: Bool) async {
        if value == focusWindowOnClickSubject.value { return }

        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.focusWindowOnClick.rawValue)
        focusWindowOnClickSubject.send(value)
    }

    /// Sets whether to show empty spaces and emits update.
    func setShowEmptySpaces(_ value: Bool) async {
        if value == showEmptySpacesSubject.value { return }

        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.showEmptySpaces.rawValue)
        showEmptySpacesSubject.send(value)
    }

    /// Sets whether performance metrics are enabled and emits update.
    func setEnablePerformanceMetrics(_ value: Bool) async {
        if value == enablePerformanceMetricsSubject.value { return }

        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.enablePerformanceMetrics.rawValue)
        enablePerformanceMetricsSubject.send(value)
    }

    /// Sets whether optimized performance is enabled and emits update.
    func setIsOptimizedPerformanceEnabled(_ value: Bool) async {
        if value == isOptimizedPerformanceEnabledSubject.value { return }

        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.isOptimizedPerformanceEnabled.rawValue)
        isOptimizedPerformanceEnabledSubject.send(value)
    }

    /// Sets the log level and emits update.
    func setLogLevel(_ level: Logger.Level) async {
        if level == logLevelSubject.value { return }

        UserDefaults.standard.set(level.rawValue, forKey: UserDefaultsKeys.logLevel.rawValue)
        logLevelSubject.send(level)
    }

    // MARK: - UI Configuration Async Setters

    /// Sets the space background opacity level and emits update.
    func setSpaceBackgroundOpacity(_ value: Double) async {
        if value == spaceBackgroundOpacitySubject.value { return }

        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.spaceBackgroundOpacity.rawValue)
        spaceBackgroundOpacitySubject.send(value)
    }

    /// Sets the space background blur radius and emits update.
    func setSpaceBackgroundBlurRadius(_ value: CGFloat) async {
        if value == spaceBackgroundBlurRadiusSubject.value { return }

        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.spaceBackgroundBlurRadius.rawValue)
        spaceBackgroundBlurRadiusSubject.send(value)
    }

    /// Sets the space background tint color and emits update.
    func setSpaceBackgroundTintColor(_ value: Color) async {
        if value == spaceBackgroundTintColorSubject.value { return }

        saveColorToUserDefaults(color: value, key: UserDefaultsKeys.spaceBackgroundTintColor.rawValue)
        spaceBackgroundTintColorSubject.send(value)
    }

    /// Sets the space foreground color and emits update.
    func setSpaceForegroundColor(_ value: Color) async {
        if value == spaceForegroundColorSubject.value { return }

        saveColorToUserDefaults(color: value, key: UserDefaultsKeys.spaceForegroundColor.rawValue)
        spaceForegroundColorSubject.send(value)
    }

    /// Sets the space border tint color and emits update.
    func setSpaceBorderTintColor(_ value: Color) async {
        if value == spaceBorderTintColorSubject.value { return }

        saveColorToUserDefaults(color: value, key: UserDefaultsKeys.spaceBorderTintColor.rawValue)
        spaceBorderTintColorSubject.send(value)
    }

    /// Sets the space border opacity and emits update.
    func setSpaceBorderOpacity(_ value: Double) async {
        if value == spaceBorderOpacitySubject.value { return }

        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.spaceBorderOpacity.rawValue)
        spaceBorderOpacitySubject.send(value)
    }

    /// Sets the space border width and emits update.
    func setSpaceBorderWidth(_ value: CGFloat) async {
        if value == spaceBorderWidthSubject.value { return }

        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.spaceBorderWidth.rawValue)
        spaceBorderWidthSubject.send(value)
    }

    /// Sets the vertical padding for the menu bar interface in points.
    func setMenuBarVerticalPadding(_ value: CGFloat) async {
        if value == menuBarVerticalPaddingSubject.value { return }

        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.menuBarVerticalPadding.rawValue)
        menuBarVerticalPaddingSubject.send(value)
    }

    /// Sets the horizontal padding for the menu bar interface in points.
    func setMenuBarHorizontalPadding(_ value: CGFloat) async {
        if value == menuBarHorizontalPaddingSubject.value { return }

        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.menuBarHorizontalPadding.rawValue)
        menuBarHorizontalPaddingSubject.send(value)
    }

    /// Sets the spacing between widgets in the menu bar in points.
    func setWidgetSpacing(_ value: CGFloat) async {
        if value == widgetSpacingSubject.value { return }

        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.widgetSpacing.rawValue)
        widgetSpacingSubject.send(value)
    }

    /// Sets the animation duration in seconds.
    func setAnimationDuration(_ value: Double) async {
        if value == animationDurationSubject.value { return }

        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.animationDuration.rawValue)
        animationDurationSubject.send(value)
    }

    /// Sets the size of window icons in points.
    func setWindowIconSize(_ value: CGFloat) async {
        if value == windowIconSizeSubject.value { return }

        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.windowIconSize.rawValue)
        windowIconSizeSubject.send(value)
    }

    /// Sets the corner radius for space elements in points.
    func setSpaceCornerRadius(_ value: CGFloat) async {
        if value == spaceCornerRadiusSubject.value { return }

        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.spaceCornerRadius.rawValue)
        spaceCornerRadiusSubject.send(value)
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
    func openAeroSpaceConfig() async {
        let configPath = await getAeroSpaceConfigPath()
        NSWorkspace.shared.open(configPath)
    }

    /// Gets the AeroSpace configuration file path, creating a default one if needed
    func getAeroSpaceConfigPath() async -> URL {
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
    func resetToDefaults() async {
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
}

/// Helper struct for Color serialization to UserDefaults.
private struct ColorComponents: Codable {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double
}
