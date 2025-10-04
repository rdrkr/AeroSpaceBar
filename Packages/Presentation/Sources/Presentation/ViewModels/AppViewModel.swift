// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Domain

/// ViewModel for managing app-level state and interactions.
///
/// This ViewModel manages app-level state that spans across multiple views,
/// including keyboard shortcuts and global UI state. It runs on the main actor
/// and uses Combine for reactive updates.
@MainActor
public final class AppViewModel: ObservableObject {
    /// Whether the globe key is currently being held.
    @Published public private(set) var isGlobeKeyPressed: Bool

    // MARK: - Use Cases

    /// The use case for getting globe key press state.
    private let getGlobeKeyPressStateUseCase: GetGlobeKeyPressStateUseCase

    /// Cancellable subscriptions for Combine publishers.
    private var cancellables: Set<AnyCancellable> = []

    /// Initializes the app ViewModel with the specified dependencies.
    ///
    /// This initializer sets up the use case and begins monitoring for state updates.
    /// - Parameter getGlobeKeyPressStateUseCase: Use case for getting globe key press state
    init(getGlobeKeyPressStateUseCase: GetGlobeKeyPressStateUseCase) {
        self.getGlobeKeyPressStateUseCase = getGlobeKeyPressStateUseCase

        // Load initial value from use case
        isGlobeKeyPressed = getGlobeKeyPressStateUseCase.execute().blockingFirst()

        setupReactiveSubscriptions()
    }

    // MARK: - Private Methods

    /// Sets up reactive bindings for state changes.
    ///
    /// This method establishes Combine subscriptions to monitor changes
    /// in globe key press state and update the published properties accordingly.
    private func setupReactiveSubscriptions() {
        getGlobeKeyPressStateUseCase.execute()
            .assign(to: \.isGlobeKeyPressed, on: self)
            .store(in: &cancellables)
    }
}
