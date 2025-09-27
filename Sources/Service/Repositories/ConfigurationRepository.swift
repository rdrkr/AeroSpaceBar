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
public final class ConfigurationRepository: ConfigurationGateway {
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

    private let spacesVisualConfigSubject = CurrentValueSubject<[VisualProperties], Never>(
        ConfigurationDefaults.spacesVisualConfiguration
    )

    private let spacesAppearanceModeSubject = CurrentValueSubject<SpacesAppearanceMode, Never>(
        ConfigurationDefaults.spacesAppearanceMode
    )

    private let globalSpacesVisualConfigSubject = CurrentValueSubject<VisualProperties, Never>(
        ConfigurationDefaults.defaultSpaceVisualConfig
    )

    private let groupsSubject = CurrentValueSubject<[Domain.Group], Never>(
        ConfigurationDefaults.groups
    )

    private let groupsAppearanceModeSubject = CurrentValueSubject<GroupsAppearanceMode, Never>(
        ConfigurationDefaults.groupsAppearanceMode
    )

    private let globalGroupsVisualConfigSubject = CurrentValueSubject<VisualProperties, Never>(
        ConfigurationDefaults.defaultGroupsGlobalVisualConfig
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

    public var globalSpacesVisualConfigPublisher: AnyPublisher<VisualProperties, Never> {
        globalSpacesVisualConfigSubject.eraseToAnyPublisher()
    }

    public var spacesVisualConfigPublisher: AnyPublisher<[VisualProperties], Never> {
        spacesVisualConfigSubject.eraseToAnyPublisher()
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

    public var globalGroupsVisualConfigPublisher: AnyPublisher<VisualProperties, Never> {
        globalGroupsVisualConfigSubject.eraseToAnyPublisher()
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
        let spacesVisualConfigurationWrapper: CollectionWrapper<VisualProperties>? = loadStructFromTOML(
            configKey: UserDefaultsKeys.spacesVisualConfiguration.rawValue
        )
        let spacesVisualConfiguration = spacesVisualConfigurationWrapper?.items ?? spacesVisualConfigSubject.value
        spacesVisualConfigSubject.send(spacesVisualConfiguration)

        let spacesAppearanceMode = loadSpacesAppearanceMode() ?? spacesAppearanceModeSubject.value
        spacesAppearanceModeSubject.send(spacesAppearanceMode)

        let globalSpacesVisualConfig = loadStructFromTOML(
            configKey: UserDefaultsKeys.globalSpacesVisualConfig.rawValue
        ) ?? globalSpacesVisualConfigSubject.value
        globalSpacesVisualConfigSubject.send(globalSpacesVisualConfig)

        let groupsWrapper: CollectionWrapper<Domain.Group>? = loadStructFromTOML(
            configKey: UserDefaultsKeys.groups.rawValue
        )
        let groups = groupsWrapper?.items ?? groupsSubject.value
        groupsSubject.send(groups)

        let groupsAppearanceMode = loadGroupsAppearanceMode() ?? groupsAppearanceModeSubject.value
        groupsAppearanceModeSubject.send(groupsAppearanceMode)

        let globalGroupsVisualConfig = loadStructFromTOML(
            configKey: UserDefaultsKeys.globalGroupsVisualConfig.rawValue
        ) ?? globalGroupsVisualConfigSubject.value
        globalGroupsVisualConfigSubject.send(globalGroupsVisualConfig)
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
    public func setShowWindowTitles(_ value: Bool) {
        if value == showWindowTitlesSubject.value { return }

        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.showWindowTitles.rawValue)
        showWindowTitlesSubject.send(value)
    }

    /// Sets the AeroSpace path and emits update.
    public func setAeroSpacePath(_ path: String) {
        if path == aeroSpacePathSubject.value { return }

        UserDefaults.standard.set(path, forKey: UserDefaultsKeys.aeroSpaceCustomPath.rawValue)

        let resolvedPath = path.isEmpty ? resolveAeroSpacePath() : path
        aeroSpacePathSubject.send(resolvedPath)
    }

    /// Sets whether to focus window on click and emits update.
    public func setFocusWindowOnClick(_ value: Bool) {
        if value == focusWindowOnClickSubject.value { return }

        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.focusWindowOnClick.rawValue)
        focusWindowOnClickSubject.send(value)
    }

    /// Sets whether to show empty spaces and emits update.
    public func setShowEmptySpaces(_ value: Bool) {
        if value == showEmptySpacesSubject.value { return }

        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.showEmptySpaces.rawValue)
        showEmptySpacesSubject.send(value)
    }

