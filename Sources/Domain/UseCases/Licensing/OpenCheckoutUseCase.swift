// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import AppKit
import Foundation

/// Use case for getting the Paddle checkout URL.
@MainActor
public final class OpenCheckoutUseCase {
    private let licensingGateway: LicensingGateway

    /// Initializes the use case with the required gateway.
    /// - Parameter licensingGateway: The licensing gateway to use
    public init(licensingGateway: LicensingGateway) {
        self.licensingGateway = licensingGateway
    }

    /// Executes the use case to start the checkout process.
    /// - Parameter parentWindow: The parent window (ignored for now)
    /// - Returns: The Paddle checkout URL for the presentation layer to use
    public func execute(from _: NSWindow?) -> URL {
        licensingGateway.createCheckoutURL()
    }

    /// Gets the checkout URL synchronously.
    /// - Returns: The Paddle checkout URL
    public func getCheckoutURL() -> URL {
        licensingGateway.createCheckoutURL()
    }

    /// Handles successful checkout completion.
    /// - Parameter licenseKey: The license key from successful checkout
    public func handleSuccess(licenseKey: String) async {
        await licensingGateway.handleCheckoutSuccess(licenseKey: licenseKey)
    }
}
