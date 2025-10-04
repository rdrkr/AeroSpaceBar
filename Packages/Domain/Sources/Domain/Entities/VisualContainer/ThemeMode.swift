// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Theme mode for visual customization of spaces and groups.
///
/// This enum defines the different modes for applying visual themes to spaces and groups:
/// - `preset`: User selects from a predefined list of visual themes
/// - `glass`: Applies macOS 26+ glass effect (only available on macOS 26 and later)
/// - `custom`: User manually configures individual visual properties (colors, opacity, etc.)
@frozen
public enum ThemeMode: String, CaseIterable, Codable, Sendable {
    /// User selects from a predefined list of visual themes.
    case preset

    /// Applies macOS 26+ glass effect (only available on macOS 26 and later).
    case glass

    /// User manually configures individual visual properties.
    case custom

    /// Whether this theme mode is available or not.
    public var isAvailable: Bool {
        switch self {
        case .glass: if #available(macOS 26.0, *) { true } else { false }
        case .preset,
             .custom: true
        }
    }

    /// Whether this theme mode supports user customized colors.
    public var isColorCustomizable: Bool {
        switch self {
        case .custom: true
        case .glass,
             .preset: false
        }
    }

    /// Whether this theme mode supports user customized effect properties.
    public var isEffectCustomizable: Bool {
        switch self {
        case .glass: false
        case .preset,
             .custom: true
        }
    }

    /// Whether this theme mode supports user customized geometric properties.
    public var isGeometryCustomizable: Bool {
        switch self {
        case .glass: false
        case .preset,
             .custom: true
        }
    }
}
