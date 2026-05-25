// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Foundation

/// Use case for setting the hidden-spaces configuration.
@MainActor
public final class SetHiddenSpacesUseCase {
    private let configurationGateway: ConfigurationGateway

    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to set which spaces are hidden.
    /// - Parameter value: The list of space IDs to hide
    public func execute(value: [String]) async {
        await configurationGateway.setHiddenSpaces(value)
    }
}
