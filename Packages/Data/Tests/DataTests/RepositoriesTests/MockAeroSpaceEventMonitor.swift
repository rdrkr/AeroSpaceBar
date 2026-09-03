// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

@testable import Data
import Foundation

/// Mock event monitor that lets a test drive AeroSpace signals by hand.
///
/// Replaces the real socket subscription so repository tests are deterministic
/// and do not require a running AeroSpace.
public final class MockAeroSpaceEventMonitor: AeroSpaceEventMonitorProtocol, @unchecked Sendable {
    /// Guards the continuation and recorded state.
    private let lock = NSLock()

    /// Continuation for the stream handed to the repository.
    private var continuation: AsyncStream<AeroSpaceMonitorSignal>.Continuation?

    /// The event types the repository subscribed to.
    private var recordedEvents: [AeroSpaceEventType] = []

    /// How many times `start(events:)` was called.
    private var recordedStartCount = 0

    /// Initializes the mock.
    public init() { }

    /// The event types the repository subscribed to.
    public var subscribedEvents: [AeroSpaceEventType] {
        lock.lock()
        defer { lock.unlock() }
        return recordedEvents
    }

    /// How many times monitoring was started.
    public var startCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return recordedStartCount
    }

    /// Hands the repository a stream this mock controls.
    public func start(events: [AeroSpaceEventType]) -> AsyncStream<AeroSpaceMonitorSignal> {
        AsyncStream { continuation in
            lock.lock()
            recordedEvents = events
            recordedStartCount += 1
            self.continuation = continuation
            lock.unlock()
        }
    }

    /// Emits a signal to the repository.
    /// - Parameter signal: The signal to deliver
    public func emit(_ signal: AeroSpaceMonitorSignal) {
        lock.lock()
        let continuation = continuation
        lock.unlock()

        continuation?.yield(signal)
    }

    /// Ends the stream, as a cancelled subscription would.
    public func finish() {
        lock.lock()
        let continuation = continuation
        self.continuation = nil
        lock.unlock()

        continuation?.finish()
    }
}
