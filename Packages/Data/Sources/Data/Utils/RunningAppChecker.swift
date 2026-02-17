// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import AppKit
import Foundation

public protocol RunningAppCheckerProtocol: Sendable {
    func isRunning(name: String) -> Bool
}

public struct RunningAppChecker: RunningAppCheckerProtocol {
    public init() { }

    public func isRunning(name: String) -> Bool {
        NSWorkspace.shared
            .runningApplications
            .compactMap { $0.localizedName?.lowercased() }
            .contains(name.lowercased())
    }
}
