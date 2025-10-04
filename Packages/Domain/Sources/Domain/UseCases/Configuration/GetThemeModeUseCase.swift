// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine

/// Use case for retrieving theme mode.
///
/// This use case encapsulates the business logic for accessing the
/// theme mode setting through the data layer.
/// It follows the clean architecture pattern by isolating this
/// specific business operation.
@MainActor
public final class GetThemeModeUseCase {
    /// The configuration gateway for accessing theme mode data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified configuration gateway.
    /// - Parameter configurationGateway: The gateway for configuration operations
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to get the theme mode.
    /// - Returns: A publisher that emits the current theme mode
    public func execute() -> AnyPublisher<ThemeMode, Never> {
        configurationGateway.themeModePublisher
    }
}
