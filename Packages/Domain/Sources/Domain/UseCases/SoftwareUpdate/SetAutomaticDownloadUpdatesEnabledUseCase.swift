// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Use case for setting the automatic download updates enabled configuration.
@MainActor
public final class SetAutomaticDownloadUpdatesEnabledUseCase {
    private let softwareUpdateGateway: SoftwareUpdateGateway

    public init(softwareUpdateGateway: SoftwareUpdateGateway) {
        self.softwareUpdateGateway = softwareUpdateGateway
    }

    /// Executes the use case to set whether automatic downloading of updates is enabled.
    /// - Parameter enabled: The desired state for automatic update downloads.
    public func execute(enabled: Bool) async {
        await softwareUpdateGateway.setAutomaticDownloadUpdatesEnabled(enabled)
    }
}
