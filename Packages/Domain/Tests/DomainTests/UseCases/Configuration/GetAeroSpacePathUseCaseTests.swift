// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
@testable import Domain
import Nimble
import XCTest

@MainActor
final class GetAeroSpacePathUseCaseTests: XCTestCase {
    private var useCase: GetAeroSpacePathUseCase?
    private var mockGateway: MockConfigurationGateway?
    private var cancellables: Set<AnyCancellable>?

    override func setUp() async throws {
        try await super.setUp()
        mockGateway = MockConfigurationGateway()
        guard let mockGateway else {
            fatalError("Mock gateway should be initialized")
        }

        useCase = GetAeroSpacePathUseCase(configurationGateway: mockGateway)
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() async throws {
        cancellables?.removeAll()
        useCase = nil
        mockGateway = nil
        try await super.tearDown()
    }

    func testGetAeroSpacePathUseCaseInitialization() {
        guard let useCase else {
            fail("Test dependencies not initialized")
            return
        }

        // Then use case should be initialized
        expect(useCase).toNot(beNil())
    }

    func testExecute() {
        guard let useCase, let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given a mock path
        let expectedPath = "/usr/local/bin/aerospace"
        mockGateway.emitAeroSpacePath(expectedPath)

        // When executing
        let publisher = useCase.execute()

        // Then should return publisher with expected path
        var receivedPath: String?
        let expectation = expectation(description: "Path received")

        publisher
            .sink { path in
                receivedPath = path
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
        expect(receivedPath) == expectedPath
    }

    func testExecuteReturnsPublisher() {
        guard let useCase else {
            fail("Test dependencies not initialized")
            return
        }

        // When executing
        let publisher = useCase.execute()

        // Then should return a publisher
        expect(publisher).toNot(beNil())
    }
}
