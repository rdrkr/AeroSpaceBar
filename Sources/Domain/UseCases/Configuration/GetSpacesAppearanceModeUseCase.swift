// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine

/// Use case for retrieving spaces appearance mode.
///
/// This use case encapsulates the business logic for accessing the
/// spaces appearance mode setting through the data layer.
/// It follows the clean architecture pattern by isolating this
/// specific business operation.
@MainActor
public final class GetSpacesAppearanceModeUseCase {
    /// The configuration gateway for accessing spaces appearance mode data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified configuration gateway.
    /// - Parameter configurationGateway: The gateway for configuration operations
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to get the spaces appearance mode.
    /// - Returns: A publisher that emits the current spaces appearance mode
    public func execute() -> AnyPublisher<SpacesAppearanceMode, Never> {
        configurationGateway.spacesAppearanceModePublisher
    }
}
