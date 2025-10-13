// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import XCTest

final class SpacesViewModelUITests: XCTestCase {
    private var app: XCUIApplication?

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app?.launch()
    }

    override func tearDown() {
        app = nil
    }

    func testSpacesViewModelUI() { }

    func testIsAeroSpaceRunningDisplayUI() { }

    func testWallpaperDisplayUI() { }

    func testSpacesDisplayUI() { }

    func testUIConfigurationPropertiesUI() { }

    func testSwitchToSpaceUI() { }

    func testSwitchToWindowUI() { }
}
