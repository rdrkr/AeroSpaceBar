// Copyright (c) 2026 Jakub Kubiak.

import Domain
import Foundation

/// A real-time event emitted by AeroSpace's `subscribe` command.
public struct AeroSpaceEvent: Decodable, Equatable, Sendable {
    public let name: String
    public let windowId: UInt32?
    public let workspace: String?
    public let previousWorkspace: String?
    public let appBundleId: String?
    public let appName: String?

    private enum CodingKeys: String, CodingKey {
        case name = "_event"
        case windowId
        case workspace
        case previousWorkspace = "prevWorkspace"
        case appBundleId
        case appName
    }
}

/// Produces the continuous stream exposed by `aerospace subscribe`.
public protocol AeroSpaceEventClientProtocol: Sendable {
    func events(executablePath: String) -> AsyncThrowingStream<AeroSpaceEvent, Error>
}

/// Keeps one AeroSpace process alive and decodes its JSON-lines event stream.
///
/// Unlike the previous AppleScript callback, this process is started once. Focus
/// changes therefore reach the app without launching an AppleScript process for
/// every interaction.
public struct AeroSpaceEventClient: AeroSpaceEventClientProtocol {
    public init() { }

    public func events(executablePath: String) -> AsyncThrowingStream<AeroSpaceEvent, Error> {
        AsyncThrowingStream { continuation in
            let task = Task.detached(priority: .userInitiated) {
                let process = Process()
                let outputPipe = Pipe()
                let errorPipe = Pipe()

                process.executableURL = URL(fileURLWithPath: executablePath)
                process.arguments = [
                    "subscribe",
                    "focus-changed",
                    "focused-workspace-changed",
                    "window-detected"
                ]
                process.standardInput = FileHandle.nullDevice
                process.standardOutput = outputPipe
                process.standardError = errorPipe

                do {
                    try process.run()

                    try await withTaskCancellationHandler {
                        for try await line in outputPipe.fileHandleForReading.bytes.lines {
                            try Task.checkCancellation()

                            guard let data = line.data(using: .utf8) else { continue }

                            let event = try JSONDecoder().decode(AeroSpaceEvent.self, from: data)
                            continuation.yield(event)
                        }
                    } onCancel: {
                        if process.isRunning {
                            process.terminate()
                        }
                    }

                    process.waitUntilExit()
                    guard !Task.isCancelled else {
                        continuation.finish()
                        return
                    }

                    guard process.terminationStatus == 0 else {
                        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                        let message = String(data: errorData, encoding: .utf8) ?? "Unknown error"
                        let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
                        throw AppError.commandExecutionError(
                            "AeroSpace event subscription failed: \(trimmedMessage)"
                        )
                    }

                    continuation.finish()
                } catch is CancellationError {
                    if process.isRunning {
                        process.terminate()
                    }
                    continuation.finish()
                } catch {
                    if process.isRunning {
                        process.terminate()
                    }
                    continuation.finish(throwing: error)
                }
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}
