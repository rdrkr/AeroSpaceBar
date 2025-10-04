// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation

/// Use case for getting the configuration file path.
///
/// This use case provides access to the configuration file path
/// through a reactive publisher, following the domain-driven design pattern.
@MainActor
public final class GetConfigFilePathUseCase {
    /// The configuration gateway for accessing configuration data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the configuration gateway.
    /// - Parameter configurationGateway: The gateway for accessing configuration data
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to get the configuration file path.
    ///
    /// - Returns: A publisher that emits the configuration file path.
    public func execute() -> AnyPublisher<String, Never> {
        configurationGateway.configFilePathPublisher
    }
}
