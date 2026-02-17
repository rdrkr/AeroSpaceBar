// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
@testable import Domain
import Nimble
import XCTest

/// Tests for path-related configuration use cases.
///
/// These tests verify:
/// - GetAeroSpacePathUseCase
/// - SetAeroSpacePathUseCase
/// - GetConfigFilePathUseCase
/// - SetConfigFilePathUseCase
/// - GetAeroSpaceConfigPathUseCase
/// - GetAeroSpaceVersionUseCase
/// - OpenAeroSpaceConfigUseCase
/// - OpenConfigFileUseCase
@MainActor
final class PathConfigurationUseCaseTests: XCTestCase {
    private var mockGateway: MockConfigurationGateway?
    private var cancellables: Set<AnyCancellable>?

    override func setUp() async throws {
        try await super.setUp()
        mockGateway = MockConfigurationGateway()
        cancellables = []
    }

    // MARK: - AeroSpacePath Tests

    func testGetAeroSpacePath() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let useCase = GetAeroSpacePathUseCase(configurationGateway: mockGateway)
        var receivedValue: String?

        // When
        useCase.execute()
            .sink { value in receivedValue = value }
            .store(in: &cancellables)

        // Then
        expect(receivedValue).toNot(beNil())
        expect(receivedValue) == mockGateway.aeroSpacePathToEmit
    }

    func testSetAeroSpacePath() async {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let useCase = SetAeroSpacePathUseCase(configurationGateway: mockGateway)
        let newPath = "/opt/aerospace/bin/aerospace"

        // When
        await useCase.execute(value: newPath)

        // Then
        expect(mockGateway.setAeroSpacePathCalls.last) == newPath
    }

    // MARK: - ConfigFilePath Tests

    func testGetConfigFilePath() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let useCase = GetConfigFilePathUseCase(configurationGateway: mockGateway)
        var receivedValue: String?

        // When
        useCase.execute()
            .sink { value in receivedValue = value }
            .store(in: &cancellables)

        // Then
        expect(receivedValue).toNot(beNil())
        expect(receivedValue) == mockGateway.configFilePathToEmit
    }

    func testSetConfigFilePath() async {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let useCase = SetConfigFilePathUseCase(configurationGateway: mockGateway)
        let newPath = "/path/to/config.toml"

        // When
        await useCase.execute(value: newPath)

        // Then
        expect(mockGateway.setConfigFilePathCalls.last) == newPath
    }

    // MARK: - AeroSpaceConfigPath Tests

    func testGetAeroSpaceConfigPath() async {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let useCase = GetAeroSpaceConfigPathUseCase(configurationGateway: mockGateway)

        // When
        let result = await useCase.execute()

        // Then
        expect(result).toNot(beNil())
        expect(result.path) == "/Users/test/.aerospace.toml"
    }

    // MARK: - AeroSpaceVersion Tests

    func testGetAeroSpaceVersion() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let useCase = GetAeroSpaceVersionUseCase(configurationGateway: mockGateway)
        var receivedValue: String??

        // When
        useCase.execute()
            .sink { value in receivedValue = value }
            .store(in: &cancellables)

        // Then
        expect(receivedValue).toNot(beNil())
        expect(receivedValue) == mockGateway.currentAeroSpaceVersionToEmit
    }

    // MARK: - OpenAeroSpaceConfig Tests

    func testOpenAeroSpaceConfig() async {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let useCase = OpenAeroSpaceConfigUseCase(configurationGateway: mockGateway)

        // When & Then - Should execute without errors
        await useCase.execute()
    }

    // MARK: - OpenConfigFile Tests

    func testOpenConfigFile() async {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let useCase = OpenConfigFileUseCase(configurationGateway: mockGateway)

        // When & Then - Should execute without errors
        await useCase.execute()
    }
}
