// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine

/// Use case for retrieving the Quick Hide trigger key setting.
///
/// Exposes a publisher of QuickHideTriggerKey reflecting the currently configured trigger key.
@MainActor
public final class GetQuickHideTriggerKeyUseCase {
    /// The configuration gateway for accessing Quick Hide trigger key data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified configuration gateway.
    /// - Parameter configurationGateway: The gateway for configuration operations
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to get the Quick Hide trigger key as a publisher.
    /// - Returns: A publisher that emits the current Quick Hide trigger key
    public func execute() -> AnyPublisher<QuickHideTriggerKey, Never> {
        configurationGateway.quickHideTriggerKeyPublisher
    }
}
