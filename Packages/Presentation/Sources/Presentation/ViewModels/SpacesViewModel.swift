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
public final class SpacesViewModel: ObservableObject {
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

    @Published var globalSpacesColorProperties: ColorProperties {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setGlobalSpacesColorPropertiesUseCase.execute(value: globalSpacesColorProperties)
            }
        }
    }

    /// Global geometric properties for spaces.
    @Published var globalSpacesGeometricProperties: GeometricProperties {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setGlobalSpacesGeometricPropertiesUseCase.execute(value: globalSpacesGeometricProperties)
            }
        }
    }

    /// Global effect properties for spaces.
    @Published var globalSpacesEffectProperties: EffectProperties {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setGlobalSpacesEffectPropertiesUseCase.execute(value: globalSpacesEffectProperties)
            }
        }
    }

    /// Whether the globe key is currently being held.
    @Published var isGlobeKeyPressed: Bool = false

    /// Whether the system menu bar is currently visible.
    @Published var isMenuBarVisible: Bool

    /// Whether spaces functionality is enabled via feature flags.
    @Published var isSpacesEnabled: Bool

    /// The current theme mode.
    @Published var themeMode: ThemeMode

    /// The current theme preset.
    @Published var themePresetColorProperties: ThemePresetColorProperties

    /// The current theme preset geometric properties.
    @Published var themePresetGeometricProperties: GeometricProperties {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setThemePresetGeometricPropertiesUseCase.execute(value: themePresetGeometricProperties)
            }
        }
    }

    /// The current theme preset effect properties.
    @Published var themePresetEffectProperties: EffectProperties {
        didSet {
            Task.detached(priority: .utility) { [self] in
                await setThemePresetEffectPropertiesUseCase.execute(value: themePresetEffectProperties)
            }
        }
    }

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
    private let getGlobalSpacesColorPropertiesUseCase: GetGlobalSpacesColorPropertiesUseCase
    private let setGlobalSpacesColorPropertiesUseCase: SetGlobalSpacesColorPropertiesUseCase
    private let getGlobalSpacesGeometricPropertiesUseCase: GetGlobalSpacesGeometricPropertiesUseCase
    private let setGlobalSpacesGeometricPropertiesUseCase: SetGlobalSpacesGeometricPropertiesUseCase
    private let getGlobalSpacesEffectPropertiesUseCase: GetGlobalSpacesEffectPropertiesUseCase
    private let setGlobalSpacesEffectPropertiesUseCase: SetGlobalSpacesEffectPropertiesUseCase
    private let getSpacesColorPropertiesUseCase: GetSpacesColorPropertiesUseCase
    private let setSpacesColorPropertiesUseCase: SetSpacesColorPropertiesUseCase
    private let getSpacesGeometricPropertiesUseCase: GetSpacesGeometricPropertiesUseCase
    private let setSpacesGeometricPropertiesUseCase: SetSpacesGeometricPropertiesUseCase
    private let getSpacesEffectPropertiesUseCase: GetSpacesEffectPropertiesUseCase
    private let setSpacesEffectPropertiesUseCase: SetSpacesEffectPropertiesUseCase
    private let getThemeModeUseCase: GetThemeModeUseCase
    private let getThemePresetColorPropertiesUseCase: GetThemePresetColorPropertiesUseCase
    private let getThemePresetGeometricPropertiesUseCase: GetThemePresetGeometricPropertiesUseCase
    private let setThemePresetGeometricPropertiesUseCase: SetThemePresetGeometricPropertiesUseCase
    private let getThemePresetEffectPropertiesUseCase: GetThemePresetEffectPropertiesUseCase
    private let setThemePresetEffectPropertiesUseCase: SetThemePresetEffectPropertiesUseCase
    private let getGlobeKeyPressStateUseCase: GetGlobeKeyPressStateUseCase

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
    ///   - getGlobalSpacesColorPropertiesUseCase: Use case for getting consolidated space color properties
    ///   - setGlobalSpacesColorPropertiesUseCase: Use case for setting consolidated space color properties
    ///   - getGlobalSpacesGeometricPropertiesUseCase: Use case for getting consolidated space geometric properties
    ///   - setGlobalSpacesGeometricPropertiesUseCase: Use case for setting consolidated space geometric properties
    ///   - getGlobalSpacesEffectPropertiesUseCase: Use case for getting consolidated space effect properties
    ///   - setGlobalSpacesEffectPropertiesUseCase: Use case for setting consolidated space effect properties
    ///   - getSpacesColorPropertiesUseCase: Use case for getting space color properties
    ///   - setSpacesColorPropertiesUseCase: Use case for setting space color properties
    ///   - getSpacesGeometricPropertiesUseCase: Use case for getting space geometric properties
    ///   - setSpacesGeometricPropertiesUseCase: Use case for setting space geometric properties
    ///   - getSpacesEffectPropertiesUseCase: Use case for getting space effect properties
    ///   - setSpacesEffectPropertiesUseCase: Use case for setting space effect properties
    ///   - getThemeModeUseCase: Use case for getting theme mode
    ///   - getThemePresetColorPropertiesUseCase: Use case for getting theme preset
    ///   - getThemePresetGeometricPropertiesUseCase: Use case for getting theme preset geometric properties
    ///   - setThemePresetGeometricPropertiesUseCase: Use case for setting theme preset geometric properties
    ///   - getThemePresetEffectPropertiesUseCase: Use case for getting theme preset effect properties
    ///   - setThemePresetEffectPropertiesUseCase: Use case for setting theme preset effect properties
    ///   - getGlobeKeyPressStateUseCase: Use case for getting globe key press state
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
        getGlobalSpacesColorPropertiesUseCase: GetGlobalSpacesColorPropertiesUseCase,
        setGlobalSpacesColorPropertiesUseCase: SetGlobalSpacesColorPropertiesUseCase,
        getGlobalSpacesGeometricPropertiesUseCase: GetGlobalSpacesGeometricPropertiesUseCase,
        setGlobalSpacesGeometricPropertiesUseCase: SetGlobalSpacesGeometricPropertiesUseCase,
        getGlobalSpacesEffectPropertiesUseCase: GetGlobalSpacesEffectPropertiesUseCase,
        setGlobalSpacesEffectPropertiesUseCase: SetGlobalSpacesEffectPropertiesUseCase,
        getSpacesColorPropertiesUseCase: GetSpacesColorPropertiesUseCase,
        setSpacesColorPropertiesUseCase: SetSpacesColorPropertiesUseCase,
        getSpacesGeometricPropertiesUseCase: GetSpacesGeometricPropertiesUseCase,
        setSpacesGeometricPropertiesUseCase: SetSpacesGeometricPropertiesUseCase,
        getSpacesEffectPropertiesUseCase: GetSpacesEffectPropertiesUseCase,
        setSpacesEffectPropertiesUseCase: SetSpacesEffectPropertiesUseCase,
        getThemeModeUseCase: GetThemeModeUseCase,
        getThemePresetColorPropertiesUseCase: GetThemePresetColorPropertiesUseCase,
        getThemePresetGeometricPropertiesUseCase: GetThemePresetGeometricPropertiesUseCase,
        setThemePresetGeometricPropertiesUseCase: SetThemePresetGeometricPropertiesUseCase,
        getThemePresetEffectPropertiesUseCase: GetThemePresetEffectPropertiesUseCase,
        setThemePresetEffectPropertiesUseCase: SetThemePresetEffectPropertiesUseCase,
        getGlobeKeyPressStateUseCase: GetGlobeKeyPressStateUseCase
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
        self.getGlobalSpacesColorPropertiesUseCase = getGlobalSpacesColorPropertiesUseCase
        self.setGlobalSpacesColorPropertiesUseCase = setGlobalSpacesColorPropertiesUseCase
        self.getGlobalSpacesGeometricPropertiesUseCase = getGlobalSpacesGeometricPropertiesUseCase
        self.setGlobalSpacesGeometricPropertiesUseCase = setGlobalSpacesGeometricPropertiesUseCase
        self.getGlobalSpacesEffectPropertiesUseCase = getGlobalSpacesEffectPropertiesUseCase
        self.setGlobalSpacesEffectPropertiesUseCase = setGlobalSpacesEffectPropertiesUseCase
        self.getSpacesAppearanceModeUseCase = getSpacesAppearanceModeUseCase
        self.setSpacesAppearanceModeUseCase = setSpacesAppearanceModeUseCase
        self.getSpacesColorPropertiesUseCase = getSpacesColorPropertiesUseCase
        self.setSpacesColorPropertiesUseCase = setSpacesColorPropertiesUseCase
        self.getSpacesGeometricPropertiesUseCase = getSpacesGeometricPropertiesUseCase
        self.setSpacesGeometricPropertiesUseCase = setSpacesGeometricPropertiesUseCase
        self.getSpacesEffectPropertiesUseCase = getSpacesEffectPropertiesUseCase
        self.setSpacesEffectPropertiesUseCase = setSpacesEffectPropertiesUseCase
        self.getThemeModeUseCase = getThemeModeUseCase
        self.getThemePresetColorPropertiesUseCase = getThemePresetColorPropertiesUseCase
        self.getThemePresetGeometricPropertiesUseCase = getThemePresetGeometricPropertiesUseCase
        self.setThemePresetGeometricPropertiesUseCase = setThemePresetGeometricPropertiesUseCase
        self.getThemePresetEffectPropertiesUseCase = getThemePresetEffectPropertiesUseCase
        self.setThemePresetEffectPropertiesUseCase = setThemePresetEffectPropertiesUseCase
        self.getGlobeKeyPressStateUseCase = getGlobeKeyPressStateUseCase

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
        globalSpacesColorProperties = getGlobalSpacesColorPropertiesUseCase.execute().blockingFirst()
        globalSpacesGeometricProperties = getGlobalSpacesGeometricPropertiesUseCase.execute().blockingFirst()
        globalSpacesEffectProperties = getGlobalSpacesEffectPropertiesUseCase.execute().blockingFirst()
        themeMode = getThemeModeUseCase.execute().blockingFirst()
        themePresetColorProperties = getThemePresetColorPropertiesUseCase.execute().blockingFirst()
        themePresetGeometricProperties = getThemePresetGeometricPropertiesUseCase.execute().blockingFirst()
        themePresetEffectProperties = getThemePresetEffectPropertiesUseCase.execute().blockingFirst()

        setupReactiveSubscriptions()

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
                let sortedAllSpaces = allSpacesData.sorted { $0.id < $1.id }
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

        getGlobalSpacesColorPropertiesUseCase.execute()
            .assign(to: \.globalSpacesColorProperties, on: self)
            .store(in: &cancellables)

        getGlobalSpacesGeometricPropertiesUseCase.execute()
            .assign(to: \.globalSpacesGeometricProperties, on: self)
            .store(in: &cancellables)

        getGlobalSpacesEffectPropertiesUseCase.execute()
            .assign(to: \.globalSpacesEffectProperties, on: self)
            .store(in: &cancellables)

        getThemeModeUseCase.execute()
            .assign(to: \.themeMode, on: self)
            .store(in: &cancellables)

        getThemePresetColorPropertiesUseCase.execute()
            .assign(to: \.themePresetColorProperties, on: self)
            .store(in: &cancellables)

        getThemePresetGeometricPropertiesUseCase.execute()
            .assign(to: \.themePresetGeometricProperties, on: self)
            .store(in: &cancellables)

        getThemePresetEffectPropertiesUseCase.execute()
            .assign(to: \.themePresetEffectProperties, on: self)
            .store(in: &cancellables)

        getGlobeKeyPressStateUseCase.execute()
            .assign(to: \.isGlobeKeyPressed, on: self)
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

    /// Updates a specific space's color properties.
    ///
    /// This method updates the color properties for a space at the specified ID.
    /// It modifies the local spaces array and persists the changes via the configuration use case.
    /// - Parameters:
    ///   - spaceId: The ID of the space to update
    ///   - colorProperties: The new color properties for the space
    func updateSpaceColorProperties(spaceId: String, colorProperties: ColorProperties) {
        // Update the local spaces array
        if let index = allSpaces.firstIndex(where: { $0.id == spaceId }) {
            allSpaces[index].colorProperties = colorProperties

            // Persist the changes using the use case
            Task { @MainActor in
                let allSpaceColorProperties = allSpaces.map(\.colorProperties)
                await setSpacesColorPropertiesUseCase.execute(value: allSpaceColorProperties)
            }

            updateFilteredSpaces()
        }
    }

    /// Updates a specific space's effect properties.
    ///
    /// This method updates the effect properties for a space at the specified ID.
    /// It modifies the local spaces array and persists the changes via the configuration use case.
    /// - Parameters:
    ///   - spaceId: The ID of the space to update
    ///   - effectProperties: The new effect properties for the space
    func updateSpaceEffectProperties(spaceId: String, effectProperties: EffectProperties) {
        // Update the local spaces array
        if let index = allSpaces.firstIndex(where: { $0.id == spaceId }) {
            allSpaces[index].effectProperties = effectProperties

            // Persist the changes using the use case
            Task { @MainActor in
                let allSpaceEffectProperties = allSpaces.map(\.effectProperties)
                await setSpacesEffectPropertiesUseCase.execute(value: allSpaceEffectProperties)
            }

            updateFilteredSpaces()
        }
    }

    /// Updates the geometric properties for a specific space.
    ///
    /// - Parameters:
    ///   - spaceId: The identifier of the space to update
    ///   - geometricProperties: The new geometric properties to apply
    func updateSpaceGeometricProperties(spaceId: String, geometricProperties: GeometricProperties) {
        // Update the local spaces array
        if let index = allSpaces.firstIndex(where: { $0.id == spaceId }) {
            allSpaces[index].geometricProperties = geometricProperties

            // Persist the changes using the use case
            Task { @MainActor in
                let allSpaceGeometricProperties = allSpaces.map(\.geometricProperties)
                await setSpacesGeometricPropertiesUseCase.execute(value: allSpaceGeometricProperties)
            }

            updateFilteredSpaces()
        }
    }

    /// Resets all spaces-related settings to their default values.
    ///
    /// This method resets spaces color properties, appearance mode, and related UI settings
    /// to their default values as defined in ConfigurationDefaults.
    func resetSpacesToDefaults() async {
        await setSpacesColorPropertiesUseCase.execute(value: ConfigurationDefaults.spacesColorProperties)
        await setSpacesEffectPropertiesUseCase.execute(value: ConfigurationDefaults.spacesEffectProperties)
        await setSpacesGeometricPropertiesUseCase.execute(value: ConfigurationDefaults.spacesGeometricProperties)
        await setGlobalSpacesColorPropertiesUseCase.execute(value: ConfigurationDefaults.spaceColorProperties)
        await setGlobalSpacesEffectPropertiesUseCase.execute(value: ConfigurationDefaults.spaceEffectProperties)
        await setGlobalSpacesGeometricPropertiesUseCase.execute(
            value: ConfigurationDefaults.spaceGeometricProperties
        )

        await setThemePresetEffectPropertiesUseCase.execute(value: ConfigurationDefaults.themePresetEffectProperties)
        await setThemePresetGeometricPropertiesUseCase
            .execute(value: ConfigurationDefaults.themePresetGeometricProperties)

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
}
