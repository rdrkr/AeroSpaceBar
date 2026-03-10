// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine

/// Use case for retrieving the Quick Hide trigger key press state.
///
/// This use case provides access to a publisher that emits boolean values
/// representing the current state of the configured Quick Hide trigger key
/// (true when pressed, false when released). It follows the clean architecture
/// pattern by delegating to the KeyboardShortcutsGateway.
@MainActor
public final class GetQuickHideTriggerKeyPressStateUseCase {
    /// The keyboard shortcuts gateway to retrieve the trigger key state from.
    private let keyboardShortcutsGateway: KeyboardShortcutsGateway

    /// Initializes a new instance of the use case.
    ///
    /// - Parameter keyboardShortcutsGateway: The gateway to use for retrieving trigger key state.
    public init(keyboardShortcutsGateway: KeyboardShortcutsGateway) {
        self.keyboardShortcutsGateway = keyboardShortcutsGateway
    }

    /// Executes the use case to retrieve the Quick Hide trigger key press state publisher.
    ///
    /// - Returns: A publisher that emits boolean values representing the trigger key state.
    ///            True indicates the key is pressed, false indicates it is released.
    public func execute() -> AnyPublisher<Bool, Never> {
        keyboardShortcutsGateway.quickHideTriggerKeyPressStatePublisher
    }
}
