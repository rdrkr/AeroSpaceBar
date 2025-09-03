// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation

/// Use case for retrieving the enable performance metrics setting.
///
/// This use case encapsulates the business logic for getting the current enable performance metrics setting.
/// It belongs to the domain layer and coordinates between the presentation and data layers.
@MainActor
final class GetEnablePerformanceMetricsUseCase {
    /// The configuration gateway for data access.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified gateway.
    /// - Parameter configurationGateway: The gateway for configuration data access
    init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to get the enable performance metrics setting as a publisher.
    /// - Returns: A publisher that emits enable performance metrics values
    func execute() -> AnyPublisher<Bool, Never> {
        configurationGateway.enablePerformanceMetricsPublisher
    }
}
