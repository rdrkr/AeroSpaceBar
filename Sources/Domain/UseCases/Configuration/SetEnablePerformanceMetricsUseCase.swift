// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Use case for setting the enable performance metrics setting.
///
/// This use case encapsulates the business logic for setting the enable performance metrics setting.
/// It belongs to the domain layer and coordinates between the presentation and data layers.
@MainActor
public final class SetEnablePerformanceMetricsUseCase {
    /// The configuration gateway for data access.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified gateway.
    /// - Parameter configurationGateway: The gateway for configuration data access
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to set the enable performance metrics setting.
    /// - Parameter value: Whether to enable performance metrics
    public func execute(value: Bool?) async {
        if let value {
            await configurationGateway.setEnablePerformanceMetrics(value)
        } else {
            // For nil, set to default value (true)
            await configurationGateway.setEnablePerformanceMetrics(true)
        }
    }
}
