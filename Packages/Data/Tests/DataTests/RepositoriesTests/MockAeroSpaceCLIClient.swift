// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Data
import Foundation

final class MockAeroSpaceCLIClient: AeroSpaceCLIClientProtocol, @unchecked Sendable {
    var executeResult: Result<Data, Error>?
    var executedArguments: [String]?

    func execute(arguments: [String]) throws -> Data {
        executedArguments = arguments
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
