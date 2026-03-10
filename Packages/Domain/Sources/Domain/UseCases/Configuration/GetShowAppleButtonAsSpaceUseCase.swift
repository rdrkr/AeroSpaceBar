// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation

/// Use case for retrieving the show-apple-button-as-space setting.
///
/// Exposes a publisher of Bool reflecting the current configuration state.
@MainActor
public final class GetShowAppleButtonAsSpaceUseCase {
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the required gateway.
    /// - Parameter configurationGateway: The gateway for accessing configuration data
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to get the show-apple-button-as-space setting as a publisher.
    /// - Returns: A publisher that emits the current value of the setting
    public func execute() -> AnyPublisher<Bool, Never> {
        configurationGateway.showAppleButtonAsSpacePublisher
    }
}
