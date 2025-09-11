// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Use case for setting the space background opacity configuration.
///
/// This use case handles the business logic for updating the space background opacity setting,
/// following the domain-driven design pattern.
@MainActor
public final class SetSpaceBackgroundOpacityUseCase {
    /// The configuration gateway for accessing configuration data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the configuration gateway.
    /// - Parameter configurationGateway: The gateway for accessing configuration data
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to set the space background opacity setting.
    ///
    /// - Parameter spaceBackgroundOpacity: The new space background opacity value (0.0 to 1.0).
    public func execute(spaceBackgroundOpacity: Double) async {
        await configurationGateway.setSpaceBackgroundOpacity(spaceBackgroundOpacity)
    }
}
