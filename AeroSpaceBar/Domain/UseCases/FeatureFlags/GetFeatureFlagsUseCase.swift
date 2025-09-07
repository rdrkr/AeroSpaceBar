// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation

/// Use case for retrieving feature flags configuration.
///
/// This use case provides access to the current feature flags settings,
/// allowing other parts of the application to react to feature flag changes.
/// Only available in debug builds.
final class GetFeatureFlagsUseCase: Sendable {
    private let gateway: FeatureFlagsGateway

    /// Initializes the use case with a feature flags gateway.
    /// - Parameter gateway: The gateway for accessing feature flags
    init(gateway: FeatureFlagsGateway) {
        self.gateway = gateway
    }

    /// Executes the use case to get feature flags.
    /// - Returns: A publisher that emits the current FeatureFlags configuration
    func execute() -> AnyPublisher<FeatureFlags, Never> {
        gateway.featureFlags
    }
}
