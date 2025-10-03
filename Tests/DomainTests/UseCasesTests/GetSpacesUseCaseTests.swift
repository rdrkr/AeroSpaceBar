// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
@testable import Domain
import XCTest

final class GetSpacesUseCaseTests: XCTestCase {
    var useCase: GetSpacesUseCase?
    var cancellables: Set<AnyCancellable>?

    override func setUp() {
        // mockSpacesGateway = MockSpacesGateway()
        // useCase = GetSpacesUseCase(spacesGateway: mockSpacesGateway)
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        cancellables?.removeAll()
        useCase = nil
    }

    func testGetSpacesUseCaseInitialization() { }

    func testExecute() { }

    func testExecuteReturnsPublisher() { }
}
