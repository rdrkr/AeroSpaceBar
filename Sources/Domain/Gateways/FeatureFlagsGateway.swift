// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation

/// Gateway protocol for feature flags management in development builds.
///
/// This protocol defines the contract for accessing and managing feature flags
/// that control experimental and development features. Only available in debug builds.
public protocol FeatureFlagsGateway: Sendable {
    /// Publisher that emits the current feature flags configuration.
    var featureFlags: AnyPublisher<FeatureFlags, Never> { get }

    /// Current feature flags configuration (synchronous access).
    var currentFeatureFlags: FeatureFlags { get }

    /// Sets the feature flags configuration.
    /// - Parameter flags: The new feature flags configuration to store
    func setFeatureFlags(_ flags: FeatureFlags) async

    /// Resets all feature flags to their default values.
    func resetToDefaults() async
}
