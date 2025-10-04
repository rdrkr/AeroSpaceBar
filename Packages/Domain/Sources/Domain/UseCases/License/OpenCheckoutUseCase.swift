// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import AppKit
import Foundation

/// Use case for getting the Paddle checkout URL.
@MainActor
public final class OpenCheckoutUseCase {
    private let licenseGateway: LicenseGateway

    /// Initializes the use case with the required gateway.
    /// - Parameter licenseGateway: The license gateway to use
    public init(licenseGateway: LicenseGateway) {
        self.licenseGateway = licenseGateway
    }

    /// Executes the use case to start the checkout process.
    /// - Parameter parentWindow: The parent window (ignored for now)
    /// - Returns: The Paddle checkout URL for the presentation layer to use
    public func execute(from _: NSWindow?) -> URL {
        licenseGateway.createCheckoutURL()
    }

    /// Gets the checkout URL synchronously.
    /// - Returns: The Paddle checkout URL
    public func getCheckoutURL() -> URL {
        licenseGateway.createCheckoutURL()
    }

    /// Handles successful checkout completion.
    /// - Parameter licenseKey: The license key from successful checkout
    public func handleSuccess(licenseKey: String) async {
        await licenseGateway.handleCheckoutSuccess(licenseKey: licenseKey)
    }
}
