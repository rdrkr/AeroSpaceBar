// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Use case for setting feature flags configuration.
///
/// This use case handles updating the feature flags settings,
/// ensuring proper validation and persistence of the configuration.
/// Only available in debug builds.
@MainActor
public final class SetFeatureFlagsUseCase {
    private let gateway: FeatureFlagsGateway

    /// Initializes the use case with a feature flags gateway.
    /// - Parameter gateway: The gateway for accessing feature flags
    public init(gateway: FeatureFlagsGateway) {
        self.gateway = gateway
    }

    /// Executes the use case to set feature flags.
    /// - Parameter flags: The new feature flags configuration to store
    public func execute(_ flags: FeatureFlags) async {
        await gateway.setFeatureFlags(flags)
    }

    /// Resets all feature flags to their default values.
    public func resetToDefaults() async {
        await gateway.resetToDefaults()
    }
}
