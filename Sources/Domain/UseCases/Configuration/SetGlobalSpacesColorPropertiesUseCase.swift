// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

/// Use case for setting global space color properties.
///
/// This use case encapsulates the business logic for updating the
/// global space color properties setting through the data layer.
/// It follows the clean architecture pattern by isolating this
/// specific business operation.
@MainActor
public final class SetGlobalSpacesColorPropertiesUseCase {
    /// The configuration gateway for accessing global space color properties data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified configuration gateway.
    /// - Parameter configurationGateway: The gateway for configuration operations
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to set the global space color properties.
    /// - Parameter value: The new global space color properties value to set
    public func execute(value: ColorProperties) async {
        await configurationGateway.setGlobalSpacesColorProperties(value)
    }
}
