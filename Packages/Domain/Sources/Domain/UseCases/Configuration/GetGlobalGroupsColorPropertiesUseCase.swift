// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine

/// Use case for retrieving global groups color properties.
///
/// This use case encapsulates the business logic for accessing the
/// global groups color properties setting through the data layer.
/// It follows the clean architecture pattern by isolating this
/// specific business operation.
@MainActor
public final class GetGlobalGroupsColorPropertiesUseCase {
    /// The configuration gateway for accessing global groups color properties data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified configuration gateway.
    /// - Parameter configurationGateway: The gateway for configuration operations
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to get the global groups color properties.
    /// - Returns: A publisher that emits the current global groups color properties
    public func execute() -> AnyPublisher<ColorProperties, Never> {
        configurationGateway.globalGroupsColorPropertiesPublisher
    }
}
