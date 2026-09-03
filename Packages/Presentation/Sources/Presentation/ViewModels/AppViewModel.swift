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
    /// Whether the Quick Hide trigger key is currently being held.
    @Published public private(set) var isQuickHideTriggerKeyPressed: Bool

    /// Whether the Quick Hide feature is enabled.
    @Published public private(set) var isQuickHideEnabled: Bool

    /// The currently configured Quick Hide trigger key.
    @Published public private(set) var quickHideTriggerKey: QuickHideTriggerKey

    /// The glyph symbol name for the menu bar icon when the trigger key is active.
    ///
    /// Returns the glyph image name matching the current trigger key when Quick Hide
    /// is enabled and the key is pressed, or the default icon should be used.
    public var activeMenuBarGlyphSymbolName: String {
        guard isQuickHideEnabled, isQuickHideTriggerKeyPressed else { return "AppGlyph" }

        return quickHideTriggerKey.glyphSymbol
    }

    // MARK: - Use Cases

    /// The use case for getting Quick Hide trigger key press state.
    private let getQuickHideTriggerKeyPressStateUseCase: GetQuickHideTriggerKeyPressStateUseCase

    /// The use case for getting Quick Hide enabled state.
    private let getQuickHideEnabledUseCase: GetQuickHideEnabledUseCase

    /// The use case for getting the Quick Hide trigger key setting.
    private let getQuickHideTriggerKeyUseCase: GetQuickHideTriggerKeyUseCase

    /// Cancellable subscriptions for Combine publishers.
    private var cancellables: Set<AnyCancellable> = []

    /// Initializes the app ViewModel with the specified dependencies.
    ///
    /// This initializer sets up all use cases and begins monitoring for state updates.
    /// - Parameters:
    ///   - getQuickHideTriggerKeyPressStateUseCase: Use case for getting trigger key press state
    ///   - getQuickHideEnabledUseCase: Use case for getting Quick Hide enabled state
    ///   - getQuickHideTriggerKeyUseCase: Use case for getting the configured trigger key
    init(
        getQuickHideTriggerKeyPressStateUseCase: GetQuickHideTriggerKeyPressStateUseCase,
        getQuickHideEnabledUseCase: GetQuickHideEnabledUseCase,
        getQuickHideTriggerKeyUseCase: GetQuickHideTriggerKeyUseCase
    ) {
        self.getQuickHideTriggerKeyPressStateUseCase = getQuickHideTriggerKeyPressStateUseCase
        self.getQuickHideEnabledUseCase = getQuickHideEnabledUseCase
        self.getQuickHideTriggerKeyUseCase = getQuickHideTriggerKeyUseCase

        // Load initial values from use cases
        isQuickHideTriggerKeyPressed = getQuickHideTriggerKeyPressStateUseCase.execute().blockingFirst()
        isQuickHideEnabled = getQuickHideEnabledUseCase.execute().blockingFirst()
        quickHideTriggerKey = getQuickHideTriggerKeyUseCase.execute().blockingFirst()

        setupReactiveSubscriptions()
    }

    // MARK: - Private Methods

    /// Sets up reactive bindings for state changes.
    ///
    /// This method establishes Combine subscriptions to monitor changes
    /// in Quick Hide trigger key press state, enabled state, and trigger key setting.
    ///
    /// Uses `sink` with a weak capture rather than `assign(to:on:)`: the latter
    /// retains `self` strongly, and because the subscription is stored in `self`'s
    /// own `cancellables` that forms a cycle which keeps the view model alive forever.
    private func setupReactiveSubscriptions() {
        getQuickHideTriggerKeyPressStateUseCase.execute()
            .sink { [weak self] isPressed in
                self?.isQuickHideTriggerKeyPressed = isPressed
            }
            .store(in: &cancellables)

        getQuickHideEnabledUseCase.execute()
            .sink { [weak self] isEnabled in
                self?.isQuickHideEnabled = isEnabled
            }
            .store(in: &cancellables)

        getQuickHideTriggerKeyUseCase.execute()
            .sink { [weak self] triggerKey in
                self?.quickHideTriggerKey = triggerKey
            }
            .store(in: &cancellables)
    }
}
