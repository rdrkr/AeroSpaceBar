// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Defines how spaces visual appearance is configured
@frozen
public enum SpacesAppearanceMode: String, AppearanceMode {
    /// Each space has its own appearance configuration
    case perSpace = "per-space"

    /// All spaces share the same appearance configuration
    case allSpaces = "all-spaces"

    /// Display name for the mode
    public var displayName: LocalizedStringResource {
        switch self {
        case .perSpace:
            LocalizedStringResource("Per Space")

        case .allSpaces:
            LocalizedStringResource("All Spaces")
        }
    }

    /// Description for the mode
    public var description: LocalizedStringResource {
        switch self {
        case .perSpace:
            LocalizedStringResource("Configure appearance for each space individually.")

        case .allSpaces:
            LocalizedStringResource("Use the same appearance for all spaces.")
        }
    }

    /// Determines whether the global color properties should be shown for this mode.
    public var shouldShowGlobalConfig: Bool {
        switch self {
        case .perSpace: false
        case .allSpaces: true
        }
    }
}
