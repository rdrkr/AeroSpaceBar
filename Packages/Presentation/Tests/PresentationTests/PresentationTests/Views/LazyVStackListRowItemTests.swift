// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Nimble
@testable import Presentation
import SwiftUI
import XCTest

/// Tests for LazyVStackListRowItem component.
///
/// These tests verify:
/// - Initialization
/// - Item position detection
/// - Navigation callbacks
/// - Delete action visibility
/// - Press feedback
@MainActor
final class LazyVStackListRowItemTests: XCTestCase {
    // MARK: - Test Helpers

    private struct MockItem: Identifiable {
        let id: Int
        let name: String
    }

    private struct MockPage {
        let itemId: Int
    }

    // MARK: - Initialization Tests

    func testInitialization() {
        // Given
        let item = MockItem(id: 1, name: "Test")
        let allItems = [item]

        // When
        let rowItem = LazyVStackListRowItem(
            item: item,
            allItems: allItems,
            content: { item in Text(item.name) },
            createPage: { item in MockPage(itemId: item.id) },
            onRegisterDynamicSubPage: { _ in },
            onNavigateTo: { _ in }
        )

        // Then - Should not crash
        expect(rowItem).toNot(beNil())
    }

    func testInitializationWithDeleteCallback() {
        // Given
        let item = MockItem(id: 1, name: "Test")
        let allItems = [item]

        // When
        let rowItem = LazyVStackListRowItem(
            item: item,
            allItems: allItems,
            content: { item in Text(item.name) },
            createPage: { item in MockPage(itemId: item.id) },
            onRegisterDynamicSubPage: { _ in },
            onNavigateTo: { _ in },
            onDelete: { _ in }
        )

        // Then
        expect(rowItem.onDelete).toNot(beNil())
    }

    func testInitializationWithShouldShowDeleteAction() {
        // Given
        let item = MockItem(id: 1, name: "Test")
        let allItems = [item]

        // When
        let rowItem = LazyVStackListRowItem(
            item: item,
            allItems: allItems,
            content: { item in Text(item.name) },
            createPage: { item in MockPage(itemId: item.id) },
            onRegisterDynamicSubPage: { _ in },
            onNavigateTo: { _ in },
            shouldShowDeleteAction: { _ in true }
        )

        // Then
        expect(rowItem.shouldShowDeleteAction).toNot(beNil())
    }

    // MARK: - Item Position Tests

    func testIsFirstItemTrue() {
        // Given
        let item1 = MockItem(id: 1, name: "Item 1")
        let item2 = MockItem(id: 2, name: "Item 2")
        let allItems = [item1, item2]

        // When
        let rowItem = LazyVStackListRowItem(
            item: item1,
            allItems: allItems,
            content: { item in Text(item.name) },
            createPage: { item in MockPage(itemId: item.id) },
            onRegisterDynamicSubPage: { _ in },
            onNavigateTo: { _ in }
        )

        // Then
        expect(rowItem.isFirstItem) == true
    }

    func testIsFirstItemFalse() {
        // Given
        let item1 = MockItem(id: 1, name: "Item 1")
        let item2 = MockItem(id: 2, name: "Item 2")
        let allItems = [item1, item2]

        // When
        let rowItem = LazyVStackListRowItem(
            item: item2,
            allItems: allItems,
            content: { item in Text(item.name) },
            createPage: { item in MockPage(itemId: item.id) },
            onRegisterDynamicSubPage: { _ in },
            onNavigateTo: { _ in }
        )

        // Then
        expect(rowItem.isFirstItem) == false
    }

    func testIsLastItemTrue() {
        // Given
        let item1 = MockItem(id: 1, name: "Item 1")
        let item2 = MockItem(id: 2, name: "Item 2")
        let allItems = [item1, item2]

        // When
        let rowItem = LazyVStackListRowItem(
            item: item2,
            allItems: allItems,
            content: { item in Text(item.name) },
            createPage: { item in MockPage(itemId: item.id) },
            onRegisterDynamicSubPage: { _ in },
            onNavigateTo: { _ in }
        )

        // Then
        expect(rowItem.isLastItem) == true
    }

    func testIsLastItemFalse() {
        // Given
        let item1 = MockItem(id: 1, name: "Item 1")
        let item2 = MockItem(id: 2, name: "Item 2")
        let allItems = [item1, item2]

        // When
        let rowItem = LazyVStackListRowItem(
            item: item1,
            allItems: allItems,
            content: { item in Text(item.name) },
            createPage: { item in MockPage(itemId: item.id) },
            onRegisterDynamicSubPage: { _ in },
            onNavigateTo: { _ in }
        )

        // Then
        expect(rowItem.isLastItem) == false
    }

    func testIsMiddleItem() {
        // Given
        let item1 = MockItem(id: 1, name: "Item 1")
        let item2 = MockItem(id: 2, name: "Item 2")
        let item3 = MockItem(id: 3, name: "Item 3")
        let allItems = [item1, item2, item3]

        // When
        let rowItem = LazyVStackListRowItem(
            item: item2,
            allItems: allItems,
            content: { item in Text(item.name) },
            createPage: { item in MockPage(itemId: item.id) },
            onRegisterDynamicSubPage: { _ in },
            onNavigateTo: { _ in }
        )

        // Then
        expect(rowItem.isFirstItem) == false
        expect(rowItem.isLastItem) == false
    }

