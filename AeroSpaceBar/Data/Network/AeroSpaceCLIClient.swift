// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Protocol describing a minimal AeroSpace CLI client capable of executing commands.
protocol AeroSpaceCLIClientProtocol: Sendable {
    /// Executes an AeroSpace CLI command and returns the output data.
    /// - Parameter arguments: The CLI arguments to pass to the AeroSpace executable
    /// - Returns: The command output as `Data`
    /// - Throws: `AppError` if execution fails or the command exits non‑zero
    func execute(arguments: [String]) throws -> Data
}

/// Default implementation of `AeroSpaceCLIClientProtocol` using `Process`.
final class AeroSpaceCLIClient: AeroSpaceCLIClientProtocol {
    /// Path to the AeroSpace executable.
    private let executablePath: String

    /// Initializes the CLI client.
    /// - Parameter executablePath: The path to the AeroSpace executable.
    init(executablePath: String) {
        self.executablePath = executablePath
    }

    /// Executes an AeroSpace CLI command and returns the output data.
    func execute(arguments: [String]) throws -> Data {
        try Logger.measure("CLI Operation", id: Logger.SignpostID.cliOperation) {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: executablePath)
            process.arguments = arguments

            let pipe = Pipe()
            process.standardOutput = pipe

            Logger.info("Executing AeroSpace CLI command", category: Logger.aerospace, metadata: [
                "executable": executablePath,
                "arguments": arguments,
                "command": "\(executablePath) \(arguments.joined(separator: " "))"
            ])

            Logger.beginInterval("CLI Command Execution", id: Logger.SignpostID.cliOperation)

            do {
                try process.run()
            } catch {
                Logger.error("Failed to start AeroSpace command", error: error, category: Logger.aerospace, metadata: [
                    "executable": executablePath,
                    "arguments": arguments
                ])
                throw AppError.commandExecutionError("Failed to run AeroSpace command: \(error.localizedDescription)")
            }

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            process.waitUntilExit()

            Logger.endInterval("CLI Command Execution", id: Logger.SignpostID.cliOperation)

            Logger.debug("AeroSpace command completed", category: Logger.aerospace, metadata: [
                "exitCode": process.terminationStatus,
                "outputSize": data.count
            ])

            if let output = String(data: data, encoding: .utf8) {
                Logger.debug("AeroSpace command output", category: Logger.aerospace, metadata: [
                    "output": output,
                    "outputLength": output.count
                ])
            }

            if process.terminationStatus != 0 {
                Logger.error("AeroSpace command failed", category: Logger.aerospace, metadata: [
                    "exitCode": process.terminationStatus,
                    "executable": executablePath,
                    "arguments": arguments
                ])
                throw AppError
                    .commandExecutionError("AeroSpace command failed with exit code \(process.terminationStatus)")
            }

            Logger.info("AeroSpace command succeeded", category: Logger.aerospace, metadata: [
                "exitCode": process.terminationStatus,
                "outputSize": data.count
            ])

            return data
        }
    }
}
