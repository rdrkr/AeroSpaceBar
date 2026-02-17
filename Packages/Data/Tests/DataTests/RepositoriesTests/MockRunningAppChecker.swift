// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Data

final class MockRunningAppChecker: RunningAppCheckerProtocol, @unchecked Sendable {
    var isRunningResult: Bool = false
    var isRunningCalledWith: String?

    func isRunning(name: String) -> Bool {
        isRunningCalledWith = name
        return isRunningResult
    }
}
