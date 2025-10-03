// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

@testable import Service
import XCTest

final class AeroSpaceCLIClientTests: XCTestCase {
    var client: AeroSpaceCLIClient?

    override func setUp() {
        client = AeroSpaceCLIClient(executablePath: "/test/path/aerospace")
    }

    override func tearDown() {
        client = nil
    }

    func testAeroSpaceCLIClientInitialization() { }

    func testExecuteCommand() { }

    func testExecuteCommandWithInvalidPath() { }

    func testExecuteCommandWithNonZeroExitCode() { }
}
