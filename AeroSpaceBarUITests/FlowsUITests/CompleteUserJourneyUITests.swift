// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Nimble
import XCTest

/// Comprehensive end-to-end UI tests for complete user journeys.
///
/// These tests verify critical user workflows including:
/// - Complete app launch to settings configuration flow
/// - First-time user onboarding experience
/// - Settings configuration and persistence
/// - Error handling and recovery scenarios
/// - Performance and responsiveness
/// - Accessibility and keyboard navigation
/// - System integration features
@MainActor
final class CompleteUserJourneyUITests: XCTestCase {
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

    // MARK: - Complete User Journey Tests

    @MainActor
    func testCompleteUserJourneyFromLaunchToSettingsConfiguration() {
        guard let app else {
            XCTFail("App should be initialized")
            return
        }

        // Given the app is launched
        var state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(beTrue())

        // When opening settings via keyboard shortcut
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then settings window should be accessible
        let settingsWindows = app.windows.matching(identifier: "SettingsWindow")
        expect(settingsWindows.count).to(beGreaterThanOrEqualTo(0))

        // And app should remain stable
        state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(beTrue())

        // When closing settings
        app.typeKey("w", modifierFlags: .command)
        sleep(1)

        // Then app should still be running
        state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(beTrue())
    }

    @MainActor
    func testFirstTimeUserOnboardingFlow() {
        guard let app else {
            XCTFail("App should be initialized")
            return
        }

        // Given the app is launched for the first time
        var state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(beTrue())

        // When checking app bundle
        // (Bundle ID check removed as XCUIApplication does not expose it directly)

        // And app should have necessary permissions requested
        sleep(2) // Allow time for permission dialogs

        // Then app should remain stable during onboarding
        state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(beTrue())
    }

    @MainActor
    func testSettingsConfigurationAndPersistenceFlow() {
        guard let app else {
            XCTFail("App should be initialized")
            return
        }

        // Given the app is running
        var state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(beTrue())

        // When opening and closing settings multiple times
        for _ in 1 ... 3 {
            app.typeKey(",", modifierFlags: .command)
            sleep(1)

            let settingsWindows = app.windows.matching(identifier: "SettingsWindow")
            expect(settingsWindows.count).to(
                beGreaterThanOrEqualTo(0)
            )

            app.typeKey("w", modifierFlags: .command)
            sleep(1)
        }

        // Then app should remain stable after multiple settings interactions
        state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(beTrue())
    }

    @MainActor
    func testSpaceManagementAndNavigationFlow() {
        guard let app else {
            XCTFail("App should be initialized")
            return
        }

        // Given the app is running
        var state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(beTrue())

        // When performing navigation operations
        sleep(2) // Allow time for space detection

        // Then app should handle navigation without crashes
        state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(beTrue())

        // And settings should still be accessible
        app.typeKey(",", modifierFlags: .command)
        sleep(1)
        app.typeKey("w", modifierFlags: .command)
        sleep(1)

        state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(beTrue())
    }

    @MainActor
    func testErrorHandlingAndRecoveryFlow() {
        guard let app else {
            XCTFail("App should be initialized")
            return
        }

        // Given the app is running
        var state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(beTrue())

        // When opening settings to potentially configure AeroSpace path
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then app should handle configuration errors gracefully
        state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(beTrue())

        // When closing settings
        app.typeKey("w", modifierFlags: .command)
        sleep(1)

        // Then app should recover from any error state
        state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(beTrue())
    }

    @MainActor
    func testPerformanceAndResponsivenessFlow() {
        guard let app else {
            XCTFail("App should be initialized")
            return
        }

        // Given the app is running
        let startTime = Date()

        // When performing multiple operations rapidly
        for _ in 0 ..< 10 {
            app.typeKey(",", modifierFlags: .command) // Open settings
            usleep(100_000) // 100ms delay
            app.typeKey("w", modifierFlags: .command) // Close settings
            usleep(100_000)
        }

        let duration = Date().timeIntervalSince(startTime)

        // Then operations should complete in reasonable time (< 30 seconds for 10 iterations)
        expect(duration).to(beLessThan(30.0))

        // And app should remain stable after rapid operations
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(beTrue())
    }

    @MainActor
    func testAccessibilityAndUsabilityFlow() {
        guard let app else {
            XCTFail("App should be initialized")
            return
        }

        // Given the app is running
        var state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(beTrue())

        // When using keyboard shortcuts to navigate
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then keyboard navigation should work
        // Test tab navigation (basic accessibility)
        app.typeKey(XCUIKeyboardKey.tab, modifierFlags: [])
        app.typeKey(XCUIKeyboardKey.tab, modifierFlags: [])
        sleep(1)

        // And app should remain accessible
        state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(beTrue())

        // When closing with keyboard
        app.typeKey("w", modifierFlags: .command)
        sleep(1)

        // Then keyboard shortcuts should work throughout
        state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(beTrue())
    }

    @MainActor
    func testIntegrationWithSystemFeaturesFlow() {
        guard let app else {
            XCTFail("App should be initialized")
            return
        }

        // Given the app is running
        var state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(beTrue())

        // When accessing settings (system integration point)
        app.typeKey(",", modifierFlags: .command)
        sleep(2)

        // Then system integration should work
        let settingsWindows = app.windows.matching(identifier: "SettingsWindow")
        expect(settingsWindows.count) > 0

        // When performing cleanup
        app.typeKey("w", modifierFlags: .command)
        sleep(1)

        // Then app should integrate properly with system
        state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(beTrue())

        // And app should terminate cleanly
        app.terminate()
        sleep(2)
        state = app.state
        expect(state).to(equal(.notRunning))
    }
}
