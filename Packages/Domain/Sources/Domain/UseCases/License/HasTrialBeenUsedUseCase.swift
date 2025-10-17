// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Use case for checking if trial has already been used on this device.
@MainActor
public final class HasTrialBeenUsedUseCase {
    private let licenseGateway: LicenseGateway

    /// Initializes the use case with the required gateway.
    /// - Parameter licenseGateway: The license gateway to use
    public init(licenseGateway: LicenseGateway) {
        self.licenseGateway = licenseGateway
    }

    /// Checks if a trial has already been used on this device.
    /// - Returns: True if trial was previously activated, false otherwise
    public func execute() -> Bool {
        licenseGateway.hasTrialBeenUsed()
    }
}
