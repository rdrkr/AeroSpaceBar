// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// Use case for setting space border tint color configuration.
///
/// This use case encapsulates the business logic for updating the
/// space border tint color setting through the data layer.
/// It follows the clean architecture pattern by isolating this
/// specific business operation.
@MainActor
struct SetSpaceBorderTintColorUseCase {
    /// The configuration gateway for accessing space border tint color data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified configuration gateway.
    /// - Parameter configurationGateway: The gateway for configuration operations
    init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to set the space border tint color.
    /// - Parameter spaceBorderTintColor: The new space border tint color value to set
    func execute(spaceBorderTintColor: Color) async {
        await configurationGateway.setSpaceBorderTintColor(spaceBorderTintColor)
    }
}
