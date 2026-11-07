// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine

/// Observes the displays selected for spaces.
@MainActor
public final class GetSpacesDisplayConfigurationUseCase {
    private let configurationGateway: ConfigurationGateway

    /// Creates the use case with the application's configuration gateway.
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Returns the current configuration and subsequent changes.
    public func execute() -> AnyPublisher<DisplayConfiguration, Never> {
        configurationGateway.spacesDisplayConfigurationPublisher
    }
}
