// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Use case for setting the automatic check for updates enabled configuration.
@MainActor
public final class SetAutomaticCheckForUpdatesEnabledUseCase {
    private let softwareUpdateGateway: SoftwareUpdateGateway

    public init(softwareUpdateGateway: SoftwareUpdateGateway) {
        self.softwareUpdateGateway = softwareUpdateGateway
    }

    /// Executes the use case to set whether automatic checking for updates is enabled.
    /// - Parameter enabled: The desired state for automatic update checks.
    public func execute(enabled: Bool) async {
        await softwareUpdateGateway.setAutomaticCheckForUpdatesEnabled(enabled)
    }
}
