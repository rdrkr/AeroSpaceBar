// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Foundation

/// Use case for setting the show-foreground-overlay configuration.
///
/// Handles updating the configuration to control whether the foreground
/// color overlay should be displayed on groups and the Apple Button.
@MainActor
public final class SetShowForegroundOverlayUseCase {
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the required gateway dependency.
    /// - Parameter configurationGateway: The gateway for configuration operations
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to set the show-foreground-overlay setting.
    /// - Parameter value: Whether to show the foreground overlay
    public func execute(value: Bool) async {
        await configurationGateway.setShowForegroundOverlay(value)
    }
}
