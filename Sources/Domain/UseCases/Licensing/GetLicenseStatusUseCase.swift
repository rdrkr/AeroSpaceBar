// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation

/// Use case for getting the current license status.
@MainActor
public final class GetLicenseStatusUseCase {
    private let licensingGateway: LicensingGateway

    /// Initializes the use case with the required gateway.
    /// - Parameter licensingGateway: The licensing gateway to use
    public init(licensingGateway: LicensingGateway) {
        self.licensingGateway = licensingGateway
    }

    /// Executes the use case to get license status updates.
    /// - Returns: Publisher that emits license status changes
    public func execute() -> AnyPublisher<LicenseStatus, Never> {
        licensingGateway.licenseStatusPublisher
    }

    /// Gets the current license status synchronously.
    /// - Returns: The current license status
    public func getCurrentStatus() -> LicenseStatus {
        licensingGateway.currentLicenseStatus
    }
}
