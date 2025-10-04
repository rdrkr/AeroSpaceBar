// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Use case for opening the configuration file.
///
/// This use case encapsulates the business logic for opening the configuration file
/// in the default system editor.
@MainActor
public final class OpenConfigFileUseCase {
    /// The configuration gateway for data access.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified gateway.
    /// - Parameter configurationGateway: The gateway for configuration data access
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to open the configuration file.
    public func execute() async {
        await configurationGateway.openConfigFile()
    }
}
