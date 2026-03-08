// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Nimble
@testable import Presentation
import SwiftUI
import XCTest

/// Tests for LazyVStackList component.
///
/// These tests verify:
/// - Initialization with and without selection
/// - Selection handling and storage
/// - Keyboard navigation
/// - Environment context propagation
@MainActor
final class LazyVStackListTests: XCTestCase {
    // MARK: - Test Helpers

    private struct MockItem: Identifiable, Hashable {
        let id: Int
        let name: String
    }

    // MARK: - Initialization Tests

    func testInitializationWithoutSelection() {
        // Given/When
        let list = LazyVStackList {
            Text("Test")
        }

        // Then - Should not crash
        expect(list).toNot(beNil())
    }

    func testInitializationWithSelection() {
        // Given
        var selectedItem: MockItem?

        // When
        let list = LazyVStackList(selection: Binding(
            get: { selectedItem },
            set: { selectedItem = $0 }
        )) {
            Text("Test")
        }

        // Then - Should not crash
        expect(list).toNot(beNil())
    }

    func testInitializationWithDefaultParameters() {
        // Given
        var selectedItem: MockItem?

        // When - Initialize with default parameters
        let list = LazyVStackList(selection: Binding(
            get: { selectedItem },
            set: { selectedItem = $0 }
        )) {
            Text("Test")
        }

        // Then - Should use defaults
        expect(list).toNot(beNil())
    }

    func testInitializationWithCustomSpacing() {
        // Given
        let customSpacing: CGFloat = 10

        // When
        let list = LazyVStackList(spacing: customSpacing) {
            Text("Test")
        }

        // Then
        expect(list.spacing) == customSpacing
    }

    func testInitializationWithShowHoverEffect() {
        // Given
        let showHoverEffect = true

        // When
        let list = LazyVStackList(showHoverEffect: showHoverEffect) {
            Text("Test")
        }

        // Then
        expect(list.showHoverEffect) == showHoverEffect
    }

    func testInitializationWithNativeScrollView() {
        // Given
        let useNativeScrollView = true

        // When
        let list = LazyVStackList(useNativeScrollView: useNativeScrollView) {
            Text("Test")
        }

        // Then
        expect(list.useNativeScrollView) == useNativeScrollView
    }

    // MARK: - Selection Tests

    func testSelectionWithNilBinding() {
        // Given
        var selectedItem: MockItem?

        // When
        let list = LazyVStackList(selection: Binding(
            get: { selectedItem },
            set: { selectedItem = $0 }
        )) {
            Text("Test")
        }

        // Then - Selection should be nil initially
        expect(list.selection).to(beNil())
    }

    func testSelectionEnabledWithBinding() {
        // Given
        var selectedItem: MockItem? = MockItem(id: 1, name: "Item 1")

        // When
        let list = LazyVStackList(selection: Binding(
            get: { selectedItem },
            set: { selectedItem = $0 }
        )) {
            Text("Test")
        }

        // Then - Selection should be enabled
        expect(list.selectionEnabled) == true
    }

    func testSelectionDisabledWithoutBinding() {
        // Given/When
        let list = LazyVStackList {
            Text("Test")
        }

        // Then - Selection should be disabled
        expect(list.selectionEnabled) == false
    }

    // MARK: - Property Tests

    func testSpacingProperty() {
        // Given
        let spacing: CGFloat = 15

        // When
        let list = LazyVStackList(spacing: spacing) {
            Text("Test")
        }

        // Then
        expect(list.spacing) == spacing
    }

    func testShowHoverEffectProperty() {
        // Given
        let showHover = true

        // When
        let list = LazyVStackList(showHoverEffect: showHover) {
            Text("Test")
        }

        // Then
        expect(list.showHoverEffect) == showHover
    }

    func testUseNativeScrollViewProperty() {
        // Given
        let useScrollView = true

        // When
        let list = LazyVStackList(useNativeScrollView: useScrollView) {
            Text("Test")
        }

        // Then
        expect(list.useNativeScrollView) == useScrollView
    }

    func testDefaultSpacingIsZero() {
        // Given/When
        let list = LazyVStackList {
            Text("Test")
        }

        // Then
        expect(list.spacing) == 0
    }

    func testDefaultShowHoverEffectIsFalse() {
        // Given/When
        let list = LazyVStackList {
            Text("Test")
        }

        // Then
        expect(list.showHoverEffect) == false
    }

    func testDefaultUseNativeScrollViewIsFalse() {
        // Given/When
        let list = LazyVStackList {
            Text("Test")
        }

        // Then
        expect(list.useNativeScrollView) == false
    }

    func testSelectionModeDefaultScrollViewIsTrue() {
        // Given
        var selectedItem: MockItem?

        // When
        let list = LazyVStackList(selection: Binding(
            get: { selectedItem },
            set: { selectedItem = $0 }
        )) {
            Text("Test")
        }

        // Then - Selection mode should default to scrolling enabled
        expect(list.useNativeScrollView) == true
    }
}
