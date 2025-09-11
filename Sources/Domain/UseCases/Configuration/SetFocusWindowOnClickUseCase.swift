// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Use case for setting the focus window on click configuration.
///
/// This use case handles the business logic for updating the focus window on click setting,
/// following the domain-driven design pattern.
@MainActor
public final class SetFocusWindowOnClickUseCase {
    /// The spaces gateway for data access.
    private let configurationGateway: ConfigurationGateway

    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to set the focus window on click setting.
    ///
    /// - Parameter enabled: The new focus window on click setting.
    public func execute(enabled: Bool) async {
        await configurationGateway.setFocusWindowOnClick(enabled)
    }
}
