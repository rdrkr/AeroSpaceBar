// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Foundation

/// Use case for setting the show-apple-button-as-space configuration.
@MainActor
public final class SetShowAppleButtonAsSpaceUseCase {
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the required gateway.
    /// - Parameter configurationGateway: The gateway for accessing configuration data
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to set whether to show the Apple Button as a space.
    /// - Parameter value: The desired state for showing the Apple Button as a space
    public func execute(value: Bool) async {
        await configurationGateway.setShowAppleButtonAsSpace(value)
    }
}
