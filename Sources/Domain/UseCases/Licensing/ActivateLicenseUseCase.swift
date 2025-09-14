// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Use case for activating a license key.
public final class ActivateLicenseUseCase {
    private let licensingGateway: LicensingGateway

    /// Initializes the use case with the required gateway.
    /// - Parameter licensingGateway: The licensing gateway to use
    public init(licensingGateway: LicensingGateway) {
        self.licensingGateway = licensingGateway
    }

    /// Executes the use case to activate a license.
    /// - Parameter licenseKey: The license key to activate
    /// - Returns: The license information if successful
    public func execute(licenseKey: String) async throws -> LicenseInfo {
        try await licensingGateway.activateLicense(licenseKey)
    }
}
