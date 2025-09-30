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
    /// The callback to update AeroSpaceBar on focus change
    private static let onFocusChangedCallback = """
    exec-and-forget osascript -e \"
    tell application \\\"System Events\\\" to
        if (get name of every process) contains \\\"AeroSpaceBar\\\" then
            tell application \\\"AeroSpaceBar\\\" to «event ascrpsbr» \\\"updateOnFocusChanged\\\"
    \"
    """.replacingOccurrences(of: "\n", with: " ")

    /// The icon cache gateway for loading app icons.
    private let iconCache: IconCache

    /// Use case for getting the AeroSpace executable path.
    private let getAeroSpacePathUseCase: GetAeroSpacePathUseCase

    /// Use case for getting the AeroSpace configuration file path.
    private let getAeroSpaceConfigPathUseCase: GetAeroSpaceConfigPathUseCase

    /// Use case for getting the optimized performance enabled setting.
    private let getOptimizedPerformanceEnabledUseCase: GetOptimizedPerformanceEnabledUseCase

    /// Use case for getting the spaces color properties.
    private let getSpacesColorPropertiesUseCase: GetSpacesColorPropertiesUseCase

    /// Cached AeroSpace executable path.
    private var aeroSpaceExecutable: String

    /// Whether optimized performance is enabled.
    private var optimizedPerformanceEnabled: Bool

    /// Cached spaces color properties.
    private var spacesColorProperties: [ColorProperties]

    /// Task for window focus monitoring.
    private var windowFocusMonitoringTask: Task<Void, Never>?

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
        iconCache: IconCache,
        getAeroSpacePathUseCase: GetAeroSpacePathUseCase,
        getAeroSpaceConfigPathUseCase: GetAeroSpaceConfigPathUseCase,
        getOptimizedPerformanceEnabledUseCase: GetOptimizedPerformanceEnabledUseCase,
        getSpacesColorPropertiesUseCase: GetSpacesColorPropertiesUseCase
    ) {
        self.iconCache = iconCache
        self.getAeroSpacePathUseCase = getAeroSpacePathUseCase
        self.getAeroSpaceConfigPathUseCase = getAeroSpaceConfigPathUseCase
        self.getOptimizedPerformanceEnabledUseCase = getOptimizedPerformanceEnabledUseCase
        self.getSpacesColorPropertiesUseCase = getSpacesColorPropertiesUseCase

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
                command: AeroSpaceRepository.onFocusChangedCallback
            )
        } else {
            try? await AeroSpaceConfiguration.removeOnFocusChanged(
                at: getAeroSpaceConfigPathUseCase.execute(),
                command: AeroSpaceRepository.onFocusChangedCallback
            )
        }

        if success == true {
            reloadAeroSpaceConfig()
            Logger.info("Successfully configured AeroSpace configuration", category: Logger.config)

        } else {
            Logger.warning("Failed to configure AeroSpace configuration", category: Logger.config)
        }
    }

    /// Reloads the AeroSpace configuration.
    private func reloadAeroSpaceConfig() {
        let executablePath = aeroSpaceExecutable
        guard !executablePath.isEmpty else {
            Logger.warning("Cannot reload AeroSpace config: executable path not set", category: Logger.config)
            return
        }

        do {
            let cli = AeroSpaceCLIClient(executablePath: executablePath)
            _ = try cli.execute(arguments: ["reload-config"])
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

        Logger.info("Event handlers removed", category: Logger.spaces)

        // Set up event handlers for optimized performance
        if optimizedPerformanceEnabled {
            NSAppleEventManager.shared().setEventHandler(
                self,
                andSelector: #selector(handleAppleEvent(_:withReplyEvent:)),
                forEventClass: AEEventClass(0x6173_6372), // 'ascr'
                andEventID: AEEventID(0x7073_6272) // 'psbr'
            )

            windowFocusMonitoringTask = Task.detached(priority: .utility) { [weak self] in
                guard let self else { return }

                // Continuously monitor AeroSpace running state
                repeat {
                    let isRunning = isAeroSpaceRunning()

                    Task { @MainActor in
                        let wasRunning = self.aeroSpaceRunningSubject.value

                        if isRunning != wasRunning {
                            if isRunning {
                                await self.updateSpacesData()
                            } else {
                                self.aeroSpaceRunningSubject.send(false)
                            }
                        }
                    }
                    try? await Task.sleep(for: .seconds(5))
                } while !Task.isCancelled
            }

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

            await reconfigureAeroSpaceOffMain(executablePath: executable, optimized: optimized)
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

    deinit {
        // Apple Events cleanup is handled automatically when the object is deallocated
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
                try self.fetchSpacesWithWindows(executablePath: executablePath)
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
                let cli = AeroSpaceCLIClient(executablePath: executablePath)
                _ = try cli.execute(arguments: ["workspace", spaceId])
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
                let cli = AeroSpaceCLIClient(executablePath: executablePath)
                _ = try cli.execute(arguments: ["focus", "--window-id", windowId])
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
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        process.arguments = ["/Applications/AeroSpace.app"]

        do {
            try process.run()
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
    private nonisolated func isAeroSpaceRunning() -> Bool {
        // Check for various possible AeroSpace process names
        let isRunning = NSWorkspace.shared
            .runningApplications
            .compactMap {
                $0.localizedName?.lowercased()
            }
            .contains("aerospace")

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
    private nonisolated func fetchSpacesWithWindows(executablePath: String) throws -> [Space] {
        guard isAeroSpaceRunning() else {
            throw AppError.aeroSpaceNotRunning
        }

        let spaces = try fetchSpaces(executablePath: executablePath)
        let windows = try fetchWindows(executablePath: executablePath)
        let focusedSpace = try fetchFocusedSpace(executablePath: executablePath)
        let focusedWindow = try fetchFocusedWindow(executablePath: executablePath)

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
    private nonisolated func buildSpacesWithWindows(
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
    private nonisolated func fetchSpaces(executablePath: String) throws -> [Space] {
        let cli = AeroSpaceCLIClient(executablePath: executablePath)
        let data = try cli.execute(arguments: ["list-workspaces", "--all", "--json"])

        do {
            let spaces = try JSONDecoder().decode([Space].self, from: data)
            return spaces
        } catch {
            throw AppError.decodingError(error.localizedDescription)
        }
    }

    /// Fetches all windows from AeroSpace.
    /// - Returns: An array of windows
    /// - Throws: AppError if the operation fails
    private nonisolated func fetchWindows(executablePath: String) throws -> [Window] {
        let cli = AeroSpaceCLIClient(executablePath: executablePath)
        let data = try cli.execute(arguments: [
            "list-windows", "--all", "--json", "--format",
            "%{window-id} %{app-name} %{window-title} %{workspace}"
        ])

        do {
            let windows = try JSONDecoder().decode([Window].self, from: data)
            return windows
        } catch {
            throw AppError.decodingError(error.localizedDescription)
        }
    }

    /// Fetches the currently focused space from AeroSpace.
    /// - Returns: The focused space, or nil if none
    /// - Throws: AppError if the operation fails
    private nonisolated func fetchFocusedSpace(executablePath: String) throws -> Space? {
        let cli = AeroSpaceCLIClient(executablePath: executablePath)
        let data = try cli.execute(arguments: ["list-workspaces", "--focused", "--json"])

        do {
            let spaces = try JSONDecoder().decode([Space].self, from: data)
            return spaces.first
        } catch {
            throw AppError.decodingError(error.localizedDescription)
        }
    }

    /// Fetches the currently focused window from AeroSpace.
    /// - Returns: The focused window, or nil if none
    /// - Throws: AppError if the operation fails
    private nonisolated func fetchFocusedWindow(executablePath: String) throws -> Window? {
        let cli = AeroSpaceCLIClient(executablePath: executablePath)
        let data = try cli.execute(arguments: [
            "list-windows", "--focused", "--json", "--format",
            "%{window-id} %{app-name} %{window-title} %{workspace}"
        ])

        do {
            let windows = try JSONDecoder().decode([Window].self, from: data)
            return windows.first
        } catch {
            throw AppError.decodingError(error.localizedDescription)
        }
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

    // Add this new method that does the heavy work off-main
    private nonisolated func reconfigureAeroSpaceOffMain(executablePath: String, optimized: Bool) async {
        let success: Bool? = try? await {
            if optimized {
                try await AeroSpaceConfiguration.appendOnFocusChanged(
                    at: getAeroSpaceConfigPathUseCase.execute(),
                    command: AeroSpaceRepository.onFocusChangedCallback
                )
            } else {
                try await AeroSpaceConfiguration.removeOnFocusChanged(
                    at: getAeroSpaceConfigPathUseCase.execute(),
                    command: AeroSpaceRepository.onFocusChangedCallback
                )
            }
        }()

        if success == true, !executablePath.isEmpty {
            do {
                let cli = AeroSpaceCLIClient(executablePath: executablePath)
                _ = try cli.execute(arguments: ["reload-config"])
                Logger.info("Successfully reloaded AeroSpace configuration", category: Logger.config)
            } catch {
                Logger.error("Failed to reload AeroSpace configuration", error: error, category: Logger.config)
            }
        }
    }
}
