// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Defines how groups visual appearance is configured
public enum GroupsAppearanceMode: String, AppearanceMode {
    /// Each group has its own appearance configuration
    case perGroup = "per-group"

    /// All groups share the same appearance configuration
    case allGroups = "all-groups"

    /// Groups use the same appearance as spaces
    case matchSpaces = "match-spaces"

    /// Display name for the mode
    public var displayName: LocalizedStringResource {
        switch self {
        case .perGroup:
            LocalizedStringResource("Per Group")
        case .allGroups:
            LocalizedStringResource("All Groups")
        case .matchSpaces:
            LocalizedStringResource("Match Spaces")
        }
    }

    /// Description for the mode
    public var description: LocalizedStringResource {
        switch self {
        case .perGroup:
            LocalizedStringResource("Configure appearance for each group individually.")
        case .allGroups:
            LocalizedStringResource("Use the same appearance for all groups.")
        case .matchSpaces:
            LocalizedStringResource("Use the same appearance as spaces.")
        }
    }

    /// Determines whether the global color properties should be shown for this mode.
    public var shouldShowGlobalConfig: Bool {
        switch self {
        case .perGroup:
            false
        case .allGroups:
            true
        case .matchSpaces:
            false
        }
    }
}
