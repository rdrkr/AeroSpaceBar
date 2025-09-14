// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Represents feature flags for development and experimental features.
///
/// This struct defines feature flags that can be toggled during development
/// to enable or disable specific functionality. Only available in debug builds.
public struct FeatureFlags: Codable, Equatable, Sendable {
    // MARK: - Core Features

    /// Whether to enable the groups functionality for menu bar applications.
    public let enableGroups: Bool

    /// Whether to enable the spaces visualization feature.
    public let enableSpaces: Bool

    /// Whether to show advanced settings in the preferences.
    public let enableAdvancedSettings: Bool
    /// Whether to enable licensing features and restrictions.
    public let enableLicensing: Bool

    #if DEBUG
        /// Whether to mock an active license for development testing.
        public let mockActiveLicense: Bool
    #endif

    // MARK: - Initialization

    #if DEBUG
        /// Creates feature flags with the specified values (DEBUG build).
        /// - Parameters:
        ///   - enableGroups: Enable groups functionality
        ///   - enableSpaces: Enable spaces visualization
        ///   - enableAdvancedSettings: Show advanced settings
        ///   - enableLicensing: Enable licensing features
        ///   - mockActiveLicense: Mock active license for development
        public init(
            enableGroups: Bool = FeatureFlagDefaults.enableGroups,
            enableSpaces: Bool = FeatureFlagDefaults.enableSpaces,
            enableAdvancedSettings: Bool = FeatureFlagDefaults.enableAdvancedSettings,
            enableLicensing: Bool = FeatureFlagDefaults.enableLicensing,
            mockActiveLicense: Bool = FeatureFlagDefaults.mockActiveLicense
        ) {
            self.enableGroups = enableGroups
            self.enableSpaces = enableSpaces
            self.enableAdvancedSettings = enableAdvancedSettings
            self.enableLicensing = enableLicensing
            self.mockActiveLicense = mockActiveLicense
        }
    #else
        /// Creates feature flags with the specified values (RELEASE build).
        /// - Parameters:
        ///   - enableGroups: Enable groups functionality
        ///   - enableSpaces: Enable spaces visualization
        ///   - enableAdvancedSettings: Show advanced settings
        ///   - enableLicensing: Enable licensing features
        public init(
            enableGroups: Bool = FeatureFlagDefaults.enableGroups,
            enableSpaces: Bool = FeatureFlagDefaults.enableSpaces,
            enableAdvancedSettings: Bool = FeatureFlagDefaults.enableAdvancedSettings,
            enableLicensing: Bool = FeatureFlagDefaults.enableLicensing
        ) {
            self.enableGroups = enableGroups
            self.enableSpaces = enableSpaces
            self.enableAdvancedSettings = enableAdvancedSettings
            self.enableLicensing = enableLicensing
        }
    #endif

    // MARK: - Convenience Methods

    /// Creates feature flags with default values.
    /// - Returns: FeatureFlags with all default values
    public static func defaultFlags() -> FeatureFlags {
        FeatureFlags()
    }

    #if DEBUG
        /// Creates a copy of the feature flags with updated values (DEBUG build).
        /// - Parameters:
        ///   - enableGroups: New value for groups feature (optional)
        ///   - enableSpaces: New value for spaces feature (optional)
        ///   - enableAdvancedSettings: New value for advanced settings (optional)
        ///   - enableLicensing: New value for licensing feature (optional)
        ///   - mockActiveLicense: New value for mock license feature (optional)
        /// - Returns: New FeatureFlags instance with updated values
        public func updating(
            enableGroups: Bool? = nil,
            enableSpaces: Bool? = nil,
            enableAdvancedSettings: Bool? = nil,
            enableLicensing: Bool? = nil,
            mockActiveLicense: Bool? = nil
        ) -> FeatureFlags {
            FeatureFlags(
                enableGroups: enableGroups ?? self.enableGroups,
                enableSpaces: enableSpaces ?? self.enableSpaces,
                enableAdvancedSettings: enableAdvancedSettings ?? self.enableAdvancedSettings,
                enableLicensing: enableLicensing ?? self.enableLicensing,
                mockActiveLicense: mockActiveLicense ?? self.mockActiveLicense
            )
        }
    #else
        /// Creates a copy of the feature flags with updated values (RELEASE build).
        /// - Parameters:
        ///   - enableGroups: New value for groups feature (optional)
        ///   - enableSpaces: New value for spaces feature (optional)
        ///   - enableAdvancedSettings: New value for advanced settings (optional)
        ///   - enableLicensing: New value for licensing feature (optional)
        /// - Returns: New FeatureFlags instance with updated values
        public func updating(
            enableGroups: Bool? = nil,
            enableSpaces: Bool? = nil,
            enableAdvancedSettings: Bool? = nil,
            enableLicensing: Bool? = nil
        ) -> FeatureFlags {
            FeatureFlags(
                enableGroups: enableGroups ?? self.enableGroups,
                enableSpaces: enableSpaces ?? self.enableSpaces,
                enableAdvancedSettings: enableAdvancedSettings ?? self.enableAdvancedSettings,
                enableLicensing: enableLicensing ?? self.enableLicensing
            )
        }
    #endif
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
