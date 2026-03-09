// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Default values for feature flags in development builds.
///
/// This enum centralizes all default feature flag values to ensure consistency
/// across the application and make it easy to adjust defaults during development.
public enum FeatureFlagDefaults {
    // MARK: - Core Features

    /// Default state for spaces visualization.
    /// Set to true since spaces are a stable core feature.
    public static let enableSpaces: Bool = true

    /// Default state for advanced settings visibility.
    /// Set to true to show all configuration options by default in development.
    public static let enableAdvancedSettings: Bool = true

    /// Default state for groups functionality.
    /// Set to true since groups are a stable core feature.
    public static let enableGroups: Bool = true

    /// Default state for software updates functionality.
    /// Set to true to enable software update checking and management.
    public static let enableSoftwareUpdates: Bool = true

    /// Default state for licensing functionality.
    /// Set to true for debug builds to test licensing features, false for release builds.
    public static let enableLicensing: Bool = false

    // Default state for trial request functionality.
    // Set to true for debug builds to allow testing, false for release builds.
    #if DEBUG
        public static let enableTrialRequest: Bool = true
    #else
        public static let enableTrialRequest: Bool = false
    #endif

    #if DEBUG
        /// Default state for mocking an active license.
        /// Set to false by default, can be enabled for testing licensed features.
        public static let mockActiveLicense: Bool = false

        /// Default checkout environment for license purchases.
        /// Set to production by default, can be switched to development for testing.
        public static let checkoutEnvironment: CheckoutEnvironment = .development
    #endif
}
