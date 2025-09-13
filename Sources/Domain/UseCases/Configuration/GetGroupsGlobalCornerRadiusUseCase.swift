// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import SwiftUI

/// Use case for getting groups global corner radius setting.
///
/// This use case encapsulates the business logic for retrieving the
/// groups global corner radius configuration from the data layer.
/// It follows the clean architecture pattern by isolating this
/// specific business operation.

@MainActor
public final class GetGroupsGlobalCornerRadiusUseCase {
    /// The configuration gateway for accessing groups global corner radius data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified configuration gateway.
    /// - Parameter configurationGateway: The gateway for configuration operations

    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to get the groups global corner radius setting.
    /// - Returns: A publisher that emits the current groups global corner radius value

    public func execute() -> AnyPublisher<Double, Never> {
        configurationGateway.groupsGlobalCornerRadiusPublisher
    }
}
