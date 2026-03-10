// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation

/// Use case for retrieving the Apple Button effect properties.
///
/// Exposes a publisher of EffectProperties reflecting the current configuration state.
@MainActor
public final class GetAppleButtonEffectPropertiesUseCase {
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the required gateway.
    /// - Parameter configurationGateway: The gateway for accessing configuration data
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to get the Apple Button effect properties as a publisher.
    /// - Returns: A publisher that emits the current Apple Button effect properties
    public func execute() -> AnyPublisher<EffectProperties, Never> {
        configurationGateway.appleButtonEffectPropertiesPublisher
    }
}
