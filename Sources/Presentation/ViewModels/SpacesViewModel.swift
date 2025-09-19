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
    /// The widget components state.
    struct WidgetState: Equatable {
        /// The current desktop wallpaper image.
        let wallpaper: NSImage?

        /// The list of available spaces with their associated windows.
        let spaces: [Space]
    }

    /// Whether AeroSpace is currently running on the system.
    @Published var isAeroSpaceRunning: Bool

    /// The current state of the widget.
    @Published var widgetState: WidgetState

    /// UI configuration properties.
    @Published var menuBarHeight: Double
    @Published var menuBarVerticalPadding: Double
    @Published var menuBarHorizontalPadding: Double
    @Published var widgetSpacing: Double
    @Published var animationDuration: Double
    @Published var windowIconSize: Double
    @Published var showWindowTitles: Bool
    @Published var focusWindowOnClick: Bool
    @Published var spacesAppearanceMode: SpacesAppearanceMode
    @Published var globalSpacesVisualConfig: VisualContainer

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
    private let getMenuBarVerticalPaddingUseCase: GetMenuBarVerticalPaddingUseCase
    private let getMenuBarHorizontalPaddingUseCase: GetMenuBarHorizontalPaddingUseCase
    private let getWidgetSpacingUseCase: GetWidgetSpacingUseCase
    private let getAnimationDurationUseCase: GetAnimationDurationUseCase
    private let getWindowIconSizeUseCase: GetWindowIconSizeUseCase
    private let getShowWindowTitlesUseCase: GetShowWindowTitlesUseCase
    private let getFocusWindowOnClickUseCase: GetFocusWindowOnClickUseCase
    private let getFeatureFlagsUseCase: GetFeatureFlagsUseCase
    private let getSpacesAppearanceModeUseCase: GetSpacesAppearanceModeUseCase
    private let getGlobalSpacesVisualConfigUseCase: GetGlobalSpacesVisualConfigUseCase

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
    ///   - getMenuBarVerticalPaddingUseCase: Use case for getting vertical padding
    ///   - getMenuBarHorizontalPaddingUseCase: Use case for getting horizontal padding
    ///   - getWidgetSpacingUseCase: Use case for getting widget spacing
    ///   - getAnimationDurationUseCase: Use case for getting animation duration
    ///   - getWindowIconSizeUseCase: Use case for getting window icon size
    ///   - getSpacesAppearanceModeUseCase: Use case for getting spaces appearance mode
    ///   - getGlobalSpacesVisualConfigUseCase: Use case for getting consolidated space visual configuration
    init(
        getSpacesUseCase: GetSpacesUseCase,
        setFocusSpaceUseCase: SetFocusSpaceUseCase,
        setFocusWindowUseCase: SetFocusWindowUseCase,
        getAeroSpaceStatusUseCase: GetAeroSpaceStatusUseCase,
        startAeroSpaceUseCase: StartAeroSpaceUseCase,
        getShowWindowTitlesUseCase: GetShowWindowTitlesUseCase,
        getFocusWindowOnClickUseCase: GetFocusWindowOnClickUseCase,
        getWallpaperUseCase: GetWallpaperUseCase,
        getMenuBarVisibilityUseCase: GetMenuBarVisibilityUseCase,
        getMenuBarHeightUseCase: GetMenuBarHeightUseCase,
        getMenuBarVerticalPaddingUseCase: GetMenuBarVerticalPaddingUseCase,
        getMenuBarHorizontalPaddingUseCase: GetMenuBarHorizontalPaddingUseCase,
        getWidgetSpacingUseCase: GetWidgetSpacingUseCase,
        getAnimationDurationUseCase: GetAnimationDurationUseCase,
        getWindowIconSizeUseCase: GetWindowIconSizeUseCase,
        getFeatureFlagsUseCase: GetFeatureFlagsUseCase,
        getSpacesAppearanceModeUseCase: GetSpacesAppearanceModeUseCase,
        getGlobalSpacesVisualConfigUseCase: GetGlobalSpacesVisualConfigUseCase
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
        self.getFocusWindowOnClickUseCase = getFocusWindowOnClickUseCase

        // Initialize UI configuration use cases
        self.getMenuBarHeightUseCase = getMenuBarHeightUseCase
        self.getMenuBarVerticalPaddingUseCase = getMenuBarVerticalPaddingUseCase
        self.getMenuBarHorizontalPaddingUseCase = getMenuBarHorizontalPaddingUseCase
        self.getWidgetSpacingUseCase = getWidgetSpacingUseCase
        self.getAnimationDurationUseCase = getAnimationDurationUseCase
        self.getWindowIconSizeUseCase = getWindowIconSizeUseCase
        self.getFeatureFlagsUseCase = getFeatureFlagsUseCase
        self.getGlobalSpacesVisualConfigUseCase = getGlobalSpacesVisualConfigUseCase
        self.getSpacesAppearanceModeUseCase = getSpacesAppearanceModeUseCase

        // Load initial values from use cases
        isAeroSpaceRunning = getAeroSpaceStatusUseCase.execute().blockingFirst()
        widgetState = WidgetState(
            wallpaper: getWallpaperUseCase.execute().blockingFirst(),
            spaces: getSpacesUseCase.execute().blockingFirst()
        )

        menuBarHeight = getMenuBarHeightUseCase.execute().blockingFirst()
        menuBarVerticalPadding = getMenuBarVerticalPaddingUseCase.execute().blockingFirst()
        menuBarHorizontalPadding = getMenuBarHorizontalPaddingUseCase.execute().blockingFirst()
        widgetSpacing = getWidgetSpacingUseCase.execute().blockingFirst()
        animationDuration = getAnimationDurationUseCase.execute().blockingFirst()
        windowIconSize = getWindowIconSizeUseCase.execute().blockingFirst()
        showWindowTitles = getShowWindowTitlesUseCase.execute().blockingFirst()
        focusWindowOnClick = getFocusWindowOnClickUseCase.execute().blockingFirst()
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

        // Monitor wallpaper and spaces changes
        getWallpaperUseCase.execute()
            .combineLatest(getSpacesUseCase.execute())
            .sink { [weak self] wallpaper, spaces in
                let sortedSpaces = spaces.sorted {
                    $0.id < $1.id
                }
                self?.widgetState = WidgetState(wallpaper: wallpaper, spaces: sortedSpaces)
            }
            .store(in: &cancellables)

        // Monitor UI configuration changes
        getMenuBarHeightUseCase.execute()
            .assign(to: \.menuBarHeight, on: self)
            .store(in: &cancellables)

        getMenuBarVerticalPaddingUseCase.execute()
            .assign(to: \.menuBarVerticalPadding, on: self)
            .store(in: &cancellables)

        getMenuBarHorizontalPaddingUseCase.execute()
            .assign(to: \.menuBarHorizontalPadding, on: self)
            .store(in: &cancellables)

        getWidgetSpacingUseCase.execute()
            .assign(to: \.widgetSpacing, on: self)
            .store(in: &cancellables)

        getAnimationDurationUseCase.execute()
            .assign(to: \.animationDuration, on: self)
            .store(in: &cancellables)

        getWindowIconSizeUseCase.execute()
            .assign(to: \.windowIconSize, on: self)
            .store(in: &cancellables)

        getShowWindowTitlesUseCase.execute()
            .assign(to: \.showWindowTitles, on: self)
            .store(in: &cancellables)
        getFocusWindowOnClickUseCase.execute()
            .assign(to: \.focusWindowOnClick, on: self)
            .store(in: &cancellables)

        // Monitor system menu bar visibility changes
        getMenuBarVisibilityUseCase.execute()
            .assign(to: \SpacesViewModel.isMenuBarVisible, on: self)
            .store(in: &cancellables)

        // Subscribe to feature flags changes
        getFeatureFlagsUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] featureFlags in
                self?.isSpacesEnabled = featureFlags.enableSpaces
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

    // MARK: - Globe Key Monitoring

    deinit {
        removeGlobeKeyMonitors()
    }

    /// Sets up global key monitoring for the globe key (fn key)
    private func setupGlobeKeyMonitors() {
        let keyPressedCallback = { [weak self] (event: NSEvent) in
            DispatchQueue.main.async {
                // The globe/fn key is represented by the .function modifier flag
                self?.isGlobeKeyPressed = event.modifierFlags.contains(.function)
            }
        }

        keyMonitors = [
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
        keyMonitors.forEach { monitor in
            NSEvent.removeMonitor(monitor)
        }

        Task { @MainActor in
            isGlobeKeyPressed = false
        }
    }
}
