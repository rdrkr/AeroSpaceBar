// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation

/// Use case for retrieving the Apple Button geometric properties.
///
/// Exposes a publisher of GeometricProperties reflecting the current configuration state.
@MainActor
public final class GetAppleButtonGeometricPropertiesUseCase {
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the required gateway.
    /// - Parameter configurationGateway: The gateway for accessing configuration data
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to get the Apple Button geometric properties as a publisher.
    /// - Returns: A publisher that emits the current Apple Button geometric properties
    public func execute() -> AnyPublisher<GeometricProperties, Never> {
        configurationGateway.appleButtonGeometricPropertiesPublisher
    }
}
