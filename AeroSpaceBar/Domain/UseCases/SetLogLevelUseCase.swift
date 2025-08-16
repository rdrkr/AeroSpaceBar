// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Use case for setting the log level setting.
///
/// This use case encapsulates the business logic for setting the log level setting.
/// It belongs to the domain layer and coordinates between the presentation and data layers.
@MainActor
final class SetLogLevelUseCase {
    /// The configuration gateway for data access.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified gateway.
    /// - Parameter configurationGateway: The gateway for configuration data access
    init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to set the log level setting.
    /// - Parameter level: The log level
    func execute(value: Logger.Level?) async {
        if let level = value {
            await configurationGateway.setLogLevel(level)
        } else {
            // For nil, set to default value (.info)
            await configurationGateway.setLogLevel(.info)
        }
    }
}
