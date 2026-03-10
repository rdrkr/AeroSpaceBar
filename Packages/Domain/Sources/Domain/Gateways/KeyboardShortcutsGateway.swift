// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine

/// Protocol defining the interface for keyboard shortcuts monitoring operations.
///
/// This protocol provides a contract for repositories that manage keyboard shortcut state,
/// allowing for easy testing and dependency injection. It belongs to the domain layer
/// and defines the business requirements for keyboard monitoring operations.
/// Following reactive patterns similar to Kotlin Flow/StateFlow.
@MainActor
public protocol KeyboardShortcutsGateway {
    // MARK: - Publishers for Reactive Data Flow

    /// Publisher that emits Quick Hide trigger key press state updates.
    /// Emits true when the configured trigger key is pressed, false when released.
    var quickHideTriggerKeyPressStatePublisher: AnyPublisher<Bool, Never> { get }
}
