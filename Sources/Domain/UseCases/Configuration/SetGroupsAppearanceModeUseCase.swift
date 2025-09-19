// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Use case for setting the groups appearance mode configuration.
@MainActor
public final class SetGroupsAppearanceModeUseCase {
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the required gateway.
    /// - Parameter configurationGateway: Gateway for configuration access
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to set the groups appearance mode.
    /// - Parameter mode: The groups appearance mode to set
    public func execute(mode: GroupsAppearanceMode) async {
        await configurationGateway.setGroupsAppearanceMode(mode)
    }
}
