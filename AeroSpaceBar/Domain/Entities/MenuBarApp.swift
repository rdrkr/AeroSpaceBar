// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import AppKit
import Foundation

/// Represents a system menu bar application.
///
/// This struct contains information about an application that has an icon
/// in the macOS system menu bar (e.g., clock, WiFi, battery, etc.).
struct MenuBarApp: Identifiable, Equatable {
    /// The unique identifier for the menu bar app.
    let id: String

    /// The position/frame of the menu bar item.
    let frame: CGRect
}
