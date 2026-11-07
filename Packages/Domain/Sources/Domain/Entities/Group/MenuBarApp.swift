// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import AppKit
import Foundation

/// Represents a system menu bar application.
///
/// This struct contains information about an application that has an icon
/// in the macOS system menu bar (e.g., clock, WiFi, battery, etc.).
public struct MenuBarApp: Identifiable, Equatable, Sendable {
    /// The unique identifier for the menu bar app.
    public let id: String

    /// The position/frame of the menu bar item.
    public let frame: CGRect

    /// Creates a menu bar app.
    /// - Parameters:
    ///   - id: The unique identifier for the menu bar app.
    ///   - frame: The position/frame of the menu bar item.
    public init(id: String, frame: CGRect) {
        self.id = id
        self.frame = frame
    }

    /// Moves the item from one menu bar to another.
    ///
    /// macOS mirrors status items on every menu bar, right-aligned in the same order, so an item keeps its
    /// distance from the right edge across menu bars of different widths.
    /// - Parameters:
    ///   - sourceMenuBar: The menu bar the frame is currently expressed in.
    ///   - targetMenuBar: The menu bar to express the frame in.
    /// - Returns: The item with its frame anchored to the target menu bar's right edge and full height.
    public func projected(from sourceMenuBar: CGRect, to targetMenuBar: CGRect) -> Self {
        Self(
            id: id,
            frame: CGRect(
                x: frame.minX - sourceMenuBar.maxX + targetMenuBar.maxX,
                y: targetMenuBar.minY,
                width: frame.width,
                height: targetMenuBar.height
            )
        )
    }

    /// Trims the part of the item left of a horizontal limit.
    ///
    /// The item stays in place with zero width when it is entirely past the limit, so group ranges that
    /// address items by index stay valid.
    /// - Parameter minX: The leftmost visible position.
    /// - Returns: The item with its frame clipped to the visible area.
    public func clipped(toMinX minX: CGFloat) -> Self {
        let clippedMinX = max(frame.minX, minX)
        let clippedMaxX = max(frame.maxX, minX)
        return Self(
            id: id,
            frame: CGRect(x: clippedMinX, y: frame.minY, width: clippedMaxX - clippedMinX, height: frame.height)
        )
    }
}
