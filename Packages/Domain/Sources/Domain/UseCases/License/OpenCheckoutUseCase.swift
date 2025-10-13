// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import AppKit
import Foundation

/// Use case for getting the license checkout URL.
@MainActor
public final class OpenCheckoutUseCase {
    private let licenseGateway: LicenseGateway

    /// Initializes the use case with the required gateway.
    /// - Parameter licenseGateway: The license gateway to use
    public init(licenseGateway: LicenseGateway) {
        self.licenseGateway = licenseGateway
    }

    /// Gets the checkout URL synchronously.
    ///
    /// Returns a static checkout URL from the LemonSqueezy Dashboard.
    /// No API call is needed - the URL directly opens the checkout page.
    ///
    /// - Returns: The license checkout URL
    public func getCheckoutURL() -> URL {
        licenseGateway.getCheckoutURL()
    }

    /// Gets the trial checkout URL synchronously.
    ///
    /// Returns a static checkout URL from the LemonSqueezy Dashboard.
    /// No API call is needed - the URL directly opens the trial checkout page.
    ///
    /// - Returns: The trial checkout URL
    public func getTrialCheckoutURL() -> URL {
        licenseGateway.getTrialCheckoutURL()
    }

    /// Handles successful checkout completion.
    /// - Parameter licenseKey: The license key from successful checkout
    public func handleSuccess(licenseKey: String) async {
        await licenseGateway.handleCheckoutSuccess(licenseKey: licenseKey)
    }
}
