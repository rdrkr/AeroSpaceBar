// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import AppKit
import Combine

/// Repository for managing spaces data through AeroSpace.
///
/// This gateway provides an interface to interact with the AeroSpace window manager,
/// including fetching spaces and windows data, and controlling focus.
/// It runs on the main actor and uses a dedicated dispatch queue for AeroSpace operations.
/// This is the data layer implementation of the SpacesGateway.
@MainActor
final class SpacesRepository: SpacesGateway {
    /// The icon cache gateway for loading app icons.
    private let iconCache: IconCache

    /// Use case for getting the AeroSpace executable path.
    private let getAeroSpacePathUseCase: GetAeroSpacePathUseCase

    /// Cached AeroSpace executable path.
    private var aeroSpaceExecutable: String = ""

    /// Cancellables for publisher subscriptions.
    private var cancellables: Set<AnyCancellable> = []

    /// A dedicated dispatch queue for AeroSpace operations.
    private let queue = DispatchQueue(label: "com.aerospacebar.spaces", qos: .userInitiated)

    /// Task for checking if a window is in focus.
    private var windowInFocusObserverTask: Task<Void, Never>?

    // MARK: - Publisher Subjects

    private let spacesWithWindowsSubject = CurrentValueSubject<[Space], Never>([])
    private let aeroSpaceRunningSubject = CurrentValueSubject<Bool, Never>(false)

    // MARK: - Publishers

    var spacesWithWindowsPublisher: AnyPublisher<[Space], Never> {
        spacesWithWindowsSubject.eraseToAnyPublisher()
    }

    var aeroSpaceRunningPublisher: AnyPublisher<Bool, Never> {
        aeroSpaceRunningSubject.eraseToAnyPublisher()
    }

    /// Initializes the spaces service with the specified dependencies.
    /// - Parameters:
    ///   - iconCache: The icon cache gateway for loading app icons
    ///   - getAeroSpacePathUseCase: Use case to resolve AeroSpace binary path dynamically
    init(
        iconCache: IconCache,
        getAeroSpacePathUseCase: GetAeroSpacePathUseCase
    ) {
        self.iconCache = iconCache
        self.getAeroSpacePathUseCase = getAeroSpacePathUseCase

        setupExecutablePathSubscription()
        setupWindowInFocusObserver()
    }

    deinit {
        windowInFocusObserverTask?.cancel()
    }

    // MARK: - SpacesGateway Implementation

    /// Sets up subscription to monitor executable path changes.
    private func setupExecutablePathSubscription() {
        getAeroSpacePathUseCase.execute()
            .sink { [weak self] path in
                self?.aeroSpaceExecutable = path
            }
            .store(in: &cancellables)
    }

    /// Sets up observer for on-focus-changed URL events to trigger spaces data updates.
    private func setupWindowInFocusObserver() {
        windowInFocusObserverTask?.cancel()
        windowInFocusObserverTask = Task {
            repeat {
                await self.updateSpacesData()
                try? await Task.sleep(for: .seconds(0.5))
            } while windowInFocusObserverTask?.isCancelled == false
        }
    }

