// Copyright (c) 2026 Jakub Kubiak.

import Data
import Foundation

final class MockAeroSpaceEventClient: AeroSpaceEventClientProtocol, @unchecked Sendable {
    func events(executablePath _: String) -> AsyncThrowingStream<AeroSpaceEvent, Error> {
        AsyncThrowingStream { continuation in
            continuation.finish()
        }
    }
}
