// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine

/// Use case for retrieving theme preset geometric properties.
///
/// This use case encapsulates the business logic for accessing the
/// theme preset geometric properties setting through the data layer.
/// It follows the clean architecture pattern by isolating this
/// specific business operation.
@MainActor
public final class GetThemePresetGeometricPropertiesUseCase {
    /// The configuration gateway for accessing theme preset geometric properties data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified configuration gateway.
    /// - Parameter configurationGateway: The gateway for configuration operations
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to get the theme preset geometric properties.
    /// - Returns: A publisher that emits the current theme preset geometric properties
    public func execute() -> AnyPublisher<GeometricProperties, Never> {
        configurationGateway.themePresetGeometricPropertiesPublisher
    }
}
