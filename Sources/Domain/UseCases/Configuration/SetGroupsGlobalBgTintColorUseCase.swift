// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// Use case for setting groups global background tint color configuration.
///
/// This use case encapsulates the business logic for updating the
/// groups global background tint color setting through the data layer.
/// It follows the clean architecture pattern by isolating this
/// specific business operation.
@MainActor
public final class SetGroupsGlobalBgTintColorUseCase {
    /// The configuration gateway for accessing groups global background tint color data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified configuration gateway.
    /// - Parameter configurationGateway: The gateway for configuration operations
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to set the groups global background tint color.
    /// - Parameter value: The new groups global background tint color value to set
    public func execute(_ value: Color) async {
        await configurationGateway.setGroupsGlobalBackgroundTintColor(value)
    }
}
