// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

@testable import AeroSpaceBar
import Combine
import XCTest

final class GetSpacesUseCaseTests: XCTestCase {
    var useCase: GetSpacesUseCase?
    private var mockSpacesGateway: MockSpacesGateway?
    var cancellables: Set<AnyCancellable>?

    func setUp() {
        // TODO: Initialize with proper actor context
        // mockSpacesGateway = MockSpacesGateway()
        // useCase = GetSpacesUseCase(spacesGateway: mockSpacesGateway)
        cancellables = Set<AnyCancellable>()
    }

    func tearDown() {
        cancellables?.removeAll()
        useCase = nil
        mockSpacesGateway = nil
    }

    func testGetSpacesUseCaseInitialization() {
        // TODO: Test use case initialization
    }

    func testExecute() {
        // TODO: Test execute method
    }

    func testExecuteReturnsPublisher() {
        // TODO: Test execute returns publisher
    }
}

// MARK: - Mock Spaces Gateway

private class MockSpacesGateway: SpacesGateway {
    var spacesWithWindowsPublisher: AnyPublisher<[Space], Never> = Just([]).eraseToAnyPublisher()
    var aeroSpaceRunningPublisher: AnyPublisher<Bool, Never> = Just(false).eraseToAnyPublisher()

    func focusSpace(spaceId _: String, needWindowFocus _: Bool) async throws { }
    func focusWindow(windowId _: String) async throws { }
}
