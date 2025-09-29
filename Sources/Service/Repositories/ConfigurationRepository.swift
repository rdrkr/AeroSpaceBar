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

    public var configFilePathPublisher: AnyPublisher<String, Never> {
        configFilePathSubject.eraseToAnyPublisher()
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
                aeroSpacePath: aeroSpacePathSubject.value
            )
        }

        set {
            showWindowTitlesSubject.send(newValue.showWindowTitles)
            aeroSpacePathSubject.send(newValue.aeroSpacePath)
        }
    }

    private var groupsSettings: GroupsSettings<RequiredMode> {
        get {
            GroupsSettings<RequiredMode>(
                showGroups: showGroupsSubject.value,
                groups: groupsSubject.value,
                groupsAppearanceMode: groupsAppearanceModeSubject.value.rawValue,
                globalGroupsVisualConfig: globalGroupsVisualConfigSubject.value
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
            globalGroupsVisualConfigSubject.send(newValue.globalGroupsVisualConfig)
        }
    }

    private var spacesSettings: SpacesSettings<RequiredMode> {
        get {
            SpacesSettings<RequiredMode>(
                showEmptySpaces: showEmptySpacesSubject.value,
                spacesVisualConfig: spacesVisualConfigSubject.value,
                spacesAppearanceMode: spacesAppearanceModeSubject.value.rawValue,
                globalSpacesVisualConfig: globalSpacesVisualConfigSubject.value
            )
        }

        set {
            showEmptySpacesSubject.send(newValue.showEmptySpaces)
            spacesVisualConfigSubject.send(newValue.spacesVisualConfig)
            spacesAppearanceModeSubject.send(
                SpacesAppearanceMode.allCases.first(
                    where: { $0.rawValue == newValue.spacesAppearanceMode }
                ) ?? ConfigurationDefaults.spacesAppearanceMode
            )
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
        spacesVisualConfigSubject.send(ConfigurationDefaults.spacesVisualConfiguration)
        spacesAppearanceModeSubject.send(ConfigurationDefaults.spacesAppearanceMode)
        globalSpacesVisualConfigSubject.send(ConfigurationDefaults.defaultSpaceVisualConfig)
        groupsSubject.send(ConfigurationDefaults.groups)
        groupsAppearanceModeSubject.send(ConfigurationDefaults.groupsAppearanceMode)
        globalGroupsVisualConfigSubject.send(ConfigurationDefaults.defaultGroupsGlobalVisualConfig)
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

    // MARK: - UI Configuration Async Setters

    /// Sets the vertical padding for the menu bar interface in points.

    /// Sets the spaces configuration and emits update.
    public func setSpacesVisualConfig(_ value: [VisualProperties]) {
        if value == spacesVisualConfigSubject.value { return }

        spacesVisualConfigSubject.send(value)
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

    /// Sets the global space visual configuration and emits update.
    public func setGlobalSpacesVisualConfig(_ value: VisualProperties) {
        if value == globalSpacesVisualConfigSubject.value { return }

        globalSpacesVisualConfigSubject.send(value)
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

    /// Sets the global groups visual configuration and emits update.
    public func setGlobalGroupsVisualConfig(_ value: VisualProperties) {
        if value == globalGroupsVisualConfigSubject.value { return }

        globalGroupsVisualConfigSubject.send(value)
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
        // Reset all subjects to default values without triggering file saves
        isUpdatingFromFile = true

        setConfigFilePath(ConfigurationDefaults.configFilePath)
        loadInitialAeroSpaceConfiguration()
        showWindowTitlesSubject.send(ConfigurationDefaults.showWindowTitles)
        focusWindowOnClickSubject.send(ConfigurationDefaults.focusWindowOnClick)
        showEmptySpacesSubject.send(ConfigurationDefaults.showEmptySpaces)
        showGroupsSubject.send(ConfigurationDefaults.showGroups)
        enablePerformanceMetricsSubject.send(ConfigurationDefaults.enablePerformanceMetrics)
        isOptimizedPerformanceEnabledSubject.send(ConfigurationDefaults.isOptimizedPerformanceEnabled)
        logLevelSubject.send(ConfigurationDefaults.logLevel)

        // Reset UI configuration subjects
        spacesVisualConfigSubject.send(ConfigurationDefaults.spacesVisualConfiguration)
        spacesAppearanceModeSubject.send(ConfigurationDefaults.spacesAppearanceMode)
        globalSpacesVisualConfigSubject.send(ConfigurationDefaults.defaultSpaceVisualConfig)
        groupsSubject.send(ConfigurationDefaults.groups)
        groupsAppearanceModeSubject.send(ConfigurationDefaults.groupsAppearanceMode)
        globalGroupsVisualConfigSubject.send(ConfigurationDefaults.defaultGroupsGlobalVisualConfig)

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
        Logger.debug("loadConfigurationFromFile() called", category: Logger.config)
        isUpdatingFromFile = true
        defer { isUpdatingFromFile = false }

        let configPath = configFilePathSubject.value
        guard FileManager.default.fileExists(atPath: configPath) else {
            Logger.info("Config file does not exist, using defaults: \\(configPath)", category: Logger.config)
            return
        }

        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: configPath))
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

    /// Saves current configuration to the TOML file.
    private func saveConfigurationToFile() {
        let configPath = configFilePathSubject.value
        let url = URL(fileURLWithPath: configPath)

        // Create directory if it doesn't exist
        let directory = url.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        do {
            let tomlString = try TOMLEncoder().encode(configurationData)
            let annotatedTomlString = addEnumComments(to: tomlString)
            try annotatedTomlString.write(to: url, atomically: true, encoding: String.Encoding.utf8)
            Logger.info("Configuration saved to file: \\(configPath)", category: Logger.config)
        } catch {
            Logger.error("Failed to save configuration to file: \\(error)", category: Logger.config)
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
