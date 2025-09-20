// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Use case for deactivating the current license.
@MainActor
public final class DeactivateLicenseUseCase {
    private let licensingGateway: LicensingGateway

    /// Initializes the use case with the required gateway.
    /// - Parameter licensingGateway: The licensing gateway to use
    public init(licensingGateway: LicensingGateway) {
        self.licensingGateway = licensingGateway
    }

    /// Executes the use case to deactivate the current license.
    public func execute() async {
        await licensingGateway.deactivateLicense()
    }
}
