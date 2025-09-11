// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Use case for setting the show-groups configuration.
///
/// Handles updating the configuration to control whether groups
/// should be displayed in the menu bar interface.
@MainActor
public final class SetShowGroupsUseCase {
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the required gateway dependency.
    /// - Parameter configurationGateway: The gateway for configuration operations
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to set the show-groups setting.
    /// - Parameter value: Whether to show groups in the interface
    public func execute(_ value: Bool) async {
        await configurationGateway.setShowGroups(value)
    }
}
