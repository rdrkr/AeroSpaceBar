// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine

/// Use case for retrieving theme preset.
///
/// This use case encapsulates the business logic for accessing the
/// theme preset setting through the data layer.
/// It follows the clean architecture pattern by isolating this
/// specific business operation.
@MainActor
public final class GetThemePresetColorPropertiesUseCase {
    /// The configuration gateway for accessing theme preset data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified configuration gateway.
    /// - Parameter configurationGateway: The gateway for configuration operations
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to get the theme preset.
    /// - Returns: A publisher that emits the current theme preset
    public func execute() -> AnyPublisher<ThemePresetColorProperties, Never> {
        configurationGateway.themePresetColorPropertiesPublisher
    }
}
