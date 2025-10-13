// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Use case for resetting all license feature flags to their default values.
///
/// This use case handles resetting all license-related feature flags back to their
/// default values, clearing any user customizations and stored preferences.
@MainActor
public final class ResetLicenseFeatureFlagsUseCase {
    private let gateway: LicenseGateway

    /// Initializes the use case with a license feature flags gateway.
    /// - Parameter gateway: The gateway for accessing license feature flags
    public init(gateway: LicenseGateway) {
        self.gateway = gateway
    }

    /// Executes the use case to reset all license feature flags to their default values.
    public func execute() async {
        await gateway.resetLicenseFeatureFlags()
    }
}
