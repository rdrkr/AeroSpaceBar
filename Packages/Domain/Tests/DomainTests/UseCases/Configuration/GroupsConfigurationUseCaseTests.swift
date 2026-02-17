// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
@testable import Domain
import Nimble
import XCTest

/// Tests for Groups configuration use cases.
///
/// These tests verify:
/// - GetGroupsUseCase
/// - SetGroupsUseCase
@MainActor
final class GroupsConfigurationUseCaseTests: XCTestCase {
    private var mockGateway: MockConfigurationGateway?
    private var cancellables: Set<AnyCancellable>?

    override func setUp() async throws {
        try await super.setUp()
        mockGateway = MockConfigurationGateway()
        cancellables = []
    }

    override func tearDown() async throws {
        cancellables?.removeAll()
        mockGateway = nil
        try await super.tearDown()
    }

    func testGetGroups() async {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let groups = [
            Group(
                id: 1,
                startIndex: 1,
                endIndex: 5,
                colorProperties: ConfigurationDefaults.groupsGlobalColorProperties,
                geometricProperties: GeometricProperties(),
                effectProperties: EffectProperties()
            )
        ]
        mockGateway.emitGroups(groups)
        let useCase = GetGroupsUseCase(configurationGateway: mockGateway)

        // When
        var result: [Group]?
        useCase.execute()
            .sink { value in
                result = value
            }
            .store(in: &cancellables)

        try? await Task.sleep(for: .milliseconds(100))

        // Then
        expect(result) == groups
    }

    func testSetGroups() async {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let groups = [
            Group(
                id: 1,
                startIndex: 1,
                endIndex: 5,
                colorProperties: ConfigurationDefaults.groupsGlobalColorProperties,
                geometricProperties: GeometricProperties(),
                effectProperties: EffectProperties()
            )
        ]
        let useCase = SetGroupsUseCase(configurationGateway: mockGateway)

        // When
        await useCase.execute(value: groups)

        // Then
        expect(mockGateway.setGroupsCalls.count) == 1
        expect(mockGateway.setGroupsCalls.first) == groups
    }
}
