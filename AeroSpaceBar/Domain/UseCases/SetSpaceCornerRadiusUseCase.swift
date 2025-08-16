// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation
import SwiftUI

/// Use case for setting the space corner radius configuration.
///
/// This use case encapsulates the business logic for setting the space corner radius
/// in the configuration gateway. It belongs to the domain layer and follows
/// clean architecture principles.
@MainActor
final class SetSpaceCornerRadiusUseCase {
    /// The configuration gateway for accessing configuration data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the configuration gateway.
    /// - Parameter configurationGateway: The gateway for accessing configuration data
    init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to set the space corner radius.
    /// - Parameter value: The space corner radius in points
    func execute(_ value: CGFloat) async {
        await configurationGateway.setSpaceCornerRadius(value)
    }
}
