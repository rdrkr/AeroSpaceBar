// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Data
import Foundation

final class MockAeroSpaceCLIClient: AeroSpaceCLIClientProtocol, @unchecked Sendable {
    var executeResult: Result<Data, Error>?
    var executedArguments: [String]?

    /// Every argument list this client was called with, in order.
    var executedCommands: [[String]] = []

    /// The number of invocations whose first argument was `subcommand`.
    /// - Parameter subcommand: The AeroSpace subcommand to count
    /// - Returns: How many times it was invoked
    func callCount(of subcommand: String) -> Int {
        executedCommands.count { $0.first == subcommand }
    }

    func execute(arguments: [String]) throws -> Data {
        executedArguments = arguments
        executedCommands.append(arguments)
        if let result = executeResult {
            return try result.get()
        }
        return Data()
    }
}

final class MockAeroSpaceCLIClientFactory: AeroSpaceCLIClientFactoryProtocol, @unchecked Sendable {
    var mockClient = MockAeroSpaceCLIClient()

    func makeClient(executablePath _: String) -> AeroSpaceCLIClientProtocol {
        mockClient
    }
}
