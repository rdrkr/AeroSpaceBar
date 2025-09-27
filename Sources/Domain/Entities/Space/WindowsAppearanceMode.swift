// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Defines how windows visual appearance is configured
public enum WindowsAppearanceMode: String, AppearanceMode {
    /// Each window has its own appearance configuration
    case perWindow = "per_window"

    /// All windows share the same appearance configuration
    case allWindows = "all_windows"

    /// Display name for the mode
    public var displayName: LocalizedStringResource {
        switch self {
        case .perWindow:
            LocalizedStringResource("Per Window")
        case .allWindows:
            LocalizedStringResource("All Windows")
        }
    }

    /// Description for the mode
    public var description: LocalizedStringResource {
        switch self {
        case .perWindow:
            LocalizedStringResource("Configure appearance for each window individually.")
        case .allWindows:
            LocalizedStringResource("Use the same appearance for all windows.")
        }
    }

    /// Determines whether the global visual configuration should be shown for this mode.
    public var shouldShowGlobalConfig: Bool {
        switch self {
        case .perWindow:
            false
        case .allWindows:
            true
        }
    }
}
