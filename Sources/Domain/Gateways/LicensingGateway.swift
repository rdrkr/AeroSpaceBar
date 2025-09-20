// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation

/// Gateway for managing application licensing through Paddle.
@MainActor
public protocol LicensingGateway {
    /// Publisher that emits the current license status.
    var licenseStatusPublisher: AnyPublisher<LicenseStatus, Never> { get }

    /// The current license status.
    var currentLicenseStatus: LicenseStatus { get }

    /// Validates the current license with Paddle servers.
    /// - Returns: The updated license status
    func validateLicense() async -> LicenseStatus

    /// Activates a license with the provided license key.
    /// - Parameter licenseKey: The license key to activate
    /// - Returns: The license information if successful
    func activateLicense(_ licenseKey: String) async throws -> LicenseInfo

    func deactivateLicense() async

    func createCheckoutURL() -> URL

    /// Handles successful checkout completion
    /// - Parameter licenseKey: The license key from the successful checkout
    func handleCheckoutSuccess(licenseKey: String) async

    func getTrialDaysRemaining() -> Int?

    /// Starts the trial period.
    func startTrial()

    /// Checks if the application should show licensing prompts.
    /// - Returns: True if licensing UI should be shown
    func shouldShowLicensingPrompt() -> Bool
}
