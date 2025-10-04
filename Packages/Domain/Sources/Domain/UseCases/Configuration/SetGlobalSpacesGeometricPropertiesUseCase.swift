// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

/// Use case for setting global space geometric properties.
///
/// This use case encapsulates the business logic for updating the
/// global space geometric properties setting through the data layer.
/// It follows the clean architecture pattern by isolating this
/// specific business operation.
@MainActor
public final class SetGlobalSpacesGeometricPropertiesUseCase {
    /// The configuration gateway for accessing global space geometric properties data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified configuration gateway.
    /// - Parameter configurationGateway: The gateway for configuration operations
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to set the global space geometric properties.
    /// - Parameter value: The new global space geometric properties value to set
    public func execute(value: GeometricProperties) async {
        await configurationGateway.setGlobalSpacesGeometricProperties(value)
    }
}
