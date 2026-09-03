// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import CryptoKit
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

    // Interval between license validation checks
    #if DEBUG
        /// Shorter interval for debug builds to facilitate testing
        private static let validationIntervalSeconds: TimeInterval = 30 // 30 seconds
    #else
        /// Longer interval for production builds
        private static let validationIntervalSeconds: TimeInterval = 5 * 60 * 60 // 5 hours
    #endif

    /// Grace period for offline trial validation (7 days)
    /// This only applies to trial licenses, not purchased licenses
    private static let trialValidationGracePeriodSeconds: TimeInterval = 7 * 24 * 60 * 60

    /// Trial duration in seconds (14 days)
    private static let trialDurationSeconds: TimeInterval = 14 * 24 * 60 * 60

    /// Instance name for this device/installation
    /// This persists across app reinstalls and is unique per device
    private static let instanceName: String = HardwareIdentifier.getHardwareUUID()

    // MARK: - Trial Storage Constants

    /// UserDefaults key for storing trial marker (obfuscated)
    private static let userDefaultsTrialUsedKey = "f8d9a1c3e7b2" // gitleaks:allow

    /// Hidden file name for storing trial marker in Application Support
    private static let hiddenFileName = ".sys_marker"

    // MARK: - Private Properties

    /// LemonSqueezy SDK instance
    private let lemonSqueezy: LemonSqueezy = .init("")

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
        static let trialActivationDate = "trial_activation_date"
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

    /// UserDefaults instance for storage
    private let userDefaults: UserDefaults

    // MARK: - Initialization

    /// Initializes the repository with the provided API key.
    /// - Parameter userDefaults: The UserDefaults instance to use for storage (defaults to .standard)
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        initializeLicenseInfo()
        startPeriodicValidation()
        setupFeatureFlagObservation()
    }

    // MARK: - Private Methods

    // MARK: - Trial Abuse Prevention

    /// Generates an obfuscated marker from the instance name.
    /// This makes it harder for users to understand what's being stored.
    /// - Parameter instanceName: The device instance name to obfuscate
    /// - Returns: A hash-based marker string
    private func generateTrialMarker(from instanceName: String) -> String {
        // Use SHA256 hash of instanceName + salt for obfuscation
        let saltedValue = "asb_trial_" + instanceName + "_marker"
        guard let data = saltedValue.data(using: .utf8) else {
            return instanceName // Fallback to plain instanceName if encoding fails
        }

        // Create SHA256 hash using CryptoKit
        let hash = SHA256.hash(data: data)

        // Convert to hex string (first 16 characters for shorter storage)
        // Using unsafe because String(format:) requires it in Swift 6
        return hash.prefix(8).map { unsafe String(format: "%02x", $0) }.joined()
    }

    /// Gets the path to the hidden trial marker file in Application Support.
    /// - Returns: URL to the hidden file
    private func getHiddenFilePath() -> URL? {
        guard
            let appSupport = FileManager.default
                .urls(
                    for: .applicationSupportDirectory,
                    in: .userDomainMask
                )
                .first
        else {
            return nil
        }

        // Create a subdirectory with an obscure name
        let markerDir = appSupport.appendingPathComponent("Preferences", isDirectory: true)

        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(at: markerDir, withIntermediateDirectories: true)

        return markerDir.appendingPathComponent(Self.hiddenFileName)
    }

    /// Checks if trial marker exists in UserDefaults.
    /// - Returns: True if marker found and valid
    private func checkUserDefaultsForTrialMarker() -> Bool {
        #if DEBUG
            Logger.debug("Checking UserDefaults for trial marker", category: Logger.app)
        #endif

        if let storedMarker = userDefaults.string(forKey: Self.userDefaultsTrialUsedKey) {
            let currentMarker = generateTrialMarker(from: Self.instanceName)
            return storedMarker == currentMarker
        }
        return false
    }

    /// Checks if trial marker exists in hidden file.
    /// - Returns: True if marker found and valid
    private func checkHiddenFileForTrialMarker() -> Bool {
        guard let filePath = getHiddenFilePath() else { return false }

        #if DEBUG
            Logger.debug("Checking hidden file for trial marker at path: \(filePath.path)", category: Logger.app)
        #endif

        // Check if file exists and read contents
        guard let storedMarker = try? String(contentsOf: filePath, encoding: .utf8) else {
            return false
        }

        let currentMarker = generateTrialMarker(from: Self.instanceName)
        return storedMarker.trimmingCharacters(in: .whitespacesAndNewlines) == currentMarker
    }

    /// Checks if a trial has already been used on this device.
    /// Checks multiple storage locations - if ANY has the marker, trial was used.
    /// This makes it difficult for users to bypass trial restrictions by deleting one location.
    /// - Returns: True if trial was previously activated, false otherwise
    public func hasTrialBeenUsed() -> Bool {
        // Check both locations - if ANY returns true, trial was used
        let inUserDefaults = checkUserDefaultsForTrialMarker()
        let inHiddenFile = checkHiddenFileForTrialMarker()

        let trialWasUsed = inUserDefaults || inHiddenFile

        #if DEBUG
            if trialWasUsed {
                Logger.debug(
                    "Trial marker found - UserDefaults: \(inUserDefaults), File: \(inHiddenFile)",
                    category: Logger.app
                )
            } else {
                Logger.debug("No trial markers found - trial can be activated", category: Logger.app)
            }
        #endif

        return trialWasUsed
    }

    /// Marks the trial as used on this device by storing markers in multiple locations.
    /// This creates redundancy to prevent users from bypassing by deleting one storage location.
    private func markTrialAsUsed() {
        let marker = generateTrialMarker(from: Self.instanceName)

        // 1. Store in UserDefaults
        userDefaults.set(marker, forKey: Self.userDefaultsTrialUsedKey)
        #if DEBUG
            Logger.debug("Storing trial marker in UserDefaults", category: Logger.app)
        #endif

        // 2. Store in hidden file
        if var filePath = getHiddenFilePath() {
            try? marker.write(to: filePath, atomically: true, encoding: .utf8)

            // Set file attributes to make it hidden and less obvious
            var resourceValues = URLResourceValues()
            resourceValues.isHidden = true
            try? filePath.setResourceValues(resourceValues)

            #if DEBUG
                Logger.debug("Storing trial marker in hidden file at path: \(filePath.path)", category: Logger.app)
            #endif
        }

        Logger.info("Trial markers stored across multiple locations for device", category: Logger.app)
    }

    /// Determines if a variant ID corresponds to a trial variant.
    /// - Parameter variantId: The variant ID to check
    /// - Returns: True if the variant is a trial variant
    private func isTrialVariant(_ variantId: Int) -> Bool {
        let trialVariantIds = [
            Int(Self.productionTrialVariantId) ?? 0,
            Int(Self.developmentTrialVariantId) ?? 0
        ]
        let isTrial = trialVariantIds.contains(variantId)

        #if DEBUG
            Logger.debug("Checking if variant \(variantId) is a trial variant", category: Logger.app)
            Logger.debug("Expected trial variant IDs: \(trialVariantIds)", category: Logger.app)
            Logger.debug("Is trial variant: \(isTrial)", category: Logger.app)
        #endif

        return isTrial
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
            let data = userDefaults.data(forKey: UserDefaultsKeys.licenseInfo),
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
            let data = userDefaults.data(forKey: UserDefaultsKeys.licenseInfo),
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
    /// Only validates trial licenses periodically - purchased licenses don't need periodic validation.
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

                // Only validate trial licenses periodically
                // Purchased licenses don't need periodic validation as they're perpetual
                let currentInfo = licenseInfoSubject.value
                if case .trial = currentInfo.licenseStatus {
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
                            userDefaults.removeObject(forKey: UserDefaultsKeys.licenseInfo)
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
            userDefaults.set(data, forKey: UserDefaultsKeys.licenseInfo)
        }
    }

    // MARK: - Public Methods

    public func setEnableLicensing(_ enabled: Bool) {
        if enabled == enableLicensingSubject.value {
            return
        }

        Task {
            self.enableLicensingSubject.send(enabled)
        }
    }

    public func setEnableTrialRequest(_ enabled: Bool) {
        if enabled == enableTrialRequestSubject.value {
            return
        }

        Task {
            self.enableTrialRequestSubject.send(enabled)
        }
    }

    #if DEBUG
        public func setMockActiveLicense(_ enabled: Bool) {
            if enabled == mockActiveLicenseSubject.value {
                return
            }

            Task {
                self.mockActiveLicenseSubject.send(enabled)
            }
        }

        public func setCheckoutEnvironment(_ environment: CheckoutEnvironment) {
            if environment == checkoutEnvironmentSubject.value {
                return
            }

            Task {
                self.checkoutEnvironmentSubject.send(environment)
            }
        }
    #endif

    public func resetLicenseFeatureFlags() async {
        try? await deactivateLicense()

        // Clear trial markers to restore app to initial state
        // clearTrialMarkers()

        setEnableLicensing(FeatureFlagDefaults.enableLicensing)
        setEnableTrialRequest(FeatureFlagDefaults.enableTrialRequest)

        #if DEBUG
            setMockActiveLicense(FeatureFlagDefaults.mockActiveLicense)
        #endif
    }

    /// Clears all trial marker files and storage, allowing trial to be used again.
    /// This is used when resetting license feature flags to restore the app to its initial state.
    private func clearTrialMarkers() {
        // 1. Clear UserDefaults trial marker
        userDefaults.removeObject(forKey: Self.userDefaultsTrialUsedKey)

        // 2. Delete hidden file trial marker
        if let filePath = getHiddenFilePath() {
            try? FileManager.default.removeItem(at: filePath)
        }

        Logger.debug("Trial markers cleared - app restored to initial state", category: Logger.app)
    }

    /// Validates trial expiration locally by checking if trial duration has passed since activation.
    /// This is used as a fallback during the grace period when network validation fails.
    /// - Parameter activationDate: The date when the trial was first activated
    /// - Returns: True if trial has expired locally, false otherwise
    private func isTrialExpiredLocally(activationDate: Date) -> Bool {
        let now = Date()
        let timeSinceActivation = now.timeIntervalSince(activationDate)
        let isExpired = timeSinceActivation >= Self.trialDurationSeconds

        #if DEBUG
            let daysElapsed = timeSinceActivation / (24 * 60 * 60)
            Logger.debug(
                "Local trial expiration check - Days elapsed: \(daysElapsed), Expired: \(isExpired)",
                category: Logger.app
            )
        #endif

        return isExpired
    }

    private func validateLicense() async -> LicenseInfo {
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
        guard let instanceId = userDefaults.string(forKey: UserDefaultsKeys.instanceId) else {
            return handleMissingInstanceId(currentInfo: currentInfo)
        }

        do {
            let result: ValidateLicense = try await lemonSqueezy.validateLicense(
                licenseKey: currentInfo.licenseKey,
                instanceId: instanceId
            )
            return processSuccessfulValidation(result: result, currentInfo: currentInfo)
        } catch let apiError as LemonSqueezyAPIError {
            return handleValidationAPIError(apiError: apiError, currentInfo: currentInfo)
        } catch {
            return handleValidationNetworkError(error: error, currentInfo: currentInfo)
        }
    }

    private func handleMissingInstanceId(currentInfo: LicenseInfo) -> LicenseInfo {
        Logger.error("No instance ID found - license validation failed, marking as expired", category: Logger.app)

        let expiredInfo = LicenseInfo(
            licenseKey: currentInfo.licenseKey,
            licenseStatus: .expired,
            userName: currentInfo.userName,
            email: currentInfo.email,
            profileImageData: currentInfo.profileImageData
        )
        saveLicenseInfo(expiredInfo)

        // Clear instance-related data to ensure clean state
        userDefaults.removeObject(forKey: UserDefaultsKeys.instanceId)
        userDefaults.removeObject(forKey: UserDefaultsKeys.lastValidationDate)

        return expiredInfo
    }

    private func processSuccessfulValidation(result: ValidateLicense, currentInfo: LicenseInfo) -> LicenseInfo {
        // Update last validation date
        userDefaults.set(Date(), forKey: UserDefaultsKeys.lastValidationDate)

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
        if result.licenseKey.status.lowercased() == "disabled" {
            Task {
                try? await deactivateLicense()
            }
        }

        return validatedInfo
    }

    private func handleValidationAPIError(apiError: LemonSqueezyAPIError, currentInfo: LicenseInfo) -> LicenseInfo {
        Logger.error("License validation failed with API error", error: apiError, category: Logger.app)

        // If validateLicense throws, it means the request failed (e.g. 4xx, 5xx, or decoding error).
        // It does NOT mean the license is invalid (which would return 200 OK with valid=false).
        // Therefore, we should treat this as a temporary failure (like a network error)
        // to avoid expiring valid licenses due to server/connection issues.
        return handleValidationNetworkError(error: apiError, currentInfo: currentInfo)
    }

    private func handleValidationNetworkError(error: Error, currentInfo: LicenseInfo) -> LicenseInfo {
        Logger.error("License validation failed with network/system error", error: error, category: Logger.app)

        // Check if this is a trial license
        let isTrial = if case .trial = currentInfo.licenseStatus {
            true
        } else {
            false
        }

        if isTrial {
            return handleTrialNetworkError(currentInfo: currentInfo)
        }
        // For purchased licenses: no grace period, no expiration
        // If we can't validate, keep the license active indefinitely
        Logger.warning(
            "Purchased license validation failed but license is perpetual, keeping active",
            category: Logger.app
        )
        return currentInfo
    }

    private func handleTrialNetworkError(currentInfo: LicenseInfo) -> LicenseInfo {
        // For trials: apply grace period with local expiration fallback
        guard
            let lastValidation = userDefaults.object(forKey: UserDefaultsKeys.lastValidationDate) as? Date,
            Date().timeIntervalSince(lastValidation) < Self.trialValidationGracePeriodSeconds
        else {
            // Outside grace period - mark as expired
            Logger.warning(
                "Trial validation failed and outside grace period, marking as expired",
                category: Logger.app
            )
            return createExpiredLicenseInfo(from: currentInfo)
        }

        // Within grace period - check local expiration as fallback
        guard
            let trialActivationDate = userDefaults
                .object(forKey: UserDefaultsKeys.trialActivationDate) as? Date
        else {
            // No activation date stored - treat as expired for safety
            Logger.warning("No trial activation date found, marking as expired", category: Logger.app)
            return createExpiredLicenseInfo(from: currentInfo)
        }

        if isTrialExpiredLocally(activationDate: trialActivationDate) {
            // Trial has expired locally even though we're within grace period
            Logger.warning(
                "Trial expired locally (14 days passed), marking as expired",
                category: Logger.app
            )
            return createExpiredLicenseInfo(from: currentInfo)
        }

        // Within grace period and not locally expired - stay active
        Logger.warning(
            "Network validation failed but within grace period and trial not locally expired, staying active",
            category: Logger.app
        )
        return currentInfo
    }

    private func createExpiredLicenseInfo(from currentInfo: LicenseInfo) -> LicenseInfo {
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

    public func activateLicense(_ licenseKey: String) async throws -> LicenseInfo {
        do {
            // Activate license using LemonSqueezy SDK with our instance name
            let result: ActivateLicense = try await lemonSqueezy.activateLicense(
                licenseKey: licenseKey,
                instanceName: Self.instanceName
            )

            // Check if this is a trial variant
            let isTrial = isTrialVariant(result.meta.variantId)

            #if DEBUG
                Logger.debug("Trial variant detected: \(isTrial)", category: Logger.app)
            #endif

            // Prevent trial abuse: check if trial was already used on this device
            if isTrial, hasTrialBeenUsed() {
                Logger.warning("Trial activation blocked: trial already used on this device", category: Logger.app)
                throw LicenseError.trialAlreadyUsed
            }

            // Store the instance ID returned by LemonSqueezy for future validation/deactivation
            userDefaults.set(result.instance.id, forKey: UserDefaultsKeys.instanceId)
            userDefaults.set(Date(), forKey: UserDefaultsKeys.lastValidationDate)

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

            // Mark trial as used if this is a trial license
            if isTrial {
                markTrialAsUsed()
                // Store trial activation date for local expiration validation during grace period
                userDefaults.set(Date(), forKey: UserDefaultsKeys.trialActivationDate)
                Logger.debug("Trial activation date stored for local expiration validation", category: Logger.app)
            }

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
            let instanceId = userDefaults.string(forKey: UserDefaultsKeys.instanceId)
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
        userDefaults.removeObject(forKey: UserDefaultsKeys.licenseInfo)
        userDefaults.removeObject(forKey: UserDefaultsKeys.lastValidationDate)
        userDefaults.removeObject(forKey: UserDefaultsKeys.instanceId)
        userDefaults.removeObject(forKey: UserDefaultsKeys.trialActivationDate)

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
            let urlString = Self.productionCheckoutUrl
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
            let urlString = Self.productionTrialCheckoutUrl
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
