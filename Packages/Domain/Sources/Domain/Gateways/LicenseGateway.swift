// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Foundation

/// Gateway for managing application license.
@MainActor
public protocol LicenseGateway {
    /// Publisher that emits the current license information.
    var licenseInfoPublisher: AnyPublisher<LicenseInfo, Never> { get }

    /// Publisher that emits changes to the enableLicensing feature flag.
    var enableLicensingPublisher: AnyPublisher<Bool, Never> { get }

    /// Publisher that emits changes to the enableTrialRequest feature flag.
    var enableTrialRequestPublisher: AnyPublisher<Bool, Never> { get }

    #if DEBUG
        /// Publisher that emits changes to the mockActiveLicense feature flag (DEBUG builds only).
        var mockActiveLicensePublisher: AnyPublisher<Bool, Never> { get }

        /// Publisher that emits changes to the checkout environment (DEBUG builds only).
        var checkoutEnvironmentPublisher: AnyPublisher<CheckoutEnvironment, Never> { get }
    #endif

    /// Activates a license with the provided license key.
    /// - Parameter licenseKey: The license key to activate
    /// - Returns: The license information if successful
    func activateLicense(_ licenseKey: String) async throws -> LicenseInfo

    /// Deactivates the current license.
    func deactivateLicense() async throws

    /// Gets the checkout URL for purchasing a license.
    ///
    /// Returns a static checkout URL from the LemonSqueezy Dashboard.
    /// No API call is needed - the URL directly opens the checkout page.
    ///
    /// - Returns: The checkout URL
    func getCheckoutURL() -> URL

    /// Gets the checkout URL for starting a trial.
    ///
    /// Returns a static checkout URL from the LemonSqueezy Dashboard.
    /// No API call is needed - the URL directly opens the trial checkout page.
    ///
    /// - Returns: The trial checkout URL
    func getTrialCheckoutURL() -> URL

    /// Handles successful checkout completion
    /// - Parameter licenseKey: The license key from the successful checkout
    func handleCheckoutSuccess(licenseKey: String) async

    /// Sets the enableLicensing feature flag value.
    /// - Parameter enabled: Whether licensing features should be enabled
    func setEnableLicensing(_ enabled: Bool)

    /// Sets the enableTrialRequest feature flag value.
    /// - Parameter enabled: Whether trial request functionality should be enabled
    func setEnableTrialRequest(_ enabled: Bool)

    #if DEBUG
        /// Sets the mockActiveLicense feature flag value (DEBUG builds only).
        /// - Parameter enabled: Whether an active license should be mocked
        func setMockActiveLicense(_ enabled: Bool)

        /// Sets the checkout environment (DEBUG builds only).
        /// - Parameter environment: The checkout environment to use
        func setCheckoutEnvironment(_ environment: CheckoutEnvironment)
    #endif

    /// Resets all license feature flags to their default values.
    func resetLicenseFeatureFlags() async

    /// Sets the user's display name.
    /// - Parameter userName: The user's display name
    func setUserName(_ userName: String) async

    /// Sets the user's profile image.
    /// - Parameter profileImageData: The profile image data
    func setProfileImageData(_ profileImageData: Data?) async

    /// Checks if a trial has already been used on this device.
    /// - Returns: True if trial was previously activated, false otherwise
    func hasTrialBeenUsed() -> Bool
}
