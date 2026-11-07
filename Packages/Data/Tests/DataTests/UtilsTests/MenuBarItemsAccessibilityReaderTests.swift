// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import CoreGraphics
@testable import Data
import Domain
import Nimble
import XCTest

/// Tests for the filtering and normalization logic of `MenuBarItemsAccessibilityReader`.
final class MenuBarItemsAccessibilityReaderTests: XCTestCase {
    /// Bounds of a main display used by the tests.
    private let displayBounds = CGRect(x: 0, y: 0, width: 1_800, height: 1_169)

    /// Menu bar height used by the tests.
    private let menuBarHeight = 39.0

    func testFindsTheMenuBarHostingTheItems() {
        let primary = CGRect(x: 0, y: 0, width: 3_008, height: 30)
        let laptop = CGRect(x: -1_800, y: 0, width: 1_800, height: 39)
        let rawItems = [
            MenuBarItemsAccessibilityReader.RawItem(
                ownerIdentifier: "owner",
                index: 0,
                frame: CGRect(x: -198, y: 8, width: 16, height: 24)
            )
        ]

        expect(MenuBarItemsAccessibilityReader.activeMenuBar(rawItems: rawItems, menuBars: [primary, laptop])) == laptop
        expect(MenuBarItemsAccessibilityReader.activeMenuBar(rawItems: [], menuBars: [primary, laptop])).to(beNil())
    }

    func testProjectsItemsFromAnotherMenuBarOntoTheTarget() {
        let primary = CGRect(x: 0, y: 0, width: 3_008, height: 30)
        let laptop = CGRect(x: -1_800, y: 0, width: 1_800, height: 39)
        let rawItems = [
            MenuBarItemsAccessibilityReader.RawItem(
                ownerIdentifier: "owner",
                index: 0,
                frame: CGRect(x: -198, y: 8, width: 16, height: 24)
            )
        ]

        let result = MenuBarItemsAccessibilityReader.readResult(
            rawItems: rawItems,
            menuBars: [primary, laptop],
            targetMenuBar: primary
        )

        expect(result.isFromTargetMenuBar) == false
        expect(result.items.map(\.frame)) == [CGRect(x: 2_802, y: 0, width: 32, height: 30)]
    }

    func testReadsItemsDirectlyFromTheTargetMenuBar() {
        let primary = CGRect(x: 0, y: 0, width: 3_008, height: 30)
        let rawItems = [
            MenuBarItemsAccessibilityReader.RawItem(
                ownerIdentifier: "owner",
                index: 0,
                frame: CGRect(x: 2_810, y: 0, width: 17, height: 30)
            )
        ]

        let result = MenuBarItemsAccessibilityReader.readResult(
            rawItems: rawItems,
            menuBars: [primary],
            targetMenuBar: primary
        )

        expect(result.isFromTargetMenuBar) == true
        expect(result.items.count) == 1
    }

    func testDropsItemsOutsideMenuBar() {
        // Given a visible item, an item hidden at the bottom-left, and an item past the right edge
        let rawItems = [
            MenuBarItemsAccessibilityReader.RawItem(
                ownerIdentifier: "visible",
                index: 0,
                frame: CGRect(x: 1_283, y: 7.5, width: 38, height: 24)
            ),
            MenuBarItemsAccessibilityReader.RawItem(
                ownerIdentifier: "hidden",
                index: 0,
                frame: CGRect(x: -1, y: 1_157, width: 38, height: 24)
            ),
            MenuBarItemsAccessibilityReader.RawItem(
                ownerIdentifier: "offscreen",
                index: 0,
                frame: CGRect(x: 1_790, y: 0, width: 38, height: 24)
            )
        ]

        // When normalizing
        let items = MenuBarItemsAccessibilityReader.normalizedItems(
            rawItems: rawItems,
            menuBarHeight: menuBarHeight,
            displayBounds: displayBounds
        )

        // Then only the visible item remains
        expect(items.map(\.id)) == ["visible#0"]
    }

    func testDropsZeroWidthItems() {
        // Given an item without width
        let rawItems = [
            MenuBarItemsAccessibilityReader.RawItem(
                ownerIdentifier: "empty",
                index: 0,
                frame: CGRect(x: 1_000, y: 0, width: 0, height: 39)
            )
        ]

        // When normalizing
        let items = MenuBarItemsAccessibilityReader.normalizedItems(
            rawItems: rawItems,
            menuBarHeight: menuBarHeight,
            displayBounds: displayBounds
        )

        // Then the item is dropped
        expect(items).to(beEmpty())
    }

    func testNormalizesFramesToMenuBarHeight() {
        // Given a vertically centered third-party item
        let rawItems = [
            MenuBarItemsAccessibilityReader.RawItem(
                ownerIdentifier: "third-party",
                index: 0,
                frame: CGRect(x: 1_327, y: 7.5, width: 24, height: 24)
            )
        ]

        // When normalizing
        let items = MenuBarItemsAccessibilityReader.normalizedItems(
            rawItems: rawItems,
            menuBarHeight: menuBarHeight,
            displayBounds: displayBounds
        )

        // Then the frame spans the full menu bar height and gains the outer padding on both sides
        expect(items.first?.frame) == CGRect(x: 1_319, y: 0, width: 40, height: menuBarHeight)
    }

