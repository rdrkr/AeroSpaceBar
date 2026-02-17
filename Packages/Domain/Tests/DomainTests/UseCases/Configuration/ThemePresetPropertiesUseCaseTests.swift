// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
@testable import Domain
import Nimble
import XCTest

/// Tests for Theme Preset configuration use cases.
///
/// These tests verify:
/// - GetThemePresetColorPropertiesUseCase
/// - SetThemePresetColorPropertiesUseCase
/// - GetThemePresetGeometricPropertiesUseCase
/// - SetThemePresetGeometricPropertiesUseCase
/// - GetThemePresetEffectPropertiesUseCase
/// - SetThemePresetEffectPropertiesUseCase
@MainActor
final class ThemePresetPropertiesUseCaseTests: XCTestCase {
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

    func testGetThemePresetColorProperties() async {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockGateway.setThemePresetColorProperties(.tokyoNight)
        let useCase = GetThemePresetColorPropertiesUseCase(configurationGateway: mockGateway)

        // When
        var result: ThemePresetColorProperties?
        useCase.execute()
            .sink { value in
                result = value
            }
            .store(in: &cancellables)

        try? await Task.sleep(for: .milliseconds(100))

        // Then
        expect(result) == .tokyoNight
    }

    func testSetThemePresetColorProperties() async {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let useCase = SetThemePresetColorPropertiesUseCase(configurationGateway: mockGateway)

        // When
        await useCase.execute(value: .tokyoNight)

        // Then
        expect(mockGateway.setThemePresetColorPropertiesCalls.count) == 1
        expect(mockGateway.setThemePresetColorPropertiesCalls.first) == .tokyoNight
    }

    func testGetThemePresetGeometricProperties() async {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let props = GeometricProperties(cornerRadius: 12, borderWidth: 2.5)
        mockGateway.setThemePresetGeometricProperties(props)
        let useCase = GetThemePresetGeometricPropertiesUseCase(configurationGateway: mockGateway)

        // When
        var result: GeometricProperties?
        useCase.execute()
            .sink { value in
                result = value
            }
            .store(in: &cancellables)

        try? await Task.sleep(for: .milliseconds(100))

        // Then
        expect(result) == props
    }

    func testSetThemePresetGeometricProperties() async {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let props = GeometricProperties(cornerRadius: 12, borderWidth: 2.5)
        let useCase = SetThemePresetGeometricPropertiesUseCase(configurationGateway: mockGateway)

        // When
        await useCase.execute(value: props)

        // Then
        expect(mockGateway.setThemePresetGeometricPropertiesCalls.count) == 1
        expect(mockGateway.setThemePresetGeometricPropertiesCalls.first) == props
    }

    func testGetThemePresetEffectProperties() async {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let props = EffectProperties(backgroundOpacity: 0.85, backgroundBlurRadius: 10, borderOpacity: 0.95)
        mockGateway.setThemePresetEffectProperties(props)
        let useCase = GetThemePresetEffectPropertiesUseCase(configurationGateway: mockGateway)

        // When
        var result: EffectProperties?
        useCase.execute()
            .sink { value in
                result = value
            }
            .store(in: &cancellables)

        try? await Task.sleep(for: .milliseconds(100))

        // Then
        expect(result) == props
    }

    func testSetThemePresetEffectProperties() async {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let props = EffectProperties(backgroundOpacity: 0.85, backgroundBlurRadius: 10, borderOpacity: 0.95)
        let useCase = SetThemePresetEffectPropertiesUseCase(configurationGateway: mockGateway)

        // When
        await useCase.execute(value: props)

        // Then
        expect(mockGateway.setThemePresetEffectPropertiesCalls.count) == 1
        expect(mockGateway.setThemePresetEffectPropertiesCalls.first) == props
    }
}
