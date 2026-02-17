// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
@testable import Domain
import Nimble
import XCTest

/// Tests for GetCheckoutEnvironmentUseCase.
///
/// These tests verify:
/// - Initialization with license gateway
/// - Publisher forwarding behavior
/// - Reactive environment updates
@MainActor
final class GetCheckoutEnvironmentUseCaseTests: XCTestCase {
    private var sut: GetCheckoutEnvironmentUseCase?
    private var mockLicenseGateway: MockLicenseGateway?
    private var cancellables: Set<AnyCancellable> = []

    override func setUp() async throws {
        try await super.setUp()
        mockLicenseGateway = MockLicenseGateway()
        guard let gateway = mockLicenseGateway else {
            XCTFail("Failed to create mock license gateway")
            return
        }

        sut = GetCheckoutEnvironmentUseCase(licenseGateway: gateway)
    }

    override func tearDown() async throws {
        cancellables.removeAll()
        sut = nil
        mockLicenseGateway = nil
        try await super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialization() {
        guard let sut else {
            fail("SUT not initialized")
            return
        }

        // Then
        expect(sut).toNot(beNil())
    }

    // MARK: - Execution Tests

    func testExecuteReturnsPublisher() async {
        guard let sut, let mockLicenseGateway else { return }

        // Given
        let expectedEnvironment = CheckoutEnvironment.production
        mockLicenseGateway.setCheckoutEnvironment(expectedEnvironment)

        let expectation = expectation(description: "Environment publisher emits")
        var receivedEnvironment: CheckoutEnvironment?

        // When
        sut.execute()
            .sink { environment in
                receivedEnvironment = environment
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        expect(receivedEnvironment) == expectedEnvironment
    }

    func testExecuteReceivesEnvironmentUpdates() async {
        guard let sut, let mockLicenseGateway else { return }

        // Given
        let initialEnvironment = CheckoutEnvironment.production
        let updatedEnvironment = CheckoutEnvironment.development
        mockLicenseGateway.setCheckoutEnvironment(initialEnvironment)

        let firstExpectation = expectation(description: "Initial environment")
        let secondExpectation = expectation(description: "Updated environment")
        var receivedEnvironments: [CheckoutEnvironment?] = []

        // When
        sut.execute()
            .sink { environment in
                receivedEnvironments.append(environment)
                if receivedEnvironments.count == 1 {
                    firstExpectation.fulfill()
                } else if receivedEnvironments.count == 2 {
                    secondExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        await fulfillment(of: [firstExpectation], timeout: 1.0)

        // Update environment
        mockLicenseGateway.setCheckoutEnvironment(updatedEnvironment)

        // Then
        await fulfillment(of: [secondExpectation], timeout: 1.0)
        expect(receivedEnvironments.count) == 2
        expect(receivedEnvironments[0]) == initialEnvironment
        expect(receivedEnvironments[1]) == updatedEnvironment
    }

    func testExecutePublisherDoesNotComplete() async {
        guard let sut, let mockLicenseGateway else { return }

        // Given
        mockLicenseGateway.setCheckoutEnvironment(.production)
        let expectation = expectation(description: "Publisher should not complete")
        expectation.isInverted = true

        // When
        sut.execute()
            .sink(
                receiveCompletion: { completion in
                    if case .finished = completion {
                        expectation.fulfill()
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        // Then
        await fulfillment(of: [expectation], timeout: 0.5)
    }

    func testExecuteWithDifferentEnvironments() async {
        guard let sut, let mockLicenseGateway else { return }

        // Test Production
        mockLicenseGateway.setCheckoutEnvironment(.production)
        let productionExpectation = expectation(description: "Environment production emits")
        var receivedEnvironment: CheckoutEnvironment?

        sut.execute()
            .sink { env in
                receivedEnvironment = env
                productionExpectation.fulfill()
            }
            .store(in: &cancellables)

        await fulfillment(of: [productionExpectation], timeout: 1.0)
        expect(receivedEnvironment) == .production

        // Clear cancellables between tests
        cancellables.removeAll()

        // Test Development
        mockLicenseGateway.setCheckoutEnvironment(.development)
        let developmentExpectation = expectation(description: "Environment development emits")
        receivedEnvironment = nil

        sut.execute()
            .sink { env in
                receivedEnvironment = env
                developmentExpectation.fulfill()
            }
            .store(in: &cancellables)

        await fulfillment(of: [developmentExpectation], timeout: 1.0)
        expect(receivedEnvironment) == .development
    }
}
