// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

@testable import Domain
import Nimble
import SwiftUI
import XCTest

/// Tests for AnyNavigationPage type-erased wrapper.
///
/// These tests verify:
/// - Type erasure for NavigationPage protocol
/// - Property forwarding from wrapped page
/// - Hashable and Equatable conformance
/// - View builder forwarding
@MainActor
final class AnyNavigationPageTests: XCTestCase {
    // MARK: - Mock Navigation Page

    private struct MockNavigationPage: NavigationPage, Hashable, Equatable {
        let id: Int
        let name: String
        let symbolName: String
        let description: String
        let parentPage: (any NavigationPage)?

        var icon: AnyView {
            AnyView(defaultIcon)
        }

        var viewForSidebar: AnyView {
            AnyView(defaultViewForSidebar(icon))
        }

        var viewForPage: PageView {
            PageView(Text("Mock Page"))
        }

        // MARK: - Hashable

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        // MARK: - Equatable

        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.id == rhs.id
        }
    }

    // MARK: - Initialization Tests

    func testInitializationWrapsPage() {
        // Given
        let mockPage = MockNavigationPage(
            id: 1,
            name: "Test",
            symbolName: "star",
            description: "Test description",
            parentPage: nil
        )

        // When
        let anyPage = AnyNavigationPage(mockPage)

        // Then
        expect(anyPage.id) == mockPage.id
        expect(anyPage.name) == mockPage.name
        expect(anyPage.symbolName) == mockPage.symbolName
        expect(anyPage.description) == mockPage.description
    }

    func testInitializationPreservesParentPage() {
        // Given
        let parentPage = MockNavigationPage(
            id: 0,
            name: "Parent",
            symbolName: "folder",
            description: "Parent page",
            parentPage: nil
        )
        let mockPage = MockNavigationPage(
            id: 1,
            name: "Child",
            symbolName: "doc",
            description: "Child page",
            parentPage: parentPage
        )

        // When
        let anyPage = AnyNavigationPage(mockPage)

        // Then
        expect(anyPage.parentPage).toNot(beNil())
        expect(anyPage.parentPage?.id) == parentPage.id
    }

    // MARK: - Property Tests

    func testIDProperty() {
        // Given
        let mockPage = MockNavigationPage(
            id: 42,
            name: "Test",
            symbolName: "star",
            description: "Test",
            parentPage: nil
        )

        // When
        let anyPage = AnyNavigationPage(mockPage)

        // Then
        expect(anyPage.id) == 42
    }

    func testNameProperty() {
        // Given
        let mockPage = MockNavigationPage(
            id: 1,
            name: "Custom Name",
            symbolName: "star",
            description: "Test",
            parentPage: nil
        )

        // When
        let anyPage = AnyNavigationPage(mockPage)

        // Then
        expect(anyPage.name) == "Custom Name"
    }

    func testSymbolNameProperty() {
        // Given
        let mockPage = MockNavigationPage(
            id: 1,
            name: "Test",
            symbolName: "gear",
            description: "Test",
            parentPage: nil
        )

        // When
        let anyPage = AnyNavigationPage(mockPage)

        // Then
        expect(anyPage.symbolName) == "gear"
    }

    func testDescriptionProperty() {
        // Given
        let mockPage = MockNavigationPage(
            id: 1,
            name: "Test",
            symbolName: "star",
            description: "Custom description",
            parentPage: nil
        )

        // When
        let anyPage = AnyNavigationPage(mockPage)

        // Then
        expect(anyPage.description) == "Custom description"
    }

    // MARK: - View Builder Tests

    func testIconViewBuilder() {
        // Given
        let mockPage = MockNavigationPage(
            id: 1,
            name: "Test",
            symbolName: "star",
            description: "Test",
            parentPage: nil
        )
        let anyPage = AnyNavigationPage(mockPage)

        // When
        let icon = anyPage.icon

        // Then - Should not crash when accessing icon
        expect(icon).toNot(beNil())
    }

    func testViewForPageBuilder() {
        // Given
        let mockPage = MockNavigationPage(
            id: 1,
            name: "Test",
            symbolName: "star",
            description: "Test",
            parentPage: nil
        )
        let anyPage = AnyNavigationPage(mockPage)

        // When
        let pageView = anyPage.viewForPage

        // Then - Should not crash when accessing page view
        expect(pageView).toNot(beNil())
    }

    func testViewForSidebarBuilder() {
        // Given
        let mockPage = MockNavigationPage(
            id: 1,
            name: "Test",
            symbolName: "star",
            description: "Test",
            parentPage: nil
        )
        let anyPage = AnyNavigationPage(mockPage)

        // When
        let sidebarView = anyPage.viewForSidebar

        // Then - Should not crash when accessing sidebar view
        expect(sidebarView).toNot(beNil())
    }

    // MARK: - Hashable Tests

    func testHashable() {
        // Given
        let mockPage1 = MockNavigationPage(
            id: 1,
            name: "Test1",
            symbolName: "star",
            description: "Test",
            parentPage: nil
        )
        let mockPage2 = MockNavigationPage(
            id: 1,
            name: "Test2",
            symbolName: "gear",
            description: "Different",
            parentPage: nil
        )
        let mockPage3 = MockNavigationPage(
            id: 2,
            name: "Test3",
            symbolName: "star",
            description: "Test",
            parentPage: nil
        )

        let anyPage1 = AnyNavigationPage(mockPage1)
        let anyPage2 = AnyNavigationPage(mockPage2)
        let anyPage3 = AnyNavigationPage(mockPage3)

        // When
        var hasher1 = Hasher()
        var hasher2 = Hasher()
        var hasher3 = Hasher()
        anyPage1.hash(into: &hasher1)
        anyPage2.hash(into: &hasher2)
        anyPage3.hash(into: &hasher3)

        // Then - Same ID should produce same hash
        expect(hasher1.finalize()) == hasher2.finalize()
        expect(hasher1.finalize()) != hasher3.finalize()
    }

    func testSetOperations() {
        // Given
        let mockPage1 = MockNavigationPage(id: 1, name: "A", symbolName: "star", description: "Test", parentPage: nil)
        let mockPage2 = MockNavigationPage(id: 1, name: "B", symbolName: "gear", description: "Test", parentPage: nil)
        let mockPage3 = MockNavigationPage(id: 2, name: "C", symbolName: "star", description: "Test", parentPage: nil)

        let anyPage1 = AnyNavigationPage(mockPage1)
        let anyPage2 = AnyNavigationPage(mockPage2)
        let anyPage3 = AnyNavigationPage(mockPage3)

        // When
        var set = Set<AnyHashable>()
        set.insert(anyPage1)
        set.insert(anyPage2)
        set.insert(anyPage3)

        // Then
        expect(set.count) == 2
    }

    // MARK: - Equatable Tests

    func testEquality() {
        // Given
        let mockPage1 = MockNavigationPage(id: 1, name: "A", symbolName: "star", description: "Test", parentPage: nil)
        let mockPage2 = MockNavigationPage(
            id: 1,
            name: "B",
            symbolName: "gear",
            description: "Different",
            parentPage: nil
        )
        let mockPage3 = MockNavigationPage(id: 2, name: "C", symbolName: "star", description: "Test", parentPage: nil)

        let anyPage1 = AnyNavigationPage(mockPage1)
        let anyPage2 = AnyNavigationPage(mockPage2)
        let anyPage3 = AnyNavigationPage(mockPage3)

        // When/Then - Equality based on ID only
        expect(anyPage1 == anyPage2) == true
        expect(anyPage1 != anyPage3) == true
        expect(anyPage2 != anyPage3) == true
    }

    // MARK: - NavigationPage Protocol Tests

    func testConformsToNavigationPageProtocol() {
        // Given
        let mockPage = MockNavigationPage(
            id: 1,
            name: "Test",
            symbolName: "star",
            description: "Test description",
            parentPage: nil
        )
        let anyPage = AnyNavigationPage(mockPage)

        // When
        let page: any NavigationPage = anyPage

        // Then - Should compile and work
        expect(page.id) == 1
        expect(page.name) == "Test"
        expect(page.symbolName) == "star"
        expect(page.description) == "Test description"
    }

    // MARK: - Type Erasure Tests

    func testTypeErasureAllowsHeterogeneousCollection() {
        // Given
        let mockPage1 = MockNavigationPage(id: 1, name: "A", symbolName: "star", description: "Test", parentPage: nil)
        let mockPage2 = MockNavigationPage(id: 2, name: "B", symbolName: "gear", description: "Test", parentPage: nil)

        // When
        let pages: [AnyNavigationPage] = [
            AnyNavigationPage(mockPage1),
            AnyNavigationPage(mockPage2)
        ]

        // Then
        expect(pages.count) == 2
        expect(pages[0].id) == 1
        expect(pages[1].id) == 2
    }
}
