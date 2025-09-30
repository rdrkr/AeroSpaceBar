// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine

/// Use case for setting theme preset geometric properties.
///
/// This use case encapsulates the business logic for updating the
/// theme preset geometric properties setting through the data layer.
/// It follows the clean architecture pattern by isolating this
/// specific business operation.
@MainActor
public final class SetThemePresetGeometricPropertiesUseCase {
    /// The configuration gateway for persisting theme preset geometric properties data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified configuration gateway.
    /// - Parameter configurationGateway: The gateway for configuration operations
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to set the theme preset geometric properties.
    /// - Parameter value: The new theme preset geometric properties value
    public func execute(value: GeometricProperties) async {
        await configurationGateway.setThemePresetGeometricProperties(value)
    }
}
