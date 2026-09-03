// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Foundation
import ServiceManagement
import SwiftUI

/// A coordinator view model that manages the overall settings interface.
///
/// This class coordinates between different settings ViewModels and handles
/// overall settings operations like loading, saving, and resetting all settings.
@MainActor
public class SettingsViewModel: ObservableObject {
    // MARK: - AeroSpace Properties

    /// The absolute path to the AeroSpace CLI binary.
    @Published var aeroSpacePath: String {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setAeroSpacePathUseCase.execute(value: aeroSpacePath)
            }
        }
    }

    /// The current log level for application logging.
    @Published var logLevel: Logger.Level {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setLogLevelUseCase.execute(value: logLevel)
            }
        }
    }

    /// Whether to enable performance metrics collection and logging.
    @Published var enablePerformanceMetrics: Bool {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setEnablePerformanceMetricsUseCase.execute(value: enablePerformanceMetrics)
            }
        }
    }

    /// Whether to enable optimized performance behavior.
    @Published var isOptimizedPerformanceEnabled: Bool {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setOptimizedPerformanceEnabledUseCase.execute(value: isOptimizedPerformanceEnabled)
            }
        }
    }

    /// The current AeroSpace version (if available).
    @Published var aeroSpaceVersion: String?

    /// Whether the running AeroSpace supports the event-subscription API.
    ///
    /// When it does, the app is driven by AeroSpace events and the optimized
    /// performance setting no longer has any effect.
    var supportsEventSubscription: Bool {
        AeroSpaceVersion(string: aeroSpaceVersion)?.supportsEventSubscription ?? false
    }

    /// The path to the configuration file.
    @Published var configFilePath: String {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setConfigFilePathUseCase.execute(value: configFilePath)
            }
        }
    }

    /// The current theme mode.
    @Published var themeMode: ThemeMode {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setThemeModeUseCase.execute(value: themeMode)
            }
        }
    }

    /// Returns all available theme modes (those where isAvailable == true).
    var availableThemeModes: [ThemeMode] {
        ThemeMode.allCases.filter(\.isAvailable)
    }

    /// Whether the Quick Hide feature is enabled.
    @Published var quickHideEnabled: Bool {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setQuickHideEnabledUseCase.execute(value: quickHideEnabled)
            }
        }
    }

    /// The modifier key that triggers the Quick Hide feature.
    @Published var quickHideTriggerKey: QuickHideTriggerKey {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setQuickHideTriggerKeyUseCase.execute(value: quickHideTriggerKey)
            }
        }
    }

    /// The current theme preset.
    @Published var themePresetColorProperties: ThemePresetColorProperties {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setThemePresetColorPropertiesUseCase.execute(value: themePresetColorProperties)
            }
        }
    }

    // MARK: - Software Update Properties

    /// Whether automatic checking for updates is enabled.
    @Published var automaticCheckForUpdatesEnabled: Bool {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setAutomaticCheckForUpdatesEnabledUseCase.execute(enabled: automaticCheckForUpdatesEnabled)
            }
        }
    }

    /// Whether automatic downloading of updates is enabled.
    @Published var automaticDownloadUpdatesEnabled: Bool {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setAutomaticDownloadUpdatesEnabledUseCase.execute(enabled: automaticDownloadUpdatesEnabled)
            }
        }
    }

    /// The date of the last update check.
    @Published var lastUpdateCheckDate: Date?

    // MARK: - Navigation History

    /// The default page to return to when resetting navigation.
    private static let defaultPage: RootNavigationPage = .general

    /// The root pages available in the sidebar navigation.
    @Published var rootPages: [RootNavigationPage] = []

    /// The dynamic sub-pages (like individual group pages) registered for navigation.
    @Published var subPages: [AnyNavigationPage] = []

    /// The current selected page in the unified navigation system.
    @Published var selectedPage: AnyNavigationPage = .init(defaultPage) {
        didSet {
            // Only add to history if this is a user selection (not programmatic)
            if !isNavigatingProgrammatically, selectedPage != oldValue {
                Task { [self] in
                    // Add the old page to history only if it's different from the last history item
                    // Special case: if history is empty, always add the old page
                    if navigationHistory.isEmpty || navigationHistory.last?.id != oldValue.id {
                        navigationHistory.append(oldValue)
                    }
                    // Clear forward history when user makes a new selection
                    forwardHistory.removeAll()
                }
            }
        }
    }

    /// The navigation history for backward navigation.
    @Published var navigationHistory: [AnyNavigationPage] = []

    /// The forward history for forward navigation.
    @Published var forwardHistory: [AnyNavigationPage] = []

    /// The current feature flags configuration.
    @Published var featureFlags: FeatureFlags

    /// Whether licensing features are enabled.
    private var enableLicensing: Bool

    /// Whether trial request functionality is enabled.
    private var enableTrialRequest: Bool

    /// Flag to track when we're updating selectedPage programmatically to avoid adding to history
    private var isNavigatingProgrammatically: Bool = false

    /// Whether to automatically launch the application at login.
    private var _launchAtLogin: Bool = false
    var launchAtLogin: Bool {
        get {
            let newStatus = SMAppService.mainApp.status == .enabled

            if newStatus != _launchAtLogin {
                _launchAtLogin = newStatus

                Task {
                    objectWillChange.send()
                }
            }

            return _launchAtLogin
        }
        set(newValue) {
            if newValue == launchAtLogin {
                return
            }

            objectWillChange.send()

            do {
                if newValue {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }

                _launchAtLogin = newValue
            } catch {
                Logger.error("Failed to update launch at login setting", error: error, category: Logger.config)
            }
        }
    }

    // MARK: - Display Use Cases

    // MARK: - System Menu Bar Use Cases

    private let getMenuBarAppsUseCase: GetMenuBarAppsUseCase
    private let getScreenCapturePermissionGrantedUseCase: GetScreenCapturePermissionGrantedUseCase
    private let requestScreenCapturePermissionsUseCase: RequestScreenCapturePermissionsUseCase

    /// Whether screen capture permissions are granted.
    @Published var screenCapturePermissionGranted: Bool = false

    // MARK: - AeroSpace Use Cases

    private let getAeroSpacePathUseCase: GetAeroSpacePathUseCase
    private let setAeroSpacePathUseCase: SetAeroSpacePathUseCase
    private let getAeroSpaceVersionUseCase: GetAeroSpaceVersionUseCase
    private let openAeroSpaceConfigUseCase: OpenAeroSpaceConfigUseCase
    private let resetConfigurationUseCase: ResetConfigurationUseCase
    private let getLogLevelUseCase: GetLogLevelUseCase
    private let setLogLevelUseCase: SetLogLevelUseCase
    private let getEnablePerformanceMetricsUseCase: GetEnablePerformanceMetricsUseCase
    private let setEnablePerformanceMetricsUseCase: SetEnablePerformanceMetricsUseCase
    private let getOptimizedPerformanceEnabledUseCase: GetOptimizedPerformanceEnabledUseCase
    private let setOptimizedPerformanceEnabledUseCase: SetOptimizedPerformanceEnabledUseCase
    private let getFeatureFlagsUseCase: GetFeatureFlagsUseCase
    private let getEnableLicensingUseCase: GetEnableLicensingUseCase
    private let getEnableTrialRequestUseCase: GetEnableTrialRequestUseCase
    private let getConfigFilePathUseCase: GetConfigFilePathUseCase
    private let setConfigFilePathUseCase: SetConfigFilePathUseCase
    private let openConfigFileUseCase: OpenConfigFileUseCase
    private let getThemeModeUseCase: GetThemeModeUseCase
    private let setThemeModeUseCase: SetThemeModeUseCase
    private let getThemePresetColorPropertiesUseCase: GetThemePresetColorPropertiesUseCase
    private let setThemePresetColorPropertiesUseCase: SetThemePresetColorPropertiesUseCase

    // MARK: - Quick Hide Use Cases

    private let getQuickHideEnabledUseCase: GetQuickHideEnabledUseCase
    private let setQuickHideEnabledUseCase: SetQuickHideEnabledUseCase
    private let getQuickHideTriggerKeyUseCase: GetQuickHideTriggerKeyUseCase
    private let setQuickHideTriggerKeyUseCase: SetQuickHideTriggerKeyUseCase

    // MARK: - Software Update Use Cases

    private let getAutomaticCheckForUpdatesEnabledUseCase: GetAutomaticCheckForUpdatesEnabledUseCase
    private let setAutomaticCheckForUpdatesEnabledUseCase: SetAutomaticCheckForUpdatesEnabledUseCase
    private let getAutomaticDownloadUpdatesEnabledUseCase: GetAutomaticDownloadUpdatesEnabledUseCase
    private let setAutomaticDownloadUpdatesEnabledUseCase: SetAutomaticDownloadUpdatesEnabledUseCase
    private let getLastUpdateCheckDateUseCase: GetLastUpdateCheckDateUseCase
    private let checkForUpdatesUseCase: CheckForUpdatesUseCase

    /// Cancellable subscriptions for Combine publishers.
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initialization

    /// Initializes the settings view model with dependencies.
    /// - Parameters:
    ///   - getMenuBarAppsUseCase: Use case to get menu bar apps.
    ///   - getScreenCapturePermissionGrantedUseCase: Use case to get screen capture permission status.
    ///   - requestScreenCapturePermissionsUseCase: Use case to request screen capture permissions.
    ///   - getAeroSpacePathUseCase: Use case to get AeroSpace path.
    ///   - setAeroSpacePathUseCase: Use case to set AeroSpace path.
    ///   - getAeroSpaceVersionUseCase: Use case to get AeroSpace version.
    ///   - openAeroSpaceConfigUseCase: Use case to open AeroSpace config.
    ///   - resetConfigurationUseCase: Use case to reset configuration.
    ///   - getLogLevelUseCase: Use case to get log level.
    ///   - setLogLevelUseCase: Use case to set log level.
    ///   - getEnablePerformanceMetricsUseCase: Use case to get enable performance metrics setting.
    ///   - setEnablePerformanceMetricsUseCase: Use case to set enable performance metrics setting.
    ///   - getOptimizedPerformanceEnabledUseCase: Use case to get optimized performance enabled setting.
    ///   - setOptimizedPerformanceEnabledUseCase: Use case to set optimized performance enabled setting.
    ///   - getFeatureFlagsUseCase: Use case to get feature flags.
    ///   - getEnableLicensingUseCase: Use case to get enableLicensing feature flag.
    ///   - getEnableTrialRequestUseCase: Use case to get enableTrialRequest feature flag.
    ///   - getConfigFilePathUseCase: Use case to get config file path.
    ///   - setConfigFilePathUseCase: Use case to set config file path.
    ///   - openConfigFileUseCase: Use case to open config file.
    ///   - getThemeModeUseCase: Use case to get theme mode.
    ///   - setThemeModeUseCase: Use case to set theme mode.
    ///   - getThemePresetColorPropertiesUseCase: Use case to get theme preset.
    ///   - setThemePresetColorPropertiesUseCase: Use case to set theme preset.
    ///   - getAutomaticCheckForUpdatesEnabledUseCase: Use case to get automatic check for updates enabled setting.
    ///   - setAutomaticCheckForUpdatesEnabledUseCase: Use case to set automatic check for updates enabled setting.
    ///   - getAutomaticDownloadUpdatesEnabledUseCase: Use case to get automatic download updates enabled setting.
    ///   - setAutomaticDownloadUpdatesEnabledUseCase: Use case to set automatic download updates enabled setting.
    ///   - getLastUpdateCheckDateUseCase: Use case to get last update check date.
    ///   - checkForUpdatesUseCase: Use case to manually check for updates.
    ///   - getQuickHideEnabledUseCase: Use case to get Quick Hide enabled state.
    ///   - setQuickHideEnabledUseCase: Use case to set Quick Hide enabled state.
    ///   - getQuickHideTriggerKeyUseCase: Use case to get Quick Hide trigger key.
    ///   - setQuickHideTriggerKeyUseCase: Use case to set Quick Hide trigger key.
    init(
        getMenuBarAppsUseCase: GetMenuBarAppsUseCase,
        getScreenCapturePermissionGrantedUseCase: GetScreenCapturePermissionGrantedUseCase,
        requestScreenCapturePermissionsUseCase: RequestScreenCapturePermissionsUseCase,
        getAeroSpacePathUseCase: GetAeroSpacePathUseCase,
        setAeroSpacePathUseCase: SetAeroSpacePathUseCase,
        getAeroSpaceVersionUseCase: GetAeroSpaceVersionUseCase,
        openAeroSpaceConfigUseCase: OpenAeroSpaceConfigUseCase,
        resetConfigurationUseCase: ResetConfigurationUseCase,
        getLogLevelUseCase: GetLogLevelUseCase,
        setLogLevelUseCase: SetLogLevelUseCase,
        getEnablePerformanceMetricsUseCase: GetEnablePerformanceMetricsUseCase,
        setEnablePerformanceMetricsUseCase: SetEnablePerformanceMetricsUseCase,
        getOptimizedPerformanceEnabledUseCase: GetOptimizedPerformanceEnabledUseCase,
        setOptimizedPerformanceEnabledUseCase: SetOptimizedPerformanceEnabledUseCase,
        getFeatureFlagsUseCase: GetFeatureFlagsUseCase,
        getEnableLicensingUseCase: GetEnableLicensingUseCase,
        getEnableTrialRequestUseCase: GetEnableTrialRequestUseCase,
        getConfigFilePathUseCase: GetConfigFilePathUseCase,
        setConfigFilePathUseCase: SetConfigFilePathUseCase,
        openConfigFileUseCase: OpenConfigFileUseCase,
        getThemeModeUseCase: GetThemeModeUseCase,
        setThemeModeUseCase: SetThemeModeUseCase,
        getThemePresetColorPropertiesUseCase: GetThemePresetColorPropertiesUseCase,
        setThemePresetColorPropertiesUseCase: SetThemePresetColorPropertiesUseCase,
        getAutomaticCheckForUpdatesEnabledUseCase: GetAutomaticCheckForUpdatesEnabledUseCase,
        setAutomaticCheckForUpdatesEnabledUseCase: SetAutomaticCheckForUpdatesEnabledUseCase,
        getAutomaticDownloadUpdatesEnabledUseCase: GetAutomaticDownloadUpdatesEnabledUseCase,
        setAutomaticDownloadUpdatesEnabledUseCase: SetAutomaticDownloadUpdatesEnabledUseCase,
        getLastUpdateCheckDateUseCase: GetLastUpdateCheckDateUseCase,
        checkForUpdatesUseCase: CheckForUpdatesUseCase,
        getQuickHideEnabledUseCase: GetQuickHideEnabledUseCase,
        setQuickHideEnabledUseCase: SetQuickHideEnabledUseCase,
        getQuickHideTriggerKeyUseCase: GetQuickHideTriggerKeyUseCase,
        setQuickHideTriggerKeyUseCase: SetQuickHideTriggerKeyUseCase
    ) {
        // Initialize System Menu Bar Use Cases
        self.getMenuBarAppsUseCase = getMenuBarAppsUseCase
        self.getScreenCapturePermissionGrantedUseCase = getScreenCapturePermissionGrantedUseCase
        self.requestScreenCapturePermissionsUseCase = requestScreenCapturePermissionsUseCase

        // Initialize AeroSpace Use Cases
        self.getAeroSpacePathUseCase = getAeroSpacePathUseCase
        self.setAeroSpacePathUseCase = setAeroSpacePathUseCase
        self.getAeroSpaceVersionUseCase = getAeroSpaceVersionUseCase
        self.openAeroSpaceConfigUseCase = openAeroSpaceConfigUseCase
        self.resetConfigurationUseCase = resetConfigurationUseCase
        self.getLogLevelUseCase = getLogLevelUseCase
        self.setLogLevelUseCase = setLogLevelUseCase
        self.getEnablePerformanceMetricsUseCase = getEnablePerformanceMetricsUseCase
        self.setEnablePerformanceMetricsUseCase = setEnablePerformanceMetricsUseCase
        self.getOptimizedPerformanceEnabledUseCase = getOptimizedPerformanceEnabledUseCase
        self.setOptimizedPerformanceEnabledUseCase = setOptimizedPerformanceEnabledUseCase
        self.getFeatureFlagsUseCase = getFeatureFlagsUseCase
        self.getEnableLicensingUseCase = getEnableLicensingUseCase
        self.getEnableTrialRequestUseCase = getEnableTrialRequestUseCase
        self.getConfigFilePathUseCase = getConfigFilePathUseCase
        self.setConfigFilePathUseCase = setConfigFilePathUseCase
        self.openConfigFileUseCase = openConfigFileUseCase
        self.getThemeModeUseCase = getThemeModeUseCase
        self.setThemeModeUseCase = setThemeModeUseCase
        self.getThemePresetColorPropertiesUseCase = getThemePresetColorPropertiesUseCase
        self.setThemePresetColorPropertiesUseCase = setThemePresetColorPropertiesUseCase

        // Initialize Quick Hide Use Cases
        self.getQuickHideEnabledUseCase = getQuickHideEnabledUseCase
        self.setQuickHideEnabledUseCase = setQuickHideEnabledUseCase
        self.getQuickHideTriggerKeyUseCase = getQuickHideTriggerKeyUseCase
        self.setQuickHideTriggerKeyUseCase = setQuickHideTriggerKeyUseCase

        // Initialize Software Update Use Cases
        self.getAutomaticCheckForUpdatesEnabledUseCase = getAutomaticCheckForUpdatesEnabledUseCase
        self.setAutomaticCheckForUpdatesEnabledUseCase = setAutomaticCheckForUpdatesEnabledUseCase
        self.getAutomaticDownloadUpdatesEnabledUseCase = getAutomaticDownloadUpdatesEnabledUseCase
        self.setAutomaticDownloadUpdatesEnabledUseCase = setAutomaticDownloadUpdatesEnabledUseCase
        self.getLastUpdateCheckDateUseCase = getLastUpdateCheckDateUseCase
        self.checkForUpdatesUseCase = checkForUpdatesUseCase

        // Load initial values from use cases
        aeroSpacePath = getAeroSpacePathUseCase.execute().blockingFirst()
        aeroSpaceVersion = getAeroSpaceVersionUseCase.execute().blockingFirst()
        logLevel = getLogLevelUseCase.execute().blockingFirst()
        enablePerformanceMetrics = getEnablePerformanceMetricsUseCase.execute().blockingFirst()
        isOptimizedPerformanceEnabled = getOptimizedPerformanceEnabledUseCase.execute().blockingFirst()
        featureFlags = getFeatureFlagsUseCase.execute().blockingFirst()
        enableLicensing = getEnableLicensingUseCase.execute().blockingFirst()
        enableTrialRequest = getEnableTrialRequestUseCase.execute().blockingFirst()
        configFilePath = getConfigFilePathUseCase.execute().blockingFirst()
        themeMode = getThemeModeUseCase.execute().blockingFirst()
        themePresetColorProperties = getThemePresetColorPropertiesUseCase.execute().blockingFirst()
        quickHideEnabled = getQuickHideEnabledUseCase.execute().blockingFirst()
        quickHideTriggerKey = getQuickHideTriggerKeyUseCase.execute().blockingFirst()
        automaticCheckForUpdatesEnabled = getAutomaticCheckForUpdatesEnabledUseCase.execute().blockingFirst()
        automaticDownloadUpdatesEnabled = getAutomaticDownloadUpdatesEnabledUseCase.execute().blockingFirst()
        lastUpdateCheckDate = getLastUpdateCheckDateUseCase.execute().blockingFirst()

        // Setup reactive subscriptions
        updateAvailableOptions(with: featureFlags)
        setupReactiveSubscriptions()
    }

    // MARK: - Computed Properties

    /// Custom path validation error message.
    var customPathValidationError: String? {
        let customPath = aeroSpacePath

        // If path is empty, that's fine (auto-detection will be used)
        if customPath.isEmpty {
            return nil
        }

        // Check if file exists and is executable
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: customPath) {
            return "File does not exist at specified path"
        }

        if !fileManager.isExecutableFile(atPath: customPath) {
            return "File is not executable"
        }

        return nil
    }

    /// Config file path validation error message.
    var configFilePathValidationError: String? {
        let configPath = configFilePath

        // If path is empty, that's not valid for config files
        if configPath.isEmpty {
            return "Configuration file path cannot be empty"
        }

        // Check if the parent directory exists or can be created
        let url = URL(fileURLWithPath: configPath)
        let parentDirectory = url.deletingLastPathComponent()

        if !FileManager.default.fileExists(atPath: parentDirectory.path) {
            // Try to create the directory to see if it's valid
            do {
                try FileManager.default.createDirectory(at: parentDirectory, withIntermediateDirectories: true)
            } catch {
                return "Cannot create parent directory: \\(parentDirectory.path)"
            }
        }

        // Check if file exists and is readable/writable, or if it can be created
        if FileManager.default.fileExists(atPath: configPath) {
            if !FileManager.default.isReadableFile(atPath: configPath) {
                return "File is not readable"
            }
            if !FileManager.default.isWritableFile(atPath: configPath) {
                return "File is not writable"
            }
        }

        return nil
    }

    // MARK: - Computed Properties

    /// Computed property for backward navigation availability.
    var canNavigateBackward: Bool {
        !navigationHistory.isEmpty
    }

    /// Computed property for forward navigation availability.
    var canNavigateForward: Bool {
        !forwardHistory.isEmpty
    }

    /// All available pages for navigation (root pages + sub-pages).
    var allAvailablePages: [AnyNavigationPage] {
        var pages = rootPages.map { AnyNavigationPage($0) }
        pages += subPages.filter { subPage in
            // Only include sub-pages whose parent is available
            guard let parentPage = subPage.parentPage else { return true }

            return rootPages.contains { AnyNavigationPage($0).id == parentPage.id }
        }
        return pages
    }

    /// Pages that should be displayed in the sidebar (only root pages).
    var sidebarPages: [AnyNavigationPage] {
        rootPages.map { AnyNavigationPage($0) }
    }

    /// The current page to show as selected in the sidebar.
    /// For sub-pages, this returns their parent page.
    var sidebarSelectedPage: AnyNavigationPage {
        // If current page has a parent, show the parent as selected in sidebar
        if let parentPage = selectedPage.parentPage {
            return AnyNavigationPage(parentPage)
        }
        // Otherwise, show the current page
        return selectedPage
    }

    // MARK: - Public Methods

    /// Resets all settings to their default values.
    func resetSettingsToDefaults() async {
        await resetConfigurationUseCase.execute()
    }

    /// Opens the AeroSpace configuration file.
    func openAeroSpaceConfig() async {
        await openAeroSpaceConfigUseCase.execute()
    }

    /// Opens the configuration file.
    func openConfigFile() async {
        await openConfigFileUseCase.execute()
    }

    /// Requests screen capture permissions from the user.
    func requestScreenCapturePermissions() async {
        await requestScreenCapturePermissionsUseCase.execute()
    }

    /// Manually checks for available software updates.
    func checkForUpdates() async {
        await checkForUpdatesUseCase.execute()
    }

    // MARK: - Navigation Methods

    /// Sets programmatically the currently selected navigation page.
    /// - Parameter targetPage: The page to navigate to
    private func setSelectedPage(_ targetPage: AnyNavigationPage) {
        // Set flag to prevent adding to history during programmatic change
        isNavigatingProgrammatically = true
        selectedPage = targetPage
        isNavigatingProgrammatically = false
    }

    /// Navigates to a specific page and updates history.
    /// - Parameter page: The page to navigate to
    func navigateTo(_ page: AnyNavigationPage) {
        // Add current page to history before navigating
        if navigationHistory.last?.id != selectedPage.id {
            navigationHistory.append(selectedPage)
        }

        // Clear forward history when navigating to a new page
        forwardHistory.removeAll()

        setSelectedPage(page)
    }

    /// Navigates backward to the previous page in history.
    func navigateBackward() {
        guard canNavigateBackward else { return }

        // Add current page to forward history
        forwardHistory.append(selectedPage)

        // Get the previous page and remove it from history
        let previousPage = navigationHistory.removeLast()
        setSelectedPage(previousPage)
    }

    /// Navigates forward to the next page in forward history.
    func navigateForward() {
        guard canNavigateForward else { return }

        // Add current page to navigation history
        navigationHistory.append(selectedPage)

        // Get next page from forward history
        let nextPage = forwardHistory.removeLast()
        setSelectedPage(nextPage)
    }

    /// Registers a dynamic sub-page to navigation.
    /// - Parameter subPage: The sub-page to register
    func registerDynamicSubPage(_ subPage: AnyNavigationPage) {
        // Remove any existing page with the same ID
        subPages.removeAll { $0.id == subPage.id }

        // Add the new page
        subPages.append(subPage)

        // Update available pages to include the new sub-page
        updateAllAvailablePages()
    }

    /// Unregisters a dynamic sub-page from navigation.
    /// - Parameter pageId: The ID of the page to unregister
    func unregisterDynamicSubPage(withId pageId: Int) {
        subPages.removeAll { $0.id == pageId }

        // If the current selected page was removed, navigate back to groups
        if selectedPage.id == pageId {
            setSelectedPage(AnyNavigationPage(RootNavigationPage.groups))
        }

        // Clean up history
        navigationHistory.removeAll { $0.id == pageId }
        forwardHistory.removeAll { $0.id == pageId }

        // Update available pages
        updateAllAvailablePages()
    }

    /// Resets navigation state when the settings window closes.
    /// Clears navigation history and returns to the default general page.
    func resetNavigationOnWindowClose() {
        navigationHistory.removeAll()
        forwardHistory.removeAll()

        setSelectedPage(AnyNavigationPage(Self.defaultPage))
    }

    // MARK: - Private Methods

    /// Setup reactive subscriptions to UseCase publishers.
    private func setupReactiveSubscriptions() {
        // Monitor configuration changes

        getScreenCapturePermissionGrantedUseCase.execute()
            .assign(to: \.screenCapturePermissionGranted, on: self)
            .store(in: &cancellables)

        getAeroSpacePathUseCase.execute()
            .assign(to: \.aeroSpacePath, on: self)
            .store(in: &cancellables)

        getAeroSpaceVersionUseCase.execute()
            .assign(to: \.aeroSpaceVersion, on: self)
            .store(in: &cancellables)

        getLogLevelUseCase.execute()
            .assign(to: \.logLevel, on: self)
            .store(in: &cancellables)

        getEnablePerformanceMetricsUseCase.execute()
            .assign(to: \.enablePerformanceMetrics, on: self)
            .store(in: &cancellables)

        getOptimizedPerformanceEnabledUseCase.execute()
            .assign(to: \.isOptimizedPerformanceEnabled, on: self)
            .store(in: &cancellables)

        getFeatureFlagsUseCase.execute()
            .sink { [weak self] featureFlags in
                if self?.featureFlags != featureFlags {
                    self?.updateAvailableOptions(with: featureFlags)
                    self?.featureFlags = featureFlags
                }
            }
            .store(in: &cancellables)

        getEnableLicensingUseCase.execute()
            .sink { [weak self] enableLicensing in
                if self?.enableLicensing != enableLicensing {
                    self?.enableLicensing = enableLicensing
                    if let featureFlags = self?.featureFlags {
                        self?.updateAvailableOptions(with: featureFlags)
                    }
                }
            }
            .store(in: &cancellables)

        getEnableTrialRequestUseCase.execute()
            .assign(to: \.enableTrialRequest, on: self)
            .store(in: &cancellables)

        getConfigFilePathUseCase.execute()
            .assign(to: \.configFilePath, on: self)
            .store(in: &cancellables)

        getThemeModeUseCase.execute()
            .assign(to: \.themeMode, on: self)
            .store(in: &cancellables)

        getThemePresetColorPropertiesUseCase.execute()
            .assign(to: \.themePresetColorProperties, on: self)
            .store(in: &cancellables)

        getQuickHideEnabledUseCase.execute()
            .assign(to: \.quickHideEnabled, on: self)
            .store(in: &cancellables)

        getQuickHideTriggerKeyUseCase.execute()
            .assign(to: \.quickHideTriggerKey, on: self)
            .store(in: &cancellables)

        getAutomaticCheckForUpdatesEnabledUseCase.execute()
            .assign(to: \.automaticCheckForUpdatesEnabled, on: self)
            .store(in: &cancellables)

        getAutomaticDownloadUpdatesEnabledUseCase.execute()
            .assign(to: \.automaticDownloadUpdatesEnabled, on: self)
            .store(in: &cancellables)

        getLastUpdateCheckDateUseCase.execute()
            .assign(to: \.lastUpdateCheckDate, on: self)
            .store(in: &cancellables)
    }

    /// Updates available navigation options based on feature flags.
    /// - Parameter featureFlags: The current feature flags configuration
    private func updateAvailableOptions(with featureFlags: FeatureFlags) {
        let previousRootPages = rootPages

        rootPages = RootNavigationPage.allCases.filter { option in
            switch option {
            case .license:
                enableLicensing

            case .general:
                true // General is always available

            case .spaces:
                featureFlags.enableSpaces

            case .groups:
                featureFlags.enableGroups

            case .updates:
                featureFlags.enableSoftwareUpdates

            case .advanced:
                featureFlags.enableAdvancedSettings

            #if DEBUG

                case .developer:
                    true // Developer is always available in debug builds
            #endif
            }
        }

        // If groups feature was disabled, clean up all group pages from navigation
        let wasGroupsEnabled = previousRootPages.contains(.groups)
        let isGroupsEnabled = featureFlags.enableGroups

        if wasGroupsEnabled, !isGroupsEnabled {
            removeAllSubPagesOfType { page in
                // Remove all pages that have .groups as parent
                page.parentPage?.id == RootNavigationPage.groups.id
            }
        }

        // Update all available pages
        updateAllAvailablePages()
    }

    /// Updates the list of all available pages (main pages + sub-pages).
    private func updateAllAvailablePages() {
        // Start with main navigation pages converted to AnyNavigationPage
        var allAvailablePages = rootPages.map { AnyNavigationPage($0) }

        // Add currently registered sub-pages that have valid parent pages
        let validSubPages = subPages.filter { subPage in
            // Check if the sub-page's parent is still available
            guard let parentPage = subPage.parentPage else { return true }

            return rootPages.contains { AnyNavigationPage($0).id == parentPage.id }
        }

        allAvailablePages += validSubPages

        // Check if current selected page is still available
        if !allAvailablePages.contains(where: { $0.id == selectedPage.id }) {
            setSelectedPage(AnyNavigationPage(Self.defaultPage))
        }

        // Clean up navigation history to remove disabled pages
        navigationHistory = navigationHistory.filter { page in
            allAvailablePages.contains { $0.id == page.id }
        }

        // Clean up forward history to remove disabled pages
        forwardHistory = forwardHistory.filter { page in
            allAvailablePages.contains { $0.id == page.id }
        }

        // Remove sub-pages whose parent is no longer available
        subPages = validSubPages
    }

    /// Removes all sub-pages that match the given predicate from navigation history and sub-pages collection.
    ///
    /// This method is useful for cleaning up navigation state when certain features are disabled
    /// (e.g., when groups feature is turned off, all group pages should be removed from history).
    ///
    /// - Parameter predicate: A closure that returns true for pages that should be removed
    func removeAllSubPagesOfType(_ predicate: (AnyNavigationPage) -> Bool) {
        // Remove matching pages from navigation history
        navigationHistory = navigationHistory.filter { !predicate($0) }

        // Remove matching pages from forward history
        forwardHistory = forwardHistory.filter { !predicate($0) }

        // Remove matching pages from sub-pages collection
        subPages = subPages.filter { !predicate($0) }

        // If the currently selected page matches the predicate, navigate back to a safe page
        if predicate(selectedPage) {
            // Try to navigate to the parent page if available, otherwise go to default
            if
                let parentPage = selectedPage.parentPage,
                rootPages.contains(where: { AnyNavigationPage($0).id == parentPage.id })
            {
                setSelectedPage(AnyNavigationPage(parentPage))
            } else {
                setSelectedPage(AnyNavigationPage(Self.defaultPage))
            }
        }
    }
}
