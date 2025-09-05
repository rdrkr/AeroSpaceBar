// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Use case for setting the show-empty-spaces configuration.
@MainActor
final class SetShowEmptySpacesUseCase {
    private let configurationGateway: ConfigurationGateway

    init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to set whether to show empty spaces.
    /// - Parameter value: The desired state for showing empty spaces
    func execute(value: Bool) async {
        await configurationGateway.setShowEmptySpaces(value)
    }
}
