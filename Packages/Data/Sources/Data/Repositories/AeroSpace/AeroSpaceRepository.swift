// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import AppKit
import ApplicationServices
import Combine
import Domain
import Foundation

/// Repository for managing spaces data through AeroSpace.
///
/// This gateway provides an interface to interact with the AeroSpace window manager,
/// including fetching spaces and windows data, and controlling focus.
/// It runs on the main actor and uses a dedicated dispatch queue for AeroSpace operations.
/// This is the data layer implementation of the SpacesGateway.
@MainActor
public final class AeroSpaceRepository: SpacesGateway {
    /// Apple Event class ('ascr') used by the legacy osascript callback bridge.
    nonisolated static let appleEventClass = AEEventClass(0x6173_6372)

    /// Apple Event ID ('psbr') used by the legacy osascript callback bridge.
    nonisolated static let appleEventId = AEEventID(0x7073_6272)

    /// The command name carried by the legacy focus-changed Apple Event.
    nonisolated static let updateOnFocusChangedCommand = "updateOnFocusChanged"

    /// How long to coalesce a burst of change signals before refreshing.
    private static let refreshDebounceInterval: Duration = .milliseconds(150)

    /// Interval of the safety-net poll used while the event subscription is active.
    ///
    /// AeroSpace publishes no window-closed and no window-title-changed event, so
    /// a slow poll still backstops those two cases. Everything else arrives as an
    /// event; see `AeroSpaceEventType`.
    private static let subscriptionSafetyPollInterval: Duration = .seconds(5)

    /// Interval of the legacy safety-net poll used when optimized performance is on.
    static let legacySafetyPollInterval: Duration = .seconds(2)

    /// Interval of the legacy poll used when optimized performance is off.
    static let legacyPollInterval: Duration = .milliseconds(500)

    /// The AeroSpace events this app subscribes to.
    private static let subscribedEvents = AeroSpaceEventType.allCases

    /// The icon cache gateway for loading app icons.
    private let iconCache: IconCacheProtocol

    /// Use case for getting the AeroSpace executable path.
    private let getAeroSpacePathUseCase: GetAeroSpacePathUseCase

    /// Use case for getting the AeroSpace configuration file path.
    let getAeroSpaceConfigPathUseCase: GetAeroSpaceConfigPathUseCase

    /// Use case for getting the optimized performance enabled setting.
    private let getOptimizedPerformanceEnabledUseCase: GetOptimizedPerformanceEnabledUseCase

    /// Use case for getting the spaces color properties.
    private let getSpacesColorPropertiesUseCase: GetSpacesColorPropertiesUseCase

    /// Use case for getting the AeroSpace version, which decides whether the
    /// event-subscription API is available.
    private let getAeroSpaceVersionUseCase: GetAeroSpaceVersionUseCase

    /// Monitor supplying AeroSpace events, used when subscription is supported.
    private let eventMonitor: AeroSpaceEventMonitorProtocol

    /// Factory for creating AeroSpace CLI clients.
    private let cliFactory: AeroSpaceCLIClientFactoryProtocol

    /// Executor for generic commands.
    private let commandExecutor: CommandExecutorProtocol

    /// Checker for running applications.
    private let runningAppChecker: RunningAppCheckerProtocol

    /// Cached AeroSpace executable path.
    var aeroSpaceExecutable: String

    /// Whether optimized performance is enabled.
    var optimizedPerformanceEnabled: Bool

    /// Cached spaces color properties.
    private var spacesColorProperties: [ColorProperties]

    /// The parsed AeroSpace version, or `nil` until it has been resolved.
    private var aeroSpaceVersion: AeroSpaceVersion?

    /// How AeroSpace state changes are currently being observed.
    private var monitoringMode: MonitoringMode = .undetermined

    /// Long-lived tasks and notification observers backing the current monitoring
    /// mode, held in a thread-safe box so `deinit` can release them.
    let monitoringResources = MonitoringResources()

