// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Use case for setting the animation duration configuration.
///
/// This use case encapsulates the business logic for setting the animation duration
/// in the configuration gateway. It belongs to the domain layer and follows
/// clean architecture principles.
@MainActor
final class SetAnimationDurationUseCase {
    /// The configuration gateway for accessing configuration data.
    private let configurationGateway: ConfigurationGateway

    /// Initializes the use case with the configuration gateway.
    /// - Parameter configurationGateway: The gateway for accessing configuration data
    init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to set the animation duration.
    /// - Parameter value: The animation duration in seconds
    func execute(_ value: Double) async {
        await configurationGateway.setAnimationDuration(value)
    }
}
