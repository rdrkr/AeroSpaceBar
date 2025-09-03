// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import SwiftUI

/// Use case for getting space foreground color setting.
///
/// This use case encapsulates the business logic for retrieving the
/// space foreground color configuration from the data layer.
/// It follows the clean architecture pattern by isolating this
/// specific business operation.
@MainActor
struct GetSpaceForegroundColorUseCase {
    /// The configuration gateway for accessing space foreground color data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified configuration gateway.
    /// - Parameter configurationGateway: The gateway for configuration operations
    init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to get the space foreground color setting.
    /// - Returns: A publisher that emits the current space foreground color value
    func execute() -> AnyPublisher<Color, Never> {
        configurationGateway.spaceForegroundColorPublisher
    }
}
