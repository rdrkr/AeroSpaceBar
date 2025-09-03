// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// Use case for setting space foreground color configuration.
///
/// This use case encapsulates the business logic for updating the
/// space foreground color setting through the data layer.
/// It follows the clean architecture pattern by isolating this
/// specific business operation.
@MainActor
struct SetSpaceForegroundColorUseCase {
    /// The configuration gateway for accessing space foreground color data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified configuration gateway.
    /// - Parameter configurationGateway: The gateway for configuration operations
    init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to set the space foreground color.
    /// - Parameter spaceForegroundColor: The new space foreground color value to set
    func execute(spaceForegroundColor: Color) async {
        await configurationGateway.setSpaceForegroundColor(spaceForegroundColor)
    }
}
