// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Use case for manually checking for software updates.
@MainActor
public final class CheckForUpdatesUseCase {
    private let softwareUpdateGateway: SoftwareUpdateGateway

    public init(softwareUpdateGateway: SoftwareUpdateGateway) {
        self.softwareUpdateGateway = softwareUpdateGateway
    }

    /// Executes the use case to manually check for available updates.
    public func execute() async {
        await softwareUpdateGateway.checkForUpdates()
    }
}
