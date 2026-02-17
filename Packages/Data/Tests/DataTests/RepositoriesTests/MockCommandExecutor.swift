// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Data
import Foundation

final class MockCommandExecutor: CommandExecutorProtocol, @unchecked Sendable {
    var runCalled = false
    var executedURL: URL?
    var executedArguments: [String]?
    var runResult: Result<Void, Error>?

    func run(executableURL: URL, arguments: [String]) throws {
        runCalled = true
        executedURL = executableURL
        executedArguments = arguments

        if let result = runResult {
            try result.get()
        }
    }
}
