// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Default values for feature flags in development builds.
///
/// This enum centralizes all default feature flag values to ensure consistency
/// across the application and make it easy to adjust defaults during development.
enum FeatureFlagDefaults {
    // MARK: - Core Features

    /// Default state for spaces visualization.
    /// Set to true since spaces are a stable core feature.
    static let enableSpaces: Bool = true

    /// Default state for advanced settings visibility.
    /// Set to true to show all configuration options by default in development.
    static let enableAdvancedSettings: Bool = true

    /// Default state for groups functionality.
    /// Set to true since groups are a stable core feature.
    #if DEBUG
        static let enableGroups: Bool = true
    #else
        static let enableGroups: Bool = false
    #endif

    // MARK: - Convenience

    /// Creates a FeatureFlags instance with all default values.
    /// - Returns: FeatureFlags configured with default values
    static func createDefault() -> FeatureFlags {
        FeatureFlags(
            enableGroups: enableGroups,
            enableSpaces: enableSpaces,
            enableAdvancedSettings: enableAdvancedSettings
        )
    }
}
