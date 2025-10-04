// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Use case for setting whether the user has been asked for screen capture permissions.
@MainActor
public final class SetHasAskedForScreenCapturePermissionsUseCase {
    private let configurationGateway: ConfigurationGateway

    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to set whether the user has been asked for screen capture permissions.
    /// - Parameter value: The state indicating whether permissions have been requested
    public func execute(value: Bool) async {
        await configurationGateway.setHasAskedForScreenCapturePermissions(value)
    }
}
