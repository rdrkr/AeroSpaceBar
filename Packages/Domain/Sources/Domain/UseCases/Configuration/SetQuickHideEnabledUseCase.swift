// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Foundation

/// Use case for setting the Quick Hide enabled configuration.
@MainActor
public final class SetQuickHideEnabledUseCase {
    /// The configuration gateway for setting Quick Hide enabled state.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified configuration gateway.
    /// - Parameter configurationGateway: The gateway for configuration operations
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to set the Quick Hide enabled state.
    /// - Parameter value: The desired Quick Hide enabled state
    public func execute(value: Bool) async {
        await configurationGateway.setQuickHideEnabled(value)
    }
}
