// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Use case for setting the space background blur radius configuration.
///
/// This use case handles the business logic for updating the space background blur radius setting,
/// following the domain-driven design pattern.
@MainActor
public final class SetSpaceBackgroundBlurRadiusUseCase {
    /// The configuration gateway for accessing configuration data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the configuration gateway.
    /// - Parameter configurationGateway: The gateway for accessing configuration data
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to set the space background blur radius setting.
    ///
    /// - Parameter spaceBackgroundBlurRadius: The new space background blur radius value in points.
    public func execute(spaceBackgroundBlurRadius: CGFloat) async {
        await configurationGateway.setSpaceBackgroundBlurRadius(spaceBackgroundBlurRadius)
    }
}
