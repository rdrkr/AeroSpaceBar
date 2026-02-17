// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

@testable import Domain
import Nimble
import XCTest

/// Tests for OpenConfigFileUseCase.
///
/// These tests verify:
/// - Initialization with configuration gateway
/// - Execution forwards to gateway
/// - Async behavior
@MainActor
final class OpenConfigFileUseCaseTests: XCTestCase {
    private var sut: OpenConfigFileUseCase?
    private var mockConfigurationGateway: MockConfigurationGateway?

    override func setUp() async throws {
        try await super.setUp()
        mockConfigurationGateway = MockConfigurationGateway()
        guard let gateway = mockConfigurationGateway else {
            XCTFail("Failed to create mock configuration gateway")
            return
        }

        sut = OpenConfigFileUseCase(configurationGateway: gateway)
    }

    override func tearDown() async throws {
        sut = nil
        mockConfigurationGateway = nil
        try await super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialization() {
        guard let mockConfigurationGateway else {
            fail("Test dependencies not initialized")
            return
        }

        _ = mockConfigurationGateway // Mark as intentionally unused

        // Given
        let gateway = MockConfigurationGateway()

        // When
        let useCase = OpenConfigFileUseCase(configurationGateway: gateway)

        // Then
        expect(useCase).toNot(beNil())
    }

    // MARK: - Execution Tests

    func testExecuteCallsGateway() async {
        guard let sut, let mockConfigurationGateway else { return }

        // Given
        expect(mockConfigurationGateway.openConfigFileCalls) == 0

        // When
        await sut.execute()

        // Then
        expect(mockConfigurationGateway.openConfigFileCalls) == 1
    }

    func testExecuteMultipleTimes() async {
        guard let sut, let mockConfigurationGateway else { return }

        // Given
        expect(mockConfigurationGateway.openConfigFileCalls) == 0

        // When
        await sut.execute()
        await sut.execute()
        await sut.execute()

        // Then
        expect(mockConfigurationGateway.openConfigFileCalls) == 3
    }

    func testExecuteIsAsync() async {
        guard let sut else {
            fail("Test dependencies not initialized")
            return
        }

        // Given/When/Then - Should compile and execute without blocking
        await sut.execute()
    }
}
