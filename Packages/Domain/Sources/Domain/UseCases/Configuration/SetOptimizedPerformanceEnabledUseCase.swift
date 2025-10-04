// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Use case for setting the optimized performance enabled setting.
///
/// This use case encapsulates the business logic for setting the optimized performance flag.
/// It belongs to the domain layer and coordinates between the presentation and data layers.
@MainActor
public final class SetOptimizedPerformanceEnabledUseCase {
    /// The configuration gateway for data access.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified gateway.
    /// - Parameter configurationGateway: The gateway for configuration data access
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to set the optimized performance enabled setting.
    /// - Parameter value: Whether optimized performance is enabled (nil falls back to default)
    public func execute(value: Bool?) async {
        if let value {
            await configurationGateway.setIsOptimizedPerformanceEnabled(value)
        } else {
            await configurationGateway
                .setIsOptimizedPerformanceEnabled(ConfigurationDefaults.isOptimizedPerformanceEnabled)
        }
    }
}
