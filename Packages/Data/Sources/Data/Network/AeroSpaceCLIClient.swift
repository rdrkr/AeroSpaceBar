// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Domain
import Foundation

/// Protocol describing a minimal AeroSpace CLI client capable of executing commands.
public protocol AeroSpaceCLIClientProtocol: Sendable {
    /// Executes an AeroSpace CLI command and returns the output data.
    /// - Parameter arguments: The CLI arguments to pass to the AeroSpace executable
    /// - Returns: The command output as `Data`
    /// - Throws: `AppError` if execution fails or the command exits non‑zero
    func execute(arguments: [String]) async throws -> Data
}

/// Default implementation of `AeroSpaceCLIClientProtocol` using `Process`.
internal final class AeroSpaceCLIClient: AeroSpaceCLIClientProtocol {
    /// Path to the AeroSpace executable.
    private let executablePath: String

    /// Initializes the CLI client.
    /// - Parameter executablePath: The path to the AeroSpace executable.
    internal init(executablePath: String) {
        self.executablePath = executablePath
    }

    /// Executes an AeroSpace CLI command and returns the output data.
    internal func execute(arguments: [String]) async throws -> Data {
        try await Logger.measure("CLI Operation", id: Logger.SignpostID.cliOperation) {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: executablePath)
            process.arguments = arguments

            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardInput = FileHandle.nullDevice

            Logger.info("Executing AeroSpace CLI command", category: Logger.aerospace, metadata: [
                "executable": executablePath,
                "arguments": arguments,
                "command": "\(executablePath) \(arguments.joined(separator: " "))"
            ])

            Logger.beginInterval("CLI Command Execution", id: Logger.SignpostID.cliOperation)

            // Read data and wait for exit with timeout
            let result = try? await withTimeout(for: .seconds(2)) {
                try process.run()
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                process.waitUntilExit()
                return (data, process.terminationStatus)
            }

            guard let (data, terminationStatus) = result else {
                if process.isRunning {
                    process.terminate()
                }
                Logger.error("AeroSpace command timed out during execution", category: Logger.aerospace, metadata: [
                    "executable": executablePath,
                    "arguments": arguments
                ])
                throw AppError.commandExecutionError("AeroSpace command timed out during execution")
            }

            Logger.endInterval("CLI Command Execution", id: Logger.SignpostID.cliOperation)

            Logger.debug("AeroSpace command completed", category: Logger.aerospace, metadata: [
                "exitCode": terminationStatus,
                "outputSize": data.count
            ])

            if let output = String(data: data, encoding: .utf8) {
                Logger.debug("AeroSpace command output", category: Logger.aerospace, metadata: [
                    "output": output,
                    "outputLength": output.count
                ])
            }

            if terminationStatus != 0 {
                Logger.error("AeroSpace command failed", category: Logger.aerospace, metadata: [
                    "exitCode": terminationStatus,
                    "executable": executablePath,
                    "arguments": arguments
                ])
                throw AppError
                    .commandExecutionError("AeroSpace command failed with exit code \(terminationStatus)")
            }

            Logger.info("AeroSpace command succeeded", category: Logger.aerospace, metadata: [
                "exitCode": terminationStatus,
                "outputSize": data.count
            ])

            return data
        }
    }
}

/// Factory for creating AeroSpace CLI clients.
public protocol AeroSpaceCLIClientFactoryProtocol: Sendable {
    func makeClient(executablePath: String) -> AeroSpaceCLIClientProtocol
}

/// Default implementation of `AeroSpaceCLIClientFactoryProtocol`.
public struct AeroSpaceCLIClientFactory: AeroSpaceCLIClientFactoryProtocol {
    public init() { }

    public func makeClient(executablePath: String) -> AeroSpaceCLIClientProtocol {
        AeroSpaceCLIClient(executablePath: executablePath)
    }
}
