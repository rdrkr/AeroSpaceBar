// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation

/// Use case for retrieving license information.
///
/// This use case provides reactive access to the current license information
/// including status, user profile data, and license key.
@MainActor
public final class GetLicenseInfoUseCase {
    /// The license gateway for license operations.
    private let licenseGateway: LicenseGateway

    /// Initializes the use case with the required gateway.
    /// - Parameter licenseGateway: The gateway for license operations
    public init(licenseGateway: LicenseGateway) {
        self.licenseGateway = licenseGateway
    }

    /// Gets the license information publisher.
    /// - Returns: A publisher that emits license information changes
    public func execute() -> AnyPublisher<LicenseInfo, Never> {
        licenseGateway.licenseInfoPublisher
    }
}
