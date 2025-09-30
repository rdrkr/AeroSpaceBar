// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

/// Use case for setting theme mode.
///
/// This use case encapsulates the business logic for updating the
/// theme mode setting through the data layer.
/// It follows the clean architecture pattern by isolating this
/// specific business operation.
@MainActor
public final class SetThemeModeUseCase {
    /// The configuration gateway for accessing theme mode data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the specified configuration gateway.
    /// - Parameter configurationGateway: The gateway for configuration operations
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to set the theme mode.
    /// - Parameter value: The new theme mode value to set
    public func execute(value: ThemeMode) async {
        await configurationGateway.setThemeMode(value)
    }
}
