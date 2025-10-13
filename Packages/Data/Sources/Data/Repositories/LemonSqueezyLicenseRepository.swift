// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Foundation
import LemonSqueezy

/// Repository implementation for LemonSqueezy license.
@MainActor
public final class LemonSqueezyLicenseRepository: LicenseGateway {
    // MARK: - Configuration

    // MARK: - Production Checkout URLs

    /// Checkout base URL for purchasing a license
    ///
    /// To get this URL:
    /// 1. Go to LemonSqueezy Dashboard → Products
    /// 2. Select your product → Variants
    /// 3. Click on the purchase variant
    /// 4. Copy the checkout URL
    private static let checkoutBaseUrl = "https://boutique-apps.lemonsqueezy.com/buy/"

    /// Purchase variant slug for production
    private static let productionPurchaseVariantSlug = "582c9423-6d07-45ab-ac73-825490857823"

    /// Trial variant slug for production
    private static let productionTrialVariantSlug = "684a9421-a7d1-4b1a-afd6-5ed253410d8a"

    /// Purchase variant slug for development (test mode)
    private static let developmentPurchaseVariantSlug = "582c9423-6d07-45ab-ac73-825490857823"

    /// Trial variant slug for development (test mode)
    private static let developmentTrialVariantSlug = "684a9421-a7d1-4b1a-afd6-5ed253410d8a"

    /// Purchase variant ID for production
    private static let productionPurchaseVariantId = "1039603"

    /// Trial variant ID for production
    private static let productionTrialVariantId = "1040657"

    /// Purchase variant ID for development (test mode)
    private static let developmentPurchaseVariantId = "1039603"

    /// Trial variant ID for development (test mode)
    private static let developmentTrialVariantId = "1040657"

    /// Production checkout URL for purchasing a license
    private static let productionCheckoutUrl = checkoutBaseUrl +
        productionPurchaseVariantSlug +
        "?enabled=" +
        productionPurchaseVariantId

    /// Production checkout URL for starting a trial
    private static let productionTrialCheckoutUrl = checkoutBaseUrl +
        productionTrialVariantSlug +
        "?enabled=" +
        productionTrialVariantId

    // MARK: - Development Checkout URLs (Test Mode)

    /// Development checkout URL for testing purchases
    private static let developmentCheckoutUrl = checkoutBaseUrl +
        developmentPurchaseVariantSlug +
        "?enabled=" +
        developmentPurchaseVariantId

    /// Development checkout URL for testing trials
    private static let developmentTrialCheckoutUrl = checkoutBaseUrl +
        developmentTrialVariantSlug +
        "?enabled=" +
        developmentTrialVariantId

    /// Mock license key for development testing
    private static let mockLicenseKey = "MOCKED-LICENSE"

    // MARK: - License Validation Constants

    /// Interval between license validation checks
    #if DEBUG
        // Shorter interval for debug builds to facilitate testing
        private static let validationIntervalSeconds: TimeInterval = 30 // 30 seconds
    #else
        // Longer interval for production builds
        private static let validationIntervalSeconds: TimeInterval = 5 * 60 * 60 // 5 hours
    #endif

    /// Grace period for offline validation (7 days)
    private static let validationGracePeriodSeconds: TimeInterval = 7 * 24 * 60 * 60

    /// Instance name for this device/installation
    /// This persists across app reinstalls and is unique per device
    private static let instanceName: String = "AeroSpaceBar-\(HardwareIdentifier.getHardwareUUID())"

    // MARK: - Private Properties

    /// LemonSqueezy SDK instance
    private let lemonSqueezy: LemonSqueezy

    private let licenseInfoSubject = CurrentValueSubject<LicenseInfo, Never>(
        LicenseInfo()
    )

    private let enableLicensingSubject = CurrentValueSubject<Bool, Never>(
        FeatureFlagDefaults.enableLicensing
    )

    private let enableTrialRequestSubject = CurrentValueSubject<Bool, Never>(
        FeatureFlagDefaults.enableTrialRequest
    )

