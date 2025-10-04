// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Use case for setting the group configuration.
///
/// Handles updating the configuration to control how menu bar
/// applications are organized into groups.
@MainActor
public final class SetGroupsUseCase {
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the required gateway dependency.
    /// - Parameter configurationGateway: The gateway for configuration operations
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to set the group configuration.
    /// - Parameter value: The group configuration defining how apps should be grouped
    public func execute(value: [Domain.Group]) async {
        await configurationGateway.setGroups(value)
    }
}
