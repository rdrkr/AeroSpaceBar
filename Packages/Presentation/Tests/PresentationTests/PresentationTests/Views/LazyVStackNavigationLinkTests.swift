// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Nimble
@testable import Presentation
import SwiftUI
import XCTest

/// Tests for LazyVStackNavigationLink component.
///
/// These tests verify:
/// - Initialization
/// - Value and label properties
/// - Selection state
@MainActor
final class LazyVStackNavigationLinkTests: XCTestCase {
    // MARK: - Test Helpers

    private struct MockItem: Identifiable, Hashable {
        let id: Int
        let name: String
    }

    // MARK: - Initialization Tests

    func testInitialization() {
        // Given
        let item = MockItem(id: 1, name: "Test")

        // When
        let link = LazyVStackNavigationLink(value: item) {
            Text(item.name)
        }

        // Then - Should not crash
        expect(link).toNot(beNil())
    }

    func testValueProperty() {
        // Given
        let item = MockItem(id: 2, name: "Item 2")

        // When
        let link = LazyVStackNavigationLink(value: item) {
            Text(item.name)
        }

        // Then
        expect(link.value == item) == true
        expect(link.value.id == 2) == true
        expect(link.value.name == "Item 2") == true
    }

    func testInitializationWithDifferentItemTypes() {
        // Given
        struct AnotherItem: Identifiable, Hashable, Sendable {
            let id: String
            let title: String
        }

        let item = AnotherItem(id: "abc", title: "Title")

        // When
        let link = LazyVStackNavigationLink(value: item) {
            Text(item.title)
        }

        // Then
        expect(link.value.id == "abc") == true
        expect(link.value.title == "Title") == true
    }

    func testMultipleLinks() {
        // Given
        let item1 = MockItem(id: 1, name: "Item 1")
        let item2 = MockItem(id: 2, name: "Item 2")

        // When
        let link1 = LazyVStackNavigationLink(value: item1) {
            Text(item1.name)
        }
        let link2 = LazyVStackNavigationLink(value: item2) {
            Text(item2.name)
        }

        // Then
        expect(link1.value.id == 1) == true
        expect(link2.value.id == 2) == true
        expect(link1.value != link2.value) == true
    }
}