    #if DEBUG
        private let mockActiveLicenseSubject = CurrentValueSubject<Bool, Never>(
            FeatureFlagDefaults.mockActiveLicense
        )

        private let checkoutEnvironmentSubject = CurrentValueSubject<CheckoutEnvironment, Never>(
            FeatureFlagDefaults.checkoutEnvironment
        )
    #endif

    private var cancellables = Set<AnyCancellable>()
    private var validationTask: Task<Void, Never>?

    // MARK: - UserDefaults Key

    private enum UserDefaultsKeys {
        static let licenseInfo = "license_info"
        static let lastValidationDate = "last_license_validation"
        static let instanceId = "license_instance_id"
    }

    // MARK: - Public Properties

    public var licenseInfoPublisher: AnyPublisher<LicenseInfo, Never> {
        licenseInfoSubject.eraseToAnyPublisher()
    }

    public var enableLicensingPublisher: AnyPublisher<Bool, Never> {
        enableLicensingSubject.eraseToAnyPublisher()
    }

    public var enableTrialRequestPublisher: AnyPublisher<Bool, Never> {
        enableTrialRequestSubject.eraseToAnyPublisher()
    }

    #if DEBUG
        public var mockActiveLicensePublisher: AnyPublisher<Bool, Never> {
            mockActiveLicenseSubject.eraseToAnyPublisher()
        }

        public var checkoutEnvironmentPublisher: AnyPublisher<CheckoutEnvironment, Never> {
            checkoutEnvironmentSubject.eraseToAnyPublisher()
        }
    #endif

    // MARK: - Initialization

    /// Initializes the repository with the provided API key.
    /// - Parameter apiKey: LemonSqueezy API key. If not provided, uses the API key baked into the binary at build time.
    public init(apiKey: String? = nil) {
        // Initialize API key from parameter or use the build-time generated secret
        // Trim whitespace and newlines that might have been accidentally included
        let rawApiKey = apiKey ?? Secrets.lemonSqueezyAPIKey
        let lemonSqueezyApiKey = rawApiKey.trimmingCharacters(in: .whitespacesAndNewlines)

        // Validate API key
        Logger.debug("Initializing LemonSqueezy SDK", category: Logger.app)

        if lemonSqueezyApiKey.isEmpty {
            Logger.error("LemonSqueezy API key is empty!", category: Logger.app)
            Logger.error("  Raw key length: \(rawApiKey.count)", category: Logger.app)
            Logger.error("  Trimmed key length: \(lemonSqueezyApiKey.count)", category: Logger.app)
        } else {
            let keyPrefix = String(lemonSqueezyApiKey.prefix(2))
            Logger.debug("  API Key prefix: \(keyPrefix)...", category: Logger.app)
            Logger.debug("  API Key length: \(lemonSqueezyApiKey.count) characters", category: Logger.app)

            // Check for suspicious characters
            if rawApiKey != lemonSqueezyApiKey {
                Logger.warning(
                    "API key had whitespace/newlines (trimmed \(rawApiKey.count - lemonSqueezyApiKey.count) chars)",
                    category: Logger.app
                )
            }

            // Validate format (LemonSqueezy API keys typically start with specific patterns)
            if !lemonSqueezyApiKey.contains("-") {
                Logger.warning("API key format looks unusual (no hyphens found)", category: Logger.app)
            }
        }

        // Initialize LemonSqueezy SDK
        lemonSqueezy = LemonSqueezy(lemonSqueezyApiKey)
        Logger.debug("LemonSqueezy SDK initialized", category: Logger.app)

        initializeLicenseInfo()
        startPeriodicValidation()
        setupFeatureFlagObservation()
    }

    // MARK: - Private Methods

    /// Determines if a variant ID corresponds to a trial variant.
    /// - Parameter variantId: The variant ID to check
    /// - Returns: True if the variant is a trial variant
    private func isTrialVariant(_ variantId: Int) -> Bool {
        let trialVariantIds = [
            Int(Self.productionTrialVariantId) ?? 0,
            Int(Self.developmentTrialVariantId) ?? 0
        ]
        return trialVariantIds.contains(variantId)
    }

