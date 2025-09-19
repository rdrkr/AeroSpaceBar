// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine

/// Use case for retrieving global space visual configuration.
///
/// This use case encapsulates the business logic for accessing the
/// global space visual configuration setting through the data layer.
/// It follows the clean architecture pattern by isolating this
/// specific business operation.
@MainActor
public final class GetGlobalSpacesVisualConfigUseCase {
    /// The configuration gateway for accessing global space visual configuration data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified configuration gateway.
    /// - Parameter configurationGateway: The gateway for configuration operations
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to get the global space visual configuration.
    /// - Returns: A publisher that emits the current global space visual configuration
    public func execute() -> AnyPublisher<VisualContainer, Never> {
        configurationGateway.globalSpacesVisualConfigPublisher
    }
}
