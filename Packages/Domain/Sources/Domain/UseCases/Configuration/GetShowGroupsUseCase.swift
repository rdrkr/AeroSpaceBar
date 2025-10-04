// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation

/// Use case for retrieving the show-groups setting.
///
/// Exposes a publisher of Bool reflecting the current configuration state
/// for whether groups should be displayed in the menu bar interface.
@MainActor
public final class GetShowGroupsUseCase {
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the required gateway dependency.
    /// - Parameter configurationGateway: The gateway for configuration operations
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to get the show-groups setting as a publisher.
    /// - Returns: A publisher that emits Bool values indicating whether groups should be shown
    public func execute() -> AnyPublisher<Bool, Never> {
        configurationGateway.showGroupsPublisher
    }
}
