// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

@testable import Domain
import Nimble
import XCTest

/// Tests for OpenAeroSpaceConfigUseCase.
///
/// These tests verify:
/// - Initialization with configuration gateway
/// - Execution forwards to gateway
/// - Async behavior
@MainActor
final class OpenAeroSpaceConfigUseCaseTests: XCTestCase {
    private var sut: OpenAeroSpaceConfigUseCase?
    private var mockConfigurationGateway: MockConfigurationGateway?

    override func setUp() async throws {
        try await super.setUp()
        mockConfigurationGateway = MockConfigurationGateway()
        guard let gateway = mockConfigurationGateway else {
            XCTFail("Failed to create mock configuration gateway")
            return
        }

        sut = OpenAeroSpaceConfigUseCase(configurationGateway: gateway)
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
        let useCase = OpenAeroSpaceConfigUseCase(configurationGateway: gateway)

        // Then
        expect(useCase).toNot(beNil())
    }

    // MARK: - Execution Tests

    func testExecuteCallsGateway() async {
        guard let sut, let mockConfigurationGateway else { return }

        // Given
        expect(mockConfigurationGateway.openAeroSpaceConfigCalls) == 0

        // When
        await sut.execute()

        // Then
        expect(mockConfigurationGateway.openAeroSpaceConfigCalls) == 1
    }

    func testExecuteMultipleTimes() async {
        guard let sut, let mockConfigurationGateway else { return }

        // Given
        expect(mockConfigurationGateway.openAeroSpaceConfigCalls) == 0

        // When
        await sut.execute()
        await sut.execute()
        await sut.execute()

        // Then
        expect(mockConfigurationGateway.openAeroSpaceConfigCalls) == 3
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
