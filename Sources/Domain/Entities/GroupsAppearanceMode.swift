// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Defines how groups visual appearance is configured
public enum GroupsAppearanceMode: String, CaseIterable, Codable, @unchecked Sendable {
    /// Each group has its own appearance configuration
    case perApp = "per_app"

    /// All groups share the same appearance configuration
    case allGroups = "all_groups"

    /// Groups use the same appearance as spaces
    case matchSpaces = "match_spaces"

    /// Display name for the mode
    public var displayName: LocalizedStringResource {
        switch self {
        case .perApp:
            LocalizedStringResource("Per App")
        case .allGroups:
            LocalizedStringResource("All Groups")
        case .matchSpaces:
            LocalizedStringResource("Match Spaces")
        }
    }

    /// Description for the mode
    public var description: LocalizedStringResource {
        switch self {
        case .perApp:
            LocalizedStringResource("Configure appearance for each group individually.")
        case .allGroups:
            LocalizedStringResource("Use the same appearance for all groups.")
        case .matchSpaces:
            LocalizedStringResource("Use the same appearance as spaces.")
        }
    }
}
