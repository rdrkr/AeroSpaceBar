// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation

/// Use case for getting the current checkout environment.
@MainActor
public final class GetCheckoutEnvironmentUseCase {
    // MARK: - Properties

    private let licenseGateway: LicenseGateway

    // MARK: - Initialization

    /// Initializes the use case with required dependencies.
    /// - Parameter licenseGateway: The license gateway for accessing checkout environment
    public init(licenseGateway: LicenseGateway) {
        self.licenseGateway = licenseGateway
    }

    // MARK: - Public Methods

    #if DEBUG
        /// Executes the use case to get the checkout environment publisher.
        /// - Returns: A publisher that emits checkout environment changes
        public func execute() -> AnyPublisher<CheckoutEnvironment, Never> {
            licenseGateway.checkoutEnvironmentPublisher
        }
    #endif
}
