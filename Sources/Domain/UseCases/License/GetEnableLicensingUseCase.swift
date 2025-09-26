// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation

/// Use case for retrieving the enableLicensing feature flag value.
///
/// This use case provides access to the current enableLicensing feature flag setting,
/// allowing other parts of the application to react to licensing feature flag changes.
@MainActor
public final class GetEnableLicensingUseCase {
    private let gateway: LicenseGateway

    /// Initializes the use case with a license feature flags gateway.
    /// - Parameter gateway: The gateway for accessing license feature flags
    public init(gateway: LicenseGateway) {
        self.gateway = gateway
    }

    /// Executes the use case to get the enableLicensing feature flag as a publisher.
    /// - Returns: A publisher that emits the current enableLicensing value
    public func execute() -> AnyPublisher<Bool, Never> {
        gateway.enableLicensingPublisher
    }
}
