// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Domain
import Foundation

/// A signal emitted by `AeroSpaceEventMonitor`.
///
/// Connection state and events share one stream so that consumers observe them
/// in the order they occurred — in particular, `connected` always precedes the
/// initial-state burst that follows a (re)connection.
public enum AeroSpaceMonitorSignal: Sendable, Equatable {
    /// A subscription was established. The initial-state events follow.
    case connected

    /// The subscription was lost. A reconnection attempt is scheduled.
    case disconnected

    /// An event was received from AeroSpace.
    case event(AeroSpaceEvent)
}

/// Supervises a long-lived AeroSpace event subscription.
///
/// AeroSpace deletes and recreates its socket on restart and offers no replay,
/// backfill, or sequence numbers, so a dropped connection means the app's view
/// of the world is stale. This monitor reconnects with exponential backoff and
/// relies on the initial-state burst AeroSpace sends on connect to resynchronise.
public protocol AeroSpaceEventMonitorProtocol: Sendable {
    /// Starts monitoring, reconnecting for as long as the stream is consumed.
    ///
    /// The returned stream never finishes on its own: connection failures
    /// surface as `disconnected` and are retried. Cancel the consuming task, or
    /// let the stream deinitialize, to stop monitoring.
    /// - Parameter events: The event types to subscribe to
    /// - Returns: A stream of connection state changes and events
    func start(events: [AeroSpaceEventType]) -> AsyncStream<AeroSpaceMonitorSignal>
}

/// Default implementation of `AeroSpaceEventMonitorProtocol`.
public struct AeroSpaceEventMonitor: AeroSpaceEventMonitorProtocol {
    /// Delay before the first reconnection attempt.
    private static let initialRetryDelay: Duration = .milliseconds(500)

    /// Upper bound on the reconnection delay.
    private static let maximumRetryDelay: Duration = .seconds(8)

    /// The socket client used to open each subscription.
    private let client: AeroSpaceSocketClientProtocol

    /// Initializes the monitor.
    /// - Parameter client: The socket client used to open each subscription
    public init(client: AeroSpaceSocketClientProtocol = AeroSpaceSocketClient()) {
        self.client = client
    }

    /// Starts monitoring, reconnecting until the consuming task is cancelled.
    public func start(events: [AeroSpaceEventType]) -> AsyncStream<AeroSpaceMonitorSignal> {
        AsyncStream { continuation in
            let task = Task {
                await run(events: events, continuation: continuation)
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }

    // MARK: - Private Methods

    /// Runs the connect/stream/backoff loop until cancelled.
    /// - Parameters:
    ///   - events: The event types to subscribe to
    ///   - continuation: The continuation to emit signals on
    private func run(
        events: [AeroSpaceEventType],
        continuation: AsyncStream<AeroSpaceMonitorSignal>.Continuation
    ) async {
        var retryDelay = Self.initialRetryDelay

        while !Task.isCancelled {
            let didConnect = await streamOnce(events: events, continuation: continuation)

            guard !Task.isCancelled else { break }

            // A connection that produced events proves AeroSpace is reachable, so
            // the next drop should retry promptly rather than inherit the backoff
            // accumulated while it was down.
            retryDelay = didConnect ? Self.initialRetryDelay : min(retryDelay * 2, Self.maximumRetryDelay)

            do {
                try await Task.sleep(for: retryDelay)
            } catch {
                break
            }
        }

        continuation.finish()
    }

    /// Opens one subscription and forwards its events until it drops.
    /// - Parameters:
    ///   - events: The event types to subscribe to
    ///   - continuation: The continuation to emit signals on
    /// - Returns: `true` if the subscription was established, `false` if connecting failed
    private func streamOnce(
        events: [AeroSpaceEventType],
        continuation: AsyncStream<AeroSpaceMonitorSignal>.Continuation
    ) async -> Bool {
        var didConnect = false

        do {
            for try await event in client.subscribe(to: events) {
                if !didConnect {
                    didConnect = true
                    Logger.info("Connected to AeroSpace event subscription", category: Logger.aerospace)
                    continuation.yield(.connected)
                }

                continuation.yield(.event(event))
            }
        } catch {
            Logger.debug(
                "AeroSpace event subscription ended",
                category: Logger.aerospace,
                metadata: ["error": error.localizedDescription]
            )
        }

        // Emitted even when the connection was never established, so that a
        // consumer starting up while AeroSpace is down learns it is unreachable.
        continuation.yield(.disconnected)

        return didConnect
    }
}
