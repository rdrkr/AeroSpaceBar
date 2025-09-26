// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Use case for deactivating the current license.
@MainActor
public final class DeactivateLicenseUseCase {
    private let licenseGateway: LicenseGateway

    /// Initializes the use case with the required gateway.
    /// - Parameter licenseGateway: The license gateway to use
    public init(licenseGateway: LicenseGateway) {
        self.licenseGateway = licenseGateway
    }

    /// Executes the use case to deactivate the current license.
    public func execute() async {
        await licenseGateway.deactivateLicense()
    }
}
