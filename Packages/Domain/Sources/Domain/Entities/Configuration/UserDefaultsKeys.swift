// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Minimal UserDefaults key management for Logger configuration.
///
/// This enum provides UserDefaults keys specifically for Logger configuration
/// to avoid co-dependencies. Logger needs to access settings without depending
/// on ConfigurationRepository to prevent circular dependencies.
///
/// All keys follow the pattern: `com.aerospacebar.preferences.{setting}`
public enum UserDefaultsKeys: String, CaseIterable {
    // MARK: - Logger Configuration

    /// The current log level for application logging.
    case logLevel = "com.aerospacebar.preferences.logLevel"

    /// Whether to enable performance metrics collection and logging.
    case enablePerformanceMetrics = "com.aerospacebar.preferences.enablePerformanceMetrics"

    // MARK: - System Integration (kept for bootstrap)

    /// The path to the configuration file (stored in UserDefaults to bootstrap TOML loading).
    case configFilePath = "com.aerospacebar.preferences.configFilePath"

    // MARK: - Screen Capture Permissions

    /// Whether the user has been asked for screen capture permissions.
    case hasAskedForScreenCapturePermissions = "com.aerospacebar.preferences.hasAskedForScreenCapturePermissions"

    // MARK: - AeroSpace Integration

    /// Whether the AeroSpace config callbacks installed by pre-subscription
    /// versions of this app have already been cleaned up.
    ///
    /// Stored in UserDefaults rather than the TOML configuration because it is a
    /// one-time migration marker, not a user-facing setting.
    case hasRemovedLegacyAeroSpaceCallbacks = "com.aerospacebar.preferences.hasRemovedLegacyAeroSpaceCallbacks"
}
