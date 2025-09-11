// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation

/// Use case for getting AeroSpace version information.
///
/// This use case provides access to the current AeroSpace version
/// through a reactive publisher.
@MainActor
public final class GetAeroSpaceVersionUseCase {
    /// The configuration gateway for accessing configuration data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the configuration gateway.
    /// - Parameter configurationGateway: The gateway for accessing configuration data
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to get the current AeroSpace version.
    ///
    /// - Returns: A publisher that emits the current AeroSpace version string, or nil if not available.
    public func execute() -> AnyPublisher<String?, Never> {
        configurationGateway.currentAeroSpaceVersionPublisher
    }
}
