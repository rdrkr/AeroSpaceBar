// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine

/// Use case for retrieving the Quick Hide enabled state.
///
/// Exposes a publisher of Bool reflecting whether the Quick Hide feature is enabled.
@MainActor
public final class GetQuickHideEnabledUseCase {
    /// The configuration gateway for accessing Quick Hide enabled data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified configuration gateway.
    /// - Parameter configurationGateway: The gateway for configuration operations
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to get the Quick Hide enabled state as a publisher.
    /// - Returns: A publisher that emits the current Quick Hide enabled state
    public func execute() -> AnyPublisher<Bool, Never> {
        configurationGateway.quickHideEnabledPublisher
    }
}
