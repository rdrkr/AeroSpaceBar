// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Nimble
import XCTest

/// Tests for SetFocusSpaceUseCase.
///
/// These tests validate space focusing functionality - core to AeroSpace integration.
@MainActor
final class SetFocusSpaceUseCaseTests: XCTestCase {
    private var sut: SetFocusSpaceUseCase?
    private var mockGateway: MockSpacesGateway?

    override func setUp() async throws {
        try await super.setUp()
        let gateway = MockSpacesGateway()
        mockGateway = gateway
        sut = SetFocusSpaceUseCase(spacesGateway: gateway)
    }

    // MARK: - Basic Functionality Tests

    func testExecuteCallsGatewayWithSpaceId() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given a space ID
        let spaceId = "workspace-1"

        // When executing the use case
        try await sut.execute(spaceId: spaceId, needWindowFocus: false)

        // Then should call gateway with correct parameters
        expect(mockGateway.focusSpaceCalls.count) == 1
        expect(mockGateway.focusSpaceCalls.first?.spaceId) == spaceId
        expect(mockGateway.focusSpaceCalls.first?.needWindowFocus) == false
    }

    func testExecuteWithNeedWindowFocusTrue() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given a space ID and window focus flag
        let spaceId = "workspace-2"

        // When executing with needWindowFocus = true
        try await sut.execute(spaceId: spaceId, needWindowFocus: true)

        // Then should pass the flag to gateway
        expect(mockGateway.focusSpaceCalls.count) == 1
        expect(mockGateway.focusSpaceCalls.first?.spaceId) == spaceId
        expect(mockGateway.focusSpaceCalls.first?.needWindowFocus) == true
    }

    func testExecuteWithDefaultNeedWindowFocus() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given a space ID
        let spaceId = "workspace-3"

        // When executing without specifying needWindowFocus (uses default)
        try await sut.execute(spaceId: spaceId)

        // Then should use default value (false)
        expect(mockGateway.focusSpaceCalls.count) == 1
        expect(mockGateway.focusSpaceCalls.first?.needWindowFocus) == false
    }

    // MARK: - Error Handling Tests

    func testExecuteThrowsWhenGatewayThrows() async {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given gateway will throw error
        mockGateway.focusSpaceError = AppError.aeroSpaceNotRunning

        // When executing use case
        do {
            try await sut.execute(spaceId: "workspace-1")
            XCTFail("Should have thrown error")
        } catch {
            // Then should propagate the error
            expect(error is AppError) == true
            if let appError = error as? AppError {
                expect(appError) == .aeroSpaceNotRunning
            }
        }
    }

    func testExecuteThrowsCommandExecutionError() async {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given command execution error
        mockGateway.focusSpaceError = AppError.commandExecutionError("Failed to focus space")

        // When executing
        do {
            try await sut.execute(spaceId: "workspace-1")
            XCTFail("Should throw command execution error")
        } catch let error as AppError {
            // Then should be command execution error
            if case let .commandExecutionError(message) = error {
                expect(message) == "Failed to focus space"
            } else {
                XCTFail("Should be commandExecutionError case")
            }
        } catch {
            XCTFail("Should throw AppError")
        }
    }

    func testExecuteThrowsServiceUnavailableError() async {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given service unavailable error
        mockGateway.focusSpaceError = AppError.serviceUnavailable

        // When executing
        do {
            try await sut.execute(spaceId: "workspace-1")
            XCTFail("Should throw service unavailable error")
        } catch let error as AppError {
            // Then should be service unavailable error
            expect(error) == .serviceUnavailable
        } catch {
            XCTFail("Should throw AppError")
        }
    }

    // MARK: - Edge Cases

    func testExecuteWithEmptySpaceId() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given empty space ID
        let spaceId = ""

        // When executing
        try await sut.execute(spaceId: spaceId)

        // Then should pass it to gateway (validation happens in gateway/repository)
        expect(mockGateway.focusSpaceCalls.count) == 1
        expect(mockGateway.focusSpaceCalls.first?.spaceId.isEmpty) == true
    }

    func testExecuteWithNumericSpaceId() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given numeric space ID (common in AeroSpace)
        let spaceId = "1"

        // When executing
        try await sut.execute(spaceId: spaceId)

        // Then should handle numeric IDs
        expect(mockGateway.focusSpaceCalls.first?.spaceId) == "1"
    }

    func testExecuteWithLongSpaceId() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given a very long space ID
        let longId = String(repeating: "workspace-", count: 50)

        // When executing
        try await sut.execute(spaceId: longId)

        // Then should pass it to gateway
        expect(mockGateway.focusSpaceCalls.first?.spaceId) == longId
    }

    func testExecuteWithSpecialCharactersInSpaceId() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given space ID with special characters
        let specialId = "space-🚀-@#$%-test"

        // When executing
        try await sut.execute(spaceId: specialId)

        // Then should handle special characters
        expect(mockGateway.focusSpaceCalls.first?.spaceId) == specialId
    }

    // MARK: - Multiple Execution Tests

    func testMultipleExecutionsCallGatewayEachTime() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given multiple space IDs
        let spaceIds = ["1", "2", "3"]

        // When executing multiple times
        for spaceId in spaceIds {
            try await sut.execute(spaceId: spaceId)
        }

        // Then should call gateway for each
        expect(mockGateway.focusSpaceCalls.count) == 3
        expect(mockGateway.focusSpaceCalls.map(\.spaceId)) == spaceIds
    }

    func testAlternatingNeedWindowFocusFlag() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given alternating needWindowFocus values
        try await sut.execute(spaceId: "1", needWindowFocus: true)
        try await sut.execute(spaceId: "2", needWindowFocus: false)
        try await sut.execute(spaceId: "3", needWindowFocus: true)

        // Then should respect each value
        expect(mockGateway.focusSpaceCalls.count) == 3
        expect(mockGateway.focusSpaceCalls[0].needWindowFocus) == true
        expect(mockGateway.focusSpaceCalls[1].needWindowFocus) == false
        expect(mockGateway.focusSpaceCalls[2].needWindowFocus) == true
    }

    // MARK: - Async Behavior Tests

    func testExecuteIsProperlyAsync() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given a space to focus
        let spaceId = "async-space"

        // When executing asynchronously
        let task = Task {
            try await sut.execute(spaceId: spaceId)
        }

        // Then should complete asynchronously
        try await task.value
        expect(mockGateway.focusSpaceCalls.count) == 1
    }

    func testMultipleConcurrentExecutions() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given multiple concurrent focus requests
        // When executing concurrently
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask { try await sut.execute(spaceId: "1") }
            group.addTask { try await sut.execute(spaceId: "2") }
            group.addTask { try await sut.execute(spaceId: "3") }

            // Collect all results
            for try await _ in group { }
        }
        expect(mockGateway.focusSpaceCalls.count) == 3
    }

    // MARK: - Integration with Fixtures

    func testFocusSpaceFromFixtures() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given fixture spaces
        let fixtures = SpaceFixtures.array(count: 5)

        // When focusing each fixture space
        for space in fixtures {
            mockGateway.reset()
            try await sut.execute(spaceId: space.id)

            // Then should call gateway with fixture ID
            expect(mockGateway.focusSpaceCalls.first?.spaceId) == space.id
        }
    }

    func testFocusCurrentlyFocusedSpace() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given a space that is already focused
        let focusedSpace = SpaceFixtures.focused

        // When trying to focus it again
        try await sut.execute(spaceId: focusedSpace.id)

        // Then should still call gateway (idempotent operation)
        expect(mockGateway.focusSpaceCalls.count) == 1
        expect(mockGateway.focusSpaceCalls.first?.spaceId) == focusedSpace.id
    }

    // MARK: - State Verification Tests

    func testGatewayNotCalledBeforeExecution() {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given newly initialized use case
        // Then gateway should not have been called yet
        expect(mockGateway.focusSpaceCalls.isEmpty) == true
    }

    func testExecutionDoesNotModifyUseCase() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given use case
        // When executing
        try await sut.execute(spaceId: "test")

        // Then should be able to execute again (stateless)
        try await sut.execute(spaceId: "test2")
        expect(mockGateway.focusSpaceCalls.count) == 2
    }

    // MARK: - Parameter Validation Tests

    func testBothParametersPassedCorrectly() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given specific parameters
        let spaceId = "workspace-test"
        let needWindowFocus = true

        // When executing with both parameters
        try await sut.execute(spaceId: spaceId, needWindowFocus: needWindowFocus)

        // Then both should be passed to gateway
        expect(mockGateway.focusSpaceCalls.count) == 1
        let call = mockGateway.focusSpaceCalls.first
        expect(call?.spaceId) == spaceId
        expect(call?.needWindowFocus) == needWindowFocus
    }
}
