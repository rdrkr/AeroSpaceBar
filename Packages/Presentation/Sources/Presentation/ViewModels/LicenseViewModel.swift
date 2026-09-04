// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import AppKit
import Combine
import Domain
import Foundation

/// ViewModel for managing license operations and UI state.
@MainActor
public final class LicenseViewModel: ObservableObject {
    // MARK: - Published Properties

    /// The current license information containing status, user data, and license key.
    @Published public var licenseInfo: LicenseInfo

    /// The license key input field text.
    @Published public var licenseKeyInput: String = ""

    /// Whether licensing features are enabled via feature flags.
    @Published public var enableLicense: Bool

    /// Whether trial request functionality is enabled via feature flags.
    @Published public var enableTrialRequest: Bool

    /// Whether a license activation operation is currently in progress.
    @Published public var isActivating: Bool = false

    /// Whether the checkout WebView is currently being presented.
    @Published public var showingCheckoutWebView: Bool = false

    /// Error message from the most recent license activation attempt, if any.
    @Published public var activationError: String?

    /// The checkout URL for the WebView, if available.
    @Published public var checkoutURL: URL?

    // MARK: - Computed Properties

    /// Whether the user has an active license.
    public var isLicensed: Bool {
        licenseInfo.isActive
    }

    /// The user's profile image as NSImage, converted from Data.
    public var profileImage: NSImage? {
        guard let imageData = licenseInfo.profileImageData else { return nil }

        return NSImage(data: imageData)
    }

    // MARK: - Dependencies

    /// Use case for retrieving license information.
    private let getLicenseInfoUseCase: GetLicenseInfoUseCase

    /// Use case for activating a license with a provided key.
    private let activateLicenseUseCase: ActivateLicenseUseCase

    /// Use case for opening the license checkout flow.
    private let openCheckoutUseCase: OpenCheckoutUseCase

    /// Use case for deactivating the current license.
    private let deactivateLicenseUseCase: DeactivateLicenseUseCase

    /// Use case for retrieving enableLicensing feature flag.
    private let getEnableLicensingUseCase: GetEnableLicensingUseCase

    /// Use case for retrieving enableTrialRequest feature flag.
    private let getEnableTrialRequestUseCase: GetEnableTrialRequestUseCase

    /// Use case for setting the user's display name.
    private let setUserNameUseCase: SetUserNameUseCase

    /// Use case for setting the user's profile image data.
    private let setProfileImageDataUseCase: SetProfileImageDataUseCase

    /// Use case for checking if trial has been used on this device.
    private let hasTrialBeenUsedUseCase: HasTrialBeenUsedUseCase

    /// Cancellable subscriptions for Combine publishers.
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initialization

    /// Initializes the license view model with required use cases.
    public init(
        getLicenseInfoUseCase: GetLicenseInfoUseCase,
        activateLicenseUseCase: ActivateLicenseUseCase,
        openCheckoutUseCase: OpenCheckoutUseCase,
        deactivateLicenseUseCase: DeactivateLicenseUseCase,
        getEnableLicensingUseCase: GetEnableLicensingUseCase,
        getEnableTrialRequestUseCase: GetEnableTrialRequestUseCase,
        setUserNameUseCase: SetUserNameUseCase,
        setProfileImageDataUseCase: SetProfileImageDataUseCase,
        hasTrialBeenUsedUseCase: HasTrialBeenUsedUseCase
    ) {
        self.getLicenseInfoUseCase = getLicenseInfoUseCase
        self.activateLicenseUseCase = activateLicenseUseCase
        self.openCheckoutUseCase = openCheckoutUseCase
        self.deactivateLicenseUseCase = deactivateLicenseUseCase
        self.getEnableLicensingUseCase = getEnableLicensingUseCase
        self.getEnableTrialRequestUseCase = getEnableTrialRequestUseCase
        self.setUserNameUseCase = setUserNameUseCase
        self.setProfileImageDataUseCase = setProfileImageDataUseCase
        self.hasTrialBeenUsedUseCase = hasTrialBeenUsedUseCase

        licenseInfo = getLicenseInfoUseCase.execute().blockingFirst()
        enableLicense = getEnableLicensingUseCase.execute().blockingFirst()
        enableTrialRequest = getEnableTrialRequestUseCase.execute().blockingFirst()

        Logger.info("LicenseViewModel initialized", category: Logger.app)
        setupSubscriptions()
    }

    // MARK: - Public Methods

    /// Starts the 14-day trial period for the user by opening the trial checkout.
    public func startTrial() {
        Logger.info("Starting trial period via checkout", category: Logger.app)
        openTrialCheckout()
    }

