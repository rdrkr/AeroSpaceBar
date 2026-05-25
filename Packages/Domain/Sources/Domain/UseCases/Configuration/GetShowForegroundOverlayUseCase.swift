// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation

/// Use case for retrieving the show-foreground-overlay setting.
///
/// Exposes a publisher of Bool reflecting the current configuration state
/// for whether the foreground color overlay should be displayed on groups
/// and the Apple Button.
@MainActor
public final class GetShowForegroundOverlayUseCase {
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the required gateway dependency.
    /// - Parameter configurationGateway: The gateway for configuration operations
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to get the show-foreground-overlay setting as a publisher.
    /// - Returns: A publisher that emits Bool values indicating whether the foreground overlay should be shown
    public func execute() -> AnyPublisher<Bool, Never> {
        configurationGateway.showForegroundOverlayPublisher
    }
}