    func testSplitsGapsBetweenAdjacentItemsAtMidpoint() {
        // Given two glyph-only system items separated by a 16pt gap
        let rawItems = [
            MenuBarItemsAccessibilityReader.RawItem(
                ownerIdentifier: "left",
                index: 0,
                frame: CGRect(x: 1_513, y: 0, width: 26, height: 39)
            ),
            MenuBarItemsAccessibilityReader.RawItem(
                ownerIdentifier: "right",
                index: 0,
                frame: CGRect(x: 1_555, y: 0, width: 22, height: 39)
            )
        ]

        // When normalizing
        let items = MenuBarItemsAccessibilityReader.normalizedItems(
            rawItems: rawItems,
            menuBarHeight: menuBarHeight,
            displayBounds: displayBounds
        )

        // Then both items meet at the midpoint of the gap
        expect(self.frame(of: "left#0", in: items)?.maxX) == 1_547
        expect(self.frame(of: "right#0", in: items)?.minX) == 1_547
    }

    func testSplitsOverlapsBetweenAdjacentItemsAtMidpoint() {
        // Given two third-party items whose buttons overlap by 2pt
        let rawItems = [
            MenuBarItemsAccessibilityReader.RawItem(
                ownerIdentifier: "left",
                index: 0,
                frame: CGRect(x: 1_245, y: 7.5, width: 41, height: 24)
            ),
            MenuBarItemsAccessibilityReader.RawItem(
                ownerIdentifier: "right",
                index: 0,
                frame: CGRect(x: 1_284, y: 7.5, width: 38, height: 24)
            )
        ]

        // When normalizing
        let items = MenuBarItemsAccessibilityReader.normalizedItems(
            rawItems: rawItems,
            menuBarHeight: menuBarHeight,
            displayBounds: displayBounds
        )

        // Then both items are trimmed back to the midpoint of the overlap
        expect(self.frame(of: "left#0", in: items)?.maxX) == 1_285
        expect(self.frame(of: "right#0", in: items)?.minX) == 1_285
    }

    func testCapsPaddingBetweenDistantItems() {
        // Given two items far apart
        let rawItems = [
            MenuBarItemsAccessibilityReader.RawItem(
                ownerIdentifier: "left",
                index: 0,
                frame: CGRect(x: 1_000, y: 0, width: 20, height: 39)
            ),
            MenuBarItemsAccessibilityReader.RawItem(
                ownerIdentifier: "right",
                index: 0,
                frame: CGRect(x: 1_100, y: 0, width: 20, height: 39)
            )
        ]

        // When normalizing
        let items = MenuBarItemsAccessibilityReader.normalizedItems(
            rawItems: rawItems,
            menuBarHeight: menuBarHeight,
            displayBounds: displayBounds
        )

        // Then each item only gains the maximum padding instead of bridging the gap
        expect(self.frame(of: "left#0", in: items)) == CGRect(x: 992, y: 0, width: 36, height: menuBarHeight)
        expect(self.frame(of: "right#0", in: items)) == CGRect(x: 1_092, y: 0, width: 36, height: menuBarHeight)
    }

    func testClampsPaddingToDisplayBounds() {
        // Given an item close to the right edge of the display
        let rawItems = [
            MenuBarItemsAccessibilityReader.RawItem(
                ownerIdentifier: "edge",
                index: 0,
                frame: CGRect(x: 1_780, y: 0, width: 16, height: 39)
            )
        ]

        // When normalizing
        let items = MenuBarItemsAccessibilityReader.normalizedItems(
            rawItems: rawItems,
            menuBarHeight: menuBarHeight,
            displayBounds: displayBounds
        )

        // Then the trailing padding stops at the display edge
        expect(items.first?.frame) == CGRect(x: 1_772, y: 0, width: 28, height: menuBarHeight)
    }

    /// Returns the frame of the item with the given identifier.
    /// - Parameters:
    ///   - identifier: The item identifier to look up.
    ///   - items: The normalized items.
    /// - Returns: The item frame, or `nil` if no item has the identifier.
    private func frame(of identifier: String, in items: [MenuBarApp]) -> CGRect? {
        items.first { $0.id == identifier }?.frame
    }

    func testSortsItemsFromRightToLeft() {
        // Given items in arbitrary order
        let rawItems = [
            MenuBarItemsAccessibilityReader.RawItem(
                ownerIdentifier: "middle",
                index: 0,
                frame: CGRect(x: 1_400, y: 0, width: 20, height: 39)
            ),
            MenuBarItemsAccessibilityReader.RawItem(
                ownerIdentifier: "left",
                index: 0,
                frame: CGRect(x: 1_100, y: 0, width: 20, height: 39)
            ),
            MenuBarItemsAccessibilityReader.RawItem(
                ownerIdentifier: "right",
                index: 0,
                frame: CGRect(x: 1_667, y: 0, width: 113, height: 39)
            )
        ]

        // When normalizing
        let items = MenuBarItemsAccessibilityReader.normalizedItems(
            rawItems: rawItems,
            menuBarHeight: menuBarHeight,
            displayBounds: displayBounds
        )

        // Then items are ordered from right to left
        expect(items.map(\.id)) == ["right#0", "middle#0", "left#0"]
    }

    func testReturnsNoItemsWhenMenuBarHeightIsZero() {
        // Given a visible item but a hidden menu bar
        let rawItems = [
            MenuBarItemsAccessibilityReader.RawItem(
                ownerIdentifier: "visible",
                index: 0,
                frame: CGRect(x: 1_283, y: 0, width: 38, height: 24)
            )
        ]

        // When normalizing with a zero menu bar height
        let items = MenuBarItemsAccessibilityReader.normalizedItems(
            rawItems: rawItems,
            menuBarHeight: 0,
            displayBounds: displayBounds
        )

        // Then no items are returned
        expect(items).to(beEmpty())
    }
}
