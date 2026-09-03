// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

@testable import Data
import Foundation
import Nimble
import XCTest

/// Tests the supervision behaviour that keeps an AeroSpace subscription alive.
///
/// AeroSpace deletes and recreates its socket on restart and offers no replay,
/// so the monitor must surface the drop and reconnect on its own.
final class AeroSpaceEventMonitorTests: XCTestCase {
    // MARK: - Test Doubles

    /// A client whose subscription always fails to connect.
    private struct FailingClient: AeroSpaceSocketClientProtocol {
        func subscribe(to _: [AeroSpaceEventType]) -> AsyncThrowingStream<AeroSpaceEvent, Error> {
            AsyncThrowingStream { $0.finish(throwing: AppErrorStub.unreachable) }
        }
    }

    /// A client that yields a fixed set of events and then drops the connection.
    private struct ScriptedClient: AeroSpaceSocketClientProtocol {
        let events: [AeroSpaceEvent]

        func subscribe(to _: [AeroSpaceEventType]) -> AsyncThrowingStream<AeroSpaceEvent, Error> {
            AsyncThrowingStream { continuation in
                for event in events {
                    continuation.yield(event)
                }
                continuation.finish(throwing: AppErrorStub.unreachable)
            }
        }
    }

    /// Minimal error used to simulate a lost connection.
    private enum AppErrorStub: Error {
        case unreachable
    }

    // MARK: - Tests

    func testReportsDisconnectAndRetriesWhenUnreachable() async {
        // Given a monitor whose client can never connect
        let monitor = AeroSpaceEventMonitor(client: FailingClient())

        // When consuming its signals
        var disconnects = 0
        for await signal in monitor.start(events: [.focusChanged]) {
            if case .disconnected = signal {
                disconnects += 1
            }
            if disconnects >= 2 {
                break
            }
        }

        // Then it reports each failed attempt and keeps retrying rather than
        // giving up or hanging
        expect(disconnects) == 2
    }

    func testEmitsConnectedBeforeEventsThenDisconnected() async {
        // Given a client that delivers an initial-state burst then drops
        let events: [AeroSpaceEvent] = [
            .modeChanged(mode: "main"),
            .focusChanged(windowId: 1, workspace: "1")
        ]
        let monitor = AeroSpaceEventMonitor(client: ScriptedClient(events: events))

        // When consuming the first connection's signals
        var received: [AeroSpaceMonitorSignal] = []
        for await signal in monitor.start(events: AeroSpaceEventType.allCases) {
            received.append(signal)
            if received.count >= 4 {
                break
            }
        }

        // Then connection state brackets the events in order, so a consumer can
        // trust that everything after `connected` is fresh state
        expect(received) == [
            .connected,
            .event(.modeChanged(mode: "main")),
            .event(.focusChanged(windowId: 1, workspace: "1")),
            .disconnected
        ]
    }
}