    /// Updates spaces data and emits via publisher.
    private func updateSpacesData() async {
        do {
            let executablePath = aeroSpaceExecutable
            let spaces = try await withCheckedThrowingContinuation { continuation in
                queue.async {
                    do {
                        let spaces = try self.fetchSpacesWithWindows(executablePath: executablePath)
                        continuation.resume(returning: spaces)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }

            let spacesWithIcons = await loadIconsForWindows(in: spaces)
            spacesWithWindowsSubject.send(spacesWithIcons)

            // Update AeroSpace running status
            let isRunning = isAeroSpaceRunning()
            aeroSpaceRunningSubject.send(isRunning)

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
    func focusSpace(spaceId: String, needWindowFocus _: Bool) async throws {
        Logger.info("Focusing space", category: Logger.spaces, metadata: ["spaceId": spaceId])
        Logger.beginInterval("Focus Space Operation", id: Logger.SignpostID.spaceFocus)

        let executablePath = aeroSpaceExecutable
        return try await withCheckedThrowingContinuation { continuation in
            queue.async {
                do {
                    let cli = AeroSpaceCLIClient(executablePath: executablePath)
                    _ = try cli.execute(arguments: ["workspace", spaceId])
                    Logger.endInterval("Focus Space Operation", id: Logger.SignpostID.spaceFocus)

                    Logger.info(
                        "Successfully focused space",
                        category: Logger.spaces,
                        metadata: ["spaceId": spaceId]
                    )
                    continuation.resume()
                } catch {
                    Logger.error(
                        "Failed to focus space",
                        error: error,
                        category: Logger.spaces,
                        metadata: ["spaceId": spaceId]
                    )
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Focuses a specific window.
    ///
    /// This method sends a command to AeroSpace to focus the specified window.
    /// - Parameter windowId: The identifier of the window to focus
    /// - Throws: AppError if the operation fails
    func focusWindow(windowId: String) async throws {
        Logger.info("Focusing window", category: Logger.spaces, metadata: ["windowId": windowId])
        Logger.beginInterval("Focus Window Operation", id: Logger.SignpostID.windowFocus)

        let executablePath = aeroSpaceExecutable
        return try await withCheckedThrowingContinuation { continuation in
            queue.async {
                do {
                    let cli = AeroSpaceCLIClient(executablePath: executablePath)
                    _ = try cli.execute(arguments: ["focus", "--window-id", windowId])
                    Logger.endInterval("Focus Window Operation", id: Logger.SignpostID.windowFocus)

                    Logger.info(
                        "Successfully focused window",
                        category: Logger.spaces,
                        metadata: ["windowId": windowId]
                    )
                    continuation.resume()
                } catch {
                    Logger.error(
                        "Failed to focus window",
                        error: error,
                        category: Logger.spaces,
                        metadata: ["windowId": windowId]
                    )
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Checks whether AeroSpace is currently running.
    ///
    /// This method queries the running applications to determine if AeroSpace
    /// is currently active on the system.
    /// - Returns: True if AeroSpace is running, false otherwise
    nonisolated func isAeroSpaceRunning() -> Bool {
        let runningApps = NSWorkspace.shared.runningApplications.compactMap {
            $0.localizedName?.lowercased()
        }
        Logger.debug("Running apps: \(runningApps)", category: Logger.spaces)

        // Check for various possible AeroSpace process names
        let isRunning = runningApps.contains("aerospace")

        Logger.debug("AeroSpace running: \(isRunning)", category: Logger.spaces)
        return isRunning
    }

    // MARK: - Private Methods

    /// Fetches spaces with their associated windows.
    ///
    /// This method coordinates the fetching of spaces, windows, and focus information
    /// and builds the complete spaces data structure.
    /// - Returns: An array of spaces with their associated windows
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
    /// - Returns: An array of spaces with their associated windows
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

        return resultSpaces.filter { !$0.windows.isEmpty }
    }

    /// Fetches all spaces from AeroSpace.
    /// - Returns: An array of spaces
    /// - Throws: AppError if the operation fails
    private nonisolated func fetchSpaces(executablePath: String) throws -> [Space] {
        let cli = AeroSpaceCLIClient(executablePath: executablePath)
        let data = try cli.execute(arguments: ["list-workspaces", "--all", "--json"])

        do {
            let spaces = try JSONDecoder().decode([SpaceData].self, from: data)
            return spaces.map { $0.toDomain() }
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
            let windows = try JSONDecoder().decode([WindowData].self, from: data)
            return windows.map { $0.toDomain() }
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
            let spaces = try JSONDecoder().decode([SpaceData].self, from: data)
            return spaces.first?.toDomain()
        } catch {
            throw AppError.decodingError(error.localizedDescription)
        }
    }

    /// Fetches the currently focused window from AeroSpace.
    /// - Returns: The focused window, or nil if none
    /// - Throws: AppError if the operation fails
    private nonisolated func fetchFocusedWindow(executablePath: String) throws -> Window? {
        let cli = AeroSpaceCLIClient(executablePath: executablePath)
        let data = try cli.execute(arguments: ["list-windows", "--focused", "--json"])

        do {
            let windows = try JSONDecoder().decode([WindowData].self, from: data)
            return windows.first?.toDomain()
        } catch {
            throw AppError.decodingError(error.localizedDescription)
        }
    }

    /// Loads icons for all windows in the given spaces.
    /// - Parameter spaces: The spaces containing windows that need icons loaded
    /// - Returns: The spaces with icons loaded for their windows
    private func loadIconsForWindows(in spaces: [Space]) async -> [Space] {
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
}
