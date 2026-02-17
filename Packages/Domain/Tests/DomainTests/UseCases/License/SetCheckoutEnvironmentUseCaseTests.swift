// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

@testable import Domain
import Nimble
import XCTest

/// Tests for SetCheckoutEnvironmentUseCase.
///
/// These tests verify:
/// - Initialization with license gateway
/// - Method forwarding to gateway
/// - Async behavior
@MainActor
final class SetCheckoutEnvironmentUseCaseTests: XCTestCase {
    private var sut: SetCheckoutEnvironmentUseCase?
    private var mockLicenseGateway: MockLicenseGateway?

    override func setUp() async throws {
        try await super.setUp()
        mockLicenseGateway = MockLicenseGateway()
        guard let gateway = mockLicenseGateway else {
            XCTFail("Failed to create mock license gateway")
            return
        }

        sut = SetCheckoutEnvironmentUseCase(licenseGateway: gateway)
    }

    override func tearDown() async throws {
        sut = nil
        mockLicenseGateway = nil
        try await super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialization() {
        // Given
        let gateway = MockLicenseGateway()

        // When
        let useCase = SetCheckoutEnvironmentUseCase(licenseGateway: gateway)

        // Then
        expect(useCase).toNot(beNil())
    }

    // MARK: - Execution Tests

    func testExecuteWithProductionEnvironment() {
        guard let sut, let mockLicenseGateway else { return }

        // Given
        let environment = CheckoutEnvironment.production

        // When
        sut.execute(environment)

        // Then
        expect(mockLicenseGateway.setCheckoutEnvironmentCalls.count) == 1
        expect(mockLicenseGateway.setCheckoutEnvironmentCalls.first) == environment
    }

    func testExecuteWithDevelopmentEnvironment() {
        guard let sut, let mockLicenseGateway else { return }

        // Given
        let environment = CheckoutEnvironment.development

        // When
        sut.execute(environment)

        // Then
        expect(mockLicenseGateway.setCheckoutEnvironmentCalls.count) == 1
        expect(mockLicenseGateway.setCheckoutEnvironmentCalls.first) == environment
    }

    func testExecuteMultipleTimes() {
        guard let sut, let mockLicenseGateway else { return }

        // Given
        let environments = [CheckoutEnvironment.production, .development, .production]

        // When
        for environment in environments {
            sut.execute(environment)
        }

        // Then
        expect(mockLicenseGateway.setCheckoutEnvironmentCalls.count) == 3
        expect(mockLicenseGateway.setCheckoutEnvironmentCalls[0]) == environments[0]
        expect(mockLicenseGateway.setCheckoutEnvironmentCalls[1]) == environments[1]
        expect(mockLicenseGateway.setCheckoutEnvironmentCalls[2]) == environments[2]
    }

    func testExecuteWithSameEnvironmentMultipleTimes() {
        guard let sut, let mockLicenseGateway else { return }

        // Given
        let environment = CheckoutEnvironment.production

        // When
        sut.execute(environment)
        sut.execute(environment)
        sut.execute(environment)

        // Then
        expect(mockLicenseGateway.setCheckoutEnvironmentCalls.count) == 3
        expect(mockLicenseGateway.setCheckoutEnvironmentCalls.allSatisfy { $0 == environment }) == true
    }

    func testExecuteIsAsync() {
        guard let sut else {
            fail("Test dependencies not initialized")
            return
        }

        // Given/When/Then - Should compile and execute without blocking
        sut.execute(.production)
    }

    func testExecuteWithAllEnvironments() {
        guard let sut, let mockLicenseGateway else { return }

        // Given all possible environments
        let environments: [CheckoutEnvironment] = [.production, .development]

        for (index, environment) in environments.enumerated() {
            // When
            sut.execute(environment)

            // Then
            expect(mockLicenseGateway.setCheckoutEnvironmentCalls.count) == index + 1
            expect(mockLicenseGateway.setCheckoutEnvironmentCalls[index]) == environment
        }
    }
}
