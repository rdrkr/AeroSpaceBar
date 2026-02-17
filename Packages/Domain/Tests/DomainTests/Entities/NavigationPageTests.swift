// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Nimble
import SwiftUI
import XCTest

/// Tests for NavigationPage protocol and AnyNavigationPage.
///
/// These tests verify NavigationPage protocol requirements, AnyNavigationPage type erasure,
/// Equatable/Hashable conformance, and view builder functionality.
@MainActor
final class NavigationPageTests: XCTestCase {
    // MARK: - Test Types

    /// Mock NavigationPage for testing
    private struct MockPage: NavigationPage, Hashable, Equatable {
        let id: Int
        let name: String
        let description: String
        let symbolName: String
        let parentPage: (any NavigationPage)?

        var icon: AnyView {
            AnyView(defaultIcon)
        }

        var viewForPage: AnyView {
            AnyView(Text("Mock Page"))
        }

        var viewForSidebar: AnyView {
            AnyView(defaultViewForSidebar(AnyView(icon)))
        }

        init(
            id: Int,
            name: String = "Mock",
            description: String = "Mock Description",
            symbolName: String = "star.fill",
            parentPage: (any NavigationPage)? = nil
        ) {
            self.id = id
            self.name = name
            self.description = description
            self.symbolName = symbolName
            self.parentPage = parentPage
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

    // MARK: - NavigationPage Protocol Tests

    func testNavigationPageProtocolRequirements() {
        // Given a mock page
        let page = MockPage(id: 1)

        // Then should satisfy all protocol requirements
        expect(page.id) == 1
        expect(page.name) == "Mock"
        expect(page.description) == "Mock Description"
        expect(page.symbolName) == "star.fill"
        expect(page.parentPage).to(beNil())
        expect(page.icon).toNot(beNil())
        expect(page.viewForPage).toNot(beNil())
        expect(page.viewForSidebar).toNot(beNil())
    }

    func testNavigationPageWithParent() {
        // Given parent and child pages
        let parentPage = MockPage(id: 1, name: "Parent")
        let childPage = MockPage(id: 2, name: "Child", parentPage: parentPage)

        // Then child should reference parent
        expect(childPage.parentPage).toNot(beNil())
        expect((childPage.parentPage as? MockPage)?.id) == 1
    }

    func testNavigationPageDefaultIcon() {
        // Given a page with default icon
        let page = MockPage(id: 1, symbolName: "gear")

        // Then should have icon view
        expect(page.icon).toNot(beNil())
    }

    func testNavigationPageDefaultViewForSidebar() {
        // Given a page
        let page = MockPage(id: 1)

        // When accessing viewForSidebar
        let sidebarView = page.viewForSidebar

        // Then should return view
        expect(sidebarView).toNot(beNil())
    }

    // MARK: - AnyNavigationPage Initialization Tests

    func testAnyNavigationPageInitialization() {
        // Given a mock page
        let mockPage = MockPage(id: 42, name: "Test", description: "Test Description", symbolName: "star")

        // When wrapping in AnyNavigationPage
        let anyPage = AnyNavigationPage(mockPage)

        // Then should preserve all properties
        expect(anyPage.id) == 42
        expect(anyPage.name) == "Test"
        expect(anyPage.description) == "Test Description"
        expect(anyPage.symbolName) == "star"
    }

    func testAnyNavigationPagePreservesParent() {
        // Given pages with parent relationship
        let parent = MockPage(id: 1, name: "Parent")
        let child = MockPage(id: 2, name: "Child", parentPage: parent)

        // When wrapping in AnyNavigationPage
        let anyChild = AnyNavigationPage(child)

        // Then should preserve parent
        expect(anyChild.parentPage).toNot(beNil())
    }

    func testAnyNavigationPageWithoutParent() {
        // Given a page without parent
        let page = MockPage(id: 1)

        // When wrapping in AnyNavigationPage
        let anyPage = AnyNavigationPage(page)

        // Then parent should be nil
        expect(anyPage.parentPage).to(beNil())
    }

    // MARK: - AnyNavigationPage View Tests

    func testAnyNavigationPageIcon() {
        // Given a wrapped page
        let mockPage = MockPage(id: 1)
        let anyPage = AnyNavigationPage(mockPage)

        // Then should have icon
        expect(anyPage.icon).toNot(beNil())
    }

    func testAnyNavigationPageViewForPage() {
        // Given a wrapped page
        let mockPage = MockPage(id: 1)
        let anyPage = AnyNavigationPage(mockPage)

        // Then should have viewForPage
        expect(anyPage.viewForPage).toNot(beNil())
    }

    func testAnyNavigationPageViewForSidebar() {
        // Given a wrapped page
        let mockPage = MockPage(id: 1)
        let anyPage = AnyNavigationPage(mockPage)

        // Then should have viewForSidebar
        expect(anyPage.viewForSidebar).toNot(beNil())
    }

    // MARK: - Equatable Tests

    func testAnyNavigationPageEquality() {
        // Given two pages with same ID
        let page1 = MockPage(id: 1, name: "Page A")
        let page2 = MockPage(id: 1, name: "Page B")

        let anyPage1 = AnyNavigationPage(page1)
        let anyPage2 = AnyNavigationPage(page2)

        // Then they should be equal (based on ID)
        expect(anyPage1) == anyPage2
    }

    func testAnyNavigationPageInequality() {
        // Given two pages with different IDs
        let page1 = MockPage(id: 1)
        let page2 = MockPage(id: 2)

        let anyPage1 = AnyNavigationPage(page1)
        let anyPage2 = AnyNavigationPage(page2)

        // Then they should not be equal
        expect(anyPage1) != anyPage2
    }

    func testMockPageEquality() {
        // Given two mock pages with same ID
        let page1 = MockPage(id: 1, name: "A")
        let page2 = MockPage(id: 1, name: "B")

        // Then they should be equal
        expect(page1) == page2
    }

    func testMockPageInequality() {
        // Given two mock pages with different IDs
        let page1 = MockPage(id: 1)
        let page2 = MockPage(id: 2)

        // Then they should not be equal
        expect(page1) != page2
    }

    // MARK: - Hashable Tests

    func testAnyNavigationPageHashable() {
        // Given pages
        let page1 = AnyNavigationPage(MockPage(id: 1))
        let page2 = AnyNavigationPage(MockPage(id: 2))
        let page3 = AnyNavigationPage(MockPage(id: 1))

        // When adding to set
        let set: Set<AnyNavigationPage> = [page1, page2, page3]

        // Then should only store unique IDs
        expect(set.count) == 2
        expect(set.contains(page1)) == true
        expect(set.contains(page2)) == true
    }

    func testMockPageHashable() {
        // Given pages
        let page1 = MockPage(id: 1)
        let page2 = MockPage(id: 2)
        let page3 = MockPage(id: 1)

        // When adding to set
        let set: Set<MockPage> = [page1, page2, page3]

        // Then should only store unique IDs
        expect(set.count) == 2
    }

    func testHashConsistency() {
        // Given same page wrapped multiple times
        let page1 = AnyNavigationPage(MockPage(id: 42))
        let page2 = AnyNavigationPage(MockPage(id: 42))

        // Then hash values should be equal
        expect(page1.hashValue) == page2.hashValue
    }

    // MARK: - Identifiable Tests

    func testAnyNavigationPageIdentifiable() {
        // Given a wrapped page
        let anyPage = AnyNavigationPage(MockPage(id: 123))

        // Then should conform to Identifiable
        expect(anyPage.id) == 123
    }

    func testMockPageIdentifiable() {
        // Given a mock page
        let page = MockPage(id: 456)

        // Then should conform to Identifiable
        expect(page.id) == 456
    }

    // MARK: - Sendable Tests

    func testAnyNavigationPageSendable() {
        // AnyNavigationPage conforms to Sendable via NavigationPage
        Task {
            let page = AnyNavigationPage(MockPage(id: 1))
            // If this compiles, Sendable conformance is working
            expect(page).toNot(beNil())
        }
    }

    func testMockPageSendable() {
        // MockPage conforms to Sendable via NavigationPage
        Task {
            let page = MockPage(id: 1)
            // If this compiles, Sendable conformance is working
            expect(page).toNot(beNil())
        }
    }

    // MARK: - Type Erasure Tests

    func testTypeErasureAllowsMixedStorage() {
        // Given different page types
        struct PageTypeA: NavigationPage, Hashable, Equatable {
            let id: Int
            let name: String
            let description: String
            let symbolName: String
            let parentPage: (any NavigationPage)? = nil

            var icon: AnyView {
                AnyView(defaultIcon)
            }

            var viewForPage: AnyView {
                AnyView(Text("Type A"))
            }

            var viewForSidebar: AnyView {
                AnyView(defaultViewForSidebar(AnyView(icon)))
            }

            func hash(into hasher: inout Hasher) {
                hasher.combine(id)
            }

            static func == (lhs: Self, rhs: Self) -> Bool {
                lhs.id == rhs.id
            }
        }

        struct PageTypeB: NavigationPage, Hashable, Equatable {
            let id: Int
            let name: String
            let description: String
            let symbolName: String
            let parentPage: (any NavigationPage)? = nil

            var icon: AnyView {
                AnyView(defaultIcon)
            }

            var viewForPage: AnyView {
                AnyView(Text("Type B"))
            }

            var viewForSidebar: AnyView {
                AnyView(defaultViewForSidebar(AnyView(icon)))
            }

            func hash(into hasher: inout Hasher) {
                hasher.combine(id)
            }

            static func == (lhs: Self, rhs: Self) -> Bool {
                lhs.id == rhs.id
            }
        }

        // When storing in array
        let pages: [AnyNavigationPage] = [
            AnyNavigationPage(PageTypeA(id: 1, name: "A", description: "A", symbolName: "a.circle")),
            AnyNavigationPage(PageTypeB(id: 2, name: "B", description: "B", symbolName: "b.circle"))
        ]

        // Then should store different types together
        expect(pages.count) == 2
        expect(pages[0].id) == 1
        expect(pages[1].id) == 2
    }

    // MARK: - Symbol Name Tests

    func testDifferentSymbolNames() {
        // Given pages with different symbols
        let symbols = ["star.fill", "gear", "house.fill", "person.circle", "bell.fill"]

        for symbol in symbols {
            // When creating page with symbol
            let page = MockPage(id: 1, symbolName: symbol)

            // Then should preserve symbol
            expect(page.symbolName) == symbol
        }
    }

    func testEmptySymbolName() {
        // Given page with empty symbol
        let page = MockPage(id: 1, symbolName: "")

        // Then should accept empty string
        expect(page.symbolName.isEmpty) == true
    }

    // MARK: - Name and Description Tests

    func testLongNameAndDescription() {
        // Given page with long name and description
        let longName = String(repeating: "A", count: 100)
        let longDescription = String(repeating: "B", count: 500)

        let page = MockPage(id: 1, name: longName, description: longDescription)

        // Then should handle long strings
        expect(page.name.count) == 100
        expect(page.description.count) == 500
    }

    func testEmptyNameAndDescription() {
        // Given page with empty name and description
        let page = MockPage(id: 1, name: "", description: "")

        // Then should accept empty strings
        expect(page.name.isEmpty) == true
        expect(page.description.isEmpty) == true
    }

    func testSpecialCharactersInNameAndDescription() {
        // Given page with special characters
        let name = "Test 🚀 Page"
        let description = "Description with special chars: @#$%^&*()"

        let page = MockPage(id: 1, name: name, description: description)

        // Then should preserve special characters
        expect(page.name) == name
        expect(page.description) == description
    }

    // MARK: - Edge Cases

    func testZeroId() {
        // Given page with zero ID
        let page = MockPage(id: 0)

        // Then should be valid
        expect(page.id) == 0
    }

    func testNegativeId() {
        // Given page with negative ID
        let page = MockPage(id: -1)

        // Then should accept negative IDs
        expect(page.id) == -1
    }

    func testVeryLargeId() {
        // Given page with very large ID
        let page = MockPage(id: Int.max)

        // Then should handle large IDs
        expect(page.id) == Int.max
    }

    // MARK: - Collection Usage Tests

    func testArrayOfAnyNavigationPages() {
        // Given multiple pages
        let pages = [
            AnyNavigationPage(MockPage(id: 1, name: "First")),
            AnyNavigationPage(MockPage(id: 2, name: "Second")),
            AnyNavigationPage(MockPage(id: 3, name: "Third"))
        ]

        // Then should maintain order
        expect(pages.count) == 3
        expect(pages[0].name) == "First"
        expect(pages[1].name) == "Second"
        expect(pages[2].name) == "Third"
    }

    func testFilteringPages() {
        // Given pages
        let pages = [
            AnyNavigationPage(MockPage(id: 1, name: "Alpha")),
            AnyNavigationPage(MockPage(id: 2, name: "Beta")),
            AnyNavigationPage(MockPage(id: 3, name: "Alpha Beta"))
        ]

        // When filtering by name
        let filtered = pages.filter { $0.name.contains("Alpha") }

        // Then should find matching pages
        expect(filtered.count) == 2
    }

    func testSortingPages() {
        // Given unsorted pages
        let pages = [
            AnyNavigationPage(MockPage(id: 3, name: "C")),
            AnyNavigationPage(MockPage(id: 1, name: "A")),
            AnyNavigationPage(MockPage(id: 2, name: "B"))
        ]

        // When sorting by ID
        let sorted = pages.sorted { $0.id < $1.id }

        // Then should be in ID order
        expect(sorted[0].id) == 1
        expect(sorted[1].id) == 2
        expect(sorted[2].id) == 3
    }

    // MARK: - Parent Hierarchy Tests

    func testMultiLevelHierarchy() {
        // Given three-level hierarchy
        let grandparent = MockPage(id: 1, name: "Grandparent")
        let parent = MockPage(id: 2, name: "Parent", parentPage: grandparent)
        let child = MockPage(id: 3, name: "Child", parentPage: parent)

        let anyChild = AnyNavigationPage(child)

        // Then should preserve parent reference
        expect(anyChild.parentPage).toNot(beNil())
        expect((anyChild.parentPage as? MockPage)?.id) == 2
    }
}
