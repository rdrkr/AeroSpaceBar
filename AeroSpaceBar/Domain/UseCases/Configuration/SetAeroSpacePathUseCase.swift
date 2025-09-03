// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Use case for setting the AeroSpace path setting.
///
/// This use case encapsulates the business logic for setting the AeroSpace path setting.
/// It belongs to the domain layer and coordinates between the presentation and data layers.
/// Following reactive patterns similar to Kotlin Flow/StateFlow.
@MainActor
final class SetAeroSpacePathUseCase {
    /// The configuration gateway for data access.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified gateway.
    /// - Parameter configurationGateway: The gateway for configuration data access
    init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to set the AeroSpace path setting.
    /// - Parameter value: The AeroSpace path
    func execute(value: String) async {
        await configurationGateway.setAeroSpacePath(value)
    }
}
