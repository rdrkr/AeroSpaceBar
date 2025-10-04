// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
@testable import Data
import XCTest

final class AeroSpaceRepositoryTests: XCTestCase {
    var repository: AeroSpaceRepository?
    var cancellables: Set<AnyCancellable>?

    override func setUp() {
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        cancellables?.removeAll()
        repository = nil
    }

    func testAeroSpaceRepositoryInitialization() { }

    func testSpacesWithWindowsPublisher() { }

    func testAeroSpaceRunningPublisher() { }

    func testFocusSpace() { }

    func testFocusWindow() { }

    func testIsAeroSpaceRunning() { }

    func testFetchSpacesWithWindows() { }

    func testBuildSpacesWithWindows() { }
}
