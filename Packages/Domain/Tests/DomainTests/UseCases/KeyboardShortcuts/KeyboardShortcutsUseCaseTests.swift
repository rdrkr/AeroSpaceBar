// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
@testable import Domain
import Nimble
import XCTest

/// Tests for KeyboardShortcuts UseCases.
///
/// These tests verify:
/// - GetQuickHideTriggerKeyPressStateUseCase
@MainActor
final class KeyboardShortcutsUseCaseTests: XCTestCase {
    private var mockGateway: MockKeyboardShortcutsGateway?
    private var cancellables: Set<AnyCancellable>?

    override func setUp() async throws {
        try await super.setUp()
        mockGateway = MockKeyboardShortcutsGateway()
        cancellables = []
    }

    // MARK: - GetQuickHideTriggerKeyPressStateUseCase Tests

    func testGetQuickHideTriggerKeyPressStateWhenReleased() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockGateway.emitQuickHideTriggerKeyPressState(false)
        let useCase = GetQuickHideTriggerKeyPressStateUseCase(keyboardShortcutsGateway: mockGateway)
        var receivedState: Bool?

        // When
        useCase.execute()
            .sink { value in receivedState = value }
            .store(in: &cancellables)

        // Then
        expect(receivedState).toNot(beNil())
        expect(receivedState ?? true) == false
    }

    func testGetQuickHideTriggerKeyPressStateWhenPressed() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockGateway.emitQuickHideTriggerKeyPressState(true)
        let useCase = GetQuickHideTriggerKeyPressStateUseCase(keyboardShortcutsGateway: mockGateway)
        var receivedState: Bool?

        // When
        useCase.execute()
            .sink { value in receivedState = value }
            .store(in: &cancellables)

        // Then
        expect(receivedState).toNot(beNil())
        expect(receivedState ?? false) == true
    }

    // MARK: - State Toggle Tests

    func testQuickHideTriggerKeyStateTransitionFromReleasedToPressed() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockGateway.emitQuickHideTriggerKeyPressState(false)
        let useCase = GetQuickHideTriggerKeyPressStateUseCase(keyboardShortcutsGateway: mockGateway)
        var receivedStateInitial: Bool?

        // When - Get initial state (released)
        useCase.execute()
            .sink { value in receivedStateInitial = value }
            .store(in: &cancellables)

        // Then - Verify initially released
        expect(receivedStateInitial ?? true) == false

        // When - Simulate key press
        mockGateway.emitQuickHideTriggerKeyPressState(true)
        cancellables.removeAll()
        var receivedStatePressed: Bool?
        useCase.execute()
            .sink { value in receivedStatePressed = value }
            .store(in: &cancellables)

        // Then - Verify now pressed
        expect(receivedStatePressed ?? false) == true
    }

    func testQuickHideTriggerKeyStateTransitionFromPressedToReleased() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockGateway.emitQuickHideTriggerKeyPressState(true)
        let useCase = GetQuickHideTriggerKeyPressStateUseCase(keyboardShortcutsGateway: mockGateway)
        var receivedStateInitial: Bool?

        // When - Get initial state (pressed)
        useCase.execute()
            .sink { value in receivedStateInitial = value }
            .store(in: &cancellables)

        // Then - Verify initially pressed
        expect(receivedStateInitial ?? false) == true

        // When - Simulate key release
        mockGateway.emitQuickHideTriggerKeyPressState(false)
        cancellables.removeAll()
        var receivedStateReleased: Bool?
        useCase.execute()
            .sink { value in receivedStateReleased = value }
            .store(in: &cancellables)

        // Then - Verify now released
        expect(receivedStateReleased ?? true) == false
    }

    // MARK: - Publisher Emission Tests

    func testPublisherEmitsCorrectValues() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockGateway.emitQuickHideTriggerKeyPressState(false)
        let useCase = GetQuickHideTriggerKeyPressStateUseCase(keyboardShortcutsGateway: mockGateway)
        var emittedValues: [Bool] = []

        // When
        useCase.execute()
            .sink { value in emittedValues.append(value) }
            .store(in: &cancellables)

        // Then
        expect(emittedValues.count) == 1
        expect(emittedValues[0]) == false

        // When - Change state and re-subscribe
        mockGateway.emitQuickHideTriggerKeyPressState(true)
        cancellables.removeAll()
        var emittedValuesAfterChange: [Bool] = []
        useCase.execute()
            .sink { value in emittedValuesAfterChange.append(value) }
            .store(in: &cancellables)

        // Then
        expect(emittedValuesAfterChange.count) == 1
        expect(emittedValuesAfterChange[0]) == true
    }

    // MARK: - Edge Case Tests

    func testMultipleSubscriptionsReceiveSameValue() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockGateway.emitQuickHideTriggerKeyPressState(true)
        let useCase = GetQuickHideTriggerKeyPressStateUseCase(keyboardShortcutsGateway: mockGateway)

        var receivedValue1: Bool?
        var receivedValue2: Bool?
        var receivedValue3: Bool?

        // When - Subscribe multiple times
        useCase.execute()
            .sink { value in receivedValue1 = value }
            .store(in: &cancellables)

        useCase.execute()
            .sink { value in receivedValue2 = value }
            .store(in: &cancellables)

        useCase.execute()
            .sink { value in receivedValue3 = value }
            .store(in: &cancellables)

        // Then - All subscriptions should receive the same value
        expect(receivedValue1) == true
        expect(receivedValue2) == true
        expect(receivedValue3) == true
        expect(receivedValue1) == receivedValue2
        expect(receivedValue2) == receivedValue3
    }

    // MARK: - Integration Tests

    func testConsecutiveStateChanges() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let useCase = GetQuickHideTriggerKeyPressStateUseCase(keyboardShortcutsGateway: mockGateway)
        var stateHistory: [Bool] = []

        // When - Perform multiple state changes
        mockGateway.emitQuickHideTriggerKeyPressState(false)
        var receivedValue: Bool?
        useCase.execute()
            .sink { value in receivedValue = value }
            .store(in: &cancellables)
        stateHistory.append(receivedValue ?? false)

        // Simulate press
        mockGateway.emitQuickHideTriggerKeyPressState(true)
        cancellables.removeAll()
        useCase.execute()
            .sink { value in receivedValue = value }
            .store(in: &cancellables)
        stateHistory.append(receivedValue ?? false)

        // Simulate release
        mockGateway.emitQuickHideTriggerKeyPressState(false)
        cancellables.removeAll()
        useCase.execute()
            .sink { value in receivedValue = value }
            .store(in: &cancellables)
        stateHistory.append(receivedValue ?? false)

        // Then - Verify state history
        expect(stateHistory.count) == 3
        expect(stateHistory[0]) == false // Initial released state
        expect(stateHistory[1]) == true // After press
        expect(stateHistory[2]) == false // After release
    }
}
