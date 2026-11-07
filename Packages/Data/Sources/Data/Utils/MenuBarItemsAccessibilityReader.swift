// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import AppKit
import ApplicationServices
import Domain
import Foundation

/// Reads system menu bar status items through the Accessibility API.
///
/// Up to macOS 26 every status item was backed by its own Control Center window, so frames could be
/// discovered through `CGWindowListCopyWindowInfo`. Starting with macOS 27 status items are drawn into a
/// single `MenuBarAgent` strip and no longer have individual windows. Every application that owns status
/// items still exposes them as children of its `AXExtrasMenuBar` accessibility element, which this reader
/// uses instead. Reading them requires the app to be trusted for Accessibility.
///
/// The reader is an actor so scans run off the main actor and its process cache stays isolated.
actor MenuBarItemsAccessibilityReader {
    /// A status item frame read from the Accessibility API, before filtering and normalization.
    struct RawItem: Equatable {
        /// Stable identifier of the owning application (bundle identifier, or process identifier as fallback).
        let ownerIdentifier: String

        /// Index of the item within its owning application's extras menu bar.
        let index: Int

        /// The item frame in global top-left screen coordinates.
        let frame: CGRect
    }

    /// Status items read from whichever menu bar currently hosts them.
    struct ReadResult: Equatable {
        /// The visible status items, projected onto the target menu bar and sorted from right to left.
        let items: [MenuBarApp]

        /// Whether the items were read directly from the target menu bar.
        let isFromTargetMenuBar: Bool
    }

    /// An application known to expose an extras menu bar.
    private struct ItemOwner {
        /// The process identifier of the application.
        let processIdentifier: pid_t

        /// Stable identifier of the application used to build item identifiers.
        let identifier: String
    }

    /// The accessibility attribute holding an application's status items.
    private static let extrasMenuBarAttribute = "AXExtrasMenuBar"

    /// The options key requesting the system Accessibility permission prompt.
    private static let trustedCheckOptionPromptKey = "AXTrustedCheckOptionPrompt"

    /// Maximum time, in seconds, to wait for an application to answer an accessibility request.
    ///
    /// Kept short so an unresponsive application cannot stall the periodic scan.
    private static let messagingTimeout: Float = 0.05

    /// How often every running application is re-examined for an extras menu bar.
    private static let ownerDiscoveryInterval: Duration = .seconds(5)

    /// Maximum horizontal padding, in points, added on each side of a status item frame.
    ///
    /// macOS 27 reports system status items with their glyph width only and leaves a 16pt gap between them,
    /// while third-party items report their full button width. Half of that standard gap is the padding a
    /// glyph-only item needs on each side to match a full button.
    private static let maximumItemPadding: CGFloat = 8

    /// Applications that exposed an extras menu bar during the last discovery pass.
    private var itemOwners: [ItemOwner] = []

    /// The time of the last discovery pass, or `nil` if none has run yet.
    private var lastOwnerDiscovery: ContinuousClock.Instant?

    /// Whether the current process is trusted for Accessibility.
    static var isTrusted: Bool {
        AXIsProcessTrusted()
    }

    /// Shows the system prompt asking the user to trust the app for Accessibility.
    static func requestTrust() {
        let options = [trustedCheckOptionPromptKey: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
    }

    /// Reads the status items of the active menu bar and projects them onto the target menu bar.
    /// - Parameters:
    ///   - menuBars: The frames of every visible menu bar in global coordinates.
    ///   - targetMenuBar: The menu bar to express item frames in.
    /// - Returns: The visible status items and whether they came from the target menu bar.
    func readItems(menuBars: [CGRect], targetMenuBar: CGRect) -> ReadResult {
        refreshItemOwnersIfNeeded()

        let rawItems = itemOwners.flatMap { owner in
            Self.readRawItems(of: owner)
        }

        return Self.readResult(rawItems: rawItems, menuBars: menuBars, targetMenuBar: targetMenuBar)
    }

    /// Builds a read result from raw items reported on the active menu bar.
    ///
    /// The Accessibility API reports a single frame per status item, on the menu bar of the active display,
    /// so the frames can belong to any display and are projected onto the target menu bar.
    /// - Parameters:
    ///   - rawItems: The status items read from the Accessibility API.
    ///   - menuBars: The frames of every visible menu bar in global coordinates.
    ///   - targetMenuBar: The menu bar to express item frames in.
    /// - Returns: The visible status items and whether they came from the target menu bar.
    static func readResult(rawItems: [RawItem], menuBars: [CGRect], targetMenuBar: CGRect) -> ReadResult {
        let sourceMenuBar = activeMenuBar(rawItems: rawItems, menuBars: menuBars) ?? targetMenuBar
        let items = normalizedItems(
            rawItems: rawItems,
            menuBarHeight: sourceMenuBar.height,
            displayBounds: sourceMenuBar
        )

        return ReadResult(
            items: items.map { $0.projected(from: sourceMenuBar, to: targetMenuBar) },
            isFromTargetMenuBar: sourceMenuBar == targetMenuBar
        )
    }

    /// Finds the menu bar currently hosting the status items.
    /// - Parameters:
    ///   - rawItems: The status items read from the Accessibility API.
    ///   - menuBars: The frames of every visible menu bar in global coordinates.
    /// - Returns: The menu bar containing the most items, or `nil` if none contains any.
    static func activeMenuBar(rawItems: [RawItem], menuBars: [CGRect]) -> CGRect? {
        let candidates = menuBars.map { menuBar in
            (menuBar: menuBar, itemCount: rawItems.count { isVisible($0, in: menuBar) })
        }

        return candidates
            .filter { $0.itemCount > 0 }
            .max { $0.itemCount < $1.itemCount }?
            .menuBar
    }

    /// Returns whether an item is shown inside a menu bar strip.
    /// - Parameters:
    ///   - item: The status item.
    ///   - menuBar: The menu bar frame in global coordinates.
    /// - Returns: `true` if the item lies within the strip; hidden items are reported outside of it.
    private static func isVisible(_ item: RawItem, in menuBar: CGRect) -> Bool {
        item.frame.width > 0 &&
            item.frame.minY >= menuBar.minY &&
            item.frame.minY < menuBar.maxY &&
            item.frame.minX >= menuBar.minX &&
            item.frame.maxX <= menuBar.maxX
    }

    /// Filters raw status items to the ones visible in the menu bar and normalizes their frames.
    ///
    /// Items hidden by the system are reported outside the menu bar strip (for example at the bottom-left
    /// of the screen) and are dropped. System items span the full menu bar height while third-party items
    /// report a shorter, vertically centered frame, so all frames are normalized to the full menu bar height.
    ///
    /// Horizontal extents are inconsistent too: system items report only their glyph width with gaps between
    /// them, while third-party items report their full button width and may overlap their neighbors. Adjacent
    /// items are therefore tiled so they meet at the midpoint of the gap or overlap between them, with the
    /// padding on each side capped at `maximumItemPadding`, matching the contiguous item windows of macOS 26.
    /// - Parameters:
    ///   - rawItems: The status items read from the Accessibility API.
    ///   - menuBarHeight: The current menu bar height.
    ///   - displayBounds: The bounds of the main display in global coordinates.
    /// - Returns: The visible status items with normalized frames, sorted from right to left.
    static func normalizedItems(
        rawItems: [RawItem],
        menuBarHeight: Double,
        displayBounds: CGRect
    ) -> [MenuBarApp] {
        guard menuBarHeight > 0 else { return [] }

        let menuBar = CGRect(
            x: displayBounds.minX,
            y: displayBounds.minY,
            width: displayBounds.width,
            height: menuBarHeight
        )
        let visibleItems = rawItems
            .filter { isVisible($0, in: menuBar) }
            .sorted { $0.frame.minX < $1.frame.minX }

        return visibleItems.indices
            .map { index in
                let frame = visibleItems[index].frame
                let leadingPadding = index > 0
                    ? padding(between: visibleItems[index - 1].frame, and: frame)
                    : maximumItemPadding
                let trailingPadding = index < visibleItems.count - 1
                    ? padding(between: frame, and: visibleItems[index + 1].frame)
                    : maximumItemPadding
                let tiledMinX = max(frame.minX - leadingPadding, displayBounds.minX)
                let tiledMaxX = min(frame.maxX + trailingPadding, displayBounds.maxX)
                let hasTiledWidth = tiledMaxX > tiledMinX

                return MenuBarApp(
                    id: "\(visibleItems[index].ownerIdentifier)#\(visibleItems[index].index)",
                    frame: CGRect(
                        x: hasTiledWidth ? tiledMinX : frame.minX,
                        y: displayBounds.minY,
                        width: hasTiledWidth ? tiledMaxX - tiledMinX : frame.width,
                        height: menuBarHeight
                    )
                )
            }
            .sorted { $0.frame.origin.x > $1.frame.origin.x }
    }

    /// Returns the padding two adjacent items each receive so that they meet at the midpoint between them.
    /// - Parameters:
    ///   - leadingFrame: The frame of the item on the left.
    ///   - trailingFrame: The frame of the item on the right.
    /// - Returns: Half the gap between the frames capped at `maximumItemPadding`, or a negative value that
    ///   trims both items back to the midpoint when they overlap.
    private static func padding(between leadingFrame: CGRect, and trailingFrame: CGRect) -> CGFloat {
        min((trailingFrame.minX - leadingFrame.maxX) / 2, maximumItemPadding)
    }

    /// Re-examines every running application for an extras menu bar when the discovery interval elapsed.
    private func refreshItemOwnersIfNeeded() {
        let now = ContinuousClock.now
        if let lastOwnerDiscovery, now - lastOwnerDiscovery < Self.ownerDiscoveryInterval {
            return
        }

        lastOwnerDiscovery = now
        itemOwners = NSWorkspace.shared.runningApplications.compactMap { application in
            let processIdentifier = application.processIdentifier
            guard Self.attribute(Self.extrasMenuBarAttribute, of: Self.applicationElement(processIdentifier)) != nil
            else {
                return nil
            }

            return ItemOwner(
                processIdentifier: processIdentifier,
                identifier: application.bundleIdentifier ?? String(processIdentifier)
            )
        }
    }

    /// Reads the status items of a single application.
    /// - Parameter owner: The application exposing an extras menu bar.
    /// - Returns: The application's status items, or an empty array if they cannot be read.
    private static func readRawItems(of owner: ItemOwner) -> [RawItem] {
        guard
            let extrasMenuBar = element(
                from: attribute(extrasMenuBarAttribute, of: applicationElement(owner.processIdentifier))
            ),
            let children = attribute(kAXChildrenAttribute, of: extrasMenuBar) as? [AXUIElement]
        else {
            return []
        }

        return children.enumerated().compactMap { index, child in
            frame(of: child).map { frame in
                RawItem(ownerIdentifier: owner.identifier, index: index, frame: frame)
            }
        }
    }

    /// Creates the accessibility element of an application with a short messaging timeout.
    /// - Parameter processIdentifier: The process identifier of the application.
    /// - Returns: The application's accessibility element.
    private static func applicationElement(_ processIdentifier: pid_t) -> AXUIElement {
        let element = AXUIElementCreateApplication(processIdentifier)
        AXUIElementSetMessagingTimeout(element, messagingTimeout)
        return element
    }

    /// Copies the value of an accessibility attribute.
    /// - Parameters:
    ///   - name: The attribute name.
    ///   - element: The element to read the attribute from.
    /// - Returns: The attribute value, or `nil` if it is unavailable.
    private static func attribute(_ name: String, of element: AXUIElement) -> CFTypeRef? {
        var value: CFTypeRef?
        let result = unsafe AXUIElementCopyAttributeValue(element, name as CFString, &value)
        return result == .success ? value : nil
    }

    /// Casts an attribute value to an accessibility element after verifying its Core Foundation type.
    /// - Parameter value: The attribute value.
    /// - Returns: The accessibility element, or `nil` if the value is not an element.
    private static func element(from value: CFTypeRef?) -> AXUIElement? {
        guard let value, CFGetTypeID(value) == AXUIElementGetTypeID() else { return nil }

        return unsafe unsafeDowncast(value, to: AXUIElement.self)
    }

    /// Casts an attribute value to an accessibility value after verifying its Core Foundation type.
    /// - Parameter value: The attribute value.
    /// - Returns: The accessibility value, or `nil` if the value is not an `AXValue`.
    private static func axValue(from value: CFTypeRef?) -> AXValue? {
        guard let value, CFGetTypeID(value) == AXValueGetTypeID() else { return nil }

        return unsafe unsafeDowncast(value, to: AXValue.self)
    }

    /// Reads the global frame of an accessibility element.
    /// - Parameter element: The element to read the frame of.
    /// - Returns: The element frame in global top-left coordinates, or `nil` if it cannot be read.
    private static func frame(of element: AXUIElement) -> CGRect? {
        guard
            let positionValue = axValue(from: attribute(kAXPositionAttribute, of: element)),
            let sizeValue = axValue(from: attribute(kAXSizeAttribute, of: element))
        else {
            return nil
        }

        var position = CGPoint.zero
        var size = CGSize.zero
        guard
            unsafe AXValueGetValue(positionValue, .cgPoint, &position),
            unsafe AXValueGetValue(sizeValue, .cgSize, &size)
        else {
            return nil
        }

        return CGRect(origin: position, size: size)
    }
}
