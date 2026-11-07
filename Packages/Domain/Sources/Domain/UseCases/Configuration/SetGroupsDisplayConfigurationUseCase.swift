// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

/// Updates the displays selected for groups.
@MainActor
public final class SetGroupsDisplayConfigurationUseCase {
    private let configurationGateway: ConfigurationGateway

    /// Creates the use case with the application's configuration gateway.
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Persists the display configuration.
    public func execute(value: DisplayConfiguration) async {
        await configurationGateway.setGroupsDisplayConfiguration(value)
    }
}
