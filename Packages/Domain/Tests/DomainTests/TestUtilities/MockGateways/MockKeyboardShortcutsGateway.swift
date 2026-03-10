// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
@testable import Domain
import Foundation

/// Mock implementation of KeyboardShortcutsGateway for testing.
///
/// This mock allows tests to verify keyboard shortcuts interactions and control
/// the values emitted by publishers.
@MainActor
public final class MockKeyboardShortcutsGateway: KeyboardShortcutsGateway {
    // MARK: - Configurable Values

    public var quickHideTriggerKeyPressStateToEmit: Bool = false {
        didSet {
            quickHideTriggerKeyPressStateSubject.send(quickHideTriggerKeyPressStateToEmit)
        }
    }

    // MARK: - Subject

    private let quickHideTriggerKeyPressStateSubject: CurrentValueSubject<Bool, Never>

    // MARK: - Initialization

    public init() {
        quickHideTriggerKeyPressStateSubject = CurrentValueSubject(quickHideTriggerKeyPressStateToEmit)
    }

    // MARK: - Publisher

    public var quickHideTriggerKeyPressStatePublisher: AnyPublisher<Bool, Never> {
        quickHideTriggerKeyPressStateSubject.eraseToAnyPublisher()
    }

    // MARK: - Test Helpers

    public func emitQuickHideTriggerKeyPressState(_ pressed: Bool) {
        quickHideTriggerKeyPressStateSubject.send(pressed)
    }
}
