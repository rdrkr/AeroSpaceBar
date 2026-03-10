// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Foundation

/// Use case for setting the Apple Button geometric properties.
@MainActor
public final class SetAppleButtonGeometricPropertiesUseCase {
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the required gateway.
    /// - Parameter configurationGateway: The gateway for accessing configuration data
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to set the Apple Button geometric properties.
    /// - Parameter value: The new geometric properties for the Apple Button
    public func execute(value: GeometricProperties) async {
        await configurationGateway.setAppleButtonGeometricProperties(value)
    }
}
