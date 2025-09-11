// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation

/// Use case for retrieving the space background opacity setting.
///
/// This use case encapsulates the business logic for getting the current space background opacity setting.
/// It belongs to the domain layer and coordinates between the presentation and data layers.
/// Following reactive patterns similar to Kotlin Flow/StateFlow.
@MainActor
public final class GetSpaceBackgroundOpacityUseCase {
    /// The configuration gateway for data access.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified gateway.
    /// - Parameter configurationGateway: The gateway for configuration data access
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to get the space background opacity setting as a publisher.
    /// - Returns: A publisher that emits space background opacity values
    public func execute() -> AnyPublisher<Double, Never> {
        configurationGateway.spaceBackgroundOpacityPublisher
    }
}
