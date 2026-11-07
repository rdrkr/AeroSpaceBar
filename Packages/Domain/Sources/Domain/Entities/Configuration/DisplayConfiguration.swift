// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

/// Determines which displays show a menu bar feature such as spaces or groups.
public struct DisplayConfiguration: Codable, Equatable, Sendable {
    /// Display selection strategy.
    public enum Mode: String, Codable, CaseIterable, Sendable {
        /// Show the feature only on the system's primary display.
        case primary
        /// Show the feature on every connected display.
        case all
        /// Show the feature only on displays whose UUIDs are selected.
        case selected
    }

    /// The display selection strategy.
    public var mode: Mode

    /// Persistent UUID strings for selected displays, including disconnected displays.
    public var selectedDisplayIDs: [String]

    /// Returns whether a display should show the feature under this configuration.
    public func includesDisplay(id: String, isPrimary: Bool) -> Bool {
        switch mode {
        case .primary: isPrimary
        case .all: true
        case .selected: selectedDisplayIDs.contains(id)
        }
    }

    /// Creates a display configuration.
    public init(mode: Mode = .primary, selectedDisplayIDs: [String] = []) {
        self.mode = mode
        self.selectedDisplayIDs = selectedDisplayIDs
    }
}