    /// Sets whether to show groups and emits update.
    public func setShowGroups(_ value: Bool) {
        if value == showGroupsSubject.value { return }

        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.showGroups.rawValue)
        showGroupsSubject.send(value)
    }

    /// Sets whether performance metrics are enabled and emits update.
    public func setEnablePerformanceMetrics(_ value: Bool) {
        if value == enablePerformanceMetricsSubject.value { return }

        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.enablePerformanceMetrics.rawValue)
        enablePerformanceMetricsSubject.send(value)
    }

    /// Sets whether optimized performance is enabled and emits update.
    public func setIsOptimizedPerformanceEnabled(_ value: Bool) {
        if value == isOptimizedPerformanceEnabledSubject.value { return }

        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.isOptimizedPerformanceEnabled.rawValue)
        isOptimizedPerformanceEnabledSubject.send(value)
    }

    /// Sets the log level and emits update.
    public func setLogLevel(_ level: Logger.Level) {
        if level == logLevelSubject.value { return }

        UserDefaults.standard.set(level.rawValue, forKey: UserDefaultsKeys.logLevel.rawValue)
        logLevelSubject.send(level)
    }

    // MARK: - UI Configuration Async Setters

    /// Sets the vertical padding for the menu bar interface in points.

    /// Sets the spaces configuration and emits update.
    public func setSpacesVisualConfig(_ value: [VisualProperties]) {
        if value == spacesVisualConfigSubject.value { return }

        saveStructToTOML(
            configKey: UserDefaultsKeys.spacesVisualConfiguration.rawValue,
            data: CollectionWrapper(items: value)
        )

        spacesVisualConfigSubject.send(value)
    }

    /// Sets the spaces appearance mode and emits update.
    public func setSpacesAppearanceMode(_ value: SpacesAppearanceMode) {
        if value == spacesAppearanceModeSubject.value { return }

        UserDefaults.standard.set(value.rawValue, forKey: UserDefaultsKeys.spacesAppearanceMode.rawValue)
        spacesAppearanceModeSubject.send(value)
    }

    /// Sets the global space visual configuration and emits update.
    public func setGlobalSpacesVisualConfig(_ value: VisualProperties) {
        if value == globalSpacesVisualConfigSubject.value { return }

        saveStructToTOML(
            configKey: UserDefaultsKeys.globalSpacesVisualConfig.rawValue,
            data: value
        )

        globalSpacesVisualConfigSubject.send(value)
    }

    /// Sets the group configuration for menu bar applications and emits update.
    public func setGroups(_ value: [Domain.Group]) {
        if value == groupsSubject.value { return }

        saveStructToTOML(
            configKey: UserDefaultsKeys.groups.rawValue,
            data: CollectionWrapper(items: value)
        )

        groupsSubject.send(value)
    }

    /// Sets the groups appearance mode and emits update.
    public func setGroupsAppearanceMode(_ value: GroupsAppearanceMode) {
        if value == groupsAppearanceModeSubject.value { return }

        UserDefaults.standard.set(value.rawValue, forKey: UserDefaultsKeys.groupsAppearanceMode.rawValue)
        groupsAppearanceModeSubject.send(value)
    }

    /// Sets the global groups visual configuration and emits update.
    public func setGlobalGroupsVisualConfig(_ value: VisualProperties) {
        if value == globalGroupsVisualConfigSubject.value { return }

        saveStructToTOML(
            configKey: UserDefaultsKeys.globalGroupsVisualConfig.rawValue,
            data: value
        )

        globalGroupsVisualConfigSubject.send(value)
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
    public func resetToDefaults() {
        for item in UserDefaultsKeys.allCases {
            UserDefaults.standard.removeObject(forKey: item.rawValue)
        }

        // Reset all subjects to default values
        setShowWindowTitles(ConfigurationDefaults.showWindowTitles)
        setAeroSpacePath(ConfigurationDefaults.aeroSpacePath)
        setFocusWindowOnClick(ConfigurationDefaults.focusWindowOnClick)
        setShowEmptySpaces(ConfigurationDefaults.showEmptySpaces)
        setEnablePerformanceMetrics(ConfigurationDefaults.enablePerformanceMetrics)
        setIsOptimizedPerformanceEnabled(ConfigurationDefaults.isOptimizedPerformanceEnabled)
        setLogLevel(ConfigurationDefaults.logLevel)

        // Reset UI configuration subjects
        setShowGroups(ConfigurationDefaults.showGroups)

        setSpacesVisualConfig(ConfigurationDefaults.spacesVisualConfiguration)
        setSpacesAppearanceMode(ConfigurationDefaults.spacesAppearanceMode)
        setGlobalSpacesVisualConfig(ConfigurationDefaults.defaultSpaceVisualConfig)
        setGroups(ConfigurationDefaults.groups)
        setGroupsAppearanceMode(ConfigurationDefaults.groupsAppearanceMode)
        setGlobalGroupsVisualConfig(ConfigurationDefaults.defaultGroupsGlobalVisualConfig)

        Logger.info("Configuration reset to defaults", category: Logger.config)
    }

    /// Loads the groups appearance mode from UserDefaults.
    /// - Returns: The groups appearance mode if found, nil otherwise
    private func loadGroupsAppearanceMode() -> GroupsAppearanceMode? {
        guard let rawValue = UserDefaults.standard.string(forKey: UserDefaultsKeys.groupsAppearanceMode.rawValue) else {
            return nil
        }

        return GroupsAppearanceMode(rawValue: rawValue)
    }

    /// Loads the spaces appearance mode from UserDefaults.
    /// - Returns: The spaces appearance mode if found, nil otherwise
    private func loadSpacesAppearanceMode() -> SpacesAppearanceMode? {
        guard let rawValue = UserDefaults.standard.string(forKey: UserDefaultsKeys.spacesAppearanceMode.rawValue) else {
            return nil
        }

        return SpacesAppearanceMode(rawValue: rawValue)
    }

    /// Loads a TOML formatted configuration UserDefaults value to a struct.
    /// - Parameter configKey: The UserDefaults key for the configuration
    /// - Returns: The configuration struct if found, nil otherwise
    private func loadStructFromTOML<T: Codable>(configKey: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: configKey) else {
            return nil
        }

        do {
            // Convert Data to String for TOML parsing
            guard let tomlString = String(data: data, encoding: .utf8) else {
                Logger.warning("Failed to convert Data to String for TOML parsing", category: Logger.config)
                return nil
            }

            let decoder = TOMLDecoder()
            return try decoder.decode(T.self, from: tomlString)
        } catch {
            Logger.warning(
                "Failed to decode \(configKey) from UserDefaults using TOML: \(error)",
                category: Logger.config
            )
            return nil
        }
    }

    /// Saves a given struct to TOML formatted UserDefaults.
    /// - Parameter configKey: The UserDefaults key for the configuration
    /// - Parameter data: The data to save
    private func saveStructToTOML(configKey: String, data: some Codable) {
        do {
            let encoder = TOMLEncoder()
            let tomlString = try encoder.encode(data)
            guard let data = tomlString.data(using: String.Encoding.utf8) else {
                Logger.error("Failed to convert TOML string to Data", category: Logger.config)
                return
            }

            UserDefaults.standard.set(data, forKey: configKey)
        } catch {
            Logger.error(
                "Failed to encode \(configKey) to UserDefaults using TOML: \(error)",
                category: Logger.config
            )
        }
    }
}

/// Wrapper struct for TOML encoding of array.
private struct CollectionWrapper<T: Codable>: Codable {
    let items: [T]
}
