// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Represents feature flags for development and experimental features.
///
/// This struct defines feature flags that can be toggled during development
/// to enable or disable specific functionality. Only available in debug builds.
struct FeatureFlags: Codable, Equatable {
    // MARK: - Core Features

    /// Whether to enable the groups functionality for menu bar applications.
    let enableGroups: Bool

    /// Whether to enable the spaces visualization feature.
    let enableSpaces: Bool

    /// Whether to show advanced settings in the preferences.
    let enableAdvancedSettings: Bool

    // MARK: - Initialization

    /// Creates feature flags with the specified values.
    /// - Parameters:
    ///   - enableGroups: Enable groups functionality
    ///   - enableSpaces: Enable spaces visualization
    ///   - enableAdvancedSettings: Show advanced settings
    ///   - enableBetaUI: Enable beta UI components
    ///   - enableWindowPreview: Enable window preview functionality
    init(
        enableGroups: Bool = FeatureFlagDefaults.enableGroups,
        enableSpaces: Bool = FeatureFlagDefaults.enableSpaces,
        enableAdvancedSettings: Bool = FeatureFlagDefaults.enableAdvancedSettings
    ) {
        self.enableGroups = enableGroups
        self.enableSpaces = enableSpaces
        self.enableAdvancedSettings = enableAdvancedSettings
    }

    // MARK: - Convenience Methods

    /// Creates feature flags with default values.
    /// - Returns: FeatureFlags with all default values
    static func defaultFlags() -> FeatureFlags {
        FeatureFlags()
    }

    /// Creates a copy of the feature flags with updated values.
    /// - Parameters:
    ///   - enableGroups: New value for groups feature (optional)
    ///   - enableSpaces: New value for spaces feature (optional)
    ///   - enableAdvancedSettings: New value for advanced settings (optional)
    ///   - enableBetaUI: New value for beta UI (optional)
    ///   - enableWindowPreview: New value for window preview (optional)
    /// - Returns: New FeatureFlags instance with updated values
    func updating(
        enableGroups: Bool? = nil,
        enableSpaces: Bool? = nil,
        enableAdvancedSettings: Bool? = nil
    ) -> FeatureFlags {
        FeatureFlags(
            enableGroups: enableGroups ?? self.enableGroups,
            enableSpaces: enableSpaces ?? self.enableSpaces,
            enableAdvancedSettings: enableAdvancedSettings ?? self.enableAdvancedSettings
        )
    }
}

#if DEBUG
    extension FeatureFlags {
        /// Whether feature flags are available in the current build.
        static let isAvailable = true

        /// Gets a human-readable description of all feature flags and their states.
        var debugDescription: String {
            """
            Feature Flags:
            - Groups: \(enableGroups ? "✅" : "❌")
            - Spaces: \(enableSpaces ? "✅" : "❌")
            - Advanced Settings: \(enableAdvancedSettings ? "✅" : "❌")
            """
        }
    }
#else
    extension FeatureFlags {
        /// Whether feature flags are available in the current build.
        static let isAvailable = false
    }
#endif
