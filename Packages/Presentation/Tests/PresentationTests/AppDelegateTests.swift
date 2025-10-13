// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

@testable import AeroSpaceBar
import XCTest

final class AppDelegateTests: XCTestCase {
    private weak var appDelegate: AppDelegate?

    override func setUp() {
        // appDelegate = AppDelegate()
    }

    override func tearDown() {
        appDelegate = nil
    }

    func testAppDelegateInitialization() { }

    func testApplicationDidFinishLaunching() { }

    func testScreenParametersDidChange() { }

    func testSetupPanels() { }

    func testShowAboutWindow() { }

    func testWindowWillClose() { }
}
