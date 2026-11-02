// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

/// Updates the displays selected for spaces.
@MainActor
public final class SetSpacesDisplayConfigurationUseCase {
    private let configurationGateway: ConfigurationGateway

    /// Creates the use case with the application's configuration gateway.
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Persists the display configuration.
    public func execute(value: SpacesDisplayConfiguration) async {
        await configurationGateway.setSpacesDisplayConfiguration(value)
    }
}
