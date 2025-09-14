// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Use case for starting the trial period.
@MainActor
public final class StartTrialUseCase {
    private let licensingGateway: LicensingGateway

    /// Initializes the use case with the required gateway.
    /// - Parameter licensingGateway: The licensing gateway to use
    public init(licensingGateway: LicensingGateway) {
        self.licensingGateway = licensingGateway
    }

    /// Executes the use case to start the trial period.
    public func execute() {
        licensingGateway.startTrial()
    }
}
