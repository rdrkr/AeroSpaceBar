// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

/// Use case for setting spaces configuration.
///
/// This use case encapsulates the business logic for updating the
/// spaces configuration setting through the data layer.
/// It follows the clean architecture pattern by isolating this
/// specific business operation.
@MainActor
public final class SetSpacesColorPropertiesUseCase {
    /// The configuration gateway for accessing spaces configuration data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified configuration gateway.
    /// - Parameter configurationGateway: The gateway for configuration operations
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to set the spaces configuration.
    /// - Parameter value: The new spaces configuration value to set
    public func execute(value: [ColorProperties]) async {
        await configurationGateway.setSpacesColorProperties(value)
    }
}
