// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import AppKit
import Combine
import Domain

/// Repository implementation for keyboard shortcuts monitoring.
///
/// This repository manages global keyboard event monitoring, specifically
/// tracking the state of the globe/fn key. It uses NSEvent monitors to
/// capture key events both when the app is focused (local monitor) and
/// when other apps are focused (global monitor).
@MainActor
public final class KeyboardShortcutsRepository: KeyboardShortcutsGateway {
    // MARK: - Publishers

    /// Publisher that emits globe key press state updates.
    /// Emits true when the globe/fn key is pressed, false when released.
    public var globeKeyPressStatePublisher: AnyPublisher<Bool, Never> {
        globeKeyPressStateSubject.eraseToAnyPublisher()
    }

    // MARK: - Private Properties

    /// Subject for globe key press state.
    private let globeKeyPressStateSubject = CurrentValueSubject<Bool, Never>(false)

    /// Monitor for global key events.
    private nonisolated(unsafe) var keyMonitors: [Any] = []

    // MARK: - Initialization

    /// Initializes a new keyboard shortcuts repository.
    ///
    /// Sets up the global key monitors to track the globe/fn key state.
    public init() {
        setupGlobeKeyMonitors()
    }

    // MARK: - Deinitialization

    deinit {
        removeGlobeKeyMonitors()
    }

    // MARK: - Private Methods

    /// Sets up global key monitoring for the globe key (fn key).
    ///
    /// This method establishes both local and global event monitors to track
    /// the state of the function/globe key. The monitors detect the .function
    /// modifier flag and update the publisher accordingly.
    private func setupGlobeKeyMonitors() {
        let keyPressedCallback = { [weak self] (event: NSEvent) in
            _ = Task { @MainActor in
                // The globe/fn key is represented by the .function modifier flag
                self?.globeKeyPressStateSubject.send(event.modifierFlags.contains(.function))
            }
        }

        unsafe keyMonitors = [
            // Local monitor to capture key events when the app is focused
            NSEvent.addLocalMonitorForEvents(matching: [.flagsChanged]) { event in
                keyPressedCallback(event)
                return event
            },
            // Global monitor to capture key events when the app is not focused
            NSEvent.addGlobalMonitorForEvents(matching: [.flagsChanged], handler: keyPressedCallback)
        ]
        .compactMap(\.self)
    }

    /// Removes the global key monitors.
    ///
    /// This method cleans up event monitors and resets the globe key state
    /// to false when the repository is deallocated.
    private nonisolated func removeGlobeKeyMonitors() {
        unsafe keyMonitors.forEach { monitor in
            NSEvent.removeMonitor(monitor)
        }

        Task { @MainActor in
            globeKeyPressStateSubject.send(false)
        }
    }
}
