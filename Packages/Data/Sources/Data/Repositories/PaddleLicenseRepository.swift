// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Foundation

/// Repository implementation for Paddle license.
@MainActor
public final class PaddleLicenseRepository: LicenseGateway {
    // MARK: - Configuration

    /// Your Paddle vendor ID - replace with your actual vendor ID
    private let paddleVendorId = "39320"

    /// Your Paddle product ID - replace with your actual product ID
    private let paddleProductId = "pro_01k73s3x146tc2w30a2qr78y10"

    /// Paddle environment (sandbox or production)
    private let paddleEnvironment = "sandbox" // Change to "production" for live

    /// Trial duration in days
    private let trialDurationDays = 14

    /// Mock license key for development testing
    private let mockLicenseKey = "MOCKED-LICENSE"

    // MARK: - Private Properties

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
    #endif

    private var cancellables = Set<AnyCancellable>()

    // MARK: - UserDefaults Key

    private enum UserDefaultsKeys {
        static let licenseInfo = "license_info"
        static let trialStartDate = "trial_start_date"
        static let lastValidationDate = "last_license_validation"
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
    #endif

    // MARK: - Initialization

    public init() {
        initializeLicenseInfo()
        startPeriodicValidation()
        setupFeatureFlagObservation()
    }

    // MARK: - Private Methods

    /// Initializes the license info based on stored data.
    private func initializeLicenseInfo() {
        // Load from UserDefaults first to get any saved user data
        var savedUserName = ""
        var savedProfileImageData: Data?

        if
            let data = UserDefaults.standard.data(forKey: UserDefaultsKeys.licenseInfo),
            let savedInfo = try? JSONDecoder().decode(LicenseInfo.self, from: data)
        {
            savedUserName = savedInfo.userName
            savedProfileImageData = savedInfo.profileImageData
        }

        #if DEBUG
            // Check for mock license first
            if mockActiveLicenseSubject.value {
                let mockInfo = LicenseInfo(
                    licenseKey: mockLicenseKey,
                    licenseStatus: .licensed,
                    userName: savedUserName,
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

                // Validate if licensed
                if case .licensed = savedInfo.licenseStatus {
                    Task {
                        let validatedInfo = await validateLicense()
                        licenseInfoSubject.send(validatedInfo)
                    }
                }
            } else if
                let trialStartDate = UserDefaults.standard
                    .object(forKey: UserDefaultsKeys.trialStartDate) as? Date
            {
                // Check trial status
                let daysElapsed = Calendar.current.dateComponents([.day], from: trialStartDate, to: Date()).day ?? 0
                let daysRemaining = max(0, trialDurationDays - daysElapsed)

                let status: LicenseStatus = daysRemaining > 0 ? .trial(daysRemaining: daysRemaining) : .expired
                let trialInfo = LicenseInfo(
                    licenseKey: "",
                    licenseStatus: status,
                    userName: savedInfo.userName,
                    profileImageData: savedInfo.profileImageData
                )
                licenseInfoSubject.send(trialInfo)
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
                profileImageData: savedProfileImageData
            )
            licenseInfoSubject.send(defaultInfo)
            saveLicenseInfo(defaultInfo)
        }
    }

