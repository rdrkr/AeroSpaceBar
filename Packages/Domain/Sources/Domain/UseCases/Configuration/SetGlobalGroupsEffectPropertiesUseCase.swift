// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

/// Use case for setting global groups effect properties.
///
/// This use case encapsulates the business logic for updating the
/// global groups effect properties setting through the data layer.
/// It follows the clean architecture pattern by isolating this
/// specific business operation.
@MainActor
public final class SetGlobalGroupsEffectPropertiesUseCase {
    /// The configuration gateway for updating global groups effect properties data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified configuration gateway.
    /// - Parameter configurationGateway: The gateway for configuration operations
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to set the global groups effect properties.
    /// - Parameter value: The new global groups effect properties value
    public func execute(value: EffectProperties) async {
        await configurationGateway.setGlobalGroupsEffectProperties(value)
    }
}
