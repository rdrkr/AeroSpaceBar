// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Domain
import Nimble
@testable import Presentation
import SwiftUI
import XCTest

/// Tests for SpaceNavigationPage struct.
///
/// These tests verify:
/// - ID generation from spaceId hash
/// - Name generation from spaceId
/// - Symbol name consistency
/// - Description localization
/// - Icon and view builders
/// - Parent page relationship
/// - Hashable and Equatable conformance
@MainActor
final class SpaceNavigationPageTests: XCTestCase {
    // MARK: - Initialization Tests

    func testInitialization() {
        // Given/When
        let page = SpaceNavigationPage(spaceId: "1")

        // Then
        expect(page.spaceId).to(equal("1"))
        expect(page.id).to(equal("1".hashValue))
    }

    func testIDIsHashOfSpaceId() {
        // Given
        let page1 = SpaceNavigationPage(spaceId: "1")
        let page2 = SpaceNavigationPage(spaceId: "2")
        let pageAlpha = SpaceNavigationPage(spaceId: "A")

        // When/Then
        expect(page1.id).to(equal("1".hashValue))
        expect(page2.id).to(equal("2".hashValue))
        expect(pageAlpha.id).to(equal("A".hashValue))
        expect(page1.id).toNot(equal(page2.id))
    }

    // MARK: - Name Tests

    func testNamePrefix() {
        // Given/When/Then
        expect(SpaceNavigationPage.namePrefix).to(equal("Space "))
    }

    func testNameGenerationNumeric() {
        // Given
        let page1 = SpaceNavigationPage(spaceId: "1")
        let page2 = SpaceNavigationPage(spaceId: "2")
        let page10 = SpaceNavigationPage(spaceId: "10")

        // When
        let name1 = page1.name
        let name2 = page2.name
        let name10 = page10.name

        // Then
        expect(name1.contains("1")).to(beTrue())
        expect(name2.contains("2")).to(beTrue())
        expect(name10.contains("10")).to(beTrue())
    }

    func testNameGenerationAlphabetic() {
        // Given
        let pageA = SpaceNavigationPage(spaceId: "A")
        let pageZ = SpaceNavigationPage(spaceId: "Z")

        // When
        let nameA = pageA.name
        let nameZ = pageZ.name

        // Then
        expect(nameA.contains("A")).to(beTrue())
        expect(nameZ.contains("Z")).to(beTrue())
    }

    // MARK: - Symbol Name Tests

    func testSymbolName() {
        // Given
        let page = SpaceNavigationPage(spaceId: "1")

        // When
        let symbolName = page.symbolName

        // Then
        expect(symbolName).to(equal("square.3.layers.3d.top.filled"))
    }

    // MARK: - Description Tests

    func testDescription() {
        // Given
        let page = SpaceNavigationPage(spaceId: "1")

        // When
        let description = page.description

        // Then
        expect(description.isEmpty).to(beFalse())
        expect(description.contains("appearance") || description.contains("behavior")).to(beTrue())
    }

    // MARK: - Icon Tests

    func testIconIsNotNil() {
        // Given
        let page = SpaceNavigationPage(spaceId: "1")

        // When
        let icon = page.icon

        // Then - Should not crash when accessing icon
        expect(icon).toNot(beNil())
    }

    // MARK: - Parent Page Tests

    func testParentPage() {
        // Given
        let page = SpaceNavigationPage(spaceId: "1")

        // When
        let parentPage = page.parentPage

        // Then
        expect(parentPage).toNot(beNil())
        if let parent = parentPage as? RootNavigationPage {
            expect(parent).to(equal(RootNavigationPage.spaces))
        }
    }

    // MARK: - View Builder Tests

    func testViewForSidebar() {
        // Given
        let page = SpaceNavigationPage(spaceId: "1")

        // When
        let sidebarView = page.viewForSidebar

        // Then - Should not crash when accessing sidebar view
        expect(sidebarView).toNot(beNil())
    }

    func testViewForPage() {
        // Given
        let page = SpaceNavigationPage(spaceId: "1")

        // When
        let pageView = page.viewForPage

        // Then - Should not crash when accessing page view
        expect(pageView).toNot(beNil())
    }

    // MARK: - Hashable Tests

    func testHashable() {
        // Given
        let page1 = SpaceNavigationPage(spaceId: "1")
        let page2 = SpaceNavigationPage(spaceId: "1")
        let page3 = SpaceNavigationPage(spaceId: "2")

        // When
        var hasher1 = Hasher()
        var hasher2 = Hasher()
        var hasher3 = Hasher()
        page1.hash(into: &hasher1)
        page2.hash(into: &hasher2)
        page3.hash(into: &hasher3)

        // Then
        expect(hasher1.finalize()).to(equal(hasher2.finalize()))
        expect(hasher1.finalize()).toNot(equal(hasher3.finalize()))
    }

    func testSetOperations() {
        // Given
        let page1 = SpaceNavigationPage(spaceId: "1")
        let page2 = SpaceNavigationPage(spaceId: "1")
        let page3 = SpaceNavigationPage(spaceId: "2")

        // When
        var set = Set<AnyHashable>()
        set.insert(page1)
        set.insert(page2)
        set.insert(page3)

        // Then
        expect(set.count).to(equal(2), description: "Should have 2 unique pages")
    }

    // MARK: - Equatable Tests

    func testEquality() {
        // Given
        let page1 = SpaceNavigationPage(spaceId: "1")
        let page2 = SpaceNavigationPage(spaceId: "1")
        let page3 = SpaceNavigationPage(spaceId: "2")

        // When/Then
        expect(page1).to(equal(page2))
        expect(page1).toNot(equal(page3))
        expect(page2).toNot(equal(page3))
    }

    func testEqualityWithDifferentSpaceIdTypes() {
        // Given
        let pageNumeric1 = SpaceNavigationPage(spaceId: "1")
        let pageNumeric2 = SpaceNavigationPage(spaceId: "2")
        let pageAlpha = SpaceNavigationPage(spaceId: "A")

        // When/Then
        expect(pageNumeric1).toNot(equal(pageNumeric2))
        expect(pageNumeric1).toNot(equal(pageAlpha))
        expect(pageNumeric2).toNot(equal(pageAlpha))
    }

    // MARK: - NavigationPage Protocol Tests

    func testConformsToNavigationPageProtocol() {
        // Given
        let page: any Domain.NavigationPage = SpaceNavigationPage(spaceId: "1")

        // When/Then
        expect(page.id).toNot(beNil())
        expect(page.name.isEmpty).to(beFalse())
        expect(page.symbolName.isEmpty).to(beFalse())
        expect(page.description.isEmpty).to(beFalse())
        expect(page.parentPage).toNot(beNil())
    }
}
