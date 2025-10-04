// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

/// Use case for setting spaces appearance mode.
///
/// This use case encapsulates the business logic for updating the
/// spaces appearance mode setting through the data layer.
/// It follows the clean architecture pattern by isolating this
/// specific business operation.
@MainActor
public final class SetSpacesAppearanceModeUseCase {
    /// The configuration gateway for accessing spaces appearance mode data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified configuration gateway.
    /// - Parameter configurationGateway: The gateway for configuration operations
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to set the spaces appearance mode.
    /// - Parameter value: The new spaces appearance mode value to set
    public func execute(value: SpacesAppearanceMode) async {
        await configurationGateway.setSpacesAppearanceMode(value)
    }
}
