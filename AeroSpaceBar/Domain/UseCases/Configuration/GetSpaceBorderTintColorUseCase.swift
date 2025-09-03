// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import SwiftUI

/// Use case for retrieving space border tint color configuration.
///
/// This use case encapsulates the business logic for getting the
/// space border tint color setting through the data layer.
/// It follows the clean architecture pattern by isolating this
/// specific business operation.
@MainActor
struct GetSpaceBorderTintColorUseCase {
    /// The configuration gateway for accessing space border tint color data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified configuration gateway.
    /// - Parameter configurationGateway: The gateway for configuration operations
    init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to get the space border tint color.
    /// - Returns: A publisher that emits space border tint color values
    func execute() -> AnyPublisher<Color, Never> {
        configurationGateway.spaceBorderTintColorPublisher
    }
}
