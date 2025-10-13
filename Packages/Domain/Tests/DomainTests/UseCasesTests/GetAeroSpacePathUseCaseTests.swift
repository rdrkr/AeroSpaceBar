// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
@testable import Domain
import XCTest

final class GetAeroSpacePathUseCaseTests: XCTestCase {
    private var useCase: GetAeroSpacePathUseCase?
    private var cancellables: Set<AnyCancellable>?

    override func setUp() {
        // mockConfigurationGateway = MockConfigurationGateway()
        // useCase = GetAeroSpacePathUseCase(configurationGateway: mockConfigurationGateway)
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        cancellables?.removeAll()
        useCase = nil
    }

    func testGetAeroSpacePathUseCaseInitialization() { }

    func testExecute() { }

    func testExecuteReturnsPublisher() { }
}