    /// Determines the license status based on validation result and variant information.
    /// - Parameters:
    ///   - lemonSqueezyStatus: The license status from LemonSqueezy API (inactive, active, expired, disabled)
    ///   - isValid: Whether the license is currently valid (from result.valid or result.activated)
    ///   - variantId: The variant ID from LemonSqueezy
    ///   - expiresAt: Optional expiration date string (ISO 8601 format)
    /// - Returns: The appropriate license status
    private func determineLicenseStatus(
        lemonSqueezyStatus: String,
        isValid: Bool,
        variantId: Int,
        expiresAt: String?
    ) -> LicenseStatus {
        // Check LemonSqueezy status first - this is the authoritative source
        switch lemonSqueezyStatus.lowercased() {
        case "expired",
             "disabled":
            // License has expired or been manually disabled
            return .expired

        case "inactive":
            // License key exists but has no activations - treat as expired
            return .expired

        case "active":
            // License is active, check if it's valid
            guard isValid else {
                return .expired
            }

            // Check if this is a trial variant
            if isTrialVariant(variantId) {
                // Calculate days remaining from expiration date
                let daysRemaining = calculateDaysRemaining(from: expiresAt)

                // If trial has expired (0 or negative days), return expired status
                if daysRemaining <= 0 {
                    return .expired
                }

                return .trial(daysRemaining: daysRemaining)
            }

            return .licensed

        default:
            // Unknown status from LemonSqueezy - log warning and treat as expired
            Logger.warning("Unknown LemonSqueezy status: \(lemonSqueezyStatus)", category: Logger.app)
            return .expired
        }
    }

    /// Calculates the number of days remaining until expiration.
    /// - Parameter expiresAt: Optional expiration date string in various formats
    /// - Returns: Number of days remaining (0 if expired or invalid date)
    private func calculateDaysRemaining(from expiresAt: String?) -> Int {
        guard let expiresAtString = expiresAt else {
            Logger.warning("No expiration date provided", category: Logger.app)
            return 0
        }

        Logger.debug("Parsing expiration date: \(expiresAtString)", category: Logger.app)

        // Try multiple date formats as LemonSqueezy may use different formats
        let formatters: [DateFormatter] = [
            // ISO 8601 with timezone (e.g., "2025-02-01T00:00:00.000000Z")
            {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
                formatter.timeZone = TimeZone(identifier: "UTC")
                formatter.locale = Locale(identifier: "en_US_POSIX")
                return formatter
            }(),
            // ISO 8601 without microseconds (e.g., "2025-02-01T00:00:00Z")
            {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                formatter.timeZone = TimeZone(identifier: "UTC")
                formatter.locale = Locale(identifier: "en_US_POSIX")
                return formatter
            }(),
            // ISO 8601 with timezone offset (e.g., "2025-02-01T00:00:00+00:00")
            {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                formatter.locale = Locale(identifier: "en_US_POSIX")
                return formatter
            }()
        ]

        // Also try ISO8601DateFormatter
        var expirationDate: Date?

        // Try ISO8601DateFormatter first
        let iso8601Formatter = ISO8601DateFormatter()
        iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        expirationDate = iso8601Formatter.date(from: expiresAtString)

        // If that fails, try other formatters
        if expirationDate == nil {
            for formatter in formatters {
                if let date = formatter.date(from: expiresAtString) {
                    expirationDate = date
                    break
                }
            }
        }

        guard let expirationDate else {
            Logger.error(
                "Failed to parse expiration date with any known format: \(expiresAtString)",
                category: Logger.app
            )
            return 0
        }

        let calendar = Calendar.current
        let now = Date()

        // For trial licenses, use calendar day calculation (more user-friendly)
        // This counts the number of calendar days remaining, including the current day
        guard
            let startOfToday = calendar.startOfDay(for: now) as Date?,
            let startOfExpiration = calendar.startOfDay(for: expirationDate) as Date?
        else {
            Logger.error("Failed to calculate start of day", category: Logger.app)
            return 0
        }

        let components = calendar.dateComponents([.day], from: startOfToday, to: startOfExpiration)
        let daysRemaining = max(0, components.day ?? 0)

        Logger.debug(
            "Expiration date parsed: \(expirationDate), Days remaining: \(daysRemaining)",
            category: Logger.app
        )

        return daysRemaining
    }