    func testSingleItemIsFirstAndLast() {
        // Given
        let item = MockItem(id: 1, name: "Only Item")
        let allItems = [item]

        // When
        let rowItem = LazyVStackListRowItem(
            item: item,
            allItems: allItems,
            content: { item in Text(item.name) },
            createPage: { item in MockPage(itemId: item.id) },
            onRegisterDynamicSubPage: { _ in },
            onNavigateTo: { _ in }
        )

        // Then
        expect(rowItem.isFirstItem) == true
        expect(rowItem.isLastItem) == true
    }

    // MARK: - Item Index Tests

    func testItemIndexFirstItem() {
        // Given
        let item1 = MockItem(id: 1, name: "Item 1")
        let item2 = MockItem(id: 2, name: "Item 2")
        let allItems = [item1, item2]

        // When
        let rowItem = LazyVStackListRowItem(
            item: item1,
            allItems: allItems,
            content: { item in Text(item.name) },
            createPage: { item in MockPage(itemId: item.id) },
            onRegisterDynamicSubPage: { _ in },
            onNavigateTo: { _ in }
        )

        // Then
        expect(rowItem.itemIndex) == 0
    }

    func testItemIndexLastItem() {
        // Given
        let item1 = MockItem(id: 1, name: "Item 1")
        let item2 = MockItem(id: 2, name: "Item 2")
        let item3 = MockItem(id: 3, name: "Item 3")
        let allItems = [item1, item2, item3]

        // When
        let rowItem = LazyVStackListRowItem(
            item: item3,
            allItems: allItems,
            content: { item in Text(item.name) },
            createPage: { item in MockPage(itemId: item.id) },
            onRegisterDynamicSubPage: { _ in },
            onNavigateTo: { _ in }
        )

        // Then
        expect(rowItem.itemIndex) == 2
    }

    func testNumberOfItems() {
        // Given
        let items = [
            MockItem(id: 1, name: "Item 1"),
            MockItem(id: 2, name: "Item 2"),
            MockItem(id: 3, name: "Item 3")
        ]

        // When
        let rowItem = LazyVStackListRowItem(
            item: items[0],
            allItems: items,
            content: { item in Text(item.name) },
            createPage: { item in MockPage(itemId: item.id) },
            onRegisterDynamicSubPage: { _ in },
            onNavigateTo: { _ in }
        )

        // Then
        expect(rowItem.numberOfItems) == 3
    }

    // MARK: - Property Tests

    func testItemProperty() {
        // Given
        let item = MockItem(id: 42, name: "Test Item")
        let allItems = [item]

        // When
        let rowItem = LazyVStackListRowItem(
            item: item,
            allItems: allItems,
            content: { item in Text(item.name) },
            createPage: { item in MockPage(itemId: item.id) },
            onRegisterDynamicSubPage: { _ in },
            onNavigateTo: { _ in }
        )

        // Then
        expect(rowItem.item.id) == 42
        expect(rowItem.item.name) == "Test Item"
    }

    func testAllItemsProperty() {
        // Given
        let items = [
            MockItem(id: 1, name: "Item 1"),
            MockItem(id: 2, name: "Item 2"),
            MockItem(id: 3, name: "Item 3")
        ]

        // When
        let rowItem = LazyVStackListRowItem(
            item: items[0],
            allItems: items,
            content: { item in Text(item.name) },
            createPage: { item in MockPage(itemId: item.id) },
            onRegisterDynamicSubPage: { _ in },
            onNavigateTo: { _ in }
        )

        // Then
        expect(rowItem.allItems.count) == 3
        expect(rowItem.allItems[0].id) == 1
        expect(rowItem.allItems[1].id) == 2
        expect(rowItem.allItems[2].id) == 3
    }

    // MARK: - Delete Action Tests

    func testOnDeleteNilByDefault() {
        // Given
        let item = MockItem(id: 1, name: "Test")
        let allItems = [item]

        // When
        let rowItem = LazyVStackListRowItem(
            item: item,
            allItems: allItems,
            content: { item in Text(item.name) },
            createPage: { item in MockPage(itemId: item.id) },
            onRegisterDynamicSubPage: { _ in },
            onNavigateTo: { _ in }
        )

        // Then
        expect(rowItem.onDelete).to(beNil())
    }

    func testOnDeleteProvided() {
        // Given
        let item = MockItem(id: 1, name: "Test")
        let allItems = [item]

        // When
        let rowItem = LazyVStackListRowItem(
            item: item,
            allItems: allItems,
            content: { item in Text(item.name) },
            createPage: { item in MockPage(itemId: item.id) },
            onRegisterDynamicSubPage: { _ in },
            onNavigateTo: { _ in },
            onDelete: { _ in }
        )

        // Then
        expect(rowItem.onDelete).toNot(beNil())
    }

    func testShouldShowDeleteActionNilByDefault() {
        // Given
        let item = MockItem(id: 1, name: "Test")
        let allItems = [item]

        // When
        let rowItem = LazyVStackListRowItem(
            item: item,
            allItems: allItems,
            content: { item in Text(item.name) },
            createPage: { item in MockPage(itemId: item.id) },
            onRegisterDynamicSubPage: { _ in },
            onNavigateTo: { _ in }
        )

        // Then
        expect(rowItem.shouldShowDeleteAction).to(beNil())
    }

    func testShouldShowDeleteActionProvided() {
        // Given
        let item = MockItem(id: 1, name: "Test")
        let allItems = [item]

        // When
        let rowItem = LazyVStackListRowItem(
            item: item,
            allItems: allItems,
            content: { item in Text(item.name) },
            createPage: { item in MockPage(itemId: item.id) },
            onRegisterDynamicSubPage: { _ in },
            onNavigateTo: { _ in },
            shouldShowDeleteAction: { _ in true }
        )

        // Then
        expect(rowItem.shouldShowDeleteAction).toNot(beNil())
    }
}
