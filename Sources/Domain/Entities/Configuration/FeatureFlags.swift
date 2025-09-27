// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation
internal import ModifiedCopy

/// Represents feature flags for development and experimental features.
///
/// This struct defines feature flags that can be toggled during development
/// to enable or disable specific functionality. Only available in debug builds.
@CopyableCombi
public struct FeatureFlags: Equatable, Sendable {
    // MARK: - Core Features

    /// Whether to enable the groups functionality for menu bar applications.
    public var enableGroups: Bool

    /// Whether to enable the spaces visualization feature.
    public var enableSpaces: Bool

    /// Whether to show advanced settings in the preferences.
    public var enableAdvancedSettings: Bool

    // MARK: - Convenience Methods

    /// Creates feature flags with default values.
    /// - Returns: FeatureFlags with all default values
    public static func defaultFlags() -> FeatureFlags {
        FeatureFlags(
            enableGroups: FeatureFlagDefaults.enableGroups,
            enableSpaces: FeatureFlagDefaults.enableSpaces,
            enableAdvancedSettings: FeatureFlagDefaults.enableAdvancedSettings
        )
    }
}

#if DEBUG
    public extension FeatureFlags {
        /// Whether feature flags are available in the current build.
        static let isAvailable = true

        /// Gets a human-readable description of all feature flags and their states.
        var debugDescription: String {
            var result = "Feature Flags:\n"

            if enableGroups {
                result += "- Groups ✅\n"
            } else {
                result += "- Groups ❌\n"
            }

            if enableSpaces {
                result += "- Spaces ✅\n"
            } else {
                result += "- Spaces ❌\n"
            }

            if enableAdvancedSettings {
                result += "- Advanced Settings ✅"
            } else {
                result += "- Advanced Settings ❌"
            }

            return result
        }
    }
#else
    public extension FeatureFlags {
        /// Whether feature flags are available in the current build.
        static let isAvailable = false

        /// Gets a human-readable description of all feature flags and their states.
        var debugDescription: String {
            ""
        }
    }
#endif
