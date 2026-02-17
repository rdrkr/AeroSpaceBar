// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import AppKit
import Data

final class MockIconCache: IconCacheProtocol, @unchecked Sendable {
    var iconResult: NSImage?
    var iconCalledWith: String?

    @MainActor
    func icon(for appName: String) -> NSImage? {
        iconCalledWith = appName
        return iconResult
    }
}
