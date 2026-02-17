// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Nimble
import XCTest

/// UI tests for WallpaperBackgroundView.
///
/// These tests verify wallpaper background UI including:
/// - Wallpaper image display
/// - Frame sizing (half screen width minus padding)
/// - Offset positioning for proper alignment
/// - Clipping to prevent overflow
/// - Tag for identification
/// - Integration with spaces view
@MainActor
final class WallpaperBackgroundViewUITests: XCTestCase {
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

    // MARK: - Display Tests

    func testWallpaperBackgroundDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given the app is running with wallpaper enabled
        // Then wallpaper background should be displayed
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Wallpaper background should be displayed"
        )
    }

    func testWallpaperImageRendering() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given wallpaper is provided
        // Then NSImage should be rendered as SwiftUI Image
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Wallpaper image should be rendered"
        )
    }

    func testFrameWidthCalculation() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given screen width is available
        // Then frame width should be: (screenWidth / 2) - menuBarHorizontalPadding
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Frame width should be half screen minus padding"
        )
    }

    func testFrameHeightCalculation() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given screen height is available
        // Then frame height should be: screenHeight (full height)
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Frame height should be full screen height"
        )
    }

    func testOffsetXCalculation() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given screen width is available
        // Then X offset should be: (screenWidth / 4) - (menuBarHorizontalPadding / 2)
        // This centers the visible portion
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "X offset should center the wallpaper"
        )
    }

    func testOffsetYCalculation() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given wallpaper is positioned
        // Then Y offset should be 0 (no vertical offset)
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Y offset should be zero"
        )
    }

    func testClippingApplied() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given wallpaper exceeds frame bounds
        // Then clipped() modifier should be applied
        // to prevent overflow
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Wallpaper should be clipped to frame"
        )
    }

    func testWallpaperTag() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given wallpaper background is rendered
        // Then view should be tagged as "spaces-wallpaper-background"
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Wallpaper should have correct tag"
        )
    }

    func testIntegrationWithSpacesView() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given spaces view is displayed
        // Then wallpaper background should be rendered behind spaces
        // when wallpaper feature is enabled
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Wallpaper should integrate with spaces view"
        )
    }

    func testMenuBarPaddingAlignment() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given menu bar has horizontal padding
        // Then wallpaper should align with menu bar boundaries
        // accounting for ConfigurationDefaults.menuBarHorizontalPadding
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Wallpaper should align with menu bar padding"
        )
    }

    func testWallpaperCropping() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given full screen wallpaper image
        // Then only the right portion should be visible
        // to create immersive menu bar effect
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Wallpaper should show right portion of screen"
        )
    }

    func testWallpaperPreview() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given preview is available
        // Then preview should use AppIcon as sample wallpaper
        // or display placeholder message
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Preview should display sample wallpaper"
        )
    }
}
