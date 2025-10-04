// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Use case for setting the show-empty-spaces configuration.
@MainActor
public final class SetShowEmptySpacesUseCase {
    private let configurationGateway: ConfigurationGateway

    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to set whether to show empty spaces.
    /// - Parameter value: The desired state for showing empty spaces
    public func execute(value: Bool) async {
        await configurationGateway.setShowEmptySpaces(value)
    }
}
