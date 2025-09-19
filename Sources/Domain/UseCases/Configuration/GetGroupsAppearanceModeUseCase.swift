// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation

/// Use case for retrieving the groups appearance mode configuration.
@MainActor
public final class GetGroupsAppearanceModeUseCase {
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the required gateway.
    /// - Parameter configurationGateway: Gateway for configuration access
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to get the groups appearance mode.
    /// - Returns: A publisher that emits the current groups appearance mode
    public func execute() -> AnyPublisher<GroupsAppearanceMode, Never> {
        configurationGateway.groupsAppearanceModePublisher
    }
}
