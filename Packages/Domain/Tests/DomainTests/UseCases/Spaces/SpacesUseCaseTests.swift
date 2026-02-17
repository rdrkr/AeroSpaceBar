// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
@testable import Domain
import Nimble
import XCTest

/// Tests for Spaces UseCases.
///
/// These tests verify:
/// - GetSpacesUseCase
/// - GetAeroSpaceStatusUseCase
/// - SetFocusSpaceUseCase
/// - SetFocusWindowUseCase
/// - StartAeroSpaceUseCase
@MainActor
final class SpacesUseCaseTests: XCTestCase {
    private var mockGateway: MockSpacesGateway?
    private var cancellables: Set<AnyCancellable>?

    override func setUp() async throws {
        try await super.setUp()
        mockGateway = MockSpacesGateway()
        cancellables = []
    }

    // MARK: - GetSpacesUseCase Tests

    func testGetSpacesWithEmptyList() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockGateway.emitSpaces([])
        let useCase = GetSpacesUseCase(spacesGateway: mockGateway)
        var receivedSpaces: [Space]?

        // When
        useCase.execute()
            .sink { value in receivedSpaces = value }
            .store(in: &cancellables)

        // Then
        expect(receivedSpaces).toNot(beNil())
        expect(receivedSpaces?.isEmpty) == true
    }

    func testGetSpacesWithMultipleSpaces() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let space1 = Space(id: "1", isFocused: true)
        let space2 = Space(id: "2", isFocused: false)
        let space3 = Space(id: "3", isFocused: false)
        mockGateway.emitSpaces([space1, space2, space3])
        let useCase = GetSpacesUseCase(spacesGateway: mockGateway)
        var receivedSpaces: [Space]?

        // When
        useCase.execute()
            .sink { value in receivedSpaces = value }
            .store(in: &cancellables)

        // Then
        expect(receivedSpaces).toNot(beNil())
        expect(receivedSpaces?.count) == 3
        expect(receivedSpaces?[0].id) == "1"
        expect(receivedSpaces?[1].id) == "2"
        expect(receivedSpaces?[2].id) == "3"
        expect(receivedSpaces?[0].isFocused ?? false) == true
        expect(receivedSpaces?[1].isFocused ?? true) == false
    }

    // MARK: - GetAeroSpaceStatusUseCase Tests

    func testGetAeroSpaceStatusWhenRunning() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockGateway.setAeroSpaceRunning(true)
        let useCase = GetAeroSpaceStatusUseCase(spacesGateway: mockGateway)
        var receivedStatus: Bool?

        // When
        useCase.execute()
            .sink { value in receivedStatus = value }
            .store(in: &cancellables)

        // Then
        expect(receivedStatus).toNot(beNil())
        expect(receivedStatus ?? false) == true
    }

    func testGetAeroSpaceStatusWhenNotRunning() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockGateway.setAeroSpaceRunning(false)
        let useCase = GetAeroSpaceStatusUseCase(spacesGateway: mockGateway)
        var receivedStatus: Bool?

        // When
        useCase.execute()
            .sink { value in receivedStatus = value }
            .store(in: &cancellables)

        // Then
        expect(receivedStatus).toNot(beNil())
        expect(receivedStatus ?? true) == false
    }

    // MARK: - SetFocusSpaceUseCase Tests

    func testSetFocusSpaceSuccess() async throws {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let space1 = Space(id: "1", isFocused: true)
        let space2 = Space(id: "2", isFocused: false)
        mockGateway.emitSpaces([space1, space2])
        let useCase = SetFocusSpaceUseCase(spacesGateway: mockGateway)

        // When
        try await useCase.execute(spaceId: "2", needWindowFocus: false)

        // Then
        expect(mockGateway.spacesToEmit[0].isFocused) == false
        expect(mockGateway.spacesToEmit[1].isFocused) == true
    }

    func testSetFocusSpaceWithWindowFocus() async throws {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let space1 = Space(id: "1", isFocused: true)
        let space2 = Space(id: "2", isFocused: false)
        mockGateway.emitSpaces([space1, space2])
        let useCase = SetFocusSpaceUseCase(spacesGateway: mockGateway)

        // When
        try await useCase.execute(spaceId: "2", needWindowFocus: true)

        // Then
        expect(mockGateway.spacesToEmit[0].isFocused) == false
        expect(mockGateway.spacesToEmit[1].isFocused) == true
    }

    func testSetFocusSpaceWithError() async {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockGateway.shouldThrowOnFocus = true
        let useCase = SetFocusSpaceUseCase(spacesGateway: mockGateway)

        // When & Then
        do {
            try await useCase.execute(spaceId: "1", needWindowFocus: false)
            XCTFail("Expected AppError to be thrown")
        } catch let error as AppError {
            expect(error).toNot(beNil())
        } catch {
            XCTFail("Unexpected error type: \(type(of: error))")
        }
    }

    // MARK: - SetFocusWindowUseCase Tests

    func testSetFocusWindowSuccess() async throws {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let window1 = Window(id: 1_001, title: "Window 1", appName: "App1", isFocused: false, workspace: "1")
        let window2 = Window(id: 1_002, title: "Window 2", appName: "App2", isFocused: false, workspace: "1")
        let space = Space(id: "1", isFocused: true, windows: [window1, window2])
        mockGateway.emitSpaces([space])
        let useCase = SetFocusWindowUseCase(spacesGateway: mockGateway)

        // When
        try await useCase.execute(windowId: String(window2.id))

        // Then
        expect(mockGateway.spacesToEmit[0].windows[0].isFocused) == false
        expect(mockGateway.spacesToEmit[0].windows[1].isFocused) == true
    }

    func testSetFocusWindowWithError() async {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockGateway.shouldThrowOnFocus = true
        let useCase = SetFocusWindowUseCase(spacesGateway: mockGateway)

        // When & Then
        do {
            try await useCase.execute(windowId: "w1")
            XCTFail("Expected AppError to be thrown")
        } catch let error as AppError {
            expect(error).toNot(beNil())
        } catch {
            XCTFail("Unexpected error type: \(type(of: error))")
        }
    }

    // MARK: - StartAeroSpaceUseCase Tests

    func testStartAeroSpaceSuccess() async throws {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockGateway.setAeroSpaceRunning(false)
        let useCase = StartAeroSpaceUseCase(spacesGateway: mockGateway)

        // When
        try await useCase.execute()

        // Then
        expect(mockGateway.isAeroSpaceRunning) == true
    }

    func testStartAeroSpaceWhenAlreadyRunning() async throws {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockGateway.setAeroSpaceRunning(true)
        let useCase = StartAeroSpaceUseCase(spacesGateway: mockGateway)

        // When
        try await useCase.execute()

        // Then
        expect(mockGateway.isAeroSpaceRunning) == true
    }

    func testStartAeroSpaceWithError() async {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockGateway.shouldThrowOnStartAeroSpace = true
        let useCase = StartAeroSpaceUseCase(spacesGateway: mockGateway)

        // When & Then
        do {
            try await useCase.execute()
            XCTFail("Expected AppError to be thrown")
        } catch let error as AppError {
            expect(error).toNot(beNil())
        } catch {
            XCTFail("Unexpected error type: \(type(of: error))")
        }
    }

    // MARK: - Integration Tests

    func testFocusSpaceAndWindowSequence() async throws {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let window1 = Window(id: 1_001, title: "Window 1", appName: "App1", isFocused: false, workspace: "1")
        let window2 = Window(id: 1_002, title: "Window 2", appName: "App2", isFocused: false, workspace: "2")
        let space1 = Space(id: "1", isFocused: true, windows: [window1])
        let space2 = Space(id: "2", isFocused: false, windows: [window2])
        mockGateway.emitSpaces([space1, space2])

        let focusSpaceUseCase = SetFocusSpaceUseCase(spacesGateway: mockGateway)
        let focusWindowUseCase = SetFocusWindowUseCase(spacesGateway: mockGateway)

        // When - Focus space 2
        try await focusSpaceUseCase.execute(spaceId: "2")

        // Then - Verify space 2 is focused
        expect(mockGateway.spacesToEmit[0].isFocused) == false
        expect(mockGateway.spacesToEmit[1].isFocused) == true

        // When - Focus window in space 2
        try await focusWindowUseCase.execute(windowId: String(window2.id))

        // Then - Verify window 2 is focused
        expect(mockGateway.spacesToEmit[1].windows[0].isFocused) == true
    }

    func testMultiplePublisherSubscriptions() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let space1 = Space(id: "1", isFocused: true)
        let space2 = Space(id: "2", isFocused: false)
        mockGateway.emitSpaces([space1, space2])
        mockGateway.setAeroSpaceRunning(true)

        let getSpacesUseCase = GetSpacesUseCase(spacesGateway: mockGateway)
        let getStatusUseCase = GetAeroSpaceStatusUseCase(spacesGateway: mockGateway)

        var receivedSpaces: [Space]?
        var receivedStatus: Bool?

        // When
        getSpacesUseCase.execute()
            .sink { value in receivedSpaces = value }
            .store(in: &cancellables)

        getStatusUseCase.execute()
            .sink { value in receivedStatus = value }
            .store(in: &cancellables)

        // Then
        expect(receivedSpaces?.count) == 2
        expect(receivedStatus ?? false) == true
    }

    func testDefaultFocusWindowBehavior() async throws {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let window1 = Window(id: 1_001, title: "Window 1", appName: "App1", isFocused: false, workspace: "1")
        let space = Space(id: "1", isFocused: true, windows: [window1])
        mockGateway.emitSpaces([space])
        let useCase = SetFocusSpaceUseCase(spacesGateway: mockGateway)

        // When - Call with default needWindowFocus parameter (false)
        try await useCase.execute(spaceId: "1")

        // Then - Space should still be focused
        expect(mockGateway.spacesToEmit[0].isFocused) == true
    }
}
