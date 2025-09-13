// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// Use case for setting the space border width setting.
@MainActor
public final class SetSpaceBorderWidthUseCase {
    /// The configuration gateway for accessing border width data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified configuration gateway.
    /// - Parameter configurationGateway: The gateway for configuration data access
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to set the space border width setting.
    /// - Parameter spaceBorderWidth: The new border width value to set
    public func execute(spaceBorderWidth: Double) async {
        await configurationGateway.setSpaceBorderWidth(spaceBorderWidth)
    }
}
