// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Use case for activating a license key.
@MainActor
public final class ActivateLicenseUseCase {
    private let licenseGateway: LicenseGateway

    /// Initializes the use case with the required gateway.
    /// - Parameter licenseGateway: The license gateway to use
    public init(licenseGateway: LicenseGateway) {
        self.licenseGateway = licenseGateway
    }

    /// Executes the use case to activate a license.
    /// - Parameter licenseKey: The license key to activate
    /// - Returns: The license information if successful
    public func execute(licenseKey: String) async throws -> LicenseInfo {
        try await licenseGateway.activateLicense(licenseKey)
    }
}
