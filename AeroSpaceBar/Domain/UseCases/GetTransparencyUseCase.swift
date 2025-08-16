// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation

/// Use case for retrieving the transparency setting.
///
/// This use case encapsulates the business logic for getting the current transparency setting.
/// It belongs to the domain layer and coordinates between the presentation and data layers.
/// Following reactive patterns similar to Kotlin Flow/StateFlow.
@MainActor
final class GetTransparencyUseCase {
    /// The configuration gateway for data access.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified gateway.
    /// - Parameter configurationGateway: The gateway for configuration data access
    init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to get the transparency setting as a publisher.
    /// - Returns: A publisher that emits transparency values
    func execute() -> AnyPublisher<Double, Never> {
        configurationGateway.transparencyPublisher
    }
}
