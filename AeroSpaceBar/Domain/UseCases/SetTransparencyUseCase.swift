// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Use case for setting the transparency configuration.
///
/// This use case handles the business logic for updating the transparency setting,
/// following the domain-driven design pattern.
@MainActor
final class SetTransparencyUseCase {
    /// The configuration gateway for accessing configuration data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the configuration gateway.
    /// - Parameter configurationGateway: The gateway for accessing configuration data
    init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to set the transparency setting.
    ///
    /// - Parameter transparency: The new transparency value (0.0 to 1.0).
    func execute(transparency: Double) async {
        await configurationGateway.setTransparency(transparency)
    }
}
