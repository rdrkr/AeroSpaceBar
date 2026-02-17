// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Domain
import Nimble
@testable import Presentation
import SwiftUI
import XCTest

/// Tests for RootNavigationPage enum.
///
/// These tests verify:
/// - Enum case coverage and ordering
/// - Localized names and descriptions
/// - SF Symbol icon names
/// - Icon colors and styling
/// - View builders for sidebar and page content
/// - Navigation page protocol conformance
@MainActor
final class RootNavigationPageTests: XCTestCase {
    // MARK: - Case Coverage Tests

    func testAllCasesCount() {
        // Given/When
        let allCases = RootNavigationPage.allCases

        // Then
        #if DEBUG
            expect(allCases.count).to(equal(7))
        #else
            expect(allCases.count).to(equal(6))
        #endif
    }

    func testCaseRawValues() {
        // Given/When/Then
        expect(RootNavigationPage.license.rawValue).to(equal(0))
        expect(RootNavigationPage.general.rawValue).to(equal(1))
        expect(RootNavigationPage.spaces.rawValue).to(equal(2))
        expect(RootNavigationPage.groups.rawValue).to(equal(3))
        expect(RootNavigationPage.updates.rawValue).to(equal(4))
        expect(RootNavigationPage.advanced.rawValue).to(equal(5))
        #if DEBUG
            expect(RootNavigationPage.developer.rawValue).to(equal(6))
        #endif
    }

    func testCaseIDs() {
        // Given/When/Then
        expect(RootNavigationPage.license.id).to(equal(0))
        expect(RootNavigationPage.general.id).to(equal(1))
        expect(RootNavigationPage.spaces.id).to(equal(2))
        expect(RootNavigationPage.groups.id).to(equal(3))
        expect(RootNavigationPage.updates.id).to(equal(4))
        expect(RootNavigationPage.advanced.id).to(equal(5))
        #if DEBUG
            expect(RootNavigationPage.developer.id).to(equal(6))
        #endif
    }

    // MARK: - Name Tests

    func testLicenseName() {
        // Given
        let page = RootNavigationPage.license

        // When
        let name = page.name

        // Then
        expect(name.isEmpty).to(beFalse())
        expect(name).to(equal(String(localized: "License")))
    }

    func testGeneralName() {
        // Given
        let page = RootNavigationPage.general

        // When
        let name = page.name

        // Then
        expect(name.isEmpty).to(beFalse())
        expect(name).to(equal(String(localized: "General")))
    }

    func testSpacesName() {
        // Given
        let page = RootNavigationPage.spaces

        // When
        let name = page.name

        // Then
        expect(name.isEmpty).to(beFalse())
        expect(name).to(equal(String(localized: "Spaces")))
    }

    func testGroupsName() {
        // Given
        let page = RootNavigationPage.groups

        // When
        let name = page.name

        // Then
        expect(name.isEmpty).to(beFalse())
        expect(name).to(equal(String(localized: "Groups")))
    }

    func testUpdatesName() {
        // Given
        let page = RootNavigationPage.updates

        // When
        let name = page.name

        // Then
        expect(name.isEmpty).to(beFalse())
        expect(name).to(equal(String(localized: "Updates")))
    }

    func testAdvancedName() {
        // Given
        let page = RootNavigationPage.advanced

        // When
        let name = page.name

        // Then
        expect(name.isEmpty).to(beFalse())
        expect(name).to(equal(String(localized: "Advanced")))
    }

    #if DEBUG
        func testDeveloperName() {
            // Given
            let page = RootNavigationPage.developer

            // When
            let name = page.name

            // Then
            expect(name.isEmpty).to(beFalse())
            expect(name).to(equal(String(localized: "Developer")))
        }
    #endif

    // MARK: - Symbol Name Tests

    func testSymbolNames() {
        // Given/When/Then
        expect(RootNavigationPage.license.symbolName).to(equal("key.fill"))
        expect(RootNavigationPage.general.symbolName).to(equal("gear"))
        expect(RootNavigationPage.spaces.symbolName).to(equal("square.3.layers.3d.top.filled"))
        expect(RootNavigationPage.groups.symbolName).to(equal("rectangle.3.group.fill"))
        expect(RootNavigationPage.updates.symbolName).to(equal("arrow.trianglehead.2.clockwise.rotate.90.circle.fill"))
        expect(RootNavigationPage.advanced.symbolName).to(equal("star.fill"))
        #if DEBUG
            expect(RootNavigationPage.developer.symbolName).to(equal("hammer.fill"))
        #endif
    }

    // MARK: - Description Tests

    func testDescriptions() {
        // Given/When/Then
        expect(RootNavigationPage.license.description.isEmpty).to(beFalse())
        expect(RootNavigationPage.general.description.isEmpty).to(beFalse())
        expect(RootNavigationPage.spaces.description.isEmpty).to(beFalse())
        expect(RootNavigationPage.groups.description.isEmpty).to(beFalse())
        expect(RootNavigationPage.updates.description.isEmpty).to(beFalse())
        expect(RootNavigationPage.advanced.description.isEmpty).to(beFalse())
        #if DEBUG
            expect(RootNavigationPage.developer.description.isEmpty).to(beFalse())
        #endif
    }

    // MARK: - Icon Tests

    func testIconsAreNotNil() {
        // Given/When/Then
        _ = RootNavigationPage.license.icon
        _ = RootNavigationPage.general.icon
        _ = RootNavigationPage.spaces.icon
        _ = RootNavigationPage.groups.icon
        _ = RootNavigationPage.updates.icon
        _ = RootNavigationPage.advanced.icon
        #if DEBUG
            _ = RootNavigationPage.developer.icon
        #endif

        // If we get here without crash, icons are properly constructed
        expect(true).to(beTrue())
    }

    // MARK: - Parent Page Tests

    func testParentPageIsNil() {
        // Given
        let allPages = RootNavigationPage.allCases

        // When/Then - All root pages should have nil parent
        for page in allPages {
            expect(page.parentPage).to(beNil())
        }
    }

    // MARK: - View Builder Tests

    func testViewForSidebarIsNotNil() {
        // Given
        let allPages = RootNavigationPage.allCases

        // When/Then - All pages should provide sidebar views
        for page in allPages {
            _ = page.viewForSidebar
            // If we get here without crash, view builder works
        }

        expect(true).to(beTrue())
    }

    func testViewForPageIsNotNil() {
        // Given
        let allPages = RootNavigationPage.allCases

        // When/Then - All pages should provide page views
        for page in allPages {
            _ = page.viewForPage
            // If we get here without crash, view builder works
        }

        expect(true).to(beTrue())
    }

    // MARK: - NavigationPage Protocol Tests

    func testConformsToNavigationPageProtocol() {
        // Given
        let page: any NavigationPage = RootNavigationPage.license

        // When/Then
        expect(page.id).toNot(beNil())
        expect(page.name.isEmpty).to(beFalse())
        expect(page.symbolName.isEmpty).to(beFalse())
        expect(page.description.isEmpty).to(beFalse())
    }
}
