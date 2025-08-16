// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import AppKit
import Combine

/// Repository for managing application configuration and settings.
///
/// This gateway provides centralized access to application configuration,
/// including UI constants, external dependencies, refresh intervals,
/// and user preferences. It uses reactive patterns with Combine publishers
/// to emit updates when configuration values change.
/// This is the data layer implementation of the ConfigurationGateway.
@MainActor
final class ConfigurationRepository: ConfigurationGateway {
    // MARK: - Private Subjects for Publishers

    private var cancellables = Set<AnyCancellable>()

    private let showWindowTitlesSubject = CurrentValueSubject<Bool, Never>(
        ConfigurationDefaults.showWindowTitles
    )

    private let aeroSpacePathSubject = CurrentValueSubject<String, Never>(
        ConfigurationDefaults.aeroSpacePath
    )

    private let currentAeroSpaceVersionSubject = CurrentValueSubject<String?, Never>(
        nil
    )

    private let focusWindowOnClickSubject = CurrentValueSubject<Bool, Never>(
        ConfigurationDefaults.focusWindowOnClick
    )

    private let enablePerformanceMetricsSubject = CurrentValueSubject<Bool, Never>(
        ConfigurationDefaults.enablePerformanceMetrics
    )

    private let logLevelSubject = CurrentValueSubject<Logger.Level, Never>(
        ConfigurationDefaults.logLevel
    )

    // MARK: - UI Configuration Subjects

    private let transparencySubject = CurrentValueSubject<Double, Never>(
        ConfigurationDefaults.transparency
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

    private let windowCornerRadiusSubject = CurrentValueSubject<CGFloat, Never>(
        ConfigurationDefaults.windowCornerRadius
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

    var enablePerformanceMetricsPublisher: AnyPublisher<Bool, Never> {
        enablePerformanceMetricsSubject.eraseToAnyPublisher()
    }

    var logLevelPublisher: AnyPublisher<Logger.Level, Never> {
        logLevelSubject.eraseToAnyPublisher()
    }

    // MARK: - UI Configuration Publishers

    var transparencyPublisher: AnyPublisher<Double, Never> {
        transparencySubject.eraseToAnyPublisher()
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

    var windowCornerRadiusPublisher: AnyPublisher<CGFloat, Never> {
        windowCornerRadiusSubject.eraseToAnyPublisher()
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
        let transparency = UserDefaults.standard.object(forKey: UserDefaultsKeys.transparency.rawValue) as? Double
            ?? transparencySubject.value
        transparencySubject.send(transparency)

        let focusWindowOnClick = UserDefaults.standard
            .object(forKey: UserDefaultsKeys.focusWindowOnClick.rawValue) as? Bool
            ?? focusWindowOnClickSubject.value
        focusWindowOnClickSubject.send(focusWindowOnClick)

        let enablePerformanceMetrics = UserDefaults.standard
            .object(forKey: UserDefaultsKeys.enablePerformanceMetrics.rawValue) as? Bool
            ?? enablePerformanceMetricsSubject.value
        enablePerformanceMetricsSubject.send(enablePerformanceMetrics)

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

        let windowCornerRadius = UserDefaults.standard
            .object(forKey: UserDefaultsKeys.windowCornerRadius.rawValue) as? CGFloat
            ?? windowCornerRadiusSubject.value
        windowCornerRadiusSubject.send(windowCornerRadius)
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

    /// Sets whether performance metrics are enabled and emits update.
    func setEnablePerformanceMetrics(_ value: Bool) async {
        if value == enablePerformanceMetricsSubject.value { return }

        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.enablePerformanceMetrics.rawValue)
        enablePerformanceMetricsSubject.send(value)
    }

    /// Sets the log level and emits update.
    func setLogLevel(_ level: Logger.Level) async {
        if level == logLevelSubject.value { return }

        UserDefaults.standard.set(level.rawValue, forKey: UserDefaultsKeys.logLevel.rawValue)
        logLevelSubject.send(level)
    }

    // MARK: - UI Configuration Async Setters

    /// Sets the transparency level and emits update.
    func setTransparency(_ value: Double) async {
        if value == transparencySubject.value { return }

        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.transparency.rawValue)
        transparencySubject.send(value)
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

    /// Sets the corner radius for window elements in points.
    func setWindowCornerRadius(_ value: CGFloat) async {
        if value == windowCornerRadiusSubject.value { return }

        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.windowCornerRadius.rawValue)
        windowCornerRadiusSubject.send(value)
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
    private func getAeroSpaceConfigPath() async -> URL {
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
            Task { @MainActor in
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
        // Reset all subjects to default values
        showWindowTitlesSubject.send(ConfigurationDefaults.showWindowTitles)
        aeroSpacePathSubject.send(ConfigurationDefaults.aeroSpacePath)
        transparencySubject.send(ConfigurationDefaults.transparency)
        focusWindowOnClickSubject.send(ConfigurationDefaults.focusWindowOnClick)
        enablePerformanceMetricsSubject.send(ConfigurationDefaults.enablePerformanceMetrics)
        logLevelSubject.send(ConfigurationDefaults.logLevel)

        // Reset UI configuration subjects
        menuBarVerticalPaddingSubject.send(ConfigurationDefaults.menuBarVerticalPadding)
        menuBarHorizontalPaddingSubject.send(ConfigurationDefaults.menuBarHorizontalPadding)
        widgetSpacingSubject.send(ConfigurationDefaults.widgetSpacing)
        animationDurationSubject.send(ConfigurationDefaults.animationDuration)
        windowIconSizeSubject.send(ConfigurationDefaults.windowIconSize)
        spaceCornerRadiusSubject.send(ConfigurationDefaults.spaceCornerRadius)
        windowCornerRadiusSubject.send(ConfigurationDefaults.windowCornerRadius)

        for item in UserDefaultsKeys.allCases {
            UserDefaults.standard.removeObject(forKey: item.rawValue)
        }

        Logger.info("Configuration reset to defaults", category: Logger.config)
    }
}
