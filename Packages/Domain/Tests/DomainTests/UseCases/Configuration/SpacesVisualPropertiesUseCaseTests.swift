// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
@testable import Domain
import Nimble
import XCTest

/// Tests for spaces visual properties use cases.
///
/// These tests verify:
/// - GetSpacesColorPropertiesUseCase
/// - SetSpacesColorPropertiesUseCase
/// - GetSpacesEffectPropertiesUseCase
/// - SetSpacesEffectPropertiesUseCase
/// - GetSpacesGeometricPropertiesUseCase
/// - SetSpacesGeometricPropertiesUseCase
@MainActor
final class SpacesVisualPropertiesUseCaseTests: XCTestCase {
    private var mockGateway: MockConfigurationGateway?
    private var cancellables = Set<AnyCancellable>()

    override func setUp() async throws {
        try await super.setUp()
        mockGateway = MockConfigurationGateway()
    }

    // MARK: - Color Properties Tests

    func testGetSpacesColorProperties() {
        guard let mockGateway else { XCTFail("Mock gateway not initialized")
            return
        }

        // Given
        let useCase = GetSpacesColorPropertiesUseCase(configurationGateway: mockGateway)
        var receivedValue: [ColorProperties]?

        // When
        useCase.execute()
            .sink { value in receivedValue = value }
            .store(in: &cancellables)

        // Then
        expect(receivedValue).toNot(beNil())
        expect(receivedValue?.count) == mockGateway.spacesColorPropertiesToEmit.count
    }

    func testSetSpacesColorProperties() async {
        guard let mockGateway else { XCTFail("Mock gateway not initialized")
            return
        }

        // Given
        let useCase = SetSpacesColorPropertiesUseCase(configurationGateway: mockGateway)
        let newValue = [
            ColorProperties(),
            ColorProperties()
        ]

        // When
        await useCase.execute(value: newValue)

        // Then
        expect(mockGateway.setSpacesColorPropertiesCalls.count) == 1
        expect(mockGateway.setSpacesColorPropertiesCalls.first?.count) == newValue.count
    }

    // MARK: - Effect Properties Tests

    func testGetSpacesEffectProperties() {
        guard let mockGateway else { XCTFail("Mock gateway not initialized")
            return
        }

        // Given
        let useCase = GetSpacesEffectPropertiesUseCase(configurationGateway: mockGateway)
        var receivedValue: [EffectProperties]?

        // When
        useCase.execute()
            .sink { value in receivedValue = value }
            .store(in: &cancellables)

        // Then
        expect(receivedValue).toNot(beNil())
        expect(receivedValue?.count) == mockGateway.spacesEffectPropertiesToEmit.count
    }

    func testSetSpacesEffectProperties() async {
        guard let mockGateway else { XCTFail("Mock gateway not initialized")
            return
        }

        // Given
        let useCase = SetSpacesEffectPropertiesUseCase(configurationGateway: mockGateway)
        let newValue = [
            EffectProperties(),
            EffectProperties()
        ]

        // When
        await useCase.execute(value: newValue)

        // Then
        expect(mockGateway.setSpacesEffectPropertiesCalls.count) == 1
        expect(mockGateway.setSpacesEffectPropertiesCalls.first?.count) == newValue.count
    }

    // MARK: - Geometric Properties Tests

    func testGetSpacesGeometricProperties() {
        guard let mockGateway else { XCTFail("Mock gateway not initialized")
            return
        }

        // Given
        let useCase = GetSpacesGeometricPropertiesUseCase(configurationGateway: mockGateway)
        var receivedValue: [GeometricProperties]?

        // When
        useCase.execute()
            .sink { value in receivedValue = value }
            .store(in: &cancellables)

        // Then
        expect(receivedValue).toNot(beNil())
        expect(receivedValue?.count) == mockGateway.spacesGeometricPropertiesToEmit.count
    }

    func testSetSpacesGeometricProperties() async {
        guard let mockGateway else { XCTFail("Mock gateway not initialized")
            return
        }

        // Given
        let useCase = SetSpacesGeometricPropertiesUseCase(configurationGateway: mockGateway)
        let newValue = [
            GeometricProperties(),
            GeometricProperties()
        ]

        // When
        await useCase.execute(value: newValue)

        // Then
        expect(mockGateway.setSpacesGeometricPropertiesCalls.count) == 1
        expect(mockGateway.setSpacesGeometricPropertiesCalls.first?.count) == newValue.count
    }
}
