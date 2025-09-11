// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation

/// Extension to block the main thread when using Combine publishers.
///
/// This extension provides a method to block the main thread when using Combine publishers.
/// It is useful for scenarios where you need to wait for a value from a publisher and block the main thread.
///
/// Usage:
/// ```swift
/// let value = publisher.blockingFirst()
/// ```
public extension Publisher {
    func blockingFirst() -> Output {
        var result: Output?
        let semaphore = DispatchSemaphore(value: 0)
        let cancellable = first().sink(
            receiveCompletion: { _ in semaphore.signal() },
            receiveValue: { value in
                result = value
            }
        )
        semaphore.wait()
        _ = cancellable // keep alive
        guard let result else {
            fatalError("Publisher did not emit any value")
        }

        return result
    }
}
