// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation

/// Use case for retrieving the enableTrialRequest feature flag value.
///
/// This use case provides access to the current enableTrialRequest feature flag setting,
/// allowing other parts of the application to react to trial request feature flag changes.
@MainActor
public final class GetEnableTrialRequestUseCase {
    private let gateway: LicenseGateway

    /// Initializes the use case with a license gateway.
    /// - Parameter gateway: The gateway for accessing license feature flags
    public init(gateway: LicenseGateway) {
        self.gateway = gateway
    }

    /// Executes the use case to get the enableTrialRequest feature flag as a publisher.
    /// - Returns: A publisher that emits the current enableTrialRequest value
    public func execute() -> AnyPublisher<Bool, Never> {
        gateway.enableTrialRequestPublisher
    }
}
