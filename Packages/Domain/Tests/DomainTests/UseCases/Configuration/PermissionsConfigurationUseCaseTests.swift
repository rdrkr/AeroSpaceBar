// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
@testable import Domain
import Nimble
import XCTest

/// Tests for Permissions configuration use cases.
///
/// These tests verify:
/// - GetHasAskedForScreenCapturePermissionsUseCase
/// - SetHasAskedForScreenCapturePermissionsUseCase
@MainActor
final class PermissionsConfigurationUseCaseTests: XCTestCase {
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

    func testGetHasAskedForScreenCapturePermissions() async {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockGateway.setHasAskedForScreenCapturePermissions(true)
        let useCase = GetHasAskedForScreenCapturePermissionsUseCase(configurationGateway: mockGateway)

        // When
        var result: Bool?
        useCase.execute()
            .sink { value in
                result = value
            }
            .store(in: &cancellables)

        try? await Task.sleep(for: .milliseconds(100))

        // Then
        expect(result) == true
    }

    func testSetHasAskedForScreenCapturePermissions() async {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let useCase = SetHasAskedForScreenCapturePermissionsUseCase(configurationGateway: mockGateway)

        // When
        await useCase.execute(value: true)

        // Then
        expect(mockGateway.setHasAskedForScreenCapturePermissionsCalls.count) == 1
        expect(mockGateway.setHasAskedForScreenCapturePermissionsCalls.first) == true
    }
}
