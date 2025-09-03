// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// Use case for setting space background tint color configuration.
///
/// This use case encapsulates the business logic for updating the
/// space background tint color setting through the data layer.
/// It follows the clean architecture pattern by isolating this
/// specific business operation.
@MainActor
struct SetSpaceBackgroundTintColorUseCase {
    /// The configuration gateway for accessing space background tint color data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified configuration gateway.
    /// - Parameter configurationGateway: The gateway for configuration operations
    init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to set the space background tint color.
    /// - Parameter spaceBackgroundTintColor: The new space background tint color value to set
    func execute(spaceBackgroundTintColor: Color) async {
        await configurationGateway.setSpaceBackgroundTintColor(spaceBackgroundTintColor)
    }
}
