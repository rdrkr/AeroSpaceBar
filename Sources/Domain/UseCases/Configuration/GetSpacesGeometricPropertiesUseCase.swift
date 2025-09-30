// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine

/// Use case for retrieving spaces geometric properties configuration.
///
/// This use case provides access to the geometric properties for individual spaces,
/// allowing for space-specific geometry customization. It follows the clean architecture
/// pattern by delegating to the ConfigurationGateway.
@MainActor
public final class GetSpacesGeometricPropertiesUseCase {
    /// The configuration gateway to retrieve spaces geometric properties from.
    private let configurationGateway: ConfigurationGateway

    /// Initializes a new instance of the use case.
    ///
    /// - Parameter configurationGateway: The gateway to use for retrieving spaces geometric properties
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to retrieve the spaces geometric properties publisher.
    ///
    /// - Returns: A publisher that emits arrays of geometric properties for spaces
    public func execute() -> AnyPublisher<[GeometricProperties], Never> {
        configurationGateway.spacesGeometricPropertiesPublisher
    }
}