    /// Initializes the license info based on stored data.
    private func initializeLicenseInfo() {
        // Load from UserDefaults first to get any saved user data
        var savedUserName = ""
        var savedEmail = ""
        var savedProfileImageData: Data?

        if
            let data = UserDefaults.standard.data(forKey: UserDefaultsKeys.licenseInfo),
            let savedInfo = try? JSONDecoder().decode(LicenseInfo.self, from: data)
        {
            savedUserName = savedInfo.userName
            savedEmail = savedInfo.email
            savedProfileImageData = savedInfo.profileImageData
        }

        #if DEBUG
            // Check for mock license first
            if mockActiveLicenseSubject.value {
                let mockInfo = LicenseInfo(
                    licenseKey: Self.mockLicenseKey,
                    licenseStatus: .licensed,
                    userName: savedUserName,
                    email: savedEmail,
                    profileImageData: savedProfileImageData
                )
                licenseInfoSubject.send(mockInfo)
                saveLicenseInfo(mockInfo)
                return
            }
        #endif

        // Load from UserDefaults
        if
            let data = UserDefaults.standard.data(forKey: UserDefaultsKeys.licenseInfo),
            let savedInfo = try? JSONDecoder().decode(LicenseInfo.self, from: data)
        {
            // Check if we have a valid license key
            if !savedInfo.licenseKey.isEmpty {
                licenseInfoSubject.send(savedInfo)

                // Only validate active licenses on initialization
                // This refreshes license status for active licenses and trials
                // Expired licenses stay expired until user explicitly re-activates
                // This prevents expired trials from being validated repeatedly
                if savedInfo.isActive {
                    Task {
                        let validatedInfo = await validateLicense()
                        licenseInfoSubject.send(validatedInfo)
                    }
                }
            } else {
                // Use saved info as is
                licenseInfoSubject.send(savedInfo)
            }
        } else {
            // First launch - create empty license info but preserve any existing user data
            let defaultInfo = LicenseInfo(
                licenseKey: "",
                licenseStatus: .unknown,
                userName: savedUserName,
                email: savedEmail,
                profileImageData: savedProfileImageData
            )
            licenseInfoSubject.send(defaultInfo)
            saveLicenseInfo(defaultInfo)
        }
    }

