// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Nimble
@testable import Presentation
import SwiftUI
import XCTest

/// Tests for Theme system (colors and animations).
///
/// These tests verify:
/// - Color system semantic colors
/// - Shadow color definitions
/// - Animation timing constants
@MainActor
final class ThemeTests: XCTestCase {
    // MARK: - Semantic Color Tests

    func testThemePrimaryColor() {
        // Given/When
        let color = Color.themePrimary

        // Then
        expect(color).to(equal(.blue))
    }

    func testThemeSuccessColor() {
        // Given/When
        let color = Color.themeSuccess

        // Then
        expect(color).to(equal(.green))
    }

    func testThemeErrorColor() {
        // Given/When
        let color = Color.themeError

        // Then
        expect(color).to(equal(.red))
    }

    func testThemeWarningColor() {
        // Given/When
        let color = Color.themeWarning

        // Then
        expect(color).to(equal(.orange))
    }

    func testThemeSecondaryColor() {
        // Given/When
        let color = Color.themeSecondary

        // Then
        expect(color == .secondary).to(beTrue())
    }

    // MARK: - Shadow Color Tests

    func testShadowColor() {
        // Given/When
        let shadow = Color.shadow

        // Then - Should be black with opacity
        expect(shadow == Color.black.opacity(0.5)).to(beTrue())
    }

    func testIconShadowColor() {
        // Given/When
        let shadow = Color.iconShadow

        // Then - Should be black with light opacity
        expect(shadow == Color.black.opacity(0.1)).to(beTrue())
    }

    func testForegroundShadowColor() {
        // Given/When
        let shadow = Color.foregroundShadow

        // Then - Should be black with opacity
        expect(shadow == Color.black.opacity(0.5)).to(beTrue())
    }

    func testThemeShadowColor() {
        // Given/When
        let shadow = Color.themeShadow

        // Then
        expect(shadow == .shadow).to(beTrue())
    }

    func testThemeIconShadowColor() {
        // Given/When
        let shadow = Color.themeIconShadow

        // Then
        expect(shadow == .iconShadow).to(beTrue())
    }

    func testThemeForegroundShadowColor() {
        // Given/When
        let shadow = Color.themeForegroundShadow

        // Then
        expect(shadow == .foregroundShadow).to(beTrue())
    }

    // MARK: - Animation Tests

    func testThemeSmoothAnimation() {
        // Given/When
        let animation = Animation.themeSmooth

        // Then
        expect(animation == .smooth(duration: 0.3)).to(beTrue())
    }

    func testThemeSmoothFastestAnimation() {
        // Given/When
        let animation = Animation.themeSmoothFastest

        // Then
        expect(animation == .smooth(duration: 0.05)).to(beTrue())
    }

    func testThemeSmoothFastAnimation() {
        // Given/When
        let animation = Animation.themeSmoothFast

        // Then
        expect(animation == .smooth(duration: 0.15)).to(beTrue())
    }

    func testThemeSmoothSlowAnimation() {
        // Given/When
        let animation = Animation.themeSmoothSlow

        // Then
        expect(animation == .smooth(duration: 0.5)).to(beTrue())
    }

    func testThemeEaseInOutAnimation() {
        // Given/When
        let animation = Animation.themeEaseInOut

        // Then
        expect(animation == .easeInOut(duration: 0.3)).to(beTrue())
    }

    func testThemeEaseInOutFastestAnimation() {
        // Given/When
        let animation = Animation.themeEaseInOutFastest

        // Then
        expect(animation == .easeInOut(duration: 0.05)).to(beTrue())
    }

    func testThemeEaseInOutFastAnimation() {
        // Given/When
        let animation = Animation.themeEaseInOutFast

        // Then
        expect(animation == .easeInOut(duration: 0.15)).to(beTrue())
    }

    func testThemeEaseInOutSlowAnimation() {
        // Given/When
        let animation = Animation.themeEaseInOutSlow

        // Then
        expect(animation == .easeInOut(duration: 0.5)).to(beTrue())
    }

    // MARK: - Color Usage Tests

    func testThemeColorsAreAccessible() {
        // Given/When/Then - Should not crash when accessing theme colors
        _ = Color.themePrimary
        _ = Color.themeSuccess
        _ = Color.themeError
        _ = Color.themeWarning
        _ = Color.themeSecondary
        _ = Color.themeCardBackground
        _ = Color.themeShadow
        _ = Color.themeIconShadow
        _ = Color.themeForegroundShadow
        expect(true).to(beTrue())
    }

    // MARK: - Animation Usage Tests

    func testThemeAnimationsAreAccessible() {
        // Given/When/Then - Should not crash when accessing theme animations
        _ = Animation.themeSmooth
        _ = Animation.themeSmoothFastest
        _ = Animation.themeSmoothFast
        _ = Animation.themeSmoothSlow
        _ = Animation.themeEaseInOut
        _ = Animation.themeEaseInOutFastest
        _ = Animation.themeEaseInOutFast
        _ = Animation.themeEaseInOutSlow
        expect(true).to(beTrue())
    }
}
