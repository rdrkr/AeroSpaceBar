// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import SwiftUI

/// Use case for getting groups global background opacity setting.
///
/// This use case encapsulates the business logic for retrieving the
/// groups global background opacity configuration from the data layer.
/// It follows the clean architecture pattern by isolating this
/// specific business operation.

@MainActor
public final class GetGroupsGlobalBackgroundOpacityUseCase {
    /// The configuration gateway for accessing groups global background opacity data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified configuration gateway.
    /// - Parameter configurationGateway: The gateway for configuration operations

    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to get the groups global background opacity setting.
    /// - Returns: A publisher that emits the current groups global background opacity value

    public func execute() -> AnyPublisher<Double, Never> {
        configurationGateway.groupsGlobalBackgroundOpacityPublisher
    }
}
