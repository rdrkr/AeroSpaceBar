// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
@testable import Domain
import Nimble
import XCTest

/// Tests for global groups properties configuration use cases.
///
/// These tests verify:
/// - GetGlobalGroupsColorPropertiesUseCase
/// - SetGlobalGroupsColorPropertiesUseCase
/// - GetGlobalGroupsGeometricPropertiesUseCase
/// - SetGlobalGroupsGeometricPropertiesUseCase
/// - GetGlobalGroupsEffectPropertiesUseCase
/// - SetGlobalGroupsEffectPropertiesUseCase
@MainActor
final class GlobalGroupsPropertiesUseCaseTests: XCTestCase {
    private var mockGateway: MockConfigurationGateway?
    private var cancellables = Set<AnyCancellable>()

    override func setUp() async throws {
        try await super.setUp()
        mockGateway = MockConfigurationGateway()
    }

    // MARK: - GlobalGroupsColorProperties Tests

    func testGetGlobalGroupsColorProperties() {
        guard let mockGateway else { XCTFail("Mock gateway not initialized")
            return
        }

        // Given
        let useCase = GetGlobalGroupsColorPropertiesUseCase(configurationGateway: mockGateway)
        var receivedValue: ColorProperties?

        // When
        useCase.execute()
            .sink { value in receivedValue = value }
            .store(in: &cancellables)

        // Then
        expect(receivedValue).toNot(beNil())
        expect(receivedValue) == mockGateway.globalGroupsColorPropertiesToEmit
    }

    func testSetGlobalGroupsColorProperties() async {
        guard let mockGateway else { XCTFail("Mock gateway not initialized")
            return
        }

        // Given
        let useCase = SetGlobalGroupsColorPropertiesUseCase(configurationGateway: mockGateway)
        let newValue = ColorProperties(
            backgroundTintColor: .blue,
            borderTintColor: .red,
            foregroundColor: .green
        )

        // When
        await useCase.execute(value: newValue)

        // Then
        expect(mockGateway.setGlobalGroupsColorPropertiesCalls.last) == newValue
    }

    // MARK: - GlobalGroupsGeometricProperties Tests

    func testGetGlobalGroupsGeometricProperties() {
        guard let mockGateway else { XCTFail("Mock gateway not initialized")
            return
        }

        // Given
        let useCase = GetGlobalGroupsGeometricPropertiesUseCase(configurationGateway: mockGateway)
        var receivedValue: GeometricProperties?

        // When
        useCase.execute()
            .sink { value in receivedValue = value }
            .store(in: &cancellables)

        // Then
        expect(receivedValue).toNot(beNil())
        expect(receivedValue) == mockGateway.globalGroupsGeometricPropertiesToEmit
    }

    func testSetGlobalGroupsGeometricProperties() async {
        guard let mockGateway else { XCTFail("Mock gateway not initialized")
            return
        }

        // Given
        let useCase = SetGlobalGroupsGeometricPropertiesUseCase(configurationGateway: mockGateway)
        let newValue = GeometricProperties(cornerRadius: 10, borderWidth: 2)

        // When
        await useCase.execute(value: newValue)

        // Then
        expect(mockGateway.setGlobalGroupsGeometricPropertiesCalls.last) == newValue
    }

    // MARK: - GlobalGroupsEffectProperties Tests

    func testGetGlobalGroupsEffectProperties() {
        guard let mockGateway else { XCTFail("Mock gateway not initialized")
            return
        }

        // Given
        let useCase = GetGlobalGroupsEffectPropertiesUseCase(configurationGateway: mockGateway)
        var receivedValue: EffectProperties?

        // When
        useCase.execute()
            .sink { value in receivedValue = value }
            .store(in: &cancellables)

        // Then
        expect(receivedValue).toNot(beNil())
        expect(receivedValue) == mockGateway.globalGroupsEffectPropertiesToEmit
    }

    func testSetGlobalGroupsEffectProperties() async {
        guard let mockGateway else { XCTFail("Mock gateway not initialized")
            return
        }

        // Given
        let useCase = SetGlobalGroupsEffectPropertiesUseCase(configurationGateway: mockGateway)
        let newValue = EffectProperties()

        // When
        await useCase.execute(value: newValue)

        // Then
        expect(mockGateway.setGlobalGroupsEffectPropertiesCalls.last) == newValue
    }
}