    /// Debounced-refresh task; coalesces bursts of lifecycle notifications.
    private var pendingRefreshTask: Task<Void, Never>?

    /// Cancellables for publisher subscriptions.
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Publisher Subjects

    private let spacesWithWindowsSubject = CurrentValueSubject<[Space], Never>([])
    private let aeroSpaceRunningSubject = CurrentValueSubject<Bool, Never>(false)

    // MARK: - Publishers

    /// Emits the spaces and their windows whenever they actually change.
    ///
    /// Duplicates are dropped because the safety poll re-fetches on a timer: without
    /// this, an idle system would re-render the whole menu bar on every tick.
    /// Icons compare by identity, and `IconCache` hands out one `NSImage` per app,
    /// so an unchanged refresh compares equal.
    public var spacesWithWindowsPublisher: AnyPublisher<[Space], Never> {
        spacesWithWindowsSubject
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    /// Emits AeroSpace's running state whenever it changes.
    public var aeroSpaceRunningPublisher: AnyPublisher<Bool, Never> {
        aeroSpaceRunningSubject
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    /// Initializes the spaces service with the specified dependencies.
    /// - Parameters:
    ///   - iconCache: The icon cache gateway for loading app icons
    ///   - getAeroSpacePathUseCase: Use case to resolve AeroSpace binary path dynamically
    ///   - getAeroSpaceConfigPathUseCase: Use case to get the AeroSpace configuration file path
    ///   - getOptimizedPerformanceEnabledUseCase: Use case to get the optimized performance enabled setting
    ///   - getSpacesColorPropertiesUseCase: Use case to get the spaces color properties
    ///   - getAeroSpaceVersionUseCase: Use case to get the running AeroSpace version
    ///   - eventMonitor: Monitor supplying AeroSpace events when subscription is supported
    public init(
        iconCache: IconCacheProtocol,
        getAeroSpacePathUseCase: GetAeroSpacePathUseCase,
        getAeroSpaceConfigPathUseCase: GetAeroSpaceConfigPathUseCase,
        getOptimizedPerformanceEnabledUseCase: GetOptimizedPerformanceEnabledUseCase,
        getSpacesColorPropertiesUseCase: GetSpacesColorPropertiesUseCase,
        getAeroSpaceVersionUseCase: GetAeroSpaceVersionUseCase,
        eventMonitor: AeroSpaceEventMonitorProtocol = AeroSpaceEventMonitor(),
        cliFactory: AeroSpaceCLIClientFactoryProtocol = AeroSpaceCLIClientFactory(),
        commandExecutor: CommandExecutorProtocol = CommandExecutor(),
        runningAppChecker: RunningAppCheckerProtocol = RunningAppChecker()
    ) {
        self.iconCache = iconCache
        self.getAeroSpacePathUseCase = getAeroSpacePathUseCase
        self.getAeroSpaceConfigPathUseCase = getAeroSpaceConfigPathUseCase
        self.getOptimizedPerformanceEnabledUseCase = getOptimizedPerformanceEnabledUseCase
        self.getSpacesColorPropertiesUseCase = getSpacesColorPropertiesUseCase
        self.getAeroSpaceVersionUseCase = getAeroSpaceVersionUseCase
        self.eventMonitor = eventMonitor
        self.cliFactory = cliFactory
        self.commandExecutor = commandExecutor
        self.runningAppChecker = runningAppChecker

        aeroSpaceExecutable = getAeroSpacePathUseCase.execute().blockingFirst()
        optimizedPerformanceEnabled = getOptimizedPerformanceEnabledUseCase.execute().blockingFirst()
        spacesColorProperties = getSpacesColorPropertiesUseCase.execute().blockingFirst()
        aeroSpaceVersion = AeroSpaceVersion(string: getAeroSpaceVersionUseCase.execute().blockingFirst())

        setupUseCaseObservers()
        configureWindowFocusMonitoring()
    }

    /// Configures the AeroSpace configuration.
    private func configureAeroSpaceConfig() async {
        let success = if optimizedPerformanceEnabled {
            try? await AeroSpaceConfiguration.appendOnFocusChanged(
                at: getAeroSpaceConfigPathUseCase.execute(),
                command: Self.onFocusChangedCallback
            )
        } else {
            try? await AeroSpaceConfiguration.removeOnFocusChanged(
                at: getAeroSpaceConfigPathUseCase.execute(),
                command: Self.onFocusChangedCallback
            )
        }

        if success == true {
            await reloadAeroSpaceConfig()
            Logger.info("Successfully configured AeroSpace configuration", category: Logger.config)
        } else {
            Logger.warning("Failed to configure AeroSpace configuration", category: Logger.config)
        }
    }

    /// Reloads the AeroSpace configuration.
    private func reloadAeroSpaceConfig() async {
        let executablePath = aeroSpaceExecutable
        guard !executablePath.isEmpty else {
            Logger.warning("Cannot reload AeroSpace config: executable path not set", category: Logger.config)
            return
        }

        do {
            let cli = cliFactory.makeClient(executablePath: executablePath)
            _ = try await cli.execute(arguments: ["reload-config"])
            Logger.info("Successfully reloaded AeroSpace configuration", category: Logger.config)
        } catch {
            Logger.error("Failed to reload AeroSpace configuration", error: error, category: Logger.config)
        }
    }

    /// Configures how the repository observes AeroSpace state changes.
    ///
    /// Tears down whatever was running and starts the mode matching the running
    /// AeroSpace version. Safe to call repeatedly — re-invoked whenever the
    /// version or the optimized-performance setting changes.
    private func configureWindowFocusMonitoring() {
        let mode = resolveMonitoringMode()

        Logger.info("Configuring AeroSpace monitoring", category: Logger.spaces, metadata: [
            "mode": String(describing: mode),
            "aeroSpaceVersion": aeroSpaceVersion.map { "\($0.major).\($0.minor).\($0.patch)" } ?? "unknown"
        ])

        teardownMonitoring()
        monitoringMode = mode

        switch mode {
        case .undetermined:
            // The version is not known yet, so neither the event socket nor the
            // config callbacks can be used responsibly. Poll gently until it is.
            startSafetyPoll(interval: Self.legacySafetyPollInterval)

        case .subscription:
            configureEventSubscriptionMonitoring()

        case .legacy:
            configureLegacyMonitoring()
        }

        Task.detached(priority: .utility) { [weak self] in
            await self?.updateSpacesData()
        }
    }

    /// Determines the monitoring mode for the currently detected AeroSpace version.
    /// - Returns: The mode to use
    private func resolveMonitoringMode() -> MonitoringMode {
        guard let aeroSpaceVersion else { return .undetermined }

        return aeroSpaceVersion.supportsEventSubscription ? .subscription : .legacy
    }

    /// Cancels every task and removes every observer backing the current mode.
    private func teardownMonitoring() {
        monitoringResources.releaseAll()

        pendingRefreshTask?.cancel()
        pendingRefreshTask = nil

        NSAppleEventManager.shared().removeEventHandler(
            forEventClass: Self.appleEventClass,
            andEventID: Self.appleEventId
        )
    }

    // MARK: - Event Subscription Monitoring

    /// Starts event-driven monitoring against AeroSpace's subscription socket.
    ///
    /// Unlike the legacy path this never writes to the user's AeroSpace config
    /// and installs no Apple Event handler. A slow safety poll and the app
    /// lifecycle observers remain, because AeroSpace emits no event for a closed
    /// window or a changed window title.
    private func configureEventSubscriptionMonitoring() {
        let task = Task { [weak self] in
            guard let self else { return }

            for await signal in eventMonitor.start(events: Self.subscribedEvents) {
                handle(signal)
            }
        }
        monitoringResources.add(task: task)

        installAppLifecycleObservers()
        startSafetyPoll(interval: Self.subscriptionSafetyPollInterval)

        Task { [weak self] in
            await self?.removeLegacyConfigCallbacksIfNeeded()
        }
    }

    /// Reacts to one signal from the event monitor.
    ///
    /// Refreshes are debounced because AeroSpace emits events in bursts — a
    /// single workspace switch produces focus, workspace and monitor events.
    /// - Parameter signal: The signal to handle
    private func handle(_ signal: AeroSpaceMonitorSignal) {
        switch signal {
        case .connected:
            if !aeroSpaceRunningSubject.value {
                aeroSpaceRunningSubject.send(true)
            }

        case .disconnected:
            if aeroSpaceRunningSubject.value {
                aeroSpaceRunningSubject.send(false)
            }

        case let .event(event):
            guard event.requiresSpacesRefresh else { return }

            scheduleDebouncedRefresh()
        }
    }

    /// Removes the AeroSpace config callbacks that earlier versions of this app
    /// installed, once per installation.
    ///
    /// Event subscription makes those callbacks redundant, and leaving them
    /// behind would keep firing `osascript` on every focus change. Only exact
    /// matches of the commands this app wrote are removed, so a user-customized
    /// callback is left untouched.
    private func removeLegacyConfigCallbacksIfNeeded() async {
        guard !UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasRemovedLegacyAeroSpaceCallbacks.rawValue) else {
            return
        }

        let configPath = await getAeroSpaceConfigPathUseCase.execute()
        let executablePath = aeroSpaceExecutable

        let removedFocusCallback = updateOnFocusChangedCallback(at: configPath, optimized: false)
        let removedWorkspaceCallback = updateExecOnWorkspaceChangeCallback(at: configPath, optimized: false)

        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasRemovedLegacyAeroSpaceCallbacks.rawValue)

        guard removedFocusCallback || removedWorkspaceCallback, !executablePath.isEmpty else { return }

        Logger.info("Removed legacy AeroSpace callbacks now superseded by event subscription", category: Logger.config)

        do {
            let cli = cliFactory.makeClient(executablePath: executablePath)
            _ = try await cli.execute(arguments: ["reload-config"])
        } catch {
            Logger.error("Failed to reload AeroSpace configuration", error: error, category: Logger.config)
        }
    }

