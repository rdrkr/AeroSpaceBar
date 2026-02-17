// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
@testable import Domain
import Nimble
import XCTest

/// Tests for basic settings use cases.
///
/// These tests verify:
/// - GetShowEmptySpacesUseCase
/// - SetShowEmptySpacesUseCase
/// - GetShowWindowTitlesUseCase
/// - SetShowWindowTitlesUseCase
/// - GetShowGroupsUseCase
/// - SetShowGroupsUseCase
/// - GetFocusWindowOnClickUseCase
/// - SetFocusWindowOnClickUseCase
@MainActor
final class BasicSettingsUseCaseTests: XCTestCase {
    private var mockGateway: MockConfigurationGateway?
    private var cancellables = Set<AnyCancellable>()

    override func setUp() async throws {
        try await super.setUp()
        mockGateway = MockConfigurationGateway()
    }

    // MARK: - ShowEmptySpaces Tests

    func testGetShowEmptySpaces() {
        guard let mockGateway else { XCTFail("Mock gateway not initialized")
            return
        }

        // Given
        let useCase = GetShowEmptySpacesUseCase(configurationGateway: mockGateway)
        var receivedValue: Bool?

        // When
        useCase.execute()
            .sink { value in receivedValue = value }
            .store(in: &cancellables)

        // Then
        expect(receivedValue).toNot(beNil())
        expect(receivedValue) == mockGateway.showEmptySpacesToEmit
    }

    func testSetShowEmptySpaces() async {
        guard let mockGateway else { XCTFail("Mock gateway not initialized")
            return
        }

        // Given
        let useCase = SetShowEmptySpacesUseCase(configurationGateway: mockGateway)
        let newValue = true

        // When
        await useCase.execute(value: newValue)

        // Then
        expect(mockGateway.setShowEmptySpacesCalls.last) == newValue
    }

    // MARK: - ShowWindowTitles Tests

    func testGetShowWindowTitles() {
        guard let mockGateway else { XCTFail("Mock gateway not initialized")
            return
        }

        // Given
        let useCase = GetShowWindowTitlesUseCase(configurationGateway: mockGateway)
        var receivedValue: Bool?

        // When
        useCase.execute()
            .sink { value in receivedValue = value }
            .store(in: &cancellables)

        // Then
        expect(receivedValue).toNot(beNil())
        expect(receivedValue) == mockGateway.showWindowTitlesToEmit
    }

    func testSetShowWindowTitles() async {
        guard let mockGateway else { XCTFail("Mock gateway not initialized")
            return
        }

        // Given
        let useCase = SetShowWindowTitlesUseCase(configurationGateway: mockGateway)
        let newValue = true

        // When
        await useCase.execute(value: newValue)

        // Then
        expect(mockGateway.setShowWindowTitlesCalls.last) == newValue
    }

    // MARK: - ShowGroups Tests

    func testGetShowGroups() {
        guard let mockGateway else { XCTFail("Mock gateway not initialized")
            return
        }

        // Given
        let useCase = GetShowGroupsUseCase(configurationGateway: mockGateway)
        var receivedValue: Bool?

        // When
        useCase.execute()
            .sink { value in receivedValue = value }
            .store(in: &cancellables)

        // Then
        expect(receivedValue).toNot(beNil())
        expect(receivedValue) == mockGateway.showGroupsToEmit
    }

    func testSetShowGroups() async {
        guard let mockGateway else { XCTFail("Mock gateway not initialized")
            return
        }

        // Given
        let useCase = SetShowGroupsUseCase(configurationGateway: mockGateway)
        let newValue = true

        // When
        await useCase.execute(value: newValue)

        // Then
        expect(mockGateway.setShowGroupsCalls.last) == newValue
    }

    // MARK: - FocusWindowOnClick Tests

    func testGetFocusWindowOnClick() {
        guard let mockGateway else { XCTFail("Mock gateway not initialized")
            return
        }

        // Given
        let useCase = GetFocusWindowOnClickUseCase(configurationGateway: mockGateway)
        var receivedValue: Bool?

        // When
        useCase.execute()
            .sink { value in receivedValue = value }
            .store(in: &cancellables)

        // Then
        expect(receivedValue).toNot(beNil())
        expect(receivedValue) == mockGateway.focusWindowOnClickToEmit
    }

    func testSetFocusWindowOnClick() async {
        guard let mockGateway else { XCTFail("Mock gateway not initialized")
            return
        }

        // Given
        let useCase = SetFocusWindowOnClickUseCase(configurationGateway: mockGateway)
        let newValue = true

        // When
        await useCase.execute(enabled: newValue)

        // Then
        expect(mockGateway.setFocusWindowOnClickCalls.last) == newValue
    }
}
