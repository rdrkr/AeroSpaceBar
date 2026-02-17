// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
@testable import Domain
import Nimble
import XCTest

/// Tests for GetAeroSpaceVersionUseCase.
///
/// These tests verify:
/// - Initialization with configuration gateway
/// - Publisher forwarding behavior
/// - Reactive version updates
@MainActor
final class GetAeroSpaceVersionUseCaseTests: XCTestCase {
    private var sut: GetAeroSpaceVersionUseCase?
    private var mockConfigurationGateway: MockConfigurationGateway?
    private var cancellables: Set<AnyCancellable> = []

    override func setUp() async throws {
        try await super.setUp()
        mockConfigurationGateway = MockConfigurationGateway()
        guard let gateway = mockConfigurationGateway else {
            XCTFail("Failed to create mock configuration gateway")
            return
        }

        sut = GetAeroSpaceVersionUseCase(configurationGateway: gateway)
    }

    override func tearDown() async throws {
        cancellables.removeAll()
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
        let useCase = GetAeroSpaceVersionUseCase(configurationGateway: gateway)

        // Then
        expect(useCase).toNot(beNil())
    }

    // MARK: - Execution Tests

    func testExecuteReturnsPublisher() async {
        guard let sut, let mockConfigurationGateway else { return }

        // Given
        let expectedVersion = "1.0.0"
        mockConfigurationGateway.emitCurrentAeroSpaceVersion(expectedVersion)

        let expectation = expectation(description: "Version publisher emits")
        var receivedVersion: String?

        // When
        sut.execute()
            .sink { version in
                receivedVersion = version
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        expect(receivedVersion) == expectedVersion
    }

    func testExecuteReturnsNilWhenNoVersion() async {
        guard let sut, let mockConfigurationGateway else { return }

        // Given
        mockConfigurationGateway.emitCurrentAeroSpaceVersion(nil)

        let expectation = expectation(description: "Version publisher emits nil")
        var receivedVersion: String?

        // When
        sut.execute()
            .sink { version in
                receivedVersion = version
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        expect(receivedVersion).to(beNil())
    }

    func testExecuteReceivesVersionUpdates() async {
        guard let sut, let mockConfigurationGateway else { return }

        // Given
        let initialVersion = "1.0.0"
        let updatedVersion = "1.1.0"
        mockConfigurationGateway.emitCurrentAeroSpaceVersion(initialVersion)

        let firstExpectation = expectation(description: "Initial version")
        let secondExpectation = expectation(description: "Updated version")
        var receivedVersions: [String?] = []

        // When
        sut.execute()
            .sink { version in
                receivedVersions.append(version)
                if receivedVersions.count == 1 {
                    firstExpectation.fulfill()
                } else if receivedVersions.count == 2 {
                    secondExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        await fulfillment(of: [firstExpectation], timeout: 1.0)

        // Update version
        mockConfigurationGateway.emitCurrentAeroSpaceVersion(updatedVersion)

        // Then
        await fulfillment(of: [secondExpectation], timeout: 1.0)
        expect(receivedVersions.count) == 2
        expect(receivedVersions[0]) == initialVersion
        expect(receivedVersions[1]) == updatedVersion
    }

    func testExecutePublisherDoesNotComplete() async {
        guard let sut, let mockConfigurationGateway else { return }

        // Given
        mockConfigurationGateway.emitCurrentAeroSpaceVersion("1.0.0")
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
}
