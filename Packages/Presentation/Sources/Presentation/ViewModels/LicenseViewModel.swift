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

    /// Use case for opening the Paddle checkout flow.
    private let openCheckoutUseCase: OpenCheckoutUseCase

    /// Use case for starting the trial period.
    private let startTrialUseCase: StartTrialUseCase

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

    /// Cancellable subscriptions for Combine publishers.
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initialization

    /// Initializes the license view model with required use cases.
    public init(
        getLicenseInfoUseCase: GetLicenseInfoUseCase,
        activateLicenseUseCase: ActivateLicenseUseCase,
        openCheckoutUseCase: OpenCheckoutUseCase,
        startTrialUseCase: StartTrialUseCase,
        deactivateLicenseUseCase: DeactivateLicenseUseCase,
        getEnableLicensingUseCase: GetEnableLicensingUseCase,
        getEnableTrialRequestUseCase: GetEnableTrialRequestUseCase,
        setUserNameUseCase: SetUserNameUseCase,
        setProfileImageDataUseCase: SetProfileImageDataUseCase
    ) {
        self.getLicenseInfoUseCase = getLicenseInfoUseCase
        self.activateLicenseUseCase = activateLicenseUseCase
        self.openCheckoutUseCase = openCheckoutUseCase
        self.startTrialUseCase = startTrialUseCase
        self.deactivateLicenseUseCase = deactivateLicenseUseCase
        self.getEnableLicensingUseCase = getEnableLicensingUseCase
        self.getEnableTrialRequestUseCase = getEnableTrialRequestUseCase
        self.setUserNameUseCase = setUserNameUseCase
        self.setProfileImageDataUseCase = setProfileImageDataUseCase

        licenseInfo = getLicenseInfoUseCase.execute().blockingFirst()
        enableLicense = getEnableLicensingUseCase.execute().blockingFirst()
        enableTrialRequest = getEnableTrialRequestUseCase.execute().blockingFirst()

        Logger.info("LicenseViewModel initialized", category: Logger.app)
        setupSubscriptions()
    }

    // MARK: - Public Methods

    /// Starts the 14-day trial period for the user.
    public func startTrial() {
        Logger.info("Starting trial period", category: Logger.app)
        startTrialUseCase.execute()
    }

    /// Opens the Paddle checkout flow in an embedded WebView.
    public func openCheckout() {
        Logger.info("Opening checkout flow", category: Logger.app)
        checkoutURL = openCheckoutUseCase.getCheckoutURL()
        showingCheckoutWebView = true
    }

    /// Dismisses the checkout WebView.
    public func dismissCheckoutWebView() {
        showingCheckoutWebView = false
        checkoutURL = nil
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
            await deactivateLicenseUseCase.execute()
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
            .assign(to: \.licenseInfo, on: self)
            .store(in: &cancellables)

        // Subscribe to enableLicensing feature flag changes
        getEnableLicensingUseCase.execute()
            .assign(to: \.enableLicense, on: self)
            .store(in: &cancellables)

        // Subscribe to enableTrialRequest feature flag changes
        getEnableTrialRequestUseCase.execute()
            .assign(to: \.enableTrialRequest, on: self)
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
