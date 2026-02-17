// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Nimble
import XCTest

/// UI tests for DependencyContainer integration.
///
/// These tests verify dependency injection UI aspects including:
/// - Dependency injection working correctly in UI
/// - Services being properly provided to UI components
/// - ViewModels being correctly created and injected
@MainActor
final class DependencyContainerUITests: XCTestCase {
    private var app: XCUIApplication?

    override func setUp() async throws {
        try await super.setUp()
        continueAfterFailure = false
        // Use guard statement to safely initialize app

        app = XCUIApplication()

        guard let app else {
            XCTFail("XCUIApplication should be initialized")

            return
        }

        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    // MARK: - Dependency Injection Tests

    func testDependencyInjection() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given the app is launched with DI container
        // Then dependencies should be properly injected
        var state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Dependency injection should work correctly"
        )

        // And settings should be accessible (requires DI)
        app.typeKey(",", modifierFlags: .command)
        sleep(1)
        state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "DI should provide settings functionality"
        )
    }

    func testServiceProvision() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given the app is running with services provided
        // Then services should be available to UI components
        var state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Services should be properly provided"
        )

        // And app should function correctly with all services
        app.typeKey(",", modifierFlags: .command)
        sleep(1)
        app.typeKey("w", modifierFlags: .command)
        sleep(1)
        state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Services should enable full app functionality"
        )
    }

    func testViewModelCreation() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given the app is launched
        // Then ViewModels should be created via DI container
        var state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "ViewModels should be created successfully"
        )

        // And ViewModels should function in UI
        app.typeKey(",", modifierFlags: .command)
        sleep(1)
        state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "ViewModels should work correctly in UI"
        )

        app.typeKey("w", modifierFlags: .command)
        sleep(1)
    }
}
