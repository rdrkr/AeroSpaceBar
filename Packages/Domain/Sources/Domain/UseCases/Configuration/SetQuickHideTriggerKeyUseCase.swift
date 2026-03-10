// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Foundation

/// Use case for setting the Quick Hide trigger key configuration.
@MainActor
public final class SetQuickHideTriggerKeyUseCase {
    /// The configuration gateway for setting the Quick Hide trigger key.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified configuration gateway.
    /// - Parameter configurationGateway: The gateway for configuration operations
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to set the Quick Hide trigger key.
    /// - Parameter value: The desired Quick Hide trigger key
    public func execute(value: QuickHideTriggerKey) async {
        await configurationGateway.setQuickHideTriggerKey(value)
    }
}
