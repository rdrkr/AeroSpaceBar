// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

/// Use case for setting global space visual configuration.
///
/// This use case encapsulates the business logic for updating the
/// global space visual configuration setting through the data layer.
/// It follows the clean architecture pattern by isolating this
/// specific business operation.
@MainActor
public final class SetGlobalSpacesVisualConfigUseCase {
    /// The configuration gateway for accessing global space visual configuration data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified configuration gateway.
    /// - Parameter configurationGateway: The gateway for configuration operations
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to set the global space visual configuration.
    /// - Parameter value: The new global space visual configuration value to set
    public func execute(value: VisualProperties) async {
        await configurationGateway.setGlobalSpacesVisualConfig(value)
    }
}
