// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine

/// Use case for setting theme preset.
///
/// This use case encapsulates the business logic for updating the
/// theme preset setting through the data layer.
/// It follows the clean architecture pattern by isolating this
/// specific business operation.
@MainActor
public final class SetThemePresetColorPropertiesUseCase {
    /// The configuration gateway for persisting theme preset data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified configuration gateway.
    /// - Parameter configurationGateway: The gateway for configuration operations
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to set the theme preset.
    /// - Parameter value: The new theme preset value
    public func execute(value: ThemePresetColorProperties) async {
        await configurationGateway.setThemePresetColorProperties(value)
    }
}
