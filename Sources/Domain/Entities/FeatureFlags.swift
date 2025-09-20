// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Represents feature flags for development and experimental features.
///
/// This struct defines feature flags that can be toggled during development
/// to enable or disable specific functionality. Only available in debug builds.
public struct FeatureFlags: Equatable, Sendable {
    // MARK: - Core Features

    /// Whether to enable the groups functionality for menu bar applications.
    public var enableGroups: Bool

    /// Whether to enable the spaces visualization feature.
    public var enableSpaces: Bool

    /// Whether to show advanced settings in the preferences.
    public var enableAdvancedSettings: Bool

    /// Whether to enable licensing features and restrictions.
    public var enableLicensing: Bool

    #if DEBUG
        /// Whether to mock an active license for development testing.
        public var mockActiveLicense: Bool
    #endif

    // MARK: - Convenience Methods

    /// Creates feature flags with default values.
    /// - Returns: FeatureFlags with all default values
    public static func defaultFlags() -> FeatureFlags {
        #if DEBUG
            FeatureFlags(
                enableGroups: FeatureFlagDefaults.enableGroups,
                enableSpaces: FeatureFlagDefaults.enableSpaces,
                enableAdvancedSettings: FeatureFlagDefaults.enableAdvancedSettings,
                enableLicensing: FeatureFlagDefaults.enableLicensing,
                mockActiveLicense: FeatureFlagDefaults.mockActiveLicense
            )
        #else
            FeatureFlags(
                enableGroups: FeatureFlagDefaults.enableGroups,
                enableSpaces: FeatureFlagDefaults.enableSpaces,
                enableAdvancedSettings: FeatureFlagDefaults.enableAdvancedSettings,
                enableLicensing: FeatureFlagDefaults.enableLicensing
            )
        #endif
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
                result += "- Advanced Settings ✅\n"
            } else {
                result += "- Advanced Settings ❌\n"
            }

            if enableLicensing {
                result += "- Licensing ✅\n"
            } else {
                result += "- Licensing ❌\n"
            }

            if mockActiveLicense {
                result += "- Mock Active License ✅"
            } else {
                result += "- Mock Active License ❌"
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
