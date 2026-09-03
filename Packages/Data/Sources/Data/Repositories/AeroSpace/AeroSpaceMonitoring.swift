// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import AppKit
import Foundation

/// How the repository observes AeroSpace state changes.
enum MonitoringMode: Equatable {
    /// The AeroSpace version is not known yet; poll conservatively and change nothing.
    case undetermined

    /// AeroSpace 0.21.0+; subscribe to its event socket.
    case subscription

    /// AeroSpace below 0.21.0; inject config callbacks and poll.
    case legacy
}

/// Thread-safe box holding the tasks and notification observers backing the
/// active monitoring mode.
///
/// Storing them outside the main actor lets the nonisolated `deinit` release
/// them, so a discarded repository stops polling instead of leaking a live task.
final class MonitoringResources: @unchecked Sendable {
    /// Guards `tasks` and `observers`.
    private let lock = NSLock()

    /// Long-lived tasks to cancel on teardown.
    private var tasks: [Task<Void, Never>] = []

    /// NSWorkspace observer tokens to remove on teardown.
    private var observers: [NSObjectProtocol] = []

    /// Registers a task to cancel on teardown.
    /// - Parameter task: The task to retain
    func add(task: Task<Void, Never>) {
        lock.lock()
        defer { lock.unlock() }
        tasks.append(task)
    }

    /// Registers notification observers to remove on teardown.
    /// - Parameter newObservers: The observer tokens to retain
    func add(observers newObservers: [NSObjectProtocol]) {
        lock.lock()
        defer { lock.unlock() }
        observers.append(contentsOf: newObservers)
    }

    /// Cancels every retained task and removes every retained observer.
    func releaseAll() {
        lock.lock()
        let tasksToCancel = tasks
        let observersToRemove = observers
        tasks = []
        observers = []
        lock.unlock()

        // Release outside the lock to avoid holding it across framework calls.
        tasksToCancel.forEach { $0.cancel() }

        let center = NSWorkspace.shared.notificationCenter
        observersToRemove.forEach { center.removeObserver($0) }
    }
}
