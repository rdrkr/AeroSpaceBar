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

    public var globeKeyPressStateToEmit: Bool = false {
        didSet {
            globeKeyPressStateSubject.send(globeKeyPressStateToEmit)
        }
    }

    // MARK: - Subject

    private let globeKeyPressStateSubject: CurrentValueSubject<Bool, Never>

    // MARK: - Initialization

    public init() {
        globeKeyPressStateSubject = CurrentValueSubject(globeKeyPressStateToEmit)
    }

    // MARK: - Publisher

    public var globeKeyPressStatePublisher: AnyPublisher<Bool, Never> {
        globeKeyPressStateSubject.eraseToAnyPublisher()
    }

    // MARK: - Test Helpers

    public func emitGlobeKeyPressState(_ pressed: Bool) {
        globeKeyPressStateSubject.send(pressed)
    }
}
