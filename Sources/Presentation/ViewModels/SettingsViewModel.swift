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
class SettingsViewModel: ObservableObject {
    // MARK: - Display Properties

    /// Whether to immediately focus a window when clicking on it.
    @Published var focusWindowOnClick: Bool {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setFocusWindowOnClickUseCase.execute(enabled: focusWindowOnClick)
            }
        }
    }

    /// Whether to show empty spaces in the interface.
    @Published var showEmptySpaces: Bool {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setShowEmptySpacesUseCase.execute(value: showEmptySpaces)
            }
        }
    }

    /// Whether to show window titles in the interface.
    @Published var showWindowTitles: Bool {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setShowWindowTitlesUseCase.execute(value: showWindowTitles)
            }
        }
    }

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

    // MARK: - Spaces Appearance Properties

    @Published var spacesVisualConfig: [VisualContainer] {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setSpacesVisualConfigUseCase.execute(value: spacesVisualConfig)
            }
        }
    }

    @Published var spacesAppearanceMode: SpacesAppearanceMode {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setSpacesAppearanceModeUseCase.execute(value: spacesAppearanceMode)
            }
        }
    }

    @Published var globalSpacesVisualConfig: VisualContainer {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setGlobalSpacesVisualConfigUseCase.execute(value: globalSpacesVisualConfig)
            }
        }
    }

    // MARK: - Groups Appearance Properties

    @Published var groups: [Domain.Group] {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setGroupsUseCase.execute(value: groups)
            }
        }
    }

    @Published var groupsAppearanceMode: GroupsAppearanceMode {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setGroupsAppearanceModeUseCase.execute(mode: groupsAppearanceMode)
            }
        }
    }

    @Published var globalGroupsVisualConfig: VisualContainer {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setGlobalGroupsVisualConfigUseCase.execute(value: globalGroupsVisualConfig)
            }
        }
    }

    /// The current AeroSpace version (if available).
    @Published var aeroSpaceVersion: String?

    /// The duration of animations in seconds.
    @Published var animationDuration: Double

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
    private var featureFlags: FeatureFlags?

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

    private let getFocusWindowOnClickUseCase: GetFocusWindowOnClickUseCase
    private let setFocusWindowOnClickUseCase: SetFocusWindowOnClickUseCase
    private let getShowEmptySpacesUseCase: GetShowEmptySpacesUseCase
    private let setShowEmptySpacesUseCase: SetShowEmptySpacesUseCase
    private let getShowWindowTitlesUseCase: GetShowWindowTitlesUseCase
    private let setShowWindowTitlesUseCase: SetShowWindowTitlesUseCase

    // MARK: - System Menu Bar Use Cases

    private let getMenuBarAppsUseCase: GetMenuBarAppsUseCase

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
    private let getAnimationDurationUseCase: GetAnimationDurationUseCase

    // MARK: - Spaces Use Cases

    private let getSpacesVisualConfigUseCase: GetSpacesVisualConfigUseCase
    private let setSpacesVisualConfigUseCase: SetSpacesVisualConfigUseCase
    private let getSpacesAppearanceModeUseCase: GetSpacesAppearanceModeUseCase
    private let setSpacesAppearanceModeUseCase: SetSpacesAppearanceModeUseCase
    private let getGlobalSpacesVisualConfigUseCase: GetGlobalSpacesVisualConfigUseCase
    private let setGlobalSpacesVisualConfigUseCase: SetGlobalSpacesVisualConfigUseCase

    // MARK: - Groups Use Cases

    private let getGroupsUseCase: GetGroupsUseCase
    private let setGroupsUseCase: SetGroupsUseCase
    private let getGroupsAppearanceModeUseCase: GetGroupsAppearanceModeUseCase
    private let setGroupsAppearanceModeUseCase: SetGroupsAppearanceModeUseCase
    private let getGlobalGroupsVisualConfigUseCase: GetGlobalGroupsVisualConfigUseCase
    private let setGlobalGroupsVisualConfigUseCase: SetGlobalGroupsVisualConfigUseCase

    /// Cancellable subscriptions for Combine publishers.
    private var cancellables: Set<AnyCancellable> = []

    /// Current space visual configuration for building updates.
    private var currentSpaceVisualConfig: VisualContainer?

    /// Current groups visual configuration for building updates.
    private var currentGroupsVisualConfig: VisualContainer?

    // MARK: - Initialization

    /// Initializes the settings view model with dependencies.
    /// - Parameters:
    ///   - getFocusWindowOnClickUseCase: Use case to get focus window on click setting.
    ///   - setFocusWindowOnClickUseCase: Use case to set focus window on click setting.
    ///   - getShowEmptySpacesUseCase: Use case to get show empty spaces setting.
    ///   - setShowEmptySpacesUseCase: Use case to set show empty spaces setting.
    ///   - getShowWindowTitlesUseCase: Use case to get show window titles setting.
    ///   - setShowWindowTitlesUseCase: Use case to set show window titles setting.
    ///   - getMenuBarAppsUseCase: Use case to get menu bar apps.
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
    ///   - getAnimationDurationUseCase: Use case for getting animation duration.
    ///   - getSpacesVisualConfigUseCase: Use case to get spaces visual config.
    ///   - setSpacesVisualConfigUseCase: Use case to set spaces visual config.
    ///   - getSpacesAppearanceModeUseCase: Use case to get spaces appearance mode.
    ///   - setSpacesAppearanceModeUseCase: Use case to set spaces appearance mode.
    ///   - getGlobalSpacesVisualConfigUseCase: Use case to get global spaces visual config.
    ///   - setGlobalSpacesVisualConfigUseCase: Use case to set global spaces visual config.
    ///   - getGroupsUseCase: Use case to get groups.
    ///   - setGroupsUseCase: Use case to set groups.
    ///   - getGroupsAppearanceModeUseCase: Use case to get groups appearance mode.
    ///   - setGroupsAppearanceModeUseCase: Use case to set groups appearance mode.
    ///   - getGlobalGroupsVisualConfigUseCase: Use case to get global groups visual config.
    ///   - setGlobalGroupsVisualConfigUseCase: Use case to set global groups visual config.
    init(
        getFocusWindowOnClickUseCase: GetFocusWindowOnClickUseCase,
        setFocusWindowOnClickUseCase: SetFocusWindowOnClickUseCase,
        getShowEmptySpacesUseCase: GetShowEmptySpacesUseCase,
        setShowEmptySpacesUseCase: SetShowEmptySpacesUseCase,
        getShowWindowTitlesUseCase: GetShowWindowTitlesUseCase,
        setShowWindowTitlesUseCase: SetShowWindowTitlesUseCase,
        getMenuBarAppsUseCase: GetMenuBarAppsUseCase,
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
        getAnimationDurationUseCase: GetAnimationDurationUseCase,
        getSpacesVisualConfigUseCase: GetSpacesVisualConfigUseCase,
        setSpacesVisualConfigUseCase: SetSpacesVisualConfigUseCase,
        getSpacesAppearanceModeUseCase: GetSpacesAppearanceModeUseCase,
        setSpacesAppearanceModeUseCase: SetSpacesAppearanceModeUseCase,
        getGlobalSpacesVisualConfigUseCase: GetGlobalSpacesVisualConfigUseCase,
        setGlobalSpacesVisualConfigUseCase: SetGlobalSpacesVisualConfigUseCase,
        getGroupsUseCase: GetGroupsUseCase,
        setGroupsUseCase: SetGroupsUseCase,
        getGroupsAppearanceModeUseCase: GetGroupsAppearanceModeUseCase,
        setGroupsAppearanceModeUseCase: SetGroupsAppearanceModeUseCase,
        getGlobalGroupsVisualConfigUseCase: GetGlobalGroupsVisualConfigUseCase,
        setGlobalGroupsVisualConfigUseCase: SetGlobalGroupsVisualConfigUseCase
    ) {
        // Initialize Display Use Cases
        self.getFocusWindowOnClickUseCase = getFocusWindowOnClickUseCase
        self.setFocusWindowOnClickUseCase = setFocusWindowOnClickUseCase
        self.getShowEmptySpacesUseCase = getShowEmptySpacesUseCase
        self.setShowEmptySpacesUseCase = setShowEmptySpacesUseCase
        self.getShowWindowTitlesUseCase = getShowWindowTitlesUseCase
        self.setShowWindowTitlesUseCase = setShowWindowTitlesUseCase

        // Initialize System Menu Bar Use Cases
        self.getMenuBarAppsUseCase = getMenuBarAppsUseCase

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
        self.getAnimationDurationUseCase = getAnimationDurationUseCase

        // Initialize Spaces Use Cases
        self.getSpacesVisualConfigUseCase = getSpacesVisualConfigUseCase
        self.setSpacesVisualConfigUseCase = setSpacesVisualConfigUseCase
        self.getSpacesAppearanceModeUseCase = getSpacesAppearanceModeUseCase
        self.setSpacesAppearanceModeUseCase = setSpacesAppearanceModeUseCase
        self.getGlobalSpacesVisualConfigUseCase = getGlobalSpacesVisualConfigUseCase
        self.setGlobalSpacesVisualConfigUseCase = setGlobalSpacesVisualConfigUseCase

        // Initialize Groups Use Cases
        self.getGroupsUseCase = getGroupsUseCase
        self.setGroupsUseCase = setGroupsUseCase
        self.getGroupsAppearanceModeUseCase = getGroupsAppearanceModeUseCase
        self.setGroupsAppearanceModeUseCase = setGroupsAppearanceModeUseCase
        self.getGlobalGroupsVisualConfigUseCase = getGlobalGroupsVisualConfigUseCase
        self.setGlobalGroupsVisualConfigUseCase = setGlobalGroupsVisualConfigUseCase

        // Load initial values from use cases
        focusWindowOnClick = getFocusWindowOnClickUseCase.execute().blockingFirst()
        showEmptySpaces = getShowEmptySpacesUseCase.execute().blockingFirst()
        showWindowTitles = getShowWindowTitlesUseCase.execute().blockingFirst()
        aeroSpacePath = getAeroSpacePathUseCase.execute().blockingFirst()
        aeroSpaceVersion = getAeroSpaceVersionUseCase.execute().blockingFirst()
        logLevel = getLogLevelUseCase.execute().blockingFirst()
        enablePerformanceMetrics = getEnablePerformanceMetricsUseCase.execute().blockingFirst()
        isOptimizedPerformanceEnabled = getOptimizedPerformanceEnabledUseCase.execute().blockingFirst()
        animationDuration = getAnimationDurationUseCase.execute().blockingFirst()

        // Load consolidated visual configurations
        spacesVisualConfig = getSpacesVisualConfigUseCase.execute().blockingFirst()
        spacesAppearanceMode = getSpacesAppearanceModeUseCase.execute().blockingFirst()
        globalSpacesVisualConfig = getGlobalSpacesVisualConfigUseCase.execute().blockingFirst()
        groups = getGroupsUseCase.execute().blockingFirst()
        groupsAppearanceMode = getGroupsAppearanceModeUseCase.execute().blockingFirst()
        globalGroupsVisualConfig = getGlobalGroupsVisualConfigUseCase.execute().blockingFirst()

        // Setup reactive subscriptions
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
    func resetAllSettings() async {
        await resetConfigurationUseCase.execute()
    }

    /// Opens the AeroSpace configuration file.
    func openAeroSpaceConfig() async {
        await openAeroSpaceConfigUseCase.execute()
    }

    // MARK: - Navigation Methods

    /// Navigates to a specific page and updates history.
    /// - Parameter page: The page to navigate to
    func navigateTo(_ page: AnyNavigationPage) {
        // Add current page to history before navigating
        if navigationHistory.last?.id != selectedPage.id {
            navigationHistory.append(selectedPage)
        }
        // Clear forward history when navigating to a new page
        forwardHistory.removeAll()

        // Set flag to prevent adding to history during programmatic change
        isNavigatingProgrammatically = true
        selectedPage = page
        isNavigatingProgrammatically = false
    }

    /// Navigates backward to the previous page in history.
    func navigateBackward() {
        guard canNavigateBackward else { return }

        // Add current page to forward history
        forwardHistory.append(selectedPage)

        // Get the previous page and remove it from history
        let previousPage = navigationHistory.removeLast()

        // Set flag to prevent adding to history during programmatic change
        isNavigatingProgrammatically = true
        selectedPage = previousPage
        isNavigatingProgrammatically = false
    }

    /// Navigates forward to the next page in forward history.
    func navigateForward() {
        guard canNavigateForward else { return }

        // Add current page to navigation history
        navigationHistory.append(selectedPage)

        // Get next page from forward history
        let nextPage = forwardHistory.removeLast()

        // Set flag to prevent adding to history during programmatic change
        isNavigatingProgrammatically = true
        selectedPage = nextPage
        isNavigatingProgrammatically = false
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
            isNavigatingProgrammatically = true
            selectedPage = AnyNavigationPage(RootNavigationPage.groups)
            isNavigatingProgrammatically = false
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
        isNavigatingProgrammatically = true
        selectedPage = AnyNavigationPage(SettingsViewModel.defaultPage)
        isNavigatingProgrammatically = false
    }

    // MARK: - Private Methods

    /// Setup reactive subscriptions to UseCase publishers.
    private func setupReactiveSubscriptions() {
        // Monitor configuration changes

        getFocusWindowOnClickUseCase.execute()
            .assign(to: \.focusWindowOnClick, on: self)
            .store(in: &cancellables)

        getShowEmptySpacesUseCase.execute()
            .assign(to: \.showEmptySpaces, on: self)
            .store(in: &cancellables)

        getShowWindowTitlesUseCase.execute()
            .assign(to: \.showWindowTitles, on: self)
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
            .receive(on: DispatchQueue.main)
            .sink { [weak self] featureFlags in
                if self?.featureFlags != featureFlags {
                    self?.updateAvailableOptions(with: featureFlags)
                    self?.featureFlags = featureFlags
                }
            }
            .store(in: &cancellables)

        getAnimationDurationUseCase.execute()
            .assign(to: \.animationDuration, on: self)
            .store(in: &cancellables)

        // Subscribe to consolidated spaces visual configuration changes
        getSpacesVisualConfigUseCase.execute()
            .assign(to: \.spacesVisualConfig, on: self)
            .store(in: &cancellables)

        getSpacesAppearanceModeUseCase.execute()
            .assign(to: \.spacesAppearanceMode, on: self)
            .store(in: &cancellables)

        getGlobalSpacesVisualConfigUseCase.execute()
            .assign(to: \.globalSpacesVisualConfig, on: self)
            .store(in: &cancellables)

        // Subscribe to consolidated groups visual configuration changes
        getGroupsUseCase.execute()
            .assign(to: \.groups, on: self)
            .store(in: &cancellables)

        getGroupsAppearanceModeUseCase.execute()
            .assign(to: \.groupsAppearanceMode, on: self)
            .store(in: &cancellables)

        getGlobalGroupsVisualConfigUseCase.execute()
            .assign(to: \.globalGroupsVisualConfig, on: self)
            .store(in: &cancellables)
    }

    /// Updates available navigation options based on feature flags.
    /// - Parameter featureFlags: The current feature flags configuration
    private func updateAvailableOptions(with featureFlags: FeatureFlags) {
        let previousRootPages = rootPages

        rootPages = RootNavigationPage.allCases.filter { option in
            switch option {
            case .license:
                featureFlags.enableLicensing
            case .general:
                true // General is always available
            case .spaces:
                featureFlags.enableSpaces
            case .groups:
                featureFlags.enableGroups
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
            isNavigatingProgrammatically = true
            selectedPage = AnyNavigationPage(SettingsViewModel.defaultPage)
            isNavigatingProgrammatically = false
        }

        // Clean up navigation history to remove disabled pages
        navigationHistory = navigationHistory.filter { page in
            allAvailablePages.contains(where: { $0.id == page.id })
        }

        // Clean up forward history to remove disabled pages
        forwardHistory = forwardHistory.filter { page in
            allAvailablePages.contains(where: { $0.id == page.id })
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
            isNavigatingProgrammatically = true
            // Try to navigate to the parent page if available, otherwise go to default
            if
                let parentPage = selectedPage.parentPage,
                rootPages.contains(where: { AnyNavigationPage($0).id == parentPage.id })
            {
                selectedPage = AnyNavigationPage(parentPage)
            } else {
                selectedPage = AnyNavigationPage(SettingsViewModel.defaultPage)
            }
            isNavigatingProgrammatically = false
        }
    }
}
