// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
@testable import Domain
import Nimble
import XCTest

@MainActor
final class SpacesGatewayTests: XCTestCase {
    private var mockGateway: MockSpacesGateway?
    private var cancellables: Set<AnyCancellable>?

    override func setUp() async throws {
        try await super.setUp()
        mockGateway = MockSpacesGateway()
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() async throws {
        cancellables?.removeAll()
        mockGateway = nil
        try await super.tearDown()
    }

    func testSpacesWithWindowsPublisher() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given expectation
        let expectation = expectation(description: "Spaces received")
        var receivedSpaces: [Space]?

        // When subscribing to publisher
        mockGateway.spacesWithWindowsPublisher
            .dropFirst()
            .sink { spaces in
                receivedSpaces = spaces
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // And emitting test data
        let testSpace = Space(id: "1", isFocused: true)
        mockGateway.emitSpaces([testSpace])

        // Then should receive spaces
        wait(for: [expectation], timeout: 1.0)
        expect(receivedSpaces).toNot(beNil())
        expect(receivedSpaces?.count) == 1
        expect(receivedSpaces?.first?.id) == "1"
    }

    func testAeroSpaceRunningPublisher() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given expectation
        let expectation = expectation(description: "Running status received")
        expectation.expectedFulfillmentCount = 2
        var receivedStatuses: [Bool] = []

        // When subscribing to publisher
        mockGateway.aeroSpaceRunningPublisher
            .sink { isRunning in
                receivedStatuses.append(isRunning)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // And updating running status
        mockGateway.setAeroSpaceRunning(false)

        // Then should receive both statuses
        wait(for: [expectation], timeout: 1.0)
        expect(receivedStatuses.count) == 2
        expect(receivedStatuses[0]) == true
        expect(receivedStatuses[1]) == false
    }

    func testFocusSpace() throws {
        guard let mockGateway else {
            fail("Mock gateway not initialized")
            return
        }

        // Test successful focus
        try mockGateway.focusSpace(spaceId: "1", needWindowFocus: true)

        expect(mockGateway.focusSpaceCalls.count) == 1
        expect(mockGateway.focusSpaceCalls.first?.spaceId) == "1"
        expect(mockGateway.focusSpaceCalls.first?.needWindowFocus) == true

        // Test error handling
        mockGateway.focusSpaceError = .commandExecutionError("Test error")
        expect {
            try mockGateway.focusSpace(spaceId: "2", needWindowFocus: false)
        }.to(throwError())

        expect(mockGateway.focusSpaceCalls.count) == 2
    }

    func testFocusWindow() throws {
        guard let mockGateway else {
            fail("Mock gateway not initialized")
            return
        }

        // Test successful focus
        try mockGateway.focusWindow(windowId: "123")

        expect(mockGateway.focusWindowCalls.count) == 1
        expect(mockGateway.focusWindowCalls.first) == "123"

        // Test error handling
        mockGateway.focusWindowError = .commandExecutionError("Test error")
        expect {
            try mockGateway.focusWindow(windowId: "456")
        }.to(throwError())

        expect(mockGateway.focusWindowCalls.count) == 2
    }

    func testStartAeroSpace() throws {
        guard let mockGateway else {
            fail("Mock gateway not initialized")
            return
        }

        // Test successful start
        try mockGateway.startAeroSpace()

        expect(mockGateway.startAeroSpaceCallCount) == 1

        // Test error handling
        mockGateway.startAeroSpaceError = .aeroSpaceNotRunning
        do {
            try mockGateway.startAeroSpace()
            fail("Should have thrown an error")
        } catch let error as AppError {
            expect(error) == .aeroSpaceNotRunning
        }

        expect(mockGateway.startAeroSpaceCallCount) == 2
    }
}
