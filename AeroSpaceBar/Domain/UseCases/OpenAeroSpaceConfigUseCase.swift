// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation

/// Use case for opening the AeroSpace configuration file.
///
@MainActor
final class OpenAeroSpaceConfigUseCase {
    /// The configuration gateway for accessing configuration data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the configuration gateway.
    /// - Parameter configurationGateway: The gateway for accessing configuration data
    init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to open the AeroSpace configuration file.
    func execute() async {
        await configurationGateway.openAeroSpaceConfig()
    }
}
