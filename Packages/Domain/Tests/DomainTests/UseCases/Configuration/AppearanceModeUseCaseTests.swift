// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
@testable import Domain
import Nimble
import XCTest

/// Tests for appearance mode configuration use cases.
///
/// These tests verify:
/// - GetSpacesAppearanceModeUseCase
/// - SetSpacesAppearanceModeUseCase
/// - GetGroupsAppearanceModeUseCase
/// - SetGroupsAppearanceModeUseCase
/// - GetThemeModeUseCase
/// - SetThemeModeUseCase
@MainActor
final class AppearanceModeUseCaseTests: XCTestCase {
    private var mockGateway: MockConfigurationGateway?
    private var cancellables = Set<AnyCancellable>()

    override func setUp() async throws {
        try await super.setUp()
        mockGateway = MockConfigurationGateway()
    }

    // MARK: - SpacesAppearanceMode Tests

    func testGetSpacesAppearanceMode() {
        guard let mockGateway else { XCTFail("Mock gateway not initialized")
            return
        }

        // Given
        let useCase = GetSpacesAppearanceModeUseCase(configurationGateway: mockGateway)
        var receivedValue: SpacesAppearanceMode?

        // When
        useCase.execute()
            .sink { value in receivedValue = value }
            .store(in: &cancellables)

        // Then
        expect(receivedValue).toNot(beNil())
        expect(receivedValue) == mockGateway.spacesAppearanceModeToEmit
    }

    func testSetSpacesAppearanceMode() async {
        guard let mockGateway else { XCTFail("Mock gateway not initialized")
            return
        }

        // Given
        let useCase = SetSpacesAppearanceModeUseCase(configurationGateway: mockGateway)
        let newValue: SpacesAppearanceMode = .perSpace

        // When
        await useCase.execute(value: newValue)

        // Then
        expect(mockGateway.setSpacesAppearanceModeCalls.last) == newValue
    }

    // MARK: - GroupsAppearanceMode Tests

    func testGetGroupsAppearanceMode() {
        guard let mockGateway else { XCTFail("Mock gateway not initialized")
            return
        }

        // Given
        let useCase = GetGroupsAppearanceModeUseCase(configurationGateway: mockGateway)
        var receivedValue: GroupsAppearanceMode?

        // When
        useCase.execute()
            .sink { value in receivedValue = value }
            .store(in: &cancellables)

        // Then
        expect(receivedValue).toNot(beNil())
        expect(receivedValue) == mockGateway.groupsAppearanceModeToEmit
    }

    func testSetGroupsAppearanceMode() async {
        guard let mockGateway else { XCTFail("Mock gateway not initialized")
            return
        }

        // Given
        let useCase = SetGroupsAppearanceModeUseCase(configurationGateway: mockGateway)
        let newValue: GroupsAppearanceMode = .perGroup

        // When
        await useCase.execute(mode: newValue)

        // Then
        expect(mockGateway.setGroupsAppearanceModeCalls.last) == newValue
    }

    // MARK: - ThemeMode Tests

    func testGetThemeMode() {
        guard let mockGateway else { XCTFail("Mock gateway not initialized")
            return
        }

        // Given
        let useCase = GetThemeModeUseCase(configurationGateway: mockGateway)
        var receivedValue: ThemeMode?

        // When
        useCase.execute()
            .sink { value in receivedValue = value }
            .store(in: &cancellables)

        // Then
        expect(receivedValue).toNot(beNil())
        expect(receivedValue) == mockGateway.themeModeToEmit
    }

    func testSetThemeMode() async {
        guard let mockGateway else { XCTFail("Mock gateway not initialized")
            return
        }

        // Given
        let useCase = SetThemeModeUseCase(configurationGateway: mockGateway)
        let newValue: ThemeMode = .custom

        // When
        await useCase.execute(value: newValue)

        // Then
        expect(mockGateway.setThemeModeCalls.last) == newValue
    }
}
