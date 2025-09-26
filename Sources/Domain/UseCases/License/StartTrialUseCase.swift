// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Use case for starting the trial period.
@MainActor
public final class StartTrialUseCase {
    private let licenseGateway: LicenseGateway

    /// Initializes the use case with the required gateway.
    /// - Parameter licenseGateway: The license gateway to use
    public init(licenseGateway: LicenseGateway) {
        self.licenseGateway = licenseGateway
    }

    /// Executes the use case to start the trial period.
    public func execute() {
        licenseGateway.startTrial()
    }
}
