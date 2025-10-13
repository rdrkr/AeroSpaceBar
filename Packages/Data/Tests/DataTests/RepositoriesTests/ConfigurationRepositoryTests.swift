// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
@testable import Data
import XCTest

final class ConfigurationRepositoryTests: XCTestCase {
    private var repository: ConfigurationRepository?
    private var cancellables: Set<AnyCancellable>?

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
