// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine

/// Use case for retrieving global groups effect properties.
///
/// This use case encapsulates the business logic for accessing the
/// global groups effect properties setting through the data layer.
/// It follows the clean architecture pattern by isolating this
/// specific business operation.
@MainActor
public final class GetGlobalGroupsEffectPropertiesUseCase {
    /// The configuration gateway for accessing global groups effect properties data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified configuration gateway.
    /// - Parameter configurationGateway: The gateway for configuration operations
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to get the global groups effect properties.
    /// - Returns: A publisher that emits the current global groups effect properties
    public func execute() -> AnyPublisher<EffectProperties, Never> {
        configurationGateway.globalGroupsEffectPropertiesPublisher
    }
}