    /// Opens the license checkout flow in an embedded WebView.
    public func openCheckout() {
        Logger.info("Opening checkout flow", category: Logger.app)

        let url = openCheckoutUseCase.getCheckoutURL()
        checkoutURL = url
        showingCheckoutWebView = true

        Logger.debug("Using checkout URL: \(url.absoluteString)", category: Logger.app)
    }

    /// Opens the trial checkout flow in an embedded WebView.
    public func openTrialCheckout() {
        Logger.info("Opening trial checkout flow", category: Logger.app)

        // Check if trial has already been used on this device
        if hasTrialBeenUsedUseCase.execute() {
            Logger.warning("Trial checkout blocked: trial already used on this device", category: Logger.app)
            activationError = String(
                localized:
                "Trial has already been used on this device. Please purchase a license to continue using the app."
            )
            return
        }

        let url = openCheckoutUseCase.getTrialCheckoutURL()
        checkoutURL = url
        showingCheckoutWebView = true

        Logger.debug("Using trial checkout URL: \(url.absoluteString)", category: Logger.app)
    }

    /// Dismisses the checkout WebView.
    public func dismissCheckoutWebView() {
        showingCheckoutWebView = false
        checkoutURL = nil
    }

    /// Handles successful checkout completion with a license key.
    /// - Parameter licenseKey: The license key from the successful checkout
    public func handleCheckoutSuccess(licenseKey: String) {
        Logger.info("Handling checkout success", category: Logger.app)

        Task {
            await openCheckoutUseCase.handleSuccess(licenseKey: licenseKey)
        }
    }

    /// Activates a license with the provided license key.
    public func activateLicense() {
        guard !licenseKeyInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            activationError = String(localized: LocalizedStringResource("Please enter a valid license key."))
            return
        }

        Logger.info("Activating license", category: Logger.app)

        isActivating = true
        activationError = nil

        Task {
            do {
                _ = try await activateLicenseUseCase
                    .execute(licenseKey: licenseKeyInput.trimmingCharacters(in: .whitespacesAndNewlines))
                await MainActor.run {
                    licenseKeyInput = ""
                    isActivating = false
                }
                Logger.info("License activated successfully", category: Logger.app)
            } catch let error as LicenseError {
                await MainActor.run {
                    isActivating = false
                    activationError = error.localizedDescription
                }
                Logger.error("License activation failed", error: error, category: Logger.app)
            } catch {
                await MainActor.run {
                    isActivating = false
                    activationError =
                        String(localized: LocalizedStringResource("An unexpected error occurred. Please try again."))
                }
                Logger.error("Unexpected license activation error", error: error, category: Logger.app)
            }
        }
    }

    /// Deactivates the current license.
    public func deactivateLicense() {
        Logger.info("Deactivating license", category: Logger.app)

        Task {
            do {
                try await deactivateLicenseUseCase.execute()
            } catch {
                Logger.error("Failed to deactivate license", error: error, category: Logger.app)
            }
        }
    }

    /// Sets the user's display name.
    /// - Parameter userName: The user's display name
    public func setUserName(_ userName: String) {
        Task {
            await setUserNameUseCase.execute(userName: userName)
        }
    }

    /// Sets the user's profile image.
    /// - Parameter image: The profile image, or nil to clear
    public func setProfileImage(_ image: NSImage?) {
        Task {
            let imageData = image?.tiffRepresentation
            await setProfileImageDataUseCase.execute(profileImageData: imageData)
        }
    }

    // MARK: - Private Methods

    /// Sets up reactive subscriptions for license information and feature flags.
    private func setupSubscriptions() {
        // Subscribe to license info changes
        getLicenseInfoUseCase.execute()
            .sink { [weak self] newValue in
                self?.licenseInfo = newValue
            }
            .store(in: &cancellables)

        // Subscribe to enableLicensing feature flag changes
        getEnableLicensingUseCase.execute()
            .sink { [weak self] newValue in
                self?.enableLicense = newValue
            }
            .store(in: &cancellables)

        // Subscribe to enableTrialRequest feature flag changes
        getEnableTrialRequestUseCase.execute()
            .sink { [weak self] newValue in
                self?.enableTrialRequest = newValue
            }
            .store(in: &cancellables)

        // Clear activation error when license key input changes
        $licenseKeyInput
            .dropFirst()
            .sink { [weak self] _ in
                self?.activationError = nil
            }
            .store(in: &cancellables)
    }
}
