// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation
import SwiftUI

/// Use case for setting the menu bar horizontal padding configuration.
///
/// This use case encapsulates the business logic for setting the menu bar horizontal padding
/// in the configuration gateway. It belongs to the domain layer and follows
/// clean architecture principles.
@MainActor
public final class SetMenuBarHorizontalPaddingUseCase {
    /// The configuration gateway for accessing configuration data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the configuration gateway.
    /// - Parameter configurationGateway: The gateway for accessing configuration data
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to set the menu bar horizontal padding.
    /// - Parameter value: The menu bar horizontal padding in points
    public func execute(value: Double) async {
        await configurationGateway.setMenuBarHorizontalPadding(value)
    }
}