    // MARK: - Legacy Monitoring

    // MARK: - Shared Monitoring Helpers

    /// Starts the periodic refresh that backstops signals the active mode can miss.
    ///
    /// In subscription mode this covers window closes and title changes, for
    /// which AeroSpace emits no event. In legacy mode it is the primary signal.
    /// - Parameter interval: How long to wait between refreshes
    func startSafetyPoll(interval: Duration) {
        let task = Task.detached(priority: .utility) { [weak self] in
            guard let self else { return }

            repeat {
                do {
                    try await Task.sleep(for: interval)
                } catch {
                    return
                }

                if isAeroSpaceRunning() {
                    await updateSpacesData()
                } else {
                    await MainActor.run {
                        if self.aeroSpaceRunningSubject.value {
                            self.aeroSpaceRunningSubject.send(false)
                        }
                    }
                }
            } while !Task.isCancelled
        }
        monitoringResources.add(task: task)
    }

    /// Registers NSWorkspace observers that trigger a debounced refresh on app
    /// lifecycle events. Covers edge cases no AeroSpace signal reports:
    /// - `didTerminate` / `didHide`: Cmd+Q or Cmd+H empties a space.
    /// - `didActivate` / `didDeactivate`: Cmd+W on an app's last window keeps the app
    ///   running without firing termination — focus shifts to another app, which
    ///   surfaces here.
    /// - `didLaunch`: a newly launched app's first window may not yet be visible to
    ///   AeroSpace when the window is detected.
    ///
    /// The observer closures hop to the main actor, where all repository state lives.
    func installAppLifecycleObservers() {
        let center = NSWorkspace.shared.notificationCenter
        let names: [Notification.Name] = [
            NSWorkspace.didTerminateApplicationNotification,
            NSWorkspace.didHideApplicationNotification,
            NSWorkspace.didActivateApplicationNotification,
            NSWorkspace.didDeactivateApplicationNotification,
            NSWorkspace.didLaunchApplicationNotification
        ]

        monitoringResources.add(observers: names.map { name in
            center.addObserver(forName: name, object: nil, queue: nil) { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.scheduleDebouncedRefresh()
                }
            }
        })
    }

    /// Coalesces bursts of change signals into a single refresh.
    ///
    /// Both NSWorkspace notifications and AeroSpace events arrive in bursts — one
    /// workspace switch emits three events — so a short debounce avoids redundant
    /// `updateSpacesData` calls.
    private func scheduleDebouncedRefresh() {
        pendingRefreshTask?.cancel()
        pendingRefreshTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: Self.refreshDebounceInterval)
            guard !Task.isCancelled else { return }

            await self?.updateSpacesData()
        }
    }

    deinit {
        // Apple Event handlers are released when the object is deallocated.
        // Tasks and NSWorkspace observers live in a thread-safe box precisely so
        // this nonisolated deinit can still release them.
        monitoringResources.releaseAll()
    }

    // MARK: - SpacesGateway Implementation

    /// Sets up subscription to monitor executable path changes.
    private func setupUseCaseObservers() {
        getAeroSpacePathUseCase.execute()
            .sink { [weak self] newValue in
                self?.aeroSpaceExecutable = newValue
            }
            .store(in: &cancellables)

        getOptimizedPerformanceEnabledUseCase.execute()
            .sink { [weak self] enabled in
                if self?.optimizedPerformanceEnabled != enabled {
                    self?.optimizedPerformanceEnabled = enabled
                    self?.configureWindowFocusMonitoring()
                }
            }
            .store(in: &cancellables)

        // The version decides whether the event-subscription API is available, so
        // a change to it can switch the whole monitoring strategy.
        getAeroSpaceVersionUseCase.execute()
            .map(AeroSpaceVersion.init(string:))
            .sink { [weak self] version in
                if self?.aeroSpaceVersion != version {
                    self?.aeroSpaceVersion = version
                    self?.configureWindowFocusMonitoring()
                }
            }
            .store(in: &cancellables)

        getSpacesColorPropertiesUseCase.execute()
            .sink { [weak self] colorProperties in
                if self?.spacesColorProperties != colorProperties {
                    self?.spacesColorProperties = colorProperties
                    Task { @MainActor in
                        await self?.updateSpacesData()
                    }
                }
            }
            .store(in: &cancellables)
    }

    /// Updates spaces data and emits via publisher.
    func updateSpacesData() async {
        do {
            let executablePath = aeroSpaceExecutable
            let spaces = try await Task.detached(priority: .userInitiated) {
                try await self.fetchSpacesWithWindows(executablePath: executablePath)
            }.value

            let spacesWithIcons = loadIconsForWindows(in: spaces)
            let spacesWithColorProperties = applyColorPropertiesToSpaces(spacesWithIcons)
            let isRunning = isAeroSpaceRunning()

            Task { @MainActor in
                spacesWithWindowsSubject.send(spacesWithColorProperties)
                aeroSpaceRunningSubject.send(isRunning)
            }
        } catch {
            Logger.error("Failed to update spaces data", error: error, category: Logger.spaces)
        }
    }

    /// Focuses a specific space.
    ///
    /// This method sends a command to AeroSpace to focus the specified space.
    /// - Parameters:
    ///   - spaceId: The identifier of the space to focus
    ///   - needWindowFocus: Whether to also focus a window in the space
    /// - Throws: AppError if the operation fails
    public func focusSpace(spaceId: String, needWindowFocus _: Bool) async throws {
        Logger.info("Focusing space", category: Logger.spaces, metadata: ["spaceId": spaceId])
        Logger.beginInterval("Focus Space Operation", id: Logger.SignpostID.spaceFocus)

        let executablePath = aeroSpaceExecutable
        try await Task.detached(priority: .userInitiated) {
            do {
                let cli = self.cliFactory.makeClient(executablePath: executablePath)
                _ = try await cli.execute(arguments: ["workspace", spaceId])
                Logger.endInterval("Focus Space Operation", id: Logger.SignpostID.spaceFocus)

                Logger.info(
                    "Successfully focused space",
                    category: Logger.spaces,
                    metadata: ["spaceId": spaceId]
                )
            } catch {
                Logger.error(
                    "Failed to focus space",
                    error: error,
                    category: Logger.spaces,
                    metadata: ["spaceId": spaceId]
                )
                throw error
            }
        }.value
    }

    /// Focuses a specific window.
    ///
    /// This method sends a command to AeroSpace to focus the specified window.
    /// - Parameter windowId: The identifier of the window to focus
    /// - Throws: AppError if the operation fails
    public func focusWindow(windowId: String) async throws {
        Logger.info("Focusing window", category: Logger.spaces, metadata: ["windowId": windowId])
        Logger.beginInterval("Focus Window Operation", id: Logger.SignpostID.windowFocus)

        let executablePath = aeroSpaceExecutable
        try await Task.detached(priority: .userInitiated) {
            do {
                let cli = self.cliFactory.makeClient(executablePath: executablePath)
                _ = try await cli.execute(arguments: ["focus", "--window-id", windowId])
                Logger.endInterval("Focus Window Operation", id: Logger.SignpostID.windowFocus)

                Logger.info(
                    "Successfully focused window",
                    category: Logger.spaces,
                    metadata: ["windowId": windowId]
                )
            } catch {
                Logger.error(
                    "Failed to focus window",
                    error: error,
                    category: Logger.spaces,
                    metadata: ["windowId": windowId]
                )
                throw error
            }
        }.value
    }

    /// Starts AeroSpace if it's not currently running.
    /// - Throws: AppError if starting AeroSpace fails
    public func startAeroSpace() async throws {
        Logger.info("Starting AeroSpace launch sequence", category: Logger.spaces)

        // Check if AeroSpace is already running
        if isAeroSpaceRunning() {
            Logger.info("AeroSpace is already running, no need to start", category: Logger.spaces)
            return
        }

        Logger.info("Attempting to start AeroSpace", category: Logger.spaces)

        // Use 'open' command to launch AeroSpace app bundle
        // Note: We don't use AeroSpaceCLIClient here because 'open' is a system command,
        // not the AeroSpace CLI, and it returns immediately after launching the app
        do {
            try await commandExecutor.run(
                executableURL: URL(fileURLWithPath: "/usr/bin/open"),
                arguments: ["/Applications/AeroSpace.app"]
            )

            Logger.info("AeroSpace launched successfully using open command", category: Logger.spaces)
        } catch {
            Logger.error("Failed to launch AeroSpace", error: error, category: Logger.spaces)
            throw AppError.commandExecutionError("Failed to start AeroSpace: \(error.localizedDescription)")
        }

        // Give AeroSpace a moment to start up before returning
        try await Task.sleep(for: .seconds(1))

        Logger.info("AeroSpace launch sequence completed", category: Logger.spaces)
    }

    /// Checks whether AeroSpace is currently running.
    ///
    /// This method queries the running applications to determine if AeroSpace
    /// is currently active on the system.
    /// - Returns: True if AeroSpace is running, false otherwise
    nonisolated private func isAeroSpaceRunning() -> Bool {
        let isRunning = runningAppChecker.isRunning(name: "aerospace")
        Logger.debug("AeroSpace running: \(isRunning)", category: Logger.spaces)
        return isRunning
    }

    // MARK: - Private Methods

    /// Fetches spaces with their associated windows.
    ///
    /// This method coordinates the fetching of spaces, windows, and focus information
    /// and builds the complete spaces data structure.
    /// - Returns: An array of all spaces with their associated windows (including empty spaces)
    /// - Throws: AppError if any operation fails
    nonisolated private func fetchSpacesWithWindows(executablePath: String) async throws -> [Space] {
        guard isAeroSpaceRunning() else {
            throw AppError.aeroSpaceNotRunning
        }

        let spaces = try await fetchSpaces(executablePath: executablePath)
        let windows = try await fetchWindows(executablePath: executablePath)
        let focusedSpace = try await fetchFocusedSpace(executablePath: executablePath)
        let focusedWindow = await fetchFocusedWindow(executablePath: executablePath)

        return try buildSpacesWithWindows(
            spaces: spaces,
            windows: windows,
            focusedSpace: focusedSpace,
            focusedWindow: focusedWindow
        )
    }

    /// Builds spaces with their associated windows.
    ///
    /// This method takes raw spaces and windows data and builds the complete
    /// spaces structure with proper focus states and window assignments.
    /// - Parameters:
    ///   - spaces: The raw spaces data
    ///   - windows: The raw windows data
    ///   - focusedSpace: The currently focused space
    ///   - focusedWindow: The currently focused window
    /// - Returns: An array of all spaces with their associated windows (including empty spaces)
    /// - Throws: SpacesError if the operation fails
    nonisolated private func buildSpacesWithWindows(
        spaces: [Space],
        windows: [Window],
        focusedSpace: Space?,
        focusedWindow: Window?
    ) throws -> [Space] {
        // Update focused state for spaces
        var updatedSpaces = spaces
        if let focusedSpace {
            for index in 0 ..< updatedSpaces.count {
                updatedSpaces[index].isFocused = (updatedSpaces[index].id == focusedSpace.id)
            }
        }

        // Create space dictionary for efficient lookup
        var spaceDict = Dictionary(uniqueKeysWithValues: updatedSpaces.map { ($0.id, $0) })

        // Assign windows to spaces
        for window in windows {
            var mutableWindow = window

            // Mark focused window
            if let focusedWindow, mutableWindow.id == focusedWindow.id {
                mutableWindow.isFocused = true
            }

            if let workspace = mutableWindow.workspace, !workspace.isEmpty {
                if var space = spaceDict[workspace] {
                    space.windows.append(mutableWindow)
                    spaceDict[workspace] = space
                }
            } else if let focusedSpace {
                if var space = spaceDict[focusedSpace.id] {
                    space.windows.append(mutableWindow)
                    spaceDict[focusedSpace.id] = space
                }
            }
        }

        // Sort windows and filter empty spaces
        var resultSpaces = Array(spaceDict.values)
        for index in 0 ..< resultSpaces.count {
            resultSpaces[index].windows.sort { $0.id < $1.id }
        }

        return resultSpaces
    }

    /// Fetches all spaces from AeroSpace.
    /// - Returns: An array of spaces
    /// - Throws: AppError if the operation fails
    nonisolated private func fetchSpaces(executablePath: String) async throws -> [Space] {
        let cli = cliFactory.makeClient(executablePath: executablePath)
        let data = try await cli.execute(arguments: ["list-workspaces", "--all", "--json"])

        do {
            return try JSONDecoder().decode([Space].self, from: data)
        } catch {
            throw AppError.decodingError(error.localizedDescription)
        }
    }

    /// Fetches all windows from AeroSpace.
    /// - Returns: An array of windows
    /// - Throws: AppError if the operation fails
    nonisolated private func fetchWindows(executablePath: String) async throws -> [Window] {
        let cli = cliFactory.makeClient(executablePath: executablePath)
        let data = try await cli.execute(arguments: [
            "list-windows", "--all", "--json", "--format",
            "%{window-id} %{app-name} %{window-title} %{workspace}"
        ])

        do {
            return try JSONDecoder().decode([Window].self, from: data)
        } catch {
            throw AppError.decodingError(error.localizedDescription)
        }
    }

    /// Fetches the currently focused space from AeroSpace.
    /// - Returns: The focused space, or nil if none
    /// - Throws: AppError if the operation fails
    nonisolated private func fetchFocusedSpace(executablePath: String) async throws -> Space? {
        let cli = cliFactory.makeClient(executablePath: executablePath)
        let data = try await cli.execute(arguments: ["list-workspaces", "--focused", "--json"])

        do {
            let spaces = try JSONDecoder().decode([Space].self, from: data)
            return spaces.first
        } catch {
            throw AppError.decodingError(error.localizedDescription)
        }
    }

    /// Fetches the currently focused window from AeroSpace.
    ///
    /// When the focused workspace has no windows, `aerospace list-windows --focused`
    /// exits non-zero with the stderr message "No window is focused". This is not an
    /// error condition for us — it just means there is no focused window — so any
    /// failure here is mapped to `nil` rather than propagated. Letting the error
    /// escape aborts the entire spaces refresh and leaves the UI frozen on the
    /// previous state whenever the user navigates to an empty workspace.
    /// - Returns: The focused window, or nil if none / the query failed
    nonisolated private func fetchFocusedWindow(executablePath: String) async -> Window? {
        let cli = cliFactory.makeClient(executablePath: executablePath)
        guard
            let data = try? await cli.execute(arguments: [
                "list-windows", "--focused", "--json", "--format",
                "%{window-id} %{app-name} %{window-title} %{workspace}"
            ])
        else {
            return nil
        }

        return (try? JSONDecoder().decode([Window].self, from: data))?.first
    }

    /// Loads icons for all windows in the given spaces.
    /// - Parameter spaces: The spaces containing windows that need icons loaded
    /// - Returns: The spaces with icons loaded for their windows
    private func loadIconsForWindows(in spaces: [Space]) -> [Space] {
        var updatedSpaces = spaces

        updatedSpaces.indices.forEach { spaceIndex in
            updatedSpaces[spaceIndex].windows.indices.forEach { windowIndex in
                if let appName = updatedSpaces[spaceIndex].windows[windowIndex].appName {
                    updatedSpaces[spaceIndex].windows[windowIndex].appIcon = iconCache.icon(for: appName)
                }
            }
        }

        return updatedSpaces
    }

    /// Applies color properties to spaces by matching sorted space IDs with visual properties.
    /// Since ColorProperties don't contain space IDs, we sort spaces consistently by ID
    /// and apply configurations in that sorted order for more stable mapping.
    /// - Parameter spaces: The spaces to apply color properties to
    /// - Returns: The spaces with their visual properties updated
    private func applyColorPropertiesToSpaces(_ spaces: [Space]) -> [Space] {
        let colorPropertiesValue = spacesColorProperties

        // Sort spaces by ID for consistent ordering
        var sortedSpaces = spaces.sorted { $0.id < $1.id }

        // Apply color properties in sorted order
        sortedSpaces.indices.forEach { spaceIndex in
            // Apply color properties if available for this sorted index
            if spaceIndex < colorPropertiesValue.count {
                sortedSpaces[spaceIndex].colorProperties = colorPropertiesValue[spaceIndex]
            }
        }

        // Restore original order by sorting back to input order
        let originalOrder = spaces.enumerated().map { index, space in (space.id, index) }
        let orderMap = Dictionary(uniqueKeysWithValues: originalOrder)

        return sortedSpaces.sorted { space1, space2 in
            let index1 = orderMap[space1.id] ?? 0
            let index2 = orderMap[space2.id] ?? 0
            return index1 < index2
        }
    }
}
