// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
@testable import Domain
import Nimble
import XCTest

/// Tests for KeyboardShortcutsGateway protocol.
///
/// These tests verify:
/// - Protocol conformance
/// - Publisher requirements
/// - Quick Hide trigger key press state monitoring
/// - Mock implementation behavior
@MainActor
final class KeyboardShortcutsGatewayTests: XCTestCase {
    private var sut: MockKeyboardShortcutsGateway?
    private var cancellables: Set<AnyCancellable> = []

    override func setUp() async throws {
        try await super.setUp()
        sut = MockKeyboardShortcutsGateway()
        cancellables = []
    }

    override func tearDown() async throws {
        cancellables.removeAll()
        sut = nil
        try await super.tearDown()
    }

    // MARK: - Publisher Tests

    func testQuickHideTriggerKeyPressStatePublisher() async {
        guard let sut else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let expectation = expectation(description: "Publisher emits trigger key state")
        var receivedState: Bool?

        // When
        sut.quickHideTriggerKeyPressStatePublisher
            .sink { state in
                receivedState = state
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        expect(receivedState).toNot(beNil())
        expect(receivedState) == false // Default state
    }

    func testTriggerKeyPressed() async {
        guard let sut else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let expectation = expectation(description: "Trigger key pressed state")
        var receivedStates: [Bool] = []

        sut.quickHideTriggerKeyPressStatePublisher
            .sink { state in
                receivedStates.append(state)
                if receivedStates.count == 2 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        sut.emitQuickHideTriggerKeyPressState(true)

        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        expect(receivedStates) == [false, true]
    }

    func testTriggerKeyReleased() async {
        guard let sut else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        sut.emitQuickHideTriggerKeyPressState(true)

        let expectation = expectation(description: "Trigger key released state")
        var receivedState: Bool?

        sut.quickHideTriggerKeyPressStatePublisher
            .dropFirst() // Skip current pressed state
            .sink { state in
                receivedState = state
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // When
        sut.emitQuickHideTriggerKeyPressState(false)

        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        expect(receivedState) == false
    }

    func testMultipleKeyPressReleases() async {
        guard let sut else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let expectation = expectation(description: "Multiple key press/release events")
        var receivedStates: [Bool] = []

        sut.quickHideTriggerKeyPressStatePublisher
            .sink { state in
                receivedStates.append(state)
                if receivedStates.count == 5 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        sut.emitQuickHideTriggerKeyPressState(true) // Press
        sut.emitQuickHideTriggerKeyPressState(false) // Release
        sut.emitQuickHideTriggerKeyPressState(true) // Press
        sut.emitQuickHideTriggerKeyPressState(false) // Release

        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        expect(receivedStates) == [false, true, false, true, false]
    }

    // MARK: - Protocol Conformance Tests

    func testProtocolConformance() {
        // Given
        guard let sut else {
            XCTFail("MockKeyboardShortcutsGateway should be initialized")
            return
        }

        let gateway: any KeyboardShortcutsGateway = sut

        // When/Then - Should compile and not crash
        expect(gateway.quickHideTriggerKeyPressStatePublisher).toNot(beNil())
    }
}
