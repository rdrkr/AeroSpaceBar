// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import AppKit
import Combine
import Domain

/// Repository implementation for keyboard shortcuts monitoring.
///
/// This repository manages global keyboard event monitoring, specifically
/// tracking the state of the configured Quick Hide trigger key. It uses NSEvent
/// monitors to capture key events both when the app is focused (local monitor)
/// and when other apps are focused (global monitor).
@MainActor
public final class KeyboardShortcutsRepository: KeyboardShortcutsGateway {
    // MARK: - Publishers

    /// Publisher that emits Quick Hide trigger key press state updates.
    /// Emits true when the configured trigger key is pressed, false when released.
    public var quickHideTriggerKeyPressStatePublisher: AnyPublisher<Bool, Never> {
        quickHideTriggerKeyPressStateSubject.eraseToAnyPublisher()
    }

    // MARK: - Private Properties

    /// Subject for Quick Hide trigger key press state.
    private let quickHideTriggerKeyPressStateSubject = CurrentValueSubject<Bool, Never>(false)

    /// The currently configured modifier flag to monitor.
    private var currentModifierFlag: NSEvent.ModifierFlags = .function

    /// Monitor for global key events.
    /// Stored as Sendable wrapper to allow access from nonisolated deinit.
    private let keyMonitorsBox = MonitorsBox()

    /// Use case for getting the current Quick Hide trigger key.
    private let getQuickHideTriggerKeyUseCase: GetQuickHideTriggerKeyUseCase

    /// Cancellable subscriptions for Combine publishers.
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initialization

    /// Initializes a new keyboard shortcuts repository.
    ///
    /// Sets up the key monitors to track the configured Quick Hide trigger key state,
    /// and subscribes to trigger key changes to update the monitored modifier.
    /// - Parameter getQuickHideTriggerKeyUseCase: Use case for getting the Quick Hide trigger key
    public init(getQuickHideTriggerKeyUseCase: GetQuickHideTriggerKeyUseCase) {
        self.getQuickHideTriggerKeyUseCase = getQuickHideTriggerKeyUseCase
        currentModifierFlag = Self.modifierFlag(for: getQuickHideTriggerKeyUseCase.execute().blockingFirst())
        setupKeyMonitors()
        subscribeToTriggerKeyChanges()
    }

    // MARK: - Deinitialization

    deinit {
        // Clean up monitors without accessing MainActor-isolated properties
        keyMonitorsBox.removeAll()
    }

    // MARK: - Private Methods

    /// Maps a `QuickHideTriggerKey` to the corresponding `NSEvent.ModifierFlags` element.
    ///
    /// - Parameter key: The Quick Hide trigger key to map
    /// - Returns: The corresponding modifier flag for NSEvent monitoring
    private static func modifierFlag(for key: QuickHideTriggerKey) -> NSEvent.ModifierFlags {
        switch key {
        case .fn: .function
        case .control: .control
        case .option: .option
        case .command: .command
        case .shift: .shift
        }
    }

    /// Subscribes to trigger key changes and updates the monitored modifier flag.
    private func subscribeToTriggerKeyChanges() {
        getQuickHideTriggerKeyUseCase.execute()
            .sink { [weak self] triggerKey in
                self?.currentModifierFlag = Self.modifierFlag(for: triggerKey)
                // Reset press state when trigger key changes
                self?.quickHideTriggerKeyPressStateSubject.send(false)
            }
            .store(in: &cancellables)
    }

    /// Sets up key monitoring for the configured Quick Hide trigger key.
    ///
    /// This method establishes both local and global event monitors to track
    /// the state of the configured modifier key. The monitors detect the modifier
    /// flag and update the publisher accordingly.
    private func setupKeyMonitors() {
        let keyPressedCallback = { [weak self] (event: NSEvent) in
            _ = Task { @MainActor in
                guard let self else { return }

                self.quickHideTriggerKeyPressStateSubject.send(event.modifierFlags.contains(self.currentModifierFlag))
            }
        }

        let monitors: [Any] = [
            // Local monitor to capture key events when the app is focused
            NSEvent.addLocalMonitorForEvents(matching: [.flagsChanged]) { event in
                keyPressedCallback(event)
                return event
            },
            // Global monitor to capture key events when the app is not focused
            NSEvent.addGlobalMonitorForEvents(matching: [.flagsChanged], handler: keyPressedCallback)
        ]
        .compactMap(\.self)

        keyMonitorsBox.set(monitors)
    }
}

// MARK: - Sendable Monitors Box

/// Thread-safe box for storing NSEvent monitors.
/// This allows monitors to be cleaned up from nonisolated deinit.
private final class MonitorsBox: @unchecked Sendable {
    private let lock = NSLock()
    private var monitors: [Any] = []

    func set(_ newMonitors: [Any]) {
        lock.lock()
        defer { lock.unlock() }
        monitors = newMonitors
    }

    func removeAll() {
        lock.lock()
        let monitorsToRemove = monitors
        monitors = []
        lock.unlock()

        // Remove monitors outside the lock to avoid potential deadlocks
        monitorsToRemove.forEach { monitor in
            NSEvent.removeMonitor(monitor)
        }
    }
}
