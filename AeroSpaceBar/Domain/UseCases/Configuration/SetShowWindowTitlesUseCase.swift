// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Use case for setting the show-window-titles configuration.
@MainActor
final class SetShowWindowTitlesUseCase {
    private let configurationGateway: ConfigurationGateway

    init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to set whether to show window titles.
    /// - Parameter value: The desired state for showing window titles
    func execute(value: Bool) async {
        await configurationGateway.setShowWindowTitles(value)
    }
}
