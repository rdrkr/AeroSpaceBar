// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
@testable import Service
import XCTest

final class ConfigurationRepositoryTests: XCTestCase {
    var repository: ConfigurationRepository?
    var cancellables: Set<AnyCancellable>?

    override func setUp() {
        // repository = ConfigurationRepository()
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        cancellables?.removeAll()
        repository = nil
    }

    func testConfigurationRepositoryInitialization() { }

    func testShowWindowTitlesPublisher() { }

    func testAeroSpacePathPublisher() { }

    func testTransparencyPublisher() { }

    func testSetShowWindowTitles() { }

    func testSetAeroSpacePath() { }

    func testSetTransparency() { }

    func testOpenAeroSpaceConfig() { }

    func testResetToDefaults() { }
}
