// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import AppKit
import Combine
import Domain
import Foundation

/// ViewModel for managing licensing operations and UI state.
@MainActor
public final class LicensingViewModel: ObservableObject {
    // MARK: - Published Properties

    /// The current license status.
    @Published public var licenseStatus: LicenseStatus = .unknown

    /// The license key input field text.
    @Published public var licenseKeyInput: String = ""

    /// Whether a license activation operation is currently in progress.
    @Published public var isActivating: Bool = false

    /// Error message from the most recent license activation attempt, if any.
    @Published public var activationError: String?

    /// Whether licensing features are enabled via feature flags.
    @Published public var enableLicensing: Bool = true

    /// Whether the checkout WebView is currently being presented.
    @Published public var showingCheckoutWebView: Bool = false

    /// The checkout URL for the WebView, if available.
    @Published public var checkoutURL: URL?

    // MARK: - Dependencies

    /// Use case for retrieving the current license status.
    private let getLicenseStatusUseCase: GetLicenseStatusUseCase

    /// Use case for activating a license with a provided key.
    private let activateLicenseUseCase: ActivateLicenseUseCase

    /// Use case for opening the Paddle checkout flow.
    private let openCheckoutUseCase: OpenCheckoutUseCase

    /// Use case for starting the trial period.
    private let startTrialUseCase: StartTrialUseCase

    /// Use case for deactivating the current license.
    private let deactivateLicenseUseCase: DeactivateLicenseUseCase

    /// Use case for retrieving feature flags configuration.
    private let getFeatureFlagsUseCase: GetFeatureFlagsUseCase

    /// Cancellable subscriptions for Combine publishers.
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initialization

    /// Initializes the licensing view model with required use cases.
    /// - Parameters:
    ///   - getLicenseStatusUseCase: Use case for getting license status
    ///   - activateLicenseUseCase: Use case for activating licenses
    ///   - openCheckoutUseCase: Use case for opening checkout flow
    ///   - startTrialUseCase: Use case for starting trial period
    ///   - deactivateLicenseUseCase: Use case for deactivating licenses
    ///   - getFeatureFlagsUseCase: Use case for getting feature flags
    public init(
        getLicenseStatusUseCase: GetLicenseStatusUseCase,
        activateLicenseUseCase: ActivateLicenseUseCase,
        openCheckoutUseCase: OpenCheckoutUseCase,
        startTrialUseCase: StartTrialUseCase,
        deactivateLicenseUseCase: DeactivateLicenseUseCase,
        getFeatureFlagsUseCase: GetFeatureFlagsUseCase
    ) {
        self.getLicenseStatusUseCase = getLicenseStatusUseCase
        self.activateLicenseUseCase = activateLicenseUseCase
        self.openCheckoutUseCase = openCheckoutUseCase
        self.startTrialUseCase = startTrialUseCase
        self.deactivateLicenseUseCase = deactivateLicenseUseCase
        self.getFeatureFlagsUseCase = getFeatureFlagsUseCase

        Logger.info("LicensingViewModel initialized", category: Logger.app)
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
        Logger.info("Opening checkout flow in WebView", category: Logger.app)
        Task {
            let url = await openCheckoutUseCase.execute(from: nil)
            await MainActor.run {
                checkoutURL = url
                showingCheckoutWebView = true
            }
        }
    }

    /// Dismisses the checkout WebView.
    public func dismissCheckoutWebView() {
        Logger.info("Dismissing checkout WebView", category: Logger.app)
        showingCheckoutWebView = false
        checkoutURL = nil
    }

    /// Activates a license using the currently entered license key.
    ///
    /// This method validates the license key with the licensing server and updates
    /// the license status accordingly. The operation runs asynchronously and updates
    /// the UI state through published properties.
    public func activateLicense() {
        guard !licenseKeyInput.isEmpty else {
            Logger.warning("Attempted to activate license with empty key", category: Logger.app)
            return
        }

        Logger.info("Starting license activation", category: Logger.app, metadata: ["keyLength": licenseKeyInput.count])
        isActivating = true
        activationError = nil

        Task {
            do {
                _ = try await activateLicenseUseCase.execute(licenseKey: licenseKeyInput)
                Logger.info("License activation successful", category: Logger.app)
                await MainActor.run {
                    licenseKeyInput = ""
                    isActivating = false
                }
            } catch {
                Logger.error("License activation failed", error: error, category: Logger.app)
                await MainActor.run {
                    isActivating = false
                    if let licensingError = error as? LicenseError {
                        activationError = licensingError.localizedDescription
                    } else {
                        activationError = error.localizedDescription
                    }
                }
            }
        }
    }

    /// Deactivates the current license and clears all associated data.
    ///
    /// This operation removes the license key, customer information, and any
    /// profile data associated with the license from local storage.
    public func deactivateLicense() {
        Logger.info("Deactivating current license", category: Logger.app)
        Task {
            await deactivateLicenseUseCase.execute()
        }
    }

    // MARK: - Computed Properties

    /// Returns a masked version of the license key for display purposes.
    ///
    /// The key is masked to show only the first 4 and last 4 characters,
    /// with asterisks replacing the middle characters for security.
    ///
    /// - Returns: A masked license key string, or nil if no key exists or key is too short
    public var maskedLicenseKey: String? {
        let licenseKey = UserDefaults.standard.string(forKey: "paddle_license_key")
        guard let key = licenseKey, key.count > 8 else { return nil }

        let start = key.prefix(4)
        let end = key.suffix(4)
        return "\(start)****\(end)"
    }

    // MARK: - Private Methods

    /// Sets up reactive subscriptions for license status, feature flags, and input validation.
    ///
    /// This method establishes Combine publishers for:
    /// - License status changes from the licensing gateway
    /// - Feature flag updates for licensing feature enablement
    /// - License key input validation and error clearing
    private func setupSubscriptions() {
        getLicenseStatusUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newStatus in
                Logger.debug("License status changed to: \(newStatus)", category: Logger.app)
                self?.licenseStatus = newStatus
            }
            .store(in: &cancellables)

        // Subscribe to feature flags changes
        getFeatureFlagsUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] featureFlags in
                self?.enableLicensing = featureFlags.enableLicensing
            }
            .store(in: &cancellables)

        // Clear activation error when license key input changes
        $licenseKeyInput
            .sink { [weak self] newKey in
                self?.activationError = nil
                if !newKey.isEmpty {
                    Logger.debug(
                        "License key input updated",
                        category: Logger.app,
                        metadata: ["keyLength": newKey.count]
                    )
                }
            }
            .store(in: &cancellables)
    }
}
