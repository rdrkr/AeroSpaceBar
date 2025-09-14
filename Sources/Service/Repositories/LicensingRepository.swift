// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Foundation
import os

/// Repository implementation for Paddle licensing.
@MainActor
public final class LicensingRepository: @MainActor LicensingGateway, @unchecked Sendable {
    // MARK: - Configuration

    /// Your Paddle vendor ID - replace with your actual vendor ID
    private let paddleVendorId = "YOUR_PADDLE_VENDOR_ID"

    /// Your Paddle product ID - replace with your actual product ID
    private let paddleProductId = "YOUR_PADDLE_PRODUCT_ID"

    /// Paddle environment (sandbox or production)
    private let paddleEnvironment = "sandbox" // Change to "production" for live

    /// Trial duration in days
    private let trialDurationDays = 14

    // MARK: - Private Properties

    private let licenseStatusSubject = CurrentValueSubject<LicenseStatus, Never>(.unknown)
    private var cancellables = Set<AnyCancellable>()

    #if DEBUG
        private let featureFlagsGateway: FeatureFlagsGateway?
    #endif

    // MARK: - UserDefaults Keys

    private enum UserDefaultsKeys {
        static let licenseKey = "paddle_license_key"
        static let customerEmail = "paddle_customer_email"
        static let trialStartDate = "trial_start_date"
        static let licenseActivatedDate = "license_activated_date"
        static let lastValidationDate = "last_license_validation"
    }

    // MARK: - Public Properties

    public var licenseStatusPublisher: AnyPublisher<LicenseStatus, Never> {
        licenseStatusSubject.eraseToAnyPublisher()
    }

    public var currentLicenseStatus: LicenseStatus {
        licenseStatusSubject.value
    }

    // MARK: - Initialization

    #if DEBUG
        public init(featureFlagsGateway: FeatureFlagsGateway? = nil) {
            self.featureFlagsGateway = featureFlagsGateway
            initializeLicenseStatus()
            startPeriodicValidation()
            setupFeatureFlagObservation()
        }
    #else
        public init() {
            initializeLicenseStatus()
            startPeriodicValidation()
        }
    #endif

    // MARK: - Private Methods

    /// Initializes the license status based on stored data.
    private func initializeLicenseStatus() {
        #if DEBUG
            // Check for mock license first
            if let featureFlagsGateway {
                let flags = featureFlagsGateway.currentFeatureFlags
                if flags.mockActiveLicense {
                    licenseStatusSubject.send(.licensed)
                    return
                }
            }
        #endif

        if
            let licenseKey = UserDefaults.standard.string(forKey: UserDefaultsKeys.licenseKey),
            !licenseKey.isEmpty
        {
            // We have a license key, validate it
            licenseStatusSubject.send(.validating)
            Task {
                let status = await validateLicense()
                licenseStatusSubject.send(status)
            }
        } else if let trialStartDate = UserDefaults.standard.object(forKey: UserDefaultsKeys.trialStartDate) as? Date {
            // Check trial status
            let daysElapsed = Calendar.current.dateComponents([.day], from: trialStartDate, to: Date()).day ?? 0
            let daysRemaining = max(0, trialDurationDays - daysElapsed)

            if daysRemaining > 0 {
                licenseStatusSubject.send(.trial(daysRemaining: daysRemaining))
            } else {
                licenseStatusSubject.send(.expired)
            }
        } else {
            // First launch
            licenseStatusSubject.send(.unknown)
        }
    }

    /// Starts periodic license validation.
    private func startPeriodicValidation() {
        Timer.publish(every: 3_600, on: .main, in: .common) // Validate every hour
            .autoconnect()
            .sink { [weak self] _ in
                Task { [weak self] in
                    guard let self else { return }

                    if case .licensed = currentLicenseStatus {
                        let status = await validateLicense()
                        licenseStatusSubject.send(status)
                    }
                }
            }
            .store(in: &cancellables)
    }

    #if DEBUG
        /// Sets up observation of feature flag changes for mock license functionality.
        private func setupFeatureFlagObservation() {
            guard let featureFlagsGateway else { return }

            featureFlagsGateway.featureFlags
                .receive(on: DispatchQueue.main)
                .sink { [weak self] (flags: FeatureFlags) in
                    guard let self else { return }

                    if flags.mockActiveLicense {
                        // Mock license is enabled, set status to licensed
                        licenseStatusSubject.send(.licensed)
                    } else {
                        // Mock license is disabled, reinitialize status
                        initializeLicenseStatus()
                    }
                }
                .store(in: &cancellables)
        }
    #endif

