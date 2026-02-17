// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
@testable import Domain
import Nimble
import XCTest

/// Tests for Reset Configuration use case.
///
/// These tests verify:
/// - ResetConfigurationUseCase
@MainActor
final class ResetConfigurationUseCaseTests: XCTestCase {
    private var mockGateway: MockConfigurationGateway?

    override func setUp() async throws {
        try await super.setUp()
        mockGateway = MockConfigurationGateway()
    }

    override func tearDown() async throws {
        mockGateway = nil
        try await super.tearDown()
    }

    func testResetConfiguration() async {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let useCase = ResetConfigurationUseCase(configurationGateway: mockGateway)

        // When
        await useCase.execute()

        // Then
        expect(mockGateway.resetToDefaultsCalls) == 1
    }
}
