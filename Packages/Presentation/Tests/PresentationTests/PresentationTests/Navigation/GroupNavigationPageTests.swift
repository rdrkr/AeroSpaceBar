// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Nimble
@testable import Presentation
import SwiftUI
import XCTest

/// Tests for GroupNavigationPage struct.
///
/// These tests verify:
/// - ID and name generation from index
/// - Symbol name consistency
/// - Description localization
/// - Icon and view builders
/// - Parent page relationship
/// - Hashable and Equatable conformance
@MainActor
final class GroupNavigationPageTests: XCTestCase {
    // MARK: - Initialization Tests

    func testInitialization() {
        // Given/When
        let page = GroupNavigationPage(index: 0)

        // Then
        expect(page.index) == 0
        expect(page.id) == 0
    }

    func testIDMatchesIndex() {
        // Given
        let pages = (0 ..< 5).map { GroupNavigationPage(index: $0) }

        // When/Then
        for (expectedIndex, page) in pages.enumerated() {
            expect(page.id) == expectedIndex
            expect(page.index) == expectedIndex
        }
    }

    // MARK: - Name Tests

    func testNamePrefix() {
        // Given/When/Then
        expect(GroupNavigationPage.namePrefix) == "Group "
    }

    func testNameGeneration() {
        // Given
        let page0 = GroupNavigationPage(index: 0)
        let page1 = GroupNavigationPage(index: 1)
        let page5 = GroupNavigationPage(index: 5)

        // When
        let name0 = page0.name
        let name1 = page1.name
        let name5 = page5.name

        // Then - Names should use 1-based indexing (id + 1)
        expect(name0.contains("1")) == true
        expect(name1.contains("2")) == true
        expect(name5.contains("6")) == true
    }

    // MARK: - Symbol Name Tests

    func testSymbolName() {
        // Given
        let page = GroupNavigationPage(index: 0)

        // When
        let symbolName = page.symbolName

        // Then
        expect(symbolName) == "rectangle.3.group"
    }

    // MARK: - Description Tests

    func testDescription() {
        // Given
        let page = GroupNavigationPage(index: 0)

        // When
        let description = page.description

        // Then
        expect(description.isEmpty) == false
        expect(description.contains("appearance") || description.contains("behavior")) == true
    }

    // MARK: - Icon Tests

    func testIconIsNotNil() {
        // Given
        let page = GroupNavigationPage(index: 0)

        // When
        let icon = page.icon

        // Then - Should not crash when accessing icon
        expect(icon).toNot(beNil())
    }

    // MARK: - Parent Page Tests

    func testParentPage() {
        // Given
        let page = GroupNavigationPage(index: 0)

        // When
        let parentPage = page.parentPage

        // Then
        expect(parentPage).toNot(beNil())
        if let parent = parentPage as? RootNavigationPage {
            expect(parent) == RootNavigationPage.groups
        }
    }

    // MARK: - View Builder Tests

    func testViewForSidebar() {
        // Given
        let page = GroupNavigationPage(index: 0)

        // When
        let sidebarView = page.viewForSidebar

        // Then - Should not crash when accessing sidebar view
        expect(sidebarView).toNot(beNil())
    }

    func testViewForPage() {
        // Given
        let page = GroupNavigationPage(index: 0)

        // When
        let pageView = page.viewForPage

        // Then - Should not crash when accessing page view
        expect(pageView).toNot(beNil())
    }

    // MARK: - Hashable Tests

    func testHashable() {
        // Given
        let page1 = GroupNavigationPage(index: 0)
        let page2 = GroupNavigationPage(index: 0)
        let page3 = GroupNavigationPage(index: 1)

        // When
        var hasher1 = Hasher()
        var hasher2 = Hasher()
        var hasher3 = Hasher()
        page1.hash(into: &hasher1)
        page2.hash(into: &hasher2)
        page3.hash(into: &hasher3)

        // Then
        expect(hasher1.finalize()) == hasher2.finalize()
        expect(hasher1.finalize()) != hasher3.finalize()
    }

    func testSetOperations() {
        // Given
        let page1 = GroupNavigationPage(index: 0)
        let page2 = GroupNavigationPage(index: 0)
        let page3 = GroupNavigationPage(index: 1)

        // When
        var set = Set<AnyHashable>()
        set.insert(page1)
        set.insert(page2)
        set.insert(page3)

        // Then
        expect(set.count) == 2
    }

    // MARK: - Equatable Tests

    func testEquality() {
        // Given
        let page1 = GroupNavigationPage(index: 0)
        let page2 = GroupNavigationPage(index: 0)
        let page3 = GroupNavigationPage(index: 1)

        // When/Then
        expect(page1) == page2
        expect(page1) != page3
        expect(page2) != page3
    }

    // MARK: - NavigationPage Protocol Tests

    func testConformsToNavigationPageProtocol() {
        // Given
        let page = GroupNavigationPage(index: 0)

        // When/Then
        expect(page.id).toNot(beNil())
        expect(page.name.isEmpty) == false
        expect(page.symbolName.isEmpty) == false
        expect(page.description.isEmpty) == false
        expect(page.parentPage).toNot(beNil())
    }
}
