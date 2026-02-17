// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
@testable import Domain
import Nimble
import XCTest

@MainActor
final class ConfigurationGatewayTests: XCTestCase {
    private var mockGateway: MockConfigurationGateway?
    private var cancellables: Set<AnyCancellable>?

    override func setUp() async throws {
        try await super.setUp()
        mockGateway = MockConfigurationGateway()
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() async throws {
        cancellables?.removeAll()
        mockGateway = nil
        try await super.tearDown()
    }

    func testShowWindowTitlesPublisher() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given expectation
        let expectation = expectation(description: "Show window titles received")
        var receivedValue: Bool?

        // When subscribing to publisher
        mockGateway.showWindowTitlesPublisher
            .dropFirst()
            .sink { value in
                receivedValue = value
                expectation.fulfill()
            }
            .store(in: &cancellables)

        mockGateway.emitShowWindowTitles(false)

        // Then should receive value
        wait(for: [expectation], timeout: 1.0)
        expect(receivedValue).toNot(beNil())
        expect(receivedValue) == false
    }

    func testAeroSpacePathPublisher() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given expectation
        let expectation = expectation(description: "AeroSpace path received")
        var receivedPath: String?

        // When subscribing to publisher
        mockGateway.aeroSpacePathPublisher
            // No dropFirst needed here as we don't emit explicitly in this test, just check initial value
            .sink { path in
                receivedPath = path
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // Then should receive default path
        wait(for: [expectation], timeout: 1.0)
        expect(receivedPath) == "/opt/homebrew/bin/aerospace"
    }

    func testLaunchAtLoginPublisher() {
        // Note: This test assumes LaunchAtLogin functionality exists
        // Currently, the mock doesn't include this property
        // Skip test or implement when property is added to ConfigurationGateway
    }

    func testTransparencyPublisher() {
        // Note: This test assumes transparency functionality exists
        // Currently, the mock doesn't include this property
        // Skip test or implement when property is added to ConfigurationGateway
    }

    func testFocusWindowOnClickPublisher() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given expectation
        let expectation = expectation(description: "Focus window on click received")
        var receivedValue: Bool?

        // When subscribing to publisher
        mockGateway.focusWindowOnClickPublisher
            .dropFirst()
            .sink { value in
                receivedValue = value
                expectation.fulfill()
            }
            .store(in: &cancellables)

        mockGateway.emitFocusWindowOnClick(false)

        // Then should receive value
        wait(for: [expectation], timeout: 1.0)
        expect(receivedValue) == false
    }

    func testEnablePerformanceMetricsPublisher() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given expectation
        let expectation = expectation(description: "Performance metrics setting received")
        var receivedValue: Bool?

        // When subscribing to publisher
        mockGateway.enablePerformanceMetricsPublisher
            .dropFirst()
            .sink { value in
                receivedValue = value
                expectation.fulfill()
            }
            .store(in: &cancellables)

        mockGateway.setEnablePerformanceMetrics(true)

        // Then should receive value
        wait(for: [expectation], timeout: 1.0)
        expect(receivedValue) == true
    }

    func testLogLevelPublisher() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given expectation
        let expectation = expectation(description: "Log level received")
        var receivedLevel: Logger.Level?

        // When subscribing to publisher
        mockGateway.logLevelPublisher
            .dropFirst()
            .sink { level in
                receivedLevel = level
                expectation.fulfill()
            }
            .store(in: &cancellables)

        mockGateway.emitLogLevel(.debug)

        // Then should receive level
        wait(for: [expectation], timeout: 1.0)
        expect(receivedLevel) == .debug
    }

    func testCurrentAeroSpaceVersionPublisher() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given expectation
        let expectation = expectation(description: "AeroSpace version received")
        var receivedVersion: String?

        // When subscribing to publisher
        mockGateway.currentAeroSpaceVersionPublisher
            .dropFirst()
            .sink { version in
                receivedVersion = version
                expectation.fulfill()
            }
            .store(in: &cancellables)

        mockGateway.emitCurrentAeroSpaceVersion("1.2.3")

        // Then should receive version
        wait(for: [expectation], timeout: 1.0)
        expect(receivedVersion) == "1.2.3"
    }

    func testUIConfigurationPublishers() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Test show empty spaces publisher
        let expectation1 = expectation(description: "Show empty spaces received")
        var receivedShowEmptySpaces: Bool?

        mockGateway.showEmptySpacesPublisher
            .dropFirst()
            .sink { value in
                receivedShowEmptySpaces = value
                expectation1.fulfill()
            }
            .store(in: &cancellables)

        mockGateway.emitShowEmptySpaces(true)

        wait(for: [expectation1], timeout: 1.0)
        expect(receivedShowEmptySpaces) == true

        // Test show groups publisher
        let expectation2 = expectation(description: "Show groups received")
        var receivedShowGroups: Bool?

        mockGateway.showGroupsPublisher
            .dropFirst()
            .sink { value in
                receivedShowGroups = value
                expectation2.fulfill()
            }
            .store(in: &cancellables)

        mockGateway.emitShowGroups(false)

        wait(for: [expectation2], timeout: 1.0)
        expect(receivedShowGroups) == false
    }

    func testAsyncSetters() {
        guard let mockGateway else {
            fail("Mock gateway not initialized")
            return
        }

        // Test setting AeroSpace path
        mockGateway.setAeroSpacePath("/custom/path")
        expect(mockGateway.setAeroSpacePathCalls.last) == "/custom/path"

        // Test setting show window titles
        mockGateway.setShowWindowTitles(false)
        expect(mockGateway.setShowWindowTitlesCalls.last) == false

        // Test setting focus window on click
        mockGateway.setFocusWindowOnClick(false)
        expect(mockGateway.setFocusWindowOnClickCalls.last) == false

        // Test setting log level
        mockGateway.setLogLevel(.error)
        expect(mockGateway.setLogLevelCalls.last) == .error
    }

    // Configuration save/load functionality removed until needed
    // saveConfiguration and loadConfiguration methods can be re-enabled
    // when ConfigurationGateway interface supports them again

    func testConfigurationManagement() {
        guard let mockGateway else {
            fail("Mock gateway not initialized")
            return
        }

        // Test reset to defaults
        mockGateway.resetToDefaults()
    }
}
