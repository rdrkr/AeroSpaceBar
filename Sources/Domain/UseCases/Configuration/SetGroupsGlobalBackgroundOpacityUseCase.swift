// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// Use case for setting groups global background opacity configuration.
///
/// This use case encapsulates the business logic for updating the
/// groups global background opacity setting through the data layer.
/// It follows the clean architecture pattern by isolating this
/// specific business operation.
@MainActor
public final class SetGroupsGlobalBackgroundOpacityUseCase {
    /// The configuration gateway for accessing groups global background opacity data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified configuration gateway.
    /// - Parameter configurationGateway: The gateway for configuration operations
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to set the groups global background opacity.
    /// - Parameter value: The new groups global background opacity value to set
    public func execute(_ value: Double) async {
        await configurationGateway.setGroupsGlobalBackgroundOpacity(value)
    }
}
