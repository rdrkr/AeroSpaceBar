// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine

/// Use case for retrieving the globe key press state.
///
/// This use case provides access to a publisher that emits boolean values
/// representing the current state of the globe/fn key (true when pressed,
/// false when released). It follows the clean architecture pattern by
/// delegating to the KeyboardShortcutsGateway.
@MainActor
public final class GetGlobeKeyPressStateUseCase {
    /// The keyboard shortcuts gateway to retrieve the globe key state from.
    private let keyboardShortcutsGateway: KeyboardShortcutsGateway

    /// Initializes a new instance of the use case.
    ///
    /// - Parameter keyboardShortcutsGateway: The gateway to use for retrieving globe key state.
    public init(keyboardShortcutsGateway: KeyboardShortcutsGateway) {
        self.keyboardShortcutsGateway = keyboardShortcutsGateway
    }

    /// Executes the use case to retrieve the globe key press state publisher.
    ///
    /// - Returns: A publisher that emits boolean values representing the globe key state.
    ///            True indicates the key is pressed, false indicates it is released.
    public func execute() -> AnyPublisher<Bool, Never> {
        keyboardShortcutsGateway.globeKeyPressStatePublisher
    }
}
