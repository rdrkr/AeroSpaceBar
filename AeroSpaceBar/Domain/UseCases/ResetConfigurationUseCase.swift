// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation

/// Use case for resetting all configuration settings to their default values.
///
/// This use case encapsulates the business logic for resetting configuration
/// through a reactive publisher, following the domain-driven design pattern.
@MainActor
final class ResetConfigurationUseCase {
    /// The configuration gateway for accessing configuration data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the configuration gateway.
    /// - Parameter configurationGateway: The gateway for accessing configuration data
    init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to reset all configuration settings to defaults.
    func execute() async {
        await configurationGateway.resetToDefaults()
    }
}
