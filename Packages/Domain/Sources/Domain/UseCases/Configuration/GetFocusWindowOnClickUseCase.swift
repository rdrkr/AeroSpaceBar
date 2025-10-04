// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation

/// Use case for retrieving the focus window on click setting.
///
/// This use case encapsulates the business logic for getting the current focus window on click setting.
/// It belongs to the domain layer and coordinates between the presentation and data layers.
@MainActor
public final class GetFocusWindowOnClickUseCase {
    /// The configuration gateway for data access.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified gateway.
    /// - Parameter configurationGateway: The gateway for configuration data access
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to get the focus window on click setting as a publisher.
    /// - Returns: A publisher that emits focus window on click values
    public func execute() -> AnyPublisher<Bool, Never> {
        configurationGateway.focusWindowOnClickPublisher
    }
}
