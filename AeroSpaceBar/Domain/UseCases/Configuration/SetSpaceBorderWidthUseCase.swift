// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// Use case for setting the space border width setting.
@MainActor
struct SetSpaceBorderWidthUseCase {
    /// The configuration gateway for accessing border width data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified configuration gateway.
    /// - Parameter configurationGateway: The gateway for configuration data access
    init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to set the space border width setting.
    /// - Parameter spaceBorderWidth: The new border width value to set
    func execute(spaceBorderWidth: CGFloat) async {
        await configurationGateway.setSpaceBorderWidth(spaceBorderWidth)
    }
}
