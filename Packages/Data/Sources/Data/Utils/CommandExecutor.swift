// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Domain
import Foundation

public protocol CommandExecutorProtocol: Sendable {
    func run(executableURL: URL, arguments: [String]) async throws
}

public struct CommandExecutor: CommandExecutorProtocol {
    public init() { }

    public func run(executableURL: URL, arguments: [String]) throws {
        let process = Process()
        process.executableURL = executableURL
        process.arguments = arguments
        process.standardInput = FileHandle.nullDevice

        try process.run()
        process.waitUntilExit()

        if process.terminationStatus != 0 {
            throw AppError.commandExecutionError("Command failed with exit code \(process.terminationStatus)")
        }
    }
}
