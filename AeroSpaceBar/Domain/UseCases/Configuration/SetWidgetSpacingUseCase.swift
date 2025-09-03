// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation
import SwiftUI

/// Use case for setting the widget spacing configuration.
///
/// This use case encapsulates the business logic for setting the widget spacing
/// in the configuration gateway. It belongs to the domain layer and follows
/// clean architecture principles.
@MainActor
final class SetWidgetSpacingUseCase {
    /// The configuration gateway for accessing configuration data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the configuration gateway.
    /// - Parameter configurationGateway: The gateway for accessing configuration data
    init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to set the widget spacing.
    /// - Parameter value: The widget spacing in points
    func execute(_ value: CGFloat) async {
        await configurationGateway.setWidgetSpacing(value)
    }
}