    // MARK: - Public Methods

    public func validateLicense() async -> LicenseStatus {
        #if DEBUG
            // Check for mock license first
            if let featureFlagsGateway {
                let flags = featureFlagsGateway.currentFeatureFlags
                if flags.mockActiveLicense {
                    return .licensed
                }
            }
        #endif

        guard
            let licenseKey = UserDefaults.standard.string(forKey: UserDefaultsKeys.licenseKey),
            !licenseKey.isEmpty
        else {
            return await MainActor.run { currentLicenseStatus }
        }

        do {
            // Create URL for Paddle license verification
            guard let url = URL(string: "https://vendors.paddle.com/api/2.0/product/validate_license") else {
                throw LicenseError.networkError(NSError(domain: "InvalidURL", code: 0))
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

            let bodyString = "vendor_id=\(paddleVendorId)&product_id=\(paddleProductId)&license_code=\(licenseKey)"
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
                return .licensed
            } else {
                // License is invalid
                await deactivateLicense()
                return .expired
            }

        } catch {
            Logger.error("License validation failed", error: error, category: .default)

            // If we can't validate but have a recent successful validation, stay licensed
            if
                let lastValidation = UserDefaults.standard.object(forKey: UserDefaultsKeys.lastValidationDate) as? Date,
                Date().timeIntervalSince(lastValidation) < 7 * 24 * 3_600
            { // 7 days grace period
                return .licensed
            }

            return .expired
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

            let bodyString = "vendor_id=\(paddleVendorId)&product_id=\(paddleProductId)&license_code=\(licenseKey)"
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
                // Store license information
                UserDefaults.standard.set(licenseKey, forKey: UserDefaultsKeys.licenseKey)
                UserDefaults.standard.set(Date(), forKey: UserDefaultsKeys.licenseActivatedDate)
                UserDefaults.standard.set(Date(), forKey: UserDefaultsKeys.lastValidationDate)

                // Extract customer email if available
                let customerEmail = json?["customer_email"] as? String ?? ""
                UserDefaults.standard.set(customerEmail, forKey: UserDefaultsKeys.customerEmail)

                let licenseInfo = LicenseInfo(
                    licenseKey: licenseKey,
                    customerEmail: customerEmail,
                    isActive: true,
                    productId: paddleProductId
                )

                await MainActor.run {
                    licenseStatusSubject.send(.licensed)
                }

                return licenseInfo
            } else {
                throw LicenseError.invalidLicenseKey
            }

        } catch {
            throw LicenseError.networkError(error)
        }
    }

    public func deactivateLicense() async {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.licenseKey)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.customerEmail)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.licenseActivatedDate)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.lastValidationDate)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.trialStartDate)

        // Clear profile data when license is deactivated
        UserDefaults.standard.removeObject(forKey: Domain.UserDefaultsKeys.profileUserName.rawValue)
        UserDefaults.standard.removeObject(forKey: Domain.UserDefaultsKeys.profileImageData.rawValue)

        // Reset to unknown state (no trial, no license)
        await MainActor.run {
            licenseStatusSubject.send(.unknown)
        }
    }

    public func getTrialDaysRemaining() -> Int? {
        guard let trialStartDate = UserDefaults.standard.object(forKey: UserDefaultsKeys.trialStartDate) as? Date else {
            return nil
        }

        let daysElapsed = Calendar.current.dateComponents([.day], from: trialStartDate, to: Date()).day ?? 0
        let daysRemaining = max(0, trialDurationDays - daysElapsed)
        return daysRemaining > 0 ? daysRemaining : nil
    }

    public func startTrial() {
        UserDefaults.standard.set(Date(), forKey: UserDefaultsKeys.trialStartDate)
        Task { @MainActor in
            licenseStatusSubject.send(.trial(daysRemaining: trialDurationDays))
        }
    }

    public func shouldShowLicensingPrompt() -> Bool {
        switch currentLicenseStatus {
        case .licensed:
            false
        case let .trial(daysRemaining):
            daysRemaining <= 3 // Show prompt in last 3 days
        case .expired,
             .unknown:
            true
        case .validating:
            false
        @unknown default:
            true
        }
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
            Logger.info("License activated successfully: \(licenseInfo.licenseKey)", category: .default)
        } catch {
            Logger.error("Failed to activate license after purchase", error: error, category: .default)
        }
    }
}
