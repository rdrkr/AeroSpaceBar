// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Foundation

/// Use case for setting the Apple Button effect properties.
@MainActor
public final class SetAppleButtonEffectPropertiesUseCase {
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the required gateway.
    /// - Parameter configurationGateway: The gateway for accessing configuration data
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to set the Apple Button effect properties.
    /// - Parameter value: The new effect properties for the Apple Button
    public func execute(value: EffectProperties) async {
        await configurationGateway.setAppleButtonEffectProperties(value)
    }
}
