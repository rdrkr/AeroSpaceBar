// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Foundation

/// Represents the modifier key used to trigger the Quick Hide feature.
///
/// When the user holds the selected modifier key and hovers over the menu bar,
/// spaces are temporarily hidden. This enum defines all supported modifier keys
/// that can be configured as the trigger.
public enum QuickHideTriggerKey: String, Codable, CaseIterable, Sendable, Equatable {
    /// The Globe/Function key (default).
    case fn

    /// The Control modifier key.
    case control

    /// The Option/Alt modifier key.
    case option

    /// The Command modifier key.
    case command

    /// The Shift modifier key.
    case shift

    /// The human-readable display name for this trigger key.
    public var displayName: String {
        switch self {
        case .fn: "Globe/Fn"
        case .control: "Control"
        case .option: "Option"
        case .command: "Command"
        case .shift: "Shift"
        }
    }

    /// The SF Symbols system image name for this trigger key.
    public var systemImageName: String {
        switch self {
        case .fn: "globe"
        case .control: "control"
        case .option: "option"
        case .command: "command"
        case .shift: "shift"
        }
    }

    /// Glyoh Symbols name for this trigger key.
    public var glyphSymbol: String {
        switch self {
        case .fn: "AppGlyphGlobe"
        case .control: "AppGlyphControl"
        case .option: "AppGlyphOption"
        case .command: "AppGlyphCommand"
        case .shift: "AppGlyphShift"
        }
    }
}
