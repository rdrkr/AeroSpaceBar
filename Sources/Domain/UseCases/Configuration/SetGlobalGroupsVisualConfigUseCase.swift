// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

/// Use case for setting global groups visual configuration.
///
/// This use case encapsulates the business logic for updating the
/// global groups visual configuration setting through the data layer.
/// It follows the clean architecture pattern by isolating this
/// specific business operation.
@MainActor
public final class SetGlobalGroupsVisualConfigUseCase {
    /// The configuration gateway for accessing global groups visual configuration data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified configuration gateway.
    /// - Parameter configurationGateway: The gateway for configuration operations
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to set the global groups visual configuration.
    /// - Parameter value: The new global groups visual configuration value to set
    public func execute(value: VisualContainer) async {
        await configurationGateway.setGlobalGroupsVisualConfig(value)
    }
}
