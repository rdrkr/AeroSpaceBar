// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation

/// Gateway for managing application license through Paddle.
@MainActor
public protocol LicenseGateway {
    /// Publisher that emits the current license information.
    var licenseInfoPublisher: AnyPublisher<LicenseInfo, Never> { get }

    /// Publisher that emits changes to the enableLicensing feature flag.
    var enableLicensingPublisher: AnyPublisher<Bool, Never> { get }

    #if DEBUG
        /// Publisher that emits changes to the mockActiveLicense feature flag (DEBUG builds only).
        var mockActiveLicensePublisher: AnyPublisher<Bool, Never> { get }
    #endif

    /// Activates a license with the provided license key.
    /// - Parameter licenseKey: The license key to activate
    /// - Returns: The license information if successful
    func activateLicense(_ licenseKey: String) async throws -> LicenseInfo

    /// Deactivates the current license.
    func deactivateLicense() async

    /// Creates a checkout URL for purchasing a license.
    /// - Returns: The Paddle checkout URL
    func createCheckoutURL() -> URL

    /// Handles successful checkout completion
    /// - Parameter licenseKey: The license key from the successful checkout
    func handleCheckoutSuccess(licenseKey: String) async

    /// Starts the trial period.
    func startTrial()

    /// Sets the enableLicensing feature flag value.
    /// - Parameter enabled: Whether licensing features should be enabled
    func setEnableLicensing(_ enabled: Bool)

    #if DEBUG
        /// Sets the mockActiveLicense feature flag value (DEBUG builds only).
        /// - Parameter enabled: Whether an active license should be mocked
        func setMockActiveLicense(_ enabled: Bool)
    #endif

    /// Resets all license feature flags to their default values.
    func resetLicenseFeatureFlags()

    /// Sets the user's display name.
    /// - Parameter userName: The user's display name
    func setUserName(_ userName: String) async

    /// Sets the user's profile image.
    /// - Parameter profileImageData: The profile image data
    func setProfileImageData(_ profileImageData: Data?) async
}
