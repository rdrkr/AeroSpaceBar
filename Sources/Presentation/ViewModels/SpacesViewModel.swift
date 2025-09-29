// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import AppKit
import Combine
import Domain
import SwiftUI

/// ViewModel for managing spaces data and interactions.
///
/// This ViewModel manages the state of spaces data, including fetching,
/// updating, and providing user interactions for spaces and windows.
/// It runs on the main actor and uses Combine for reactive updates.
@MainActor
final class SpacesViewModel: ObservableObject {
    /// Whether AeroSpace is currently running on the system.
    @Published var isAeroSpaceRunning: Bool

    /// The current desktop wallpaper image.
    @Published var wallpaper: NSImage?

    /// The list of all available spaces with their associated windows (including empty spaces).
    @Published var allSpaces: [Space]

    /// The list of available spaces with their associated windows (filtered based on showEmptySpaces setting).
    @Published var spaces: [Space]

    /// UI configuration properties.
    @Published var spacesAppearanceMode: SpacesAppearanceMode {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setSpacesAppearanceModeUseCase.execute(value: spacesAppearanceMode)
            }
        }
    }

    @Published var menuBarHeight: Double
    @Published var showWindowTitles: Bool {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setShowWindowTitlesUseCase.execute(value: showWindowTitles)
            }
        }
    }

    @Published var focusWindowOnClick: Bool {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setFocusWindowOnClickUseCase.execute(enabled: focusWindowOnClick)
            }
        }
    }

    @Published var showEmptySpaces: Bool {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setShowEmptySpacesUseCase.execute(value: showEmptySpaces)
            }
        }
    }

    @Published var globalSpacesVisualConfig: VisualProperties {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setGlobalSpacesVisualConfigUseCase.execute(value: globalSpacesVisualConfig)
            }
        }
    }

    /// Whether the globe key is currently being held.
    @Published var isGlobeKeyPressed: Bool = false

    /// Whether the system menu bar is currently visible.
    @Published var isMenuBarVisible: Bool

    /// Whether spaces functionality is enabled via feature flags.
    @Published var isSpacesEnabled: Bool

    /// Monitor for global key events.
    private nonisolated(unsafe) var keyMonitors: [Any] = []

    // MARK: - Spaces Use Cases

    /// The use cases for spaces operations.
    private let getSpacesUseCase: GetSpacesUseCase
    private let setFocusSpaceUseCase: SetFocusSpaceUseCase
    private let setFocusWindowUseCase: SetFocusWindowUseCase
    private let getAeroSpaceStatusUseCase: GetAeroSpaceStatusUseCase
    private let startAeroSpaceUseCase: StartAeroSpaceUseCase

    /// Use case for getting desktop wallpaper image.
    private let getWallpaperUseCase: GetWallpaperUseCase

    /// Use case for getting menu bar visibility status.
    private let getMenuBarVisibilityUseCase: GetMenuBarVisibilityUseCase

    /// Use cases for UI configuration properties.
    private let getMenuBarHeightUseCase: GetMenuBarHeightUseCase
    private let getShowWindowTitlesUseCase: GetShowWindowTitlesUseCase
    private let getFocusWindowOnClickUseCase: GetFocusWindowOnClickUseCase
    private let getFeatureFlagsUseCase: GetFeatureFlagsUseCase
    private let getSpacesAppearanceModeUseCase: GetSpacesAppearanceModeUseCase
    private let setSpacesAppearanceModeUseCase: SetSpacesAppearanceModeUseCase
    private let getGlobalSpacesVisualConfigUseCase: GetGlobalSpacesVisualConfigUseCase
    private let setGlobalSpacesVisualConfigUseCase: SetGlobalSpacesVisualConfigUseCase
    private let getSpacesVisualConfigUseCase: GetSpacesVisualConfigUseCase
    private let setSpacesVisualConfigUseCase: SetSpacesVisualConfigUseCase

    /// Use cases for Spaces-related UI configuration properties.
    private let setFocusWindowOnClickUseCase: SetFocusWindowOnClickUseCase
    private let getShowEmptySpacesUseCase: GetShowEmptySpacesUseCase
    private let setShowEmptySpacesUseCase: SetShowEmptySpacesUseCase
    private let setShowWindowTitlesUseCase: SetShowWindowTitlesUseCase

    /// Cancellable subscriptions for Combine publishers.
    private var cancellables: Set<AnyCancellable> = []

    /// Initializes the spaces ViewModel with the specified dependencies.
    ///
    /// This initializer sets up all use cases and begins monitoring for data updates.
    /// - Parameters:
    ///   - getSpacesUseCase: Use case for getting spaces data
    ///   - setFocusSpaceUseCase: Use case for focusing spaces
    ///   - setFocusWindowUseCase: Use case for focusing windows
    ///   - getAeroSpaceStatusUseCase: Use case for checking AeroSpace status
    ///   - getShowWindowTitlesUseCase: Use case for getting window titles display setting
    ///   - getWallpaperUseCase: Use case for getting wallpaper image
    ///   - getMenuBarHeightUseCase: Use case for getting menu bar height
    ///   - getSpacesAppearanceModeUseCase: Use case for getting spaces appearance mode
    ///   - setSpacesAppearanceModeUseCase: Use case for setting spaces appearance mode
    ///   - getGlobalSpacesVisualConfigUseCase: Use case for getting consolidated space visual configuration
    init(
        getSpacesUseCase: GetSpacesUseCase,
        setFocusSpaceUseCase: SetFocusSpaceUseCase,
        setFocusWindowUseCase: SetFocusWindowUseCase,
        getAeroSpaceStatusUseCase: GetAeroSpaceStatusUseCase,
        startAeroSpaceUseCase: StartAeroSpaceUseCase,
        getShowWindowTitlesUseCase: GetShowWindowTitlesUseCase,
        setShowWindowTitlesUseCase: SetShowWindowTitlesUseCase,
        getFocusWindowOnClickUseCase: GetFocusWindowOnClickUseCase,
        setFocusWindowOnClickUseCase: SetFocusWindowOnClickUseCase,
        getShowEmptySpacesUseCase: GetShowEmptySpacesUseCase,
        setShowEmptySpacesUseCase: SetShowEmptySpacesUseCase,
        getWallpaperUseCase: GetWallpaperUseCase,
        getMenuBarVisibilityUseCase: GetMenuBarVisibilityUseCase,
        getMenuBarHeightUseCase: GetMenuBarHeightUseCase,
        getFeatureFlagsUseCase: GetFeatureFlagsUseCase,
        getSpacesAppearanceModeUseCase: GetSpacesAppearanceModeUseCase,
        setSpacesAppearanceModeUseCase: SetSpacesAppearanceModeUseCase,
        getGlobalSpacesVisualConfigUseCase: GetGlobalSpacesVisualConfigUseCase,
        setGlobalSpacesVisualConfigUseCase: SetGlobalSpacesVisualConfigUseCase,
        getSpacesVisualConfigUseCase: GetSpacesVisualConfigUseCase,
        setSpacesVisualConfigUseCase: SetSpacesVisualConfigUseCase
    ) {
        // Initialize spaces use cases
        self.getSpacesUseCase = getSpacesUseCase
        self.setFocusSpaceUseCase = setFocusSpaceUseCase
        self.setFocusWindowUseCase = setFocusWindowUseCase
        self.getAeroSpaceStatusUseCase = getAeroSpaceStatusUseCase
        self.startAeroSpaceUseCase = startAeroSpaceUseCase

        // Initialize wallpaper use case
        self.getWallpaperUseCase = getWallpaperUseCase
        self.getMenuBarVisibilityUseCase = getMenuBarVisibilityUseCase
        self.getShowWindowTitlesUseCase = getShowWindowTitlesUseCase
        self.setShowWindowTitlesUseCase = setShowWindowTitlesUseCase
        self.getFocusWindowOnClickUseCase = getFocusWindowOnClickUseCase
        self.setFocusWindowOnClickUseCase = setFocusWindowOnClickUseCase
        self.getShowEmptySpacesUseCase = getShowEmptySpacesUseCase
        self.setShowEmptySpacesUseCase = setShowEmptySpacesUseCase

        // Initialize UI configuration use cases
        self.getMenuBarHeightUseCase = getMenuBarHeightUseCase
        self.getFeatureFlagsUseCase = getFeatureFlagsUseCase
        self.getGlobalSpacesVisualConfigUseCase = getGlobalSpacesVisualConfigUseCase
        self.setGlobalSpacesVisualConfigUseCase = setGlobalSpacesVisualConfigUseCase
        self.getSpacesAppearanceModeUseCase = getSpacesAppearanceModeUseCase
        self.setSpacesAppearanceModeUseCase = setSpacesAppearanceModeUseCase
        self.getSpacesVisualConfigUseCase = getSpacesVisualConfigUseCase
        self.setSpacesVisualConfigUseCase = setSpacesVisualConfigUseCase

        // Load initial values from use cases
        isAeroSpaceRunning = getAeroSpaceStatusUseCase.execute().blockingFirst()
        wallpaper = getWallpaperUseCase.execute().blockingFirst()

        let initialSpaces = getSpacesUseCase.execute().blockingFirst()
        allSpaces = initialSpaces
        let initialShowEmptySpaces = getShowEmptySpacesUseCase.execute().blockingFirst()
        spaces = initialShowEmptySpaces ? initialSpaces : initialSpaces.filter { !$0.windows.isEmpty }

        menuBarHeight = getMenuBarHeightUseCase.execute().blockingFirst()
        showWindowTitles = getShowWindowTitlesUseCase.execute().blockingFirst()
        focusWindowOnClick = getFocusWindowOnClickUseCase.execute().blockingFirst()
        showEmptySpaces = getShowEmptySpacesUseCase.execute().blockingFirst()
        isMenuBarVisible = getMenuBarVisibilityUseCase.execute().blockingFirst()
        isSpacesEnabled = getFeatureFlagsUseCase.execute().blockingFirst().enableSpaces
        spacesAppearanceMode = getSpacesAppearanceModeUseCase.execute().blockingFirst()
        globalSpacesVisualConfig = getGlobalSpacesVisualConfigUseCase.execute().blockingFirst()

        setupReactiveSubscriptions()
        setupGlobeKeyMonitors()

        // Auto-start AeroSpace if not running
        Task {
            await checkAndStartAeroSpace()
        }
    }

    // MARK: - Public Methods

    /// Switches to a specific space.
    ///
    /// This method sends a command to focus the specified space and optionally
    /// focus a window within that space.
    /// - Parameters:
    ///   - space: The space to switch to
    ///   - needWindowFocus: Whether to also focus a window in the space
    func switchToSpace(_ space: Space, needWindowFocus: Bool = false) {
        guard isSpacesEnabled else { return }

        Task {
            await focusSpace(space, needWindowFocus: needWindowFocus)
        }
    }

    /// Switches to a specific window.
    ///
    /// This method sends a command to focus the specified window.
    /// - Parameter window: The window to switch to
    func switchToWindow(_ window: Domain.Window) {
        guard isSpacesEnabled else { return }

        Task {
            await focusWindow(window)
        }
    }

    // MARK: - Private Methods

    /// Checks if AeroSpace is running and starts it if not.
    ///
    /// This method is called during initialization to ensure AeroSpace is available
    /// when the app starts up. It will only attempt to start AeroSpace if it's not already running.
    private func checkAndStartAeroSpace() async {
        // Check if AeroSpace is already running
        if isAeroSpaceRunning {
            Logger.info("AeroSpace is already running, no need to start", category: Logger.spaces)
            return
        }

        Logger.info("AeroSpace not running, attempting to start", category: Logger.spaces)

        do {
            try await startAeroSpaceUseCase.execute()
            Logger.info("Successfully started AeroSpace", category: Logger.spaces)
        } catch {
            Logger.error("Failed to start AeroSpace", error: error, category: Logger.spaces)
            // Don't throw - we want the app to continue working even if AeroSpace can't be started
        }
    }

    /// Sets up reactive bindings for state changes.
    ///
    /// This method establishes Combine subscriptions to monitor changes
    /// in UI configuration and wallpaper, responding accordingly.
    private func setupReactiveSubscriptions() {
        // Monitor AeroSpace running status changes
        getAeroSpaceStatusUseCase.execute()
            .assign(to: \.isAeroSpaceRunning, on: self)
            .store(in: &cancellables)

        // Monitor wallpaper changes
        getWallpaperUseCase.execute()
            .assign(to: \.wallpaper, on: self)
            .store(in: &cancellables)

        // Monitor spaces changes
        getSpacesUseCase.execute()
            .sink { [weak self] allSpacesData in
                let sortedAllSpaces = allSpacesData.sorted {
                    $0.id < $1.id
                }
                self?.allSpaces = sortedAllSpaces

                // Update filtered spaces based on showEmptySpaces setting
                self?.updateFilteredSpaces()
            }
            .store(in: &cancellables)

        // Monitor UI configuration changes
        getMenuBarHeightUseCase.execute()
            .assign(to: \.menuBarHeight, on: self)
            .store(in: &cancellables)

        getShowWindowTitlesUseCase.execute()
            .assign(to: \.showWindowTitles, on: self)
            .store(in: &cancellables)

        getFocusWindowOnClickUseCase.execute()
            .assign(to: \.focusWindowOnClick, on: self)
            .store(in: &cancellables)

        getShowEmptySpacesUseCase.execute()
            .sink { [weak self] showEmpty in
                self?.showEmptySpaces = showEmpty
                self?.updateFilteredSpaces()
            }
            .store(in: &cancellables)

        // Monitor system menu bar visibility changes
        getMenuBarVisibilityUseCase.execute()
            .assign(to: \.isMenuBarVisible, on: self)
            .store(in: &cancellables)

        // Subscribe to feature flags changes
        getFeatureFlagsUseCase.execute()
            .sink { [weak self] featureFlags in
                if self?.isSpacesEnabled != featureFlags.enableSpaces {
                    self?.isSpacesEnabled = featureFlags.enableSpaces
                }
            }
            .store(in: &cancellables)

        getSpacesAppearanceModeUseCase.execute()
            .assign(to: \.spacesAppearanceMode, on: self)
            .store(in: &cancellables)

        getGlobalSpacesVisualConfigUseCase.execute()
            .assign(to: \.globalSpacesVisualConfig, on: self)
            .store(in: &cancellables)
    }

    /// Focuses a specific space.
    ///
    /// This method sends a command to focus the specified space and
    /// refreshes the spaces data afterward.
    /// - Parameters:
    ///   - space: The space to focus
    ///   - needWindowFocus: Whether to also focus a window in the space
    private func focusSpace(_ space: Space, needWindowFocus: Bool) async {
        do {
            try await setFocusSpaceUseCase.execute(spaceId: space.id, needWindowFocus: needWindowFocus)
        } catch {
            Logger.error("Error focusing space", error: error, category: Logger.spaces)
        }
    }

    /// Focuses a specific window.
    ///
    /// This method sends a command to focus the specified window and
    /// refreshes the spaces data afterward.
    /// - Parameter window: The window to focus
    private func focusWindow(_ window: Domain.Window) async {
        do {
            try await setFocusWindowUseCase.execute(windowId: String(window.id))
        } catch {
            Logger.error("Error focusing window", error: error, category: Logger.spaces)
        }
    }

    /// Updates a specific space's visual configuration.
    ///
    /// This method updates the visual configuration for a space at the specified ID.
    /// It modifies the local spaces array and persists the changes via the configuration use case.
    /// - Parameters:
    ///   - spaceId: The ID of the space to update
    ///   - visualConfig: The new visual configuration for the space
    func updateSpaceVisualConfig(spaceId: String, visualConfig: VisualProperties) {
        // Update the local spaces array
        if let index = allSpaces.firstIndex(where: { $0.id == spaceId }) {
            allSpaces[index].visualConfig = visualConfig

            // Persist the changes using the use case
            Task { @MainActor in
                let allSpaceVisualConfigs = allSpaces.map(\.visualConfig)
                await setSpacesVisualConfigUseCase.execute(value: allSpaceVisualConfigs)
            }

            updateFilteredSpaces()
        }
    }

    /// Resets all spaces-related settings to their default values.
    ///
    /// This method resets spaces visual configurations, appearance mode, and related UI settings
    /// to their default values as defined in ConfigurationDefaults.
    func resetSpacesToDefaults() async {
        await setSpacesVisualConfigUseCase.execute(value: ConfigurationDefaults.spacesVisualConfiguration)
        await setGlobalSpacesVisualConfigUseCase.execute(value: ConfigurationDefaults.defaultSpaceVisualConfig)
        await setSpacesAppearanceModeUseCase.execute(value: ConfigurationDefaults.spacesAppearanceMode)
        await setShowWindowTitlesUseCase.execute(value: ConfigurationDefaults.showWindowTitles)
        await setShowEmptySpacesUseCase.execute(value: ConfigurationDefaults.showEmptySpaces)
        await setFocusWindowOnClickUseCase.execute(enabled: ConfigurationDefaults.focusWindowOnClick)
    }

    /// Updates the filtered spaces list based on the showEmptySpaces setting.
    ///
    /// This method filters the allSpaces array based on the showEmptySpaces setting
    /// and updates the spaces property accordingly.
    private func updateFilteredSpaces() {
        spaces = showEmptySpaces ? allSpaces : allSpaces.filter { !$0.windows.isEmpty }
    }

    // MARK: - Globe Key Monitoring

    deinit {
        removeGlobeKeyMonitors()
    }

    /// Sets up global key monitoring for the globe key (fn key)
    private func setupGlobeKeyMonitors() {
        let keyPressedCallback = { [weak self] (event: NSEvent) in
            _ = Task { @MainActor in
                // The globe/fn key is represented by the .function modifier flag
                self?.isGlobeKeyPressed = event.modifierFlags.contains(.function)
            }
        }

        unsafe keyMonitors = [
            // Local monitor to capture key events when the app is focused
            NSEvent.addLocalMonitorForEvents(matching: [.flagsChanged]) { event in
                keyPressedCallback(event)
                return event
            },
            // Global monitor to capture key events when the app is not focused
            NSEvent.addGlobalMonitorForEvents(matching: [.flagsChanged], handler: keyPressedCallback)
        ]
        .compactMap(\.self)
    }

    /// Removes the global key monitor
    private nonisolated func removeGlobeKeyMonitors() {
        unsafe keyMonitors.forEach { monitor in
            NSEvent.removeMonitor(monitor)
        }

        Task { @MainActor in
            isGlobeKeyPressed = false
        }
    }
}
