// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation

/// Use case for retrieving the group configuration setting.
///
/// Exposes a publisher of GroupConfiguration reflecting the current
/// menu bar application grouping configuration.
@MainActor
final class GetGroupsConfigurationUseCase {
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the required gateway dependency.
    /// - Parameter configurationGateway: The gateway for configuration operations
    init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to get the group configuration as a publisher.
    /// - Returns: A publisher that emits GroupConfiguration values representing the current grouping setup
    func execute() -> AnyPublisher<[GroupConfiguration], Never> {
        configurationGateway.groupsConfigurationPublisher
    }
}