    /// Starts periodic license validation.
    private func startPeriodicValidation() {
        Timer.publish(every: 3_600, on: .main, in: .common) // Validate every hour
            .autoconnect()
            .sink { [weak self] _ in
                Task { [weak self] in
                    guard let self else { return }

                    let currentInfo = licenseInfoSubject.value
                    if case .licensed = currentInfo.licenseStatus {
                        let validatedInfo = await validateLicense()
                        licenseInfoSubject.send(validatedInfo)
                    }
                }
            }
            .store(in: &cancellables)
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
                            licenseKey: mockLicenseKey,
                            licenseStatus: .licensed,
                            userName: licenseInfoSubject.value.userName,
                            profileImageData: licenseInfoSubject.value.profileImageData
                        )
                        licenseInfoSubject.send(mockInfo)
                        saveLicenseInfo(mockInfo)
                    } else {
                        // Mock license is disabled
                        let currentInfo = licenseInfoSubject.value
                        if currentInfo.licenseKey == mockLicenseKey {
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
    #endif

    public func resetLicenseFeatureFlags() {
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

        do {
            // Create URL for Paddle license verification
            guard let url = URL(string: "https://vendors.paddle.com/api/2.0/product/validate_license") else {
                throw LicenseError.networkError(NSError(domain: "InvalidURL", code: 0))
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

            let bodyString = "vendor_id=\(paddleVendorId)&product_id=\(paddleProductId)" +
                "&license_code=\(currentInfo.licenseKey)"
            request.httpBody = bodyString.data(using: .utf8)

            let (data, response) = try await URLSession.shared.data(for: request)

            guard
                let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200
            else {
                throw LicenseError.networkError(NSError(domain: "HTTPError", code: 0))
            }

            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

            if let success = json?["success"] as? Bool, success {
                UserDefaults.standard.set(Date(), forKey: UserDefaultsKeys.lastValidationDate)

                let validatedInfo = LicenseInfo(
                    licenseKey: currentInfo.licenseKey,
                    licenseStatus: .licensed,
                    userName: currentInfo.userName,
                    profileImageData: currentInfo.profileImageData
                )

                saveLicenseInfo(validatedInfo)
                return validatedInfo
            } else {
                // License is invalid
                deactivateLicense()
                return licenseInfoSubject.value
            }

        } catch {
            Logger.error("License validation failed", error: error, category: Logger.app)

            // If we can't validate but have a recent successful validation, stay licensed
            if
                let lastValidation = UserDefaults.standard.object(forKey: UserDefaultsKeys.lastValidationDate) as? Date,
                Date().timeIntervalSince(lastValidation) < 7 * 24 * 3_600
            { // 7 days grace period
                return currentInfo
            }

            let expiredInfo = LicenseInfo(
                licenseKey: currentInfo.licenseKey,
                licenseStatus: .expired,
                userName: currentInfo.userName,
                profileImageData: currentInfo.profileImageData
            )

            saveLicenseInfo(expiredInfo)
            return expiredInfo
        }
    }

    public func activateLicense(_ licenseKey: String) async throws -> LicenseInfo {
        do {
            // Create URL for Paddle license activation
            guard let url = URL(string: "https://vendors.paddle.com/api/2.0/product/validate_license") else {
                throw LicenseError.networkError(NSError(domain: "InvalidURL", code: 0))
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

            let bodyString = "vendor_id=\(paddleVendorId)&product_id=\(paddleProductId)" +
                "&license_code=\(licenseKey)"
            request.httpBody = bodyString.data(using: .utf8)

            let (data, response) = try await URLSession.shared.data(for: request)

            guard
                let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200
            else {
                throw LicenseError.networkError(NSError(domain: "HTTPError", code: 0))
            }

            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

            if let success = json?["success"] as? Bool, success {
                UserDefaults.standard.set(Date(), forKey: UserDefaultsKeys.lastValidationDate)

                let currentInfo = licenseInfoSubject.value
                let activatedInfo = LicenseInfo(
                    licenseKey: licenseKey,
                    licenseStatus: .licensed,
                    userName: currentInfo.userName,
                    profileImageData: currentInfo.profileImageData
                )

                licenseInfoSubject.send(activatedInfo)
                saveLicenseInfo(activatedInfo)

                return activatedInfo
            } else {
                throw LicenseError.invalidLicenseKey
            }

        } catch {
            throw LicenseError.networkError(error)
        }
    }

    public func deactivateLicense() {
        let currentInfo = licenseInfoSubject.value

        #if DEBUG
            // If deactivating a mock license, turn off the mock flag
            if currentInfo.licenseKey == mockLicenseKey {
                mockActiveLicenseSubject.send(false)
            }
        #endif

        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.licenseInfo)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.trialStartDate)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.lastValidationDate)

        // Preserve user data when deactivating
        let clearedInfo = LicenseInfo(
            licenseKey: "",
            licenseStatus: .unknown,
            userName: currentInfo.userName,
            profileImageData: currentInfo.profileImageData
        )
        licenseInfoSubject.send(clearedInfo)
        saveLicenseInfo(clearedInfo)
    }

    public func startTrial() {
        UserDefaults.standard.set(Date(), forKey: UserDefaultsKeys.trialStartDate)

        let currentInfo = licenseInfoSubject.value
        let trialInfo = LicenseInfo(
            licenseKey: currentInfo.licenseKey,
            licenseStatus: .trial(daysRemaining: trialDurationDays),
            userName: currentInfo.userName,
            profileImageData: currentInfo.profileImageData
        )

        licenseInfoSubject.send(trialInfo)
        saveLicenseInfo(trialInfo)
    }

    // MARK: - Profile Management

    public func setUserName(_ userName: String) {
        let currentInfo = licenseInfoSubject.value
        let updatedInfo = LicenseInfo(
            licenseKey: currentInfo.licenseKey,
            licenseStatus: currentInfo.licenseStatus,
            userName: userName,
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
            profileImageData: profileImageData
        )

        licenseInfoSubject.send(updatedInfo)
        saveLicenseInfo(updatedInfo)
    }

    // MARK: - Checkout URL Generation

    /// Creates the Paddle checkout URL for the presentation layer to use
    public func createCheckoutURL() -> URL {
        guard var components = URLComponents(string: "https://checkout.paddle.com/checkout") else {
            fatalError("Invalid Paddle checkout URL")
        }

        components.queryItems = [
            URLQueryItem(name: "vendor", value: paddleVendorId),
            URLQueryItem(name: "product", value: paddleProductId),
            URLQueryItem(name: "title", value: "AeroSpaceBar License"),
            URLQueryItem(name: "webhook", value: ""), // Add your webhook URL if needed
            URLQueryItem(name: "passthrough", value: createPassthroughData()),
            URLQueryItem(name: "success", value: "aerospacebarlicense://success"),
            URLQueryItem(name: "cancel", value: "aerospacebarlicense://cancel")
        ]

        guard let url = components.url else {
            fatalError("Failed to create Paddle checkout URL")
        }

        return url
    }

    private func createPassthroughData() -> String {
        let passthrough = [
            "user_id": UUID().uuidString,
            "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        ]

        guard
            let data = try? JSONSerialization.data(withJSONObject: passthrough),
            let jsonString = String(data: data, encoding: .utf8)
        else {
            return ""
        }

        return jsonString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
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
