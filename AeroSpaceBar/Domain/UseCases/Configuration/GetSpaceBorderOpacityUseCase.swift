// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation

/// Use case for retrieving the space border opacity setting.
///
/// This use case encapsulates the business logic for getting the current space border opacity setting.
/// It belongs to the domain layer and coordinates between the presentation and data layers.
/// Following reactive patterns similar to Kotlin Flow/StateFlow.
@MainActor
final class GetSpaceBorderOpacityUseCase {
    /// The configuration gateway for data access.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified gateway.
    /// - Parameter configurationGateway: The gateway for configuration data access
    init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to get the space border opacity setting as a publisher.
    /// - Returns: A publisher that emits space border opacity values
    func execute() -> AnyPublisher<Double, Never> {
        configurationGateway.spaceBorderOpacityPublisher
    }
}
