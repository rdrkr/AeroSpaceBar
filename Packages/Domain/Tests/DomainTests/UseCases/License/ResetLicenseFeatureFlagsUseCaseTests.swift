// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

@testable import Domain
import Nimble
import XCTest

/// Tests for ResetLicenseFeatureFlagsUseCase.
///
/// These tests verify:
/// - Initialization with license gateway
/// - Method forwarding to gateway
/// - Async behavior
@MainActor
final class ResetLicenseFeatureFlagsUseCaseTests: XCTestCase {
    private var sut: ResetLicenseFeatureFlagsUseCase?
    private var mockLicenseGateway: MockLicenseGateway?

    override func setUp() async throws {
        try await super.setUp()
        mockLicenseGateway = MockLicenseGateway()
        guard let gateway = mockLicenseGateway else {
            XCTFail("Failed to create mock license gateway")
            return
        }

        sut = ResetLicenseFeatureFlagsUseCase(gateway: gateway)
    }

    override func tearDown() async throws {
        sut = nil
        mockLicenseGateway = nil
        try await super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialization() {
        // Test initialization

        // Given
        let gateway = MockLicenseGateway()

        // When
        let useCase = ResetLicenseFeatureFlagsUseCase(gateway: gateway)

        // Then
        expect(useCase).toNot(beNil())
    }

    // MARK: - Execution Tests

    func testExecuteCallsGateway() async {
        guard let sut, let mockLicenseGateway else { return }

        // Given
        expect(mockLicenseGateway.resetLicenseFeatureFlagsCallCount) == 0

        // When
        await sut.execute()

        // Then
        expect(mockLicenseGateway.resetLicenseFeatureFlagsCallCount) == 1
    }

    func testExecuteMultipleTimes() async {
        guard let sut, let mockLicenseGateway else { return }

        // Given
        expect(mockLicenseGateway.resetLicenseFeatureFlagsCallCount) == 0

        // When
        await sut.execute()
        await sut.execute()
        await sut.execute()

        // Then
        expect(mockLicenseGateway.resetLicenseFeatureFlagsCallCount) == 3
    }

    func testExecuteIsAsync() async {
        guard let sut else {
            fail("Test dependencies not initialized")
            return
        }

        // Given/When/Then - Should compile and execute without blocking
        await sut.execute()
    }

    func testExecuteWithDifferentGateways() async {
        // Given multiple gateways
        let gateway1 = MockLicenseGateway()
        let gateway2 = MockLicenseGateway()

        let useCase1 = ResetLicenseFeatureFlagsUseCase(gateway: gateway1)
        let useCase2 = ResetLicenseFeatureFlagsUseCase(gateway: gateway2)

        // When
        await useCase1.execute()
        await useCase2.execute()

        // Then
        expect(gateway1.resetLicenseFeatureFlagsCallCount) == 1
        expect(gateway2.resetLicenseFeatureFlagsCallCount) == 1
    }

    func testExecuteConcurrentCalls() async {
        guard let sut, let mockLicenseGateway else { return }

        // Given
        expect(mockLicenseGateway.resetLicenseFeatureFlagsCallCount) == 0

        // When
        await withTaskGroup(of: Void.self) { group in
            for _ in 0 ..< 5 {
                group.addTask {
                    await sut.execute()
                }
            }
        }

        // Then
        expect(mockLicenseGateway.resetLicenseFeatureFlagsCallCount) == 5
    }
}
