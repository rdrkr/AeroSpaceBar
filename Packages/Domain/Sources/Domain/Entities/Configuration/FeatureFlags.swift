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

    /// Whether to enable the software updates feature.
    public var enableSoftwareUpdates: Bool

    /// Whether to show advanced settings in the preferences.
    public var enableAdvancedSettings: Bool

    // MARK: - Convenience Methods

    /// Creates feature flags with default values.
    /// - Returns: FeatureFlags with all default values
    public static func defaultFlags() -> FeatureFlags {
        FeatureFlags(
            enableGroups: FeatureFlagDefaults.enableGroups,
            enableSpaces: FeatureFlagDefaults.enableSpaces,
            enableSoftwareUpdates: FeatureFlagDefaults.enableSoftwareUpdates,
            enableAdvancedSettings: FeatureFlagDefaults.enableAdvancedSettings
        )
    }

    /// Copies this instance while updating non required license flags from a given other instance.
    /// - Parameter other The other instance to be used for updating this instance.
    /// - Returns FeatureFlags with updated non required license flags.
    public func copyWithUpdatedNonRequiredLicenseFlags(other: FeatureFlags) -> FeatureFlags {
        let updatedInstance = if enableSoftwareUpdates != other.enableSoftwareUpdates {
            copy(enableSoftwareUpdates: other.enableSoftwareUpdates)
        } else {
            self
        }

        return updatedInstance
    }

    /// Copies this instance while disabling required license flags.
    /// - Returns FeatureFlags with disabled required license flags.
    public func copyWithDisabledRequiredLicenseFlags() -> FeatureFlags {
        let updatedInstance = copy(
            enableGroups: false,
            enableSpaces: false,
            enableAdvancedSettings: false
        )

        return updatedInstance
    }
}
