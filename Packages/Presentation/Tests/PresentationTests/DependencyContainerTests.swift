// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

@testable import AeroSpaceBar
import XCTest

final class DependencyContainerTests: XCTestCase {
    private var container: DependencyContainer?

    override func setUp() {
        // container = DependencyContainer.shared
    }

    override func tearDown() {
        container = nil
    }

    func testDependencyContainerSingleton() { }

    func testGetSpacesGateway() { }

    func testGetSettingsViewModel() { }

    func testGetSpacesViewModel() { }

    func testMakeGetSpacesUseCase() { }

    func testMakeSetFocusSpaceUseCase() { }

    func testMakeSetFocusWindowUseCase() { }
}
