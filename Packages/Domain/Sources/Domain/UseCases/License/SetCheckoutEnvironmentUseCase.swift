// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Use case for setting the checkout environment.
@MainActor
public final class SetCheckoutEnvironmentUseCase {
    // MARK: - Properties

    private let licenseGateway: LicenseGateway

    // MARK: - Initialization

    /// Initializes the use case with required dependencies.
    /// - Parameter licenseGateway: The license gateway for managing checkout environment
    public init(licenseGateway: LicenseGateway) {
        self.licenseGateway = licenseGateway
    }

    // MARK: - Public Methods

    #if DEBUG
        /// Executes the use case to set the checkout environment.
        /// - Parameter environment: The checkout environment to set
        public func execute(_ environment: CheckoutEnvironment) {
            licenseGateway.setCheckoutEnvironment(environment)
        }
    #endif
}
