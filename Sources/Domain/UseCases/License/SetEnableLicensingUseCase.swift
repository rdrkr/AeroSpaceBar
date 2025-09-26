// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Use case for setting the enableLicensing feature flag value.
///
/// This use case handles updating the enableLicensing feature flag setting,
/// ensuring the change is properly persisted and propagated through the system.
@MainActor
public final class SetEnableLicensingUseCase {
    private let gateway: LicenseGateway

    /// Initializes the use case with a license feature flags gateway.
    /// - Parameter gateway: The gateway for accessing license feature flags
    public init(gateway: LicenseGateway) {
        self.gateway = gateway
    }

    /// Executes the use case to set the enableLicensing feature flag value.
    /// - Parameter enabled: Whether licensing features should be enabled
    public func execute(enabled: Bool) {
        gateway.setEnableLicensing(enabled)
    }
}
