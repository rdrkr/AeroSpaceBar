// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine

/// Use case for retrieving spaces configuration.
///
/// This use case encapsulates the business logic for accessing the
/// spaces configuration setting through the data layer.
/// It follows the clean architecture pattern by isolating this
/// specific business operation.
@MainActor
public final class GetSpacesVisualConfigUseCase {
    /// The configuration gateway for accessing spaces configuration data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified configuration gateway.
    /// - Parameter configurationGateway: The gateway for configuration operations
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to get the spaces configuration.
    /// - Returns: A publisher that emits the current spaces configuration
    public func execute() -> AnyPublisher<[VisualContainer], Never> {
        configurationGateway.spacesVisualConfigPublisher
    }
}
