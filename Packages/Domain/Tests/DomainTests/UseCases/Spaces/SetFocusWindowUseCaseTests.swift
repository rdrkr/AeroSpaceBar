// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Nimble
import XCTest

/// Tests for SetFocusWindowUseCase.
///
/// These tests validate window focusing functionality - core to AeroSpace integration.
@MainActor
final class SetFocusWindowUseCaseTests: XCTestCase {
    private var sut: SetFocusWindowUseCase?
    private var mockGateway: MockSpacesGateway?

    override func setUp() async throws {
        try await super.setUp()
        let gateway = MockSpacesGateway()
        mockGateway = gateway
        sut = SetFocusWindowUseCase(spacesGateway: gateway)
    }

    // MARK: - Basic Functionality Tests

    func testExecuteCallsGatewayWithWindowId() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given a window ID
        let windowId = "window-123"

        // When executing the use case
        try await sut.execute(windowId: windowId)

        // Then should call gateway with correct window ID
        expect(mockGateway.focusWindowCalls.count) == 1
        expect(mockGateway.focusWindowCalls.first) == windowId
    }

    func testExecuteCallsGatewayMultipleTimes() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given multiple window IDs
        let windowIds = ["window-1", "window-2", "window-3"]

        // When executing for each window
        for windowId in windowIds {
            try await sut.execute(windowId: windowId)
        }

        // Then should call gateway for each
        expect(mockGateway.focusWindowCalls.count) == 3
        expect(mockGateway.focusWindowCalls) == windowIds
    }

    // MARK: - Error Handling Tests

    func testExecuteThrowsWhenGatewayThrows() async {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given gateway will throw error
        mockGateway.focusWindowError = AppError.aeroSpaceNotRunning

        // When executing use case
        do {
            try await sut.execute(windowId: "window-1")
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
        mockGateway.focusWindowError = AppError.commandExecutionError("Failed to focus window")

        // When executing
        do {
            try await sut.execute(windowId: "window-1")
            XCTFail("Should throw command execution error")
        } catch let error as AppError {
            // Then should be command execution error
            if case let .commandExecutionError(message) = error {
                expect(message) == "Failed to focus window"
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
        mockGateway.focusWindowError = AppError.serviceUnavailable

        // When executing
        do {
            try await sut.execute(windowId: "window-1")
            XCTFail("Should throw service unavailable error")
        } catch let error as AppError {
            // Then should be service unavailable error
            expect(error) == .serviceUnavailable
        } catch {
            XCTFail("Should throw AppError")
        }
    }

    func testExecuteThrowsDataFetchError() async {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given data fetch error
        mockGateway.focusWindowError = AppError.dataFetchError("Window not found")

        // When executing
        do {
            try await sut.execute(windowId: "nonexistent-window")
            XCTFail("Should throw data fetch error")
        } catch let error as AppError {
            // Then should be data fetch error
            if case let .dataFetchError(message) = error {
                expect(message) == "Window not found"
            } else {
                XCTFail("Should be dataFetchError case")
            }
        } catch {
            XCTFail("Should throw AppError")
        }
    }

    // MARK: - Edge Cases

    func testExecuteWithEmptyWindowId() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given empty window ID
        let windowId = ""

        // When executing
        try await sut.execute(windowId: windowId)

        // Then should pass it to gateway (validation happens in gateway/repository)
        expect(mockGateway.focusWindowCalls.count) == 1
        expect(mockGateway.focusWindowCalls.first?.isEmpty) == true
    }

    func testExecuteWithNumericWindowId() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given numeric window ID
        let windowId = "12345"

        // When executing
        try await sut.execute(windowId: windowId)

        // Then should handle numeric IDs
        expect(mockGateway.focusWindowCalls.first) == "12345"
    }

    func testExecuteWithLongWindowId() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given a very long window ID
        let longId = String(repeating: "window-id-", count: 50)

        // When executing
        try await sut.execute(windowId: longId)

        // Then should pass it to gateway
        expect(mockGateway.focusWindowCalls.first) == longId
    }

    func testExecuteWithSpecialCharactersInWindowId() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given window ID with special characters
        let specialId = "window-🪟-@#$%-test"

        // When executing
        try await sut.execute(windowId: specialId)

        // Then should handle special characters
        expect(mockGateway.focusWindowCalls.first) == specialId
    }

    func testExecuteWithUUIDWindowId() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given UUID-style window ID
        let uuid = "550e8400-e29b-41d4-a716-446655440000"

        // When executing
        try await sut.execute(windowId: uuid)

        // Then should handle UUID format
        expect(mockGateway.focusWindowCalls.first) == uuid
    }

    // MARK: - Integration with Fixtures

    func testFocusWindowsFromFixtures() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given fixture windows
        let windows = [
            WindowFixtures.safari,
            WindowFixtures.vscode,
            WindowFixtures.terminal,
            WindowFixtures.slack
        ]

        // When focusing each fixture window
        for window in windows {
            mockGateway.reset()
            try await sut.execute(windowId: String(window.id))

            // Then should call gateway with fixture window ID
            expect(mockGateway.focusWindowCalls.first) == String(window.id)
        }
    }

    func testFocusMinimizedWindow() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given a minimized window
        let minimizedWindow = WindowFixtures.minimized

        // When focusing it
        try await sut.execute(windowId: String(minimizedWindow.id))

        // Then should call gateway (actual behavior handled by AeroSpace)
        expect(mockGateway.focusWindowCalls.count) == 1
        expect(mockGateway.focusWindowCalls.first) == String(minimizedWindow.id)
    }

    func testFocusFloatingWindow() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given a floating window
        let floatingWindow = WindowFixtures.floating

        // When focusing it
        try await sut.execute(windowId: String(floatingWindow.id))

        // Then should call gateway
        expect(mockGateway.focusWindowCalls.first) == String(floatingWindow.id)
    }

    // MARK: - Async Behavior Tests

    func testExecuteIsProperlyAsync() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given a window to focus
        let windowId = "async-window"

        // When executing asynchronously
        let task = Task {
            try await sut.execute(windowId: windowId)
        }

        // Then should complete asynchronously
        try await task.value
        expect(mockGateway.focusWindowCalls.count) == 1
    }

    func testMultipleConcurrentExecutions() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given multiple concurrent focus requests
        // When executing concurrently
        async let result1: Void = sut.execute(windowId: "window-1")
        async let result2: Void = sut.execute(windowId: "window-2")
        async let result3: Void = sut.execute(windowId: "window-3")

        // Then all should complete
        _ = try await [result1, result2, result3]
        expect(mockGateway.focusWindowCalls.count) == 3
    }

    func testConcurrentExecutionsWithErrors() async {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given some executions will fail
        mockGateway.focusWindowError = AppError.aeroSpaceNotRunning

        // When executing concurrently
        let task1 = Task { try await sut.execute(windowId: "window-1") }
        let task2 = Task { try await sut.execute(windowId: "window-2") }

        // Then all should throw
        do {
            _ = try await task1.value
            XCTFail("Should have thrown")
        } catch {
            expect(error is AppError) == true
        }

        do {
            _ = try await task2.value
            XCTFail("Should have thrown")
        } catch {
            expect(error is AppError) == true
        }
    }

    // MARK: - State Verification Tests

    func testGatewayNotCalledBeforeExecution() {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given newly initialized use case
        // Then gateway should not have been called yet
        expect(mockGateway.focusWindowCalls.isEmpty) == true
    }

    func testExecutionDoesNotModifyUseCase() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given use case
        // When executing multiple times
        try await sut.execute(windowId: "window-1")
        try await sut.execute(windowId: "window-2")

        // Then should be stateless and reusable
        expect(mockGateway.focusWindowCalls.count) == 2
    }

    func testSameWindowMultipleFocuses() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given a window ID
        let windowId = "same-window"

        // When focusing it multiple times
        try await sut.execute(windowId: windowId)
        try await sut.execute(windowId: windowId)
        try await sut.execute(windowId: windowId)

        // Then all calls should go through (idempotent operation)
        expect(mockGateway.focusWindowCalls.count) == 3
        expect(mockGateway.focusWindowCalls.allSatisfy { $0 == windowId }) == true
    }

    // MARK: - Integration Tests

    func testFocusWindowInSpace() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given a space with windows
        let space = SpaceFixtures.withWindows
        guard let window = space.windows.first else {
            fail("No windows in test fixture")
            return
        }

        // When focusing the window
        try await sut.execute(windowId: String(window.id))

        // Then should call gateway with window ID
        expect(mockGateway.focusWindowCalls.first) == String(window.id)
    }

    func testFocusWindowsSequentially() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given a sequence of windows
        let space = SpaceFixtures.withWindows
        let windows = space.windows

        // When focusing them in sequence
        for window in windows {
            try await sut.execute(windowId: String(window.id))
        }

        // Then all should be focused in order
        expect(mockGateway.focusWindowCalls.count) == windows.count
        expect(mockGateway.focusWindowCalls) == windows.map { String($0.id) }
    }

    // MARK: - Performance Tests

    func testRapidSequentialFocusing() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given rapid window switching
        let windowIds = (1 ... 100).map { "window-\($0)" }

        // When focusing rapidly
        for windowId in windowIds {
            try await sut.execute(windowId: windowId)
        }

        // Then all should be processed
        expect(mockGateway.focusWindowCalls.count) == 100
    }
}
