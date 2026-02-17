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
/// - Globe key press state monitoring
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

    func testGlobeKeyPressStatePublisher() async {
        guard let sut else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let expectation = expectation(description: "Publisher emits globe key state")
        var receivedState: Bool?

        // When
        sut.globeKeyPressStatePublisher
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

    func testGlobeKeyPressed() async {
        guard let sut else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let expectation = expectation(description: "Globe key pressed state")
        var receivedStates: [Bool] = []

        sut.globeKeyPressStatePublisher
            .sink { state in
                receivedStates.append(state)
                if receivedStates.count == 2 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        sut.emitGlobeKeyPressState(true)

        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        expect(receivedStates) == [false, true]
    }

    func testGlobeKeyReleased() async {
        guard let sut else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        sut.emitGlobeKeyPressState(true)

        let expectation = expectation(description: "Globe key released state")
        var receivedState: Bool?

        sut.globeKeyPressStatePublisher
            .dropFirst() // Skip current pressed state
            .sink { state in
                receivedState = state
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // When
        sut.emitGlobeKeyPressState(false)

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

        sut.globeKeyPressStatePublisher
            .sink { state in
                receivedStates.append(state)
                if receivedStates.count == 5 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        sut.emitGlobeKeyPressState(true) // Press
        sut.emitGlobeKeyPressState(false) // Release
        sut.emitGlobeKeyPressState(true) // Press
        sut.emitGlobeKeyPressState(false) // Release

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
        expect(gateway.globeKeyPressStatePublisher).toNot(beNil())
    }
}
