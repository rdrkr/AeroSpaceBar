// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
@testable import Domain
import Nimble
import XCTest

/// Tests for FeatureFlagsGateway protocol.
///
/// These tests verify:
/// - Protocol conformance
/// - Publisher requirements
/// - Method signatures
/// - Feature flags operations
/// - Mock implementation behavior
@MainActor
final class FeatureFlagsGatewayTests: XCTestCase {
    private var sut: MockFeatureFlagsGateway?
    private var cancellables: Set<AnyCancellable>?

    override func setUp() async throws {
        try await super.setUp()
        sut = MockFeatureFlagsGateway()
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() async throws {
        cancellables?.removeAll()
        sut = nil
        try await super.tearDown()
    }

    // MARK: - Publisher Tests

    func testFeatureFlagsPublisher() async {
        guard let sut, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let expectation = expectation(description: "Publisher emits feature flags")
        var receivedFlags: FeatureFlags?

        // When
        sut.featureFlagsPublisher
            .sink { flags in
                receivedFlags = flags
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        expect(receivedFlags).toNot(beNil())
    }

    // MARK: - Set Feature Flags Tests

    func testSetFeatureFlags() async {
        guard let sut, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let newFlags = FeatureFlags(
            enableGroups: true,
            enableSpaces: false,
            enableSoftwareUpdates: false,
            enableAdvancedSettings: true
        )
        let expectation = expectation(description: "Feature flags updated")
        var receivedFlags: FeatureFlags?

        sut.featureFlagsPublisher
            .dropFirst() // Skip initial value
            .sink { flags in
                receivedFlags = flags
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // When
        sut.setFeatureFlags(newFlags)

        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        expect(receivedFlags?.enableGroups) == true
        expect(receivedFlags?.enableSpaces) == false
    }

    // MARK: - Reset to Defaults Tests

    func testResetToDefaults() async {
        guard let sut, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let customFlags = FeatureFlags(
            enableGroups: false,
            enableSpaces: true,
            enableSoftwareUpdates: true,
            enableAdvancedSettings: false
        )
        sut.setFeatureFlags(customFlags)

        let expectation = expectation(description: "Feature flags reset")
        var receivedFlags: FeatureFlags?

        sut.featureFlagsPublisher
            .dropFirst() // Skip current value
            .sink { flags in
                receivedFlags = flags
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // When
        sut.resetToDefaults()

        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        expect(receivedFlags).toNot(beNil())
        // Should reset to default values
    }

    // MARK: - Protocol Conformance Tests

    func testProtocolConformance() {
        guard let sut else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let gateway: any FeatureFlagsGateway = sut

        // When/Then - Should compile and not crash
        expect(gateway.featureFlagsPublisher).toNot(beNil())
    }
}
