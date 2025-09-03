// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation

/// Use case for retrieving the optimized performance enabled setting.
///
/// This use case encapsulates the business logic for getting the current optimized performance flag.
/// It belongs to the domain layer and coordinates between the presentation and data layers.
@MainActor
final class GetOptimizedPerformanceEnabledUseCase {
    /// The configuration gateway for data access.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified gateway.
    /// - Parameter configurationGateway: The gateway for configuration data access
    init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to get the optimized performance enabled setting as a publisher.
    /// - Returns: A publisher that emits optimized performance enabled values
    func execute() -> AnyPublisher<Bool, Never> {
        configurationGateway.isOptimizedPerformanceEnabledPublisher
    }
}