    /// Starts periodic license validation using async/await Task.
    private func startPeriodicValidation() {
        // Cancel existing validation task if any
        validationTask?.cancel()

        // Create new validation task
        validationTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self else { return }

                // Wait for validation interval
                try? await Task.sleep(for: .seconds(Self.validationIntervalSeconds))

                // Check if task was cancelled during sleep
                guard !Task.isCancelled else { return }

                // Validate license if currently licensed
                let currentInfo = licenseInfoSubject.value
                if currentInfo.isActive {
                    let validatedInfo = await validateLicense()
                    licenseInfoSubject.send(validatedInfo)
                }
            }
        }
    }

    deinit {
        // Cancel validation task on deinitialization
        validationTask?.cancel()
    }

    /// Sets up observation of feature flag changes for mock license functionality.
    private func setupFeatureFlagObservation() {
        #if DEBUG
            mockActiveLicenseSubject
                .dropFirst() // Skip initial value to avoid infinite loop
                .sink { [weak self] mockActiveLicense in
                    guard let self else { return }

                    if mockActiveLicense {
                        // Mock license is enabled
                        let mockInfo = LicenseInfo(
                            licenseKey: Self.mockLicenseKey,
                            licenseStatus: .licensed,
                            userName: licenseInfoSubject.value.userName,
                            email: licenseInfoSubject.value.email,
                            profileImageData: licenseInfoSubject.value.profileImageData
                        )
                        licenseInfoSubject.send(mockInfo)
                        saveLicenseInfo(mockInfo)
                    } else {
                        // Mock license is disabled
                        let currentInfo = licenseInfoSubject.value
                        if currentInfo.licenseKey == Self.mockLicenseKey {
                            // Clear mock data and reinitialize
                            UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.licenseInfo)
                            initializeLicenseInfo()
                        }
                    }
                }
                .store(in: &cancellables)
        #endif
    }

    /// Saves license info to UserDefaults.
    private func saveLicenseInfo(_ info: LicenseInfo) {
        if let data = try? JSONEncoder().encode(info) {
            UserDefaults.standard.set(data, forKey: UserDefaultsKeys.licenseInfo)
        }
    }

    // MARK: - Public Methods

    public func setEnableLicensing(_ enabled: Bool) {
        if enabled == enableLicensingSubject.value { return }

        Task {
            self.enableLicensingSubject.send(enabled)
        }
    }

    public func setEnableTrialRequest(_ enabled: Bool) {
        if enabled == enableTrialRequestSubject.value { return }

        Task {
            self.enableTrialRequestSubject.send(enabled)
        }
    }

    #if DEBUG
        public func setMockActiveLicense(_ enabled: Bool) {
            if enabled == mockActiveLicenseSubject.value { return }

            Task {
                self.mockActiveLicenseSubject.send(enabled)
            }
        }

        public func setCheckoutEnvironment(_ environment: CheckoutEnvironment) {
            if environment == checkoutEnvironmentSubject.value { return }

            Task {
                self.checkoutEnvironmentSubject.send(environment)
            }
        }
    #endif

    public func resetLicenseFeatureFlags() async {
        try? await deactivateLicense()

        setEnableLicensing(FeatureFlagDefaults.enableLicensing)
        setEnableTrialRequest(FeatureFlagDefaults.enableTrialRequest)

        #if DEBUG
            setMockActiveLicense(FeatureFlagDefaults.mockActiveLicense)
        #endif
    }

    public func validateLicense() async -> LicenseInfo {
        let currentInfo = licenseInfoSubject.value

        #if DEBUG
            // Check for mock license first
            if mockActiveLicenseSubject.value {
                return currentInfo
            }
        #endif

        guard !currentInfo.licenseKey.isEmpty else {
            return currentInfo
        }

        // Get stored instance ID from activation
        guard let instanceId = UserDefaults.standard.string(forKey: UserDefaultsKeys.instanceId) else {
            Logger.warning("No instance ID found, cannot validate license", category: Logger.app)
            return currentInfo
        }

        do {
            // Validate license using LemonSqueezy SDK with stored instance ID
            let result: ValidateLicense = try await lemonSqueezy.validateLicense(
                licenseKey: currentInfo.licenseKey,
                instanceId: instanceId
            )

            // Update last validation date
            UserDefaults.standard.set(Date(), forKey: UserDefaultsKeys.lastValidationDate)

            // Determine license status based on LemonSqueezy response
            let licenseStatus = determineLicenseStatus(
                lemonSqueezyStatus: result.licenseKey.status,
                isValid: result.valid,
                variantId: result.meta.variantId,
                expiresAt: result.licenseKey.expiresAt
            )

            let validatedInfo = LicenseInfo(
                licenseKey: result.licenseKey.key,
                licenseStatus: licenseStatus,
                userName: currentInfo.userName.isEmpty ? result.meta.customerName : currentInfo.userName,
                email: currentInfo.email.isEmpty ? result.meta.customerEmail : currentInfo.email,
                profileImageData: currentInfo.profileImageData
            )

            saveLicenseInfo(validatedInfo)

            // Only deactivate if license is disabled (manually disabled by admin)
            // Don't deactivate for expired licenses - they should stay expired
            // so users can see they had a license/trial that expired
            if result.licenseKey.status.lowercased() == "disabled" {
                Task {
                    try? await deactivateLicense()
                }
            }

            return validatedInfo
        } catch {
            Logger.error("License validation failed", error: error, category: Logger.app)

            // If we can't validate but have a recent successful validation, stay licensed
            if
                let lastValidation = UserDefaults.standard.object(forKey: UserDefaultsKeys.lastValidationDate) as? Date,
                Date().timeIntervalSince(lastValidation) < Self.validationGracePeriodSeconds
            {
                return currentInfo
            }

            let expiredInfo = LicenseInfo(
                licenseKey: currentInfo.licenseKey,
                licenseStatus: .expired,
                userName: currentInfo.userName,
                email: currentInfo.email,
                profileImageData: currentInfo.profileImageData
            )

            saveLicenseInfo(expiredInfo)
            return expiredInfo
        }
    }

    public func activateLicense(_ licenseKey: String) async throws -> LicenseInfo {
        do {
            // Activate license using LemonSqueezy SDK with our instance name
            let result: ActivateLicense = try await lemonSqueezy.activateLicense(
                licenseKey: licenseKey,
                instanceName: Self.instanceName
            )

            // Store the instance ID returned by LemonSqueezy for future validation/deactivation
            UserDefaults.standard.set(result.instance.id, forKey: UserDefaultsKeys.instanceId)
            UserDefaults.standard.set(Date(), forKey: UserDefaultsKeys.lastValidationDate)

            // Create activated license info with proper status based on LemonSqueezy response
            let currentInfo = licenseInfoSubject.value
            let licenseStatus = determineLicenseStatus(
                lemonSqueezyStatus: result.licenseKey.status,
                isValid: result.activated,
                variantId: result.meta.variantId,
                expiresAt: result.licenseKey.expiresAt
            )

            let activatedInfo = LicenseInfo(
                licenseKey: result.licenseKey.key,
                licenseStatus: licenseStatus,
                userName: currentInfo.userName.isEmpty ? result.meta.customerName : currentInfo.userName,
                email: currentInfo.email.isEmpty ? result.meta.customerEmail : currentInfo.email,
                profileImageData: currentInfo.profileImageData
            )

            licenseInfoSubject.send(activatedInfo)
            saveLicenseInfo(activatedInfo)

            return activatedInfo
        } catch let error as LemonSqueezyAPIError {
            // Map LemonSqueezy errors to domain errors
            Logger.error("License activation failed", error: error, category: Logger.app)
            if let errorMessage = error.error, errorMessage.contains("license") {
                throw LicenseError.invalidLicenseKey
            }
            throw LicenseError.networkError(error)
        } catch {
            Logger.error("License activation failed", error: error, category: Logger.app)
            throw LicenseError.networkError(error)
        }
    }

    public func deactivateLicense() async throws {
        let currentInfo = licenseInfoSubject.value

        #if DEBUG
            // If deactivating a mock license, turn off the mock flag
            if currentInfo.licenseKey == Self.mockLicenseKey {
                mockActiveLicenseSubject.send(false)
                // Clear local data for mock license
                clearLicenseData(preservingUserData: currentInfo)
                return
            }
        #endif

        // Check if we have a license key and instance ID to deactivate
        guard
            !currentInfo.licenseKey.isEmpty,
            let instanceId = UserDefaults.standard.string(forKey: UserDefaultsKeys.instanceId)
        else {
            // No license key or instance ID, just clear local data
            clearLicenseData(preservingUserData: currentInfo)
            return
        }

        do {
            // Deactivate license using LemonSqueezy SDK with stored instance ID
            _ = try await lemonSqueezy.deactivateLicense(
                licenseKey: currentInfo.licenseKey,
                instanceId: instanceId
            )

            // Clear local data after successful deactivation
            clearLicenseData(preservingUserData: currentInfo)
        } catch let error as LemonSqueezyAPIError {
            Logger.error("License deactivation failed", error: error, category: Logger.app)
            // Still clear local data even if server deactivation fails
            clearLicenseData(preservingUserData: currentInfo)
            throw LicenseError.networkError(error)
        } catch {
            Logger.error("License deactivation failed", error: error, category: Logger.app)
            clearLicenseData(preservingUserData: currentInfo)
            throw LicenseError.networkError(error)
        }
    }

    /// Clears license data while preserving user information.
    /// - Parameter currentInfo: Current license info to preserve user data from
    private func clearLicenseData(preservingUserData currentInfo: LicenseInfo) {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.licenseInfo)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.lastValidationDate)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.instanceId)

        // Preserve user data when deactivating
        let clearedInfo = LicenseInfo(
            licenseKey: "",
            licenseStatus: .unknown,
            userName: currentInfo.userName,
            email: currentInfo.email,
            profileImageData: currentInfo.profileImageData
        )
        licenseInfoSubject.send(clearedInfo)
        saveLicenseInfo(clearedInfo)
    }

    // MARK: - Profile Management

    public func setUserName(_ userName: String) {
        let currentInfo = licenseInfoSubject.value
        let updatedInfo = LicenseInfo(
            licenseKey: currentInfo.licenseKey,
            licenseStatus: currentInfo.licenseStatus,
            userName: userName,
            email: currentInfo.email,
            profileImageData: currentInfo.profileImageData
        )

        licenseInfoSubject.send(updatedInfo)
        saveLicenseInfo(updatedInfo)
    }

    public func setProfileImageData(_ profileImageData: Data?) {
        let currentInfo = licenseInfoSubject.value
        let updatedInfo = LicenseInfo(
            licenseKey: currentInfo.licenseKey,
            licenseStatus: currentInfo.licenseStatus,
            userName: currentInfo.userName,
            email: currentInfo.email,
            profileImageData: profileImageData
        )

        licenseInfoSubject.send(updatedInfo)
        saveLicenseInfo(updatedInfo)
    }

    // MARK: - Checkout URL Generation

    /// Gets the LemonSqueezy checkout URL for purchasing a license.
    ///
    /// This returns a static checkout URL from the LemonSqueezy Dashboard.
    /// No API call is needed - the URL directly opens the checkout page.
    ///
    /// - Returns: The checkout URL for purchasing a license
    public func getCheckoutURL() -> URL {
        #if DEBUG
            let urlString = checkoutEnvironmentSubject.value == .development
                ? Self.developmentCheckoutUrl
                : Self.productionCheckoutUrl
        #else
            let urlString = productionCheckoutUrl
        #endif

        guard let url = URL(string: urlString) else {
            Logger.error("Invalid checkout URL: \(urlString)", category: Logger.app)
            fatalError("Checkout URL must be valid. Please update the URL constants in LemonSqueezyLicenseRepository.")
        }

        Logger.debug("Using checkout URL: \(urlString)", category: Logger.app)
        return url
    }

    /// Gets the LemonSqueezy checkout URL for starting a trial.
    ///
    /// This returns a static checkout URL from the LemonSqueezy Dashboard.
    /// No API call is needed - the URL directly opens the trial checkout page.
    ///
    /// - Returns: The checkout URL for starting a trial
    public func getTrialCheckoutURL() -> URL {
        #if DEBUG
            let urlString = checkoutEnvironmentSubject.value == .development
                ? Self.developmentTrialCheckoutUrl
                : Self.productionTrialCheckoutUrl
        #else
            let urlString = productionTrialCheckoutUrl
        #endif

        guard let url = URL(string: urlString) else {
            Logger.error("Invalid trial checkout URL: \(urlString)", category: Logger.app)
            fatalError(
                "Trial checkout URL must be valid. Please update the URL constants in LemonSqueezyLicenseRepository."
            )
        }

        Logger.debug("Using trial checkout URL: \(urlString)", category: Logger.app)
        return url
    }

    /// Handles successful checkout completion (called from presentation layer)
    public func handleCheckoutSuccess(licenseKey: String) async {
        do {
            let licenseInfo = try await activateLicense(licenseKey)
            Logger.info("License activated successfully: \(licenseInfo.licenseKey)", category: Logger.app)
        } catch {
            Logger.error("Failed to activate license after purchase", error: error, category: Logger.app)
        }
    }
}
