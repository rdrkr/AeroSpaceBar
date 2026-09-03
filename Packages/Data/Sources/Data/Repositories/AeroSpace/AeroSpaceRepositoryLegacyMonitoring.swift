// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import AppKit
import Domain
import Foundation

/// The pre-subscription monitoring path, kept for AeroSpace versions older than
/// 0.21.0-Beta.
///
/// These versions have no event socket, so the only way to learn about focus and
/// workspace changes is to write callbacks into the user's AeroSpace config that
/// relay through `osascript` into a private Apple Event, and to poll. All of this
/// becomes dead code once the minimum supported AeroSpace version reaches 0.21.0;
/// it is isolated here so that removal is a single file deletion.
extension AeroSpaceRepository {
    /// The callback to update AeroSpaceBar on focus change.
    /// `nonisolated` so the off-main reconfiguration path can read it without hopping actors.
    nonisolated static let onFocusChangedCallback = """
    exec-and-forget osascript -e \"
    tell application \\\"System Events\\\" to
        if (get name of every process) contains \\\"AeroSpaceBar\\\" then
            tell application \\\"AeroSpaceBar\\\" to «event ascrpsbr» \\\"\(updateOnFocusChangedCommand)\\\"
    \"
    """.replacingOccurrences(of: "\n", with: " ")

    /// The `exec-on-workspace-change` process spec that notifies AeroSpaceBar of workspace transitions.
    ///
    /// Needed in addition to `on-focus-changed` because switching to an empty workspace
    /// may not always fire `on-focus-changed` (no window to focus). Directly exec's osascript
    /// (no shell) with a one-liner that only dispatches the event if AeroSpaceBar is already running.
    nonisolated static let execOnWorkspaceChangeCallback: [String] = [
        "/usr/bin/osascript",
        "-e",
        // swiftlint:disable:next line_length
        #"tell application "System Events" to if (get name of every process) contains "AeroSpaceBar" then tell application "AeroSpaceBar" to «event ascrpsbr» "\#(updateOnFocusChangedCommand)""#
    ]

    /// Starts the pre-0.21 monitoring path: config callbacks relayed through an
    /// Apple Event, NSWorkspace notifications, and polling.
    func configureLegacyMonitoring() {
        if optimizedPerformanceEnabled {
            NSAppleEventManager.shared().setEventHandler(
                self,
                andSelector: #selector(handleAppleEvent(_:withReplyEvent:)),
                forEventClass: Self.appleEventClass,
                andEventID: Self.appleEventId
            )

            startSafetyPoll(interval: Self.legacySafetyPollInterval)
            installAppLifecycleObservers()
        } else {
            startSafetyPoll(interval: Self.legacyPollInterval)
        }

        // Fire-and-forget: don't await these operations
        let executable = aeroSpaceExecutable
        let optimized = optimizedPerformanceEnabled

        let task = Task.detached(priority: .utility) { [weak self] in
            guard let self else { return }

            let configPath = await getAeroSpaceConfigPathUseCase.execute()
            await reconfigureAeroSpaceOffMain(
                configPath: configPath,
                executablePath: executable,
                optimized: optimized
            )
            await updateSpacesData()
        }
        monitoringResources.add(task: task)
    }

    /// Handles Apple Events from osascript calls.
    ///
    /// Only used in legacy mode; AeroSpace 0.21.0+ delivers the same information
    /// over the event socket.
    @objc
    func handleAppleEvent(_ event: NSAppleEventDescriptor, withReplyEvent _: NSAppleEventDescriptor) {
        // Extract the command from the Apple Event
        if let command = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue {
            switch command {
            case Self.updateOnFocusChangedCommand:
                Task.detached(priority: .utility) { [self] in
                    await updateSpacesData()
                }

            default:
                Logger.debug("Received unknown Apple Event command: \(command)", category: Logger.spaces)
            }
        }
    }

    /// Add this new method that does the heavy work off-main
    nonisolated func reconfigureAeroSpaceOffMain(
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
    nonisolated func updateOnFocusChangedCallback(at configPath: URL, optimized: Bool) -> Bool {
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
    nonisolated func updateExecOnWorkspaceChangeCallback(at configPath: URL, optimized: Bool) -> Bool {
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
