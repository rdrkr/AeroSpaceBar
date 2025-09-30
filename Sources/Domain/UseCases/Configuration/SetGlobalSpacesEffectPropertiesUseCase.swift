// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

/// Use case for setting global space effect properties.
///
/// This use case encapsulates the business logic for updating the
/// global space effect properties setting through the data layer.
/// It follows the clean architecture pattern by isolating this
/// specific business operation.
@MainActor
public final class SetGlobalSpacesEffectPropertiesUseCase {
    /// The configuration gateway for updating global space effect properties data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified configuration gateway.
    /// - Parameter configurationGateway: The gateway for configuration operations
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to set the global space effect properties.
    /// - Parameter value: The new global space effect properties value
    public func execute(value: EffectProperties) async {
        await configurationGateway.setGlobalSpacesEffectProperties(value)
    }
}
