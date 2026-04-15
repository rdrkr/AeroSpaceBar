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
    /// The callback to update AeroSpaceBar on focus change.
    /// `nonisolated` so the off-main reconfiguration path can read it without hopping actors.
    nonisolated private static let onFocusChangedCallback = """
    exec-and-forget osascript -e \"
    tell application \\\"System Events\\\" to
        if (get name of every process) contains \\\"AeroSpaceBar\\\" then
            tell application \\\"AeroSpaceBar\\\" to «event ascrpsbr» \\\"updateOnFocusChanged\\\"
    \"
    """.replacingOccurrences(of: "\n", with: " ")

    /// The `exec-on-workspace-change` process spec that notifies AeroSpaceBar of workspace transitions.
    ///
    /// Needed in addition to `on-focus-changed` because switching to an empty workspace
    /// may not always fire `on-focus-changed` (no window to focus). Directly exec's osascript
    /// (no shell) with a one-liner that only dispatches the event if AeroSpaceBar is already running.
    nonisolated private static let execOnWorkspaceChangeCallback: [String] = [
        "/usr/bin/osascript",
        "-e",
        // swiftlint:disable:next line_length
        #"tell application "System Events" to if (get name of every process) contains "AeroSpaceBar" then tell application "AeroSpaceBar" to «event ascrpsbr» "updateOnFocusChanged""#
    ]

    /// The icon cache gateway for loading app icons.
    private let iconCache: IconCacheProtocol

    /// Use case for getting the AeroSpace executable path.
    private let getAeroSpacePathUseCase: GetAeroSpacePathUseCase

    /// Use case for getting the AeroSpace configuration file path.
    private let getAeroSpaceConfigPathUseCase: GetAeroSpaceConfigPathUseCase

    /// Use case for getting the optimized performance enabled setting.
    private let getOptimizedPerformanceEnabledUseCase: GetOptimizedPerformanceEnabledUseCase

    /// Use case for getting the spaces color properties.
    private let getSpacesColorPropertiesUseCase: GetSpacesColorPropertiesUseCase

    /// Factory for creating AeroSpace CLI clients.
    private let cliFactory: AeroSpaceCLIClientFactoryProtocol

    /// Executor for generic commands.
    private let commandExecutor: CommandExecutorProtocol

    /// Checker for running applications.
    private let runningAppChecker: RunningAppCheckerProtocol

    /// Cached AeroSpace executable path.
    private var aeroSpaceExecutable: String

    /// Whether optimized performance is enabled.
    private var optimizedPerformanceEnabled: Bool

    /// Cached spaces color properties.
    private var spacesColorProperties: [ColorProperties]

    /// Task for window focus monitoring.
    private var windowFocusMonitoringTask: Task<Void, Never>?

    /// NSWorkspace observer tokens for app lifecycle notifications.
    ///
    /// Used to catch window-close edge cases that AeroSpace callbacks do not cover
    /// (e.g. closing the last window in a space by quitting its app).
    private var workspaceObservers: [NSObjectProtocol] = []

    /// Debounced-refresh task; coalesces bursts of lifecycle notifications.
    private var pendingRefreshTask: Task<Void, Never>?

    /// Cancellables for publisher subscriptions.
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Publisher Subjects

    private let spacesWithWindowsSubject = CurrentValueSubject<[Space], Never>([])
    private let aeroSpaceRunningSubject = CurrentValueSubject<Bool, Never>(false)

    // MARK: - Publishers

    public var spacesWithWindowsPublisher: AnyPublisher<[Space], Never> {
        spacesWithWindowsSubject.eraseToAnyPublisher()
    }

    public var aeroSpaceRunningPublisher: AnyPublisher<Bool, Never> {
        aeroSpaceRunningSubject.eraseToAnyPublisher()
    }

    /// Initializes the spaces service with the specified dependencies.
    /// - Parameters:
    ///   - iconCache: The icon cache gateway for loading app icons
    ///   - getAeroSpacePathUseCase: Use case to resolve AeroSpace binary path dynamically
    ///   - getAeroSpaceConfigPathUseCase: Use case to get the AeroSpace configuration file path
    ///   - getOptimizedPerformanceEnabledUseCase: Use case to get the optimized performance enabled setting
    ///   - getSpacesColorPropertiesUseCase: Use case to get the spaces color properties
    public init(
        iconCache: IconCacheProtocol,
        getAeroSpacePathUseCase: GetAeroSpacePathUseCase,
        getAeroSpaceConfigPathUseCase: GetAeroSpaceConfigPathUseCase,
        getOptimizedPerformanceEnabledUseCase: GetOptimizedPerformanceEnabledUseCase,
        getSpacesColorPropertiesUseCase: GetSpacesColorPropertiesUseCase,
        cliFactory: AeroSpaceCLIClientFactoryProtocol = AeroSpaceCLIClientFactory(),
        commandExecutor: CommandExecutorProtocol = CommandExecutor(),
        runningAppChecker: RunningAppCheckerProtocol = RunningAppChecker()
    ) {
        self.iconCache = iconCache
        self.getAeroSpacePathUseCase = getAeroSpacePathUseCase
        self.getAeroSpaceConfigPathUseCase = getAeroSpaceConfigPathUseCase
        self.getOptimizedPerformanceEnabledUseCase = getOptimizedPerformanceEnabledUseCase
        self.getSpacesColorPropertiesUseCase = getSpacesColorPropertiesUseCase
        self.cliFactory = cliFactory
        self.commandExecutor = commandExecutor
        self.runningAppChecker = runningAppChecker

        aeroSpaceExecutable = getAeroSpacePathUseCase.execute().blockingFirst()
        optimizedPerformanceEnabled = getOptimizedPerformanceEnabledUseCase.execute().blockingFirst()
        spacesColorProperties = getSpacesColorPropertiesUseCase.execute().blockingFirst()

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

    /// Sets up Apple Event handling for focus change notifications.
    private func configureWindowFocusMonitoring() {
        Logger.info("Configuring window focus monitoring", category: Logger.spaces)

        // Cancel any existing task
        windowFocusMonitoringTask?.cancel()
        windowFocusMonitoringTask = nil

        // Remove any existing event handlers
        NSAppleEventManager.shared().removeEventHandler(
            forEventClass: AEEventClass(0x6173_6372), // 'ascr'
            andEventID: AEEventID(0x7073_6272) // 'psbr'
        )

        // Tear down any previous NSWorkspace observers so toggling optimized mode is idempotent
        removeAppLifecycleObservers()

        Logger.info("Event handlers removed", category: Logger.spaces)

        // Set up event handlers for optimized performance
        if optimizedPerformanceEnabled {
            NSAppleEventManager.shared().setEventHandler(
                self,
                andSelector: #selector(handleAppleEvent(_:withReplyEvent:)),
                forEventClass: AEEventClass(0x6173_6372), // 'ascr'
                andEventID: AEEventID(0x7073_6272) // 'psbr'
            )

            // Safety-net poll: AeroSpace callbacks and NSWorkspace notifications
            // do not cover every edge case (e.g. Cmd+W closing an app's last window
            // without shifting focus to another app). A 2s refresh ensures the UI
            // eventually reflects reality even when every other signal misses.
            windowFocusMonitoringTask = Task.detached(priority: .utility) { [weak self] in
                guard let self else { return }

                repeat {
                    let isRunning = isAeroSpaceRunning()
                    if isRunning {
                        await updateSpacesData()
                    } else {
                        await MainActor.run {
                            if self.aeroSpaceRunningSubject.value {
                                self.aeroSpaceRunningSubject.send(false)
                            }
                        }
                    }
                    try? await Task.sleep(for: .seconds(2))
                } while !Task.isCancelled
            }

            // Catch window-close edge cases (e.g. closing the last window by quitting its app)
            // that neither on-focus-changed nor exec-on-workspace-change report.
            installAppLifecycleObservers()

            Logger.info("Event handlers set up", category: Logger.spaces)
        } else {
            windowFocusMonitoringTask = Task.detached(priority: .utility) { [weak self] in
                guard let self else { return }

                repeat {
                    await updateSpacesData()
                    try? await Task.sleep(for: .seconds(0.5))
                } while !Task.isCancelled
            }

            Logger.info("Window focus monitoring task set up", category: Logger.spaces)
        }

        // Fire-and-forget: don't await these operations
        let executable = aeroSpaceExecutable
        let optimized = optimizedPerformanceEnabled

        Task.detached(priority: .utility) { [weak self] in
            guard let self else { return }

            let configPath = await getAeroSpaceConfigPathUseCase.execute()
            await reconfigureAeroSpaceOffMain(
                configPath: configPath,
                executablePath: executable,
                optimized: optimized
            )
            await updateSpacesData()
        }

        Logger.info("AeroSpace configuration reconfiguration started", category: Logger.spaces)
    }

    /// Handles Apple Events from osascript calls.
    @objc
    private func handleAppleEvent(_ event: NSAppleEventDescriptor, withReplyEvent _: NSAppleEventDescriptor) {
        // Extract the command from the Apple Event
        if let command = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue {
            switch command {
            case "updateOnFocusChanged":
                Task.detached(priority: .utility) { [self] in
                    await updateSpacesData()
                }

            default:
                Logger.debug("Received unknown Apple Event command: \(command)", category: Logger.spaces)
            }
        }
    }

    /// Registers NSWorkspace observers that trigger a debounced refresh on app
    /// lifecycle events. Covers edge cases AeroSpace callbacks miss:
    /// - `didTerminate` / `didHide`: Cmd+Q or Cmd+H empties a space.
    /// - `didActivate` / `didDeactivate`: Cmd+W on an app's last window keeps the app
    ///   running without firing termination — focus shifts to another app, which
    ///   surfaces here.
    /// - `didLaunch`: a newly launched app's first window may not yet be visible to
    ///   AeroSpace when `on-window-detected` fires.
    ///
    /// The observer closures hop to the main actor, where all repository state lives.
    private func installAppLifecycleObservers() {
        let center = NSWorkspace.shared.notificationCenter
        let names: [Notification.Name] = [
            NSWorkspace.didTerminateApplicationNotification,
            NSWorkspace.didHideApplicationNotification,
            NSWorkspace.didActivateApplicationNotification,
            NSWorkspace.didDeactivateApplicationNotification,
            NSWorkspace.didLaunchApplicationNotification
        ]

        workspaceObservers = names.map { name in
            center.addObserver(forName: name, object: nil, queue: nil) { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.scheduleDebouncedRefresh()
                }
            }
        }
    }

    /// Removes any previously installed NSWorkspace observers.
    private func removeAppLifecycleObservers() {
        let center = NSWorkspace.shared.notificationCenter
        workspaceObservers.forEach { center.removeObserver($0) }
        workspaceObservers.removeAll()

        pendingRefreshTask?.cancel()
        pendingRefreshTask = nil
    }

    /// Coalesces bursts of lifecycle notifications into a single refresh.
    ///
    /// NSWorkspace often fires multiple related notifications back-to-back when an
    /// app quits; a short debounce avoids redundant `updateSpacesData` calls.
    private func scheduleDebouncedRefresh() {
        pendingRefreshTask?.cancel()
        pendingRefreshTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: .milliseconds(150))
            guard !Task.isCancelled else { return }

            await self?.updateSpacesData()
        }
    }

    deinit {
        // Apple Events cleanup is handled automatically when the object is deallocated.
        // NSWorkspace observers are torn down via configureWindowFocusMonitoring toggles;
        // for a long-lived @MainActor gateway, any residual observer is released at process exit.
    }

    // MARK: - SpacesGateway Implementation

    /// Sets up subscription to monitor executable path changes.
    private func setupUseCaseObservers() {
        getAeroSpacePathUseCase.execute()
            .assign(to: \.aeroSpaceExecutable, on: self)
            .store(in: &cancellables)

        getOptimizedPerformanceEnabledUseCase.execute()
            .sink { [weak self] enabled in
                if self?.optimizedPerformanceEnabled != enabled {
                    self?.optimizedPerformanceEnabled = enabled
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
    private func updateSpacesData() async {
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

    /// Add this new method that does the heavy work off-main
    nonisolated private func reconfigureAeroSpaceOffMain(
        configPath: URL,
        executablePath: String,
        optimized: Bool
    ) async {
        let focusChanged = updateOnFocusChangedCallback(at: configPath, optimized: optimized)
        let workspaceChanged = updateExecOnWorkspaceChangeCallback(at: configPath, optimized: optimized)

        guard focusChanged || workspaceChanged, !executablePath.isEmpty else { return }

        do {
            let cli = AeroSpaceCLIClient(executablePath: executablePath)
            _ = try await cli.execute(arguments: ["reload-config"])
            Logger.info("Successfully reloaded AeroSpace configuration", category: Logger.config)
        } catch {
            Logger.error("Failed to reload AeroSpace configuration", error: error, category: Logger.config)
        }
    }

    /// Installs or removes the `on-focus-changed` callback based on optimized state.
    /// - Returns: `true` if the TOML file was modified
    nonisolated private func updateOnFocusChangedCallback(at configPath: URL, optimized: Bool) -> Bool {
        do {
            if optimized {
                return try AeroSpaceConfiguration.appendOnFocusChanged(
                    at: configPath,
                    command: Self.onFocusChangedCallback
                )
            }
            return try AeroSpaceConfiguration.removeOnFocusChanged(
                at: configPath,
                command: Self.onFocusChangedCallback
            )
        } catch {
            Logger.error("Failed to update on-focus-changed callback", error: error, category: Logger.config)
            return false
        }
    }

    /// Installs or removes the `exec-on-workspace-change` callback based on optimized state.
    ///
    /// On conflict (user has a custom value), the file is left untouched.
    /// - Returns: `true` if the TOML file was modified
    nonisolated private func updateExecOnWorkspaceChangeCallback(at configPath: URL, optimized: Bool) -> Bool {
        do {
            if optimized {
                let result = try AeroSpaceConfiguration.installExecOnWorkspaceChange(
                    at: configPath,
                    command: Self.execOnWorkspaceChangeCallback
                )
                switch result {
                case .installed:
                    return true
                case .alreadyInstalled:
                    return false
                case let .conflict(existing):
                    Logger.warning(
                        "User has a custom exec-on-workspace-change; leaving it untouched",
                        category: Logger.config,
                        metadata: ["existing": existing.joined(separator: " ")]
                    )
                    return false
                }
            } else {
                return try AeroSpaceConfiguration.removeExecOnWorkspaceChange(
                    at: configPath,
                    command: Self.execOnWorkspaceChangeCallback
                )
            }
        } catch {
            Logger.error("Failed to update exec-on-workspace-change callback", error: error, category: Logger.config)
            return false
        }
    }
}
