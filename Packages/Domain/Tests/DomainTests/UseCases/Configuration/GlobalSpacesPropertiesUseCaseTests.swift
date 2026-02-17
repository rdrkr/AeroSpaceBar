// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
@testable import Domain
import Nimble
import XCTest

/// Tests for global spaces properties configuration use cases.
///
/// These tests verify:
/// - GetGlobalSpacesColorPropertiesUseCase
/// - SetGlobalSpacesColorPropertiesUseCase
/// - GetGlobalSpacesGeometricPropertiesUseCase
/// - SetGlobalSpacesGeometricPropertiesUseCase
/// - GetGlobalSpacesEffectPropertiesUseCase
/// - SetGlobalSpacesEffectPropertiesUseCase
@MainActor
final class GlobalSpacesPropertiesUseCaseTests: XCTestCase {
    private var mockGateway: MockConfigurationGateway?
    private var cancellables = Set<AnyCancellable>()

    override func setUp() async throws {
        try await super.setUp()
        mockGateway = MockConfigurationGateway()
    }

    // MARK: - GlobalSpacesColorProperties Tests

    func testGetGlobalSpacesColorProperties() {
        guard let mockGateway else { XCTFail("Mock gateway not initialized")
            return
        }

        // Given
        let useCase = GetGlobalSpacesColorPropertiesUseCase(configurationGateway: mockGateway)
        var receivedValue: ColorProperties?

        // When
        useCase.execute()
            .sink { value in receivedValue = value }
            .store(in: &cancellables)

        // Then
        expect(receivedValue).toNot(beNil())
        expect(receivedValue) == mockGateway.globalSpacesColorPropertiesToEmit
    }

    func testSetGlobalSpacesColorProperties() async {
        guard let mockGateway else { XCTFail("Mock gateway not initialized")
            return
        }

        // Given
        let useCase = SetGlobalSpacesColorPropertiesUseCase(configurationGateway: mockGateway)
        let newValue = ColorProperties(
            backgroundTintColor: .red,
            borderTintColor: .blue,
            foregroundColor: .green
        )

        // When
        await useCase.execute(value: newValue)

        // Then
        expect(mockGateway.setGlobalSpacesColorPropertiesCalls.last) == newValue
    }

    // MARK: - GlobalSpacesGeometricProperties Tests

    func testGetGlobalSpacesGeometricProperties() {
        guard let mockGateway else { XCTFail("Mock gateway not initialized")
            return
        }

        // Given
        let useCase = GetGlobalSpacesGeometricPropertiesUseCase(configurationGateway: mockGateway)
        var receivedValue: GeometricProperties?

        // When
        useCase.execute()
            .sink { value in receivedValue = value }
            .store(in: &cancellables)

        // Then
        expect(receivedValue).toNot(beNil())
        expect(receivedValue) == mockGateway.globalSpacesGeometricPropertiesToEmit
    }

    func testSetGlobalSpacesGeometricProperties() async {
        guard let mockGateway else { XCTFail("Mock gateway not initialized")
            return
        }

        // Given
        let useCase = SetGlobalSpacesGeometricPropertiesUseCase(configurationGateway: mockGateway)
        let newValue = GeometricProperties(cornerRadius: 8, borderWidth: 1)

        // When
        await useCase.execute(value: newValue)

        // Then
        expect(mockGateway.setGlobalSpacesGeometricPropertiesCalls.last) == newValue
    }

    // MARK: - GlobalSpacesEffectProperties Tests

    func testGetGlobalSpacesEffectProperties() {
        guard let mockGateway else { XCTFail("Mock gateway not initialized")
            return
        }

        // Given
        let useCase = GetGlobalSpacesEffectPropertiesUseCase(configurationGateway: mockGateway)
        var receivedValue: EffectProperties?

        // When
        useCase.execute()
            .sink { value in receivedValue = value }
            .store(in: &cancellables)

        // Then
        expect(receivedValue).toNot(beNil())
        expect(receivedValue) == mockGateway.globalSpacesEffectPropertiesToEmit
    }

    func testSetGlobalSpacesEffectProperties() async {
        guard let mockGateway else { XCTFail("Mock gateway not initialized")
            return
        }

        // Given
        let useCase = SetGlobalSpacesEffectPropertiesUseCase(configurationGateway: mockGateway)
        let newValue = EffectProperties()

        // When
        await useCase.execute(value: newValue)

        // Then
        expect(mockGateway.setGlobalSpacesEffectPropertiesCalls.last) == newValue
    }
}
