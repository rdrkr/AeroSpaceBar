// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation

/// Use case for getting the AeroSpace configuration file path.
///
@MainActor
final class GetAeroSpaceConfigPathUseCase {
    /// The configuration gateway for accessing configuration data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the configuration gateway.
    /// - Parameter configurationGateway: The gateway for accessing configuration data
    init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to get the AeroSpace configuration file path.
    /// - Returns: The AeroSpace configuration file path
    func execute() async -> URL {
        await configurationGateway.getAeroSpaceConfigPath()
    }
}
