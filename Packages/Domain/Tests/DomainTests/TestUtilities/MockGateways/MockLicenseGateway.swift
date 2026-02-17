// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Foundation

/// Mock implementation of LicenseGateway for testing.
///
/// This mock allows tests to control license behavior and verify interactions
/// without requiring actual LemonSqueezy API calls.
@MainActor
public final class MockLicenseGateway: LicenseGateway {
    // MARK: - Configurable Test Data

    /// License info to be emitted by the publisher
    public var licenseInfoToEmit: LicenseInfo = .init() {
        didSet {
            licenseInfoSubject.send(licenseInfoToEmit)
        }
    }

    /// Whether licensing is enabled
    public var isLicensingEnabled: Bool = true {
        didSet {
            enableLicensingSubject.send(isLicensingEnabled)
        }
    }

    /// Whether trial requests are enabled
    public var isTrialRequestEnabled: Bool = true {
        didSet {
            enableTrialRequestSubject.send(isTrialRequestEnabled)
        }
    }

    #if DEBUG
        /// Whether mock active license is enabled (DEBUG only)
        public var isMockActiveLicenseEnabled: Bool = false {
            didSet {
                mockActiveLicenseSubject.send(isMockActiveLicenseEnabled)
            }
        }

        /// Current checkout environment (DEBUG only)
        public var checkoutEnvironment: CheckoutEnvironment = .production {
            didSet {
                checkoutEnvironmentSubject.send(checkoutEnvironment)
            }
        }
    #endif

    /// Whether trial has been used on this device
    public var trialHasBeenUsed: Bool = false

    /// Current user name (convenience accessor to licenseInfo.userName)
    public var userName: String? {
        get { licenseInfoToEmit.userName }
        set {
            licenseInfoToEmit = LicenseInfo(
                licenseKey: licenseInfoToEmit.licenseKey,
                licenseStatus: licenseInfoToEmit.licenseStatus,
                userName: newValue ?? "",
                email: licenseInfoToEmit.email,
                profileImageData: licenseInfoToEmit.profileImageData
            )
        }
    }

    /// Current profile image data (convenience accessor to licenseInfo.profileImageData)
    public var profileImageData: Data? {
        get { licenseInfoToEmit.profileImageData }
        set {
            licenseInfoToEmit = LicenseInfo(
                licenseKey: licenseInfoToEmit.licenseKey,
                licenseStatus: licenseInfoToEmit.licenseStatus,
                userName: licenseInfoToEmit.userName,
                email: licenseInfoToEmit.email,
                profileImageData: newValue
            )
        }
    }

    /// Errors to throw for specific operations
    public var activateLicenseError: Error?
    public var deactivateLicenseError: Error?

    /// License info to return from activation
    public var activationResult: LicenseInfo?

    /// Alias for isLicensingEnabled (for test compatibility)
    public var isLicensingEnabledToEmit: Bool {
        get { isLicensingEnabled }
        set { isLicensingEnabled = newValue }
    }

    #if DEBUG
        /// Alias for isMockActiveLicenseEnabled (for test compatibility)
        public var mockActiveLicenseToEmit: Bool {
            get { isMockActiveLicenseEnabled }
            set { isMockActiveLicenseEnabled = newValue }
        }

        /// Alias for checkoutEnvironment (for test compatibility)
        public var checkoutEnvironmentToEmit: CheckoutEnvironment {
            get { checkoutEnvironment }
            set { checkoutEnvironment = newValue }
        }
    #endif

    /// URL to return from checkout requests (for test compatibility)
    public var checkoutURLToReturn: URL?

    /// Trial checkout URL to return from checkout requests (for test compatibility)
    public var trialCheckoutURLToReturn: URL?

    /// Alias for trialHasBeenUsed (for test compatibility)
    public var hasTrialBeenUsedToReturn: Bool {
        get { trialHasBeenUsed }
        set { trialHasBeenUsed = newValue }
    }

    // MARK: - Call Tracking

    /// Tracks calls to activateLicense with their parameters
    public private(set) var activateLicenseCalls: [String] = []

    /// Tracks calls to deactivateLicense
    public private(set) var deactivateLicenseCallCount: Int = 0

    /// Tracks calls to handleCheckoutSuccess with their parameters
    public private(set) var checkoutSuccessCalls: [String] = []

    /// Tracks calls to setEnableLicensing with their parameters
    public private(set) var setEnableLicensingCalls: [Bool] = []

    /// Tracks calls to setEnableTrialRequest with their parameters
    public private(set) var setEnableTrialRequestCalls: [Bool] = []

    #if DEBUG
        /// Tracks calls to setMockActiveLicense with their parameters
        public private(set) var setMockActiveLicenseCalls: [Bool] = []

        /// Tracks calls to setCheckoutEnvironment with their parameters
        public private(set) var setCheckoutEnvironmentCalls: [CheckoutEnvironment] = []
    #endif

    /// Tracks calls to resetLicenseFeatureFlags
    public private(set) var resetLicenseFeatureFlagsCallCount: Int = 0

    /// Alias for resetLicenseFeatureFlagsCallCount (for test compatibility)
    public var resetLicenseFeatureFlagsCalls: Int {
        resetLicenseFeatureFlagsCallCount
    }

    /// Tracks calls to setUserName with their parameters
    public private(set) var setUserNameCalls: [String] = []

    /// Tracks calls to setProfileImageData with their parameters
    public private(set) var setProfileImageDataCalls: [Data?] = []

    /// Tracks calls to hasTrialBeenUsed
    public private(set) var hasTrialBeenUsedCalls: Int = 0

    /// Tracks calls to getCheckoutURL
    public private(set) var getCheckoutURLCalls: Int = 0

    /// Tracks calls to getTrialCheckoutURL
    public private(set) var getTrialCheckoutURLCalls: Int = 0

    // MARK: - Publishers

    private let licenseInfoSubject: CurrentValueSubject<LicenseInfo, Never>
    private let enableLicensingSubject: CurrentValueSubject<Bool, Never>
    private let enableTrialRequestSubject: CurrentValueSubject<Bool, Never>

    #if DEBUG
        private let mockActiveLicenseSubject: CurrentValueSubject<Bool, Never>
        private let checkoutEnvironmentSubject: CurrentValueSubject<CheckoutEnvironment, Never>
    #endif

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

    public init(
        licenseInfo: LicenseInfo = .init(),
        isLicensingEnabled: Bool = true,
        isTrialRequestEnabled: Bool = true
    ) {
        licenseInfoToEmit = licenseInfo
        self.isLicensingEnabled = isLicensingEnabled
        self.isTrialRequestEnabled = isTrialRequestEnabled

        licenseInfoSubject = CurrentValueSubject(licenseInfo)
        enableLicensingSubject = CurrentValueSubject(isLicensingEnabled)
        enableTrialRequestSubject = CurrentValueSubject(isTrialRequestEnabled)

        #if DEBUG
            mockActiveLicenseSubject = CurrentValueSubject(isMockActiveLicenseEnabled)
            checkoutEnvironmentSubject = CurrentValueSubject(checkoutEnvironment)
        #endif
    }

    // MARK: - Gateway Methods

    public func activateLicense(_ licenseKey: String) async throws -> LicenseInfo {
        await Task.yield() // Make truly async
        activateLicenseCalls.append(licenseKey)

        // Validate license key is not empty (matches real implementation behavior)
        if licenseKey.isEmpty {
            throw LicenseError.invalidLicenseKey
        }

        if let error = activateLicenseError {
            throw error
        }

        // If activationResult is set, use it; otherwise create a LicenseInfo with the provided key
        let result = activationResult ?? LicenseInfo(
            licenseKey: licenseKey,
            licenseStatus: .licensed,
            userName: licenseInfoToEmit.userName,
            email: licenseInfoToEmit.email,
            profileImageData: licenseInfoToEmit.profileImageData
        )
        licenseInfoToEmit = result
        licenseInfoSubject.send(result)
        return result
    }

    public func deactivateLicense() async throws {
        await Task.yield() // Make truly async
        deactivateLicenseCallCount += 1

        if let error = deactivateLicenseError {
            throw error
        }

        // Clear license info
        let clearedInfo = LicenseInfo(
            licenseKey: "",
            licenseStatus: .unknown,
            userName: licenseInfoSubject.value.userName,
            email: licenseInfoSubject.value.email,
            profileImageData: licenseInfoSubject.value.profileImageData
        )
        licenseInfoToEmit = clearedInfo
        licenseInfoSubject.send(clearedInfo)
    }

    public func getCheckoutURL() -> URL {
        getCheckoutURLCalls += 1
        if let url = checkoutURLToReturn {
            return url
        }
        guard let url = URL(string: "https://test.lemonsqueezy.com/checkout/purchase") else {
            fatalError("Invalid checkout URL")
        }

        return url
    }

    public func getTrialCheckoutURL() -> URL {
        getTrialCheckoutURLCalls += 1
        if let url = trialCheckoutURLToReturn {
            return url
        }
        guard let url = URL(string: "https://test.lemonsqueezy.com/checkout/trial") else {
            fatalError("Invalid trial checkout URL")
        }

        return url
    }

    public func handleCheckoutSuccess(licenseKey: String) async {
        await Task.yield() // Make truly async
        checkoutSuccessCalls.append(licenseKey)
        // In real implementation, this would call activateLicense
        _ = try? await activateLicense(licenseKey)
    }

    public func setEnableLicensing(_ enabled: Bool) {
        setEnableLicensingCalls.append(enabled)
        isLicensingEnabled = enabled
    }

    public func setEnableTrialRequest(_ enabled: Bool) {
        setEnableTrialRequestCalls.append(enabled)
        isTrialRequestEnabled = enabled
    }

    #if DEBUG
        public func setMockActiveLicense(_ enabled: Bool) {
            setMockActiveLicenseCalls.append(enabled)
            isMockActiveLicenseEnabled = enabled
        }

        public func setCheckoutEnvironment(_ environment: CheckoutEnvironment) {
            setCheckoutEnvironmentCalls.append(environment)
            checkoutEnvironment = environment
        }
    #endif

    public func resetLicenseFeatureFlags() async {
        await Task.yield() // Make truly async
        resetLicenseFeatureFlagsCallCount += 1

        // Reset all license feature flags to defaults (false)
        setEnableLicensing(false)
        setEnableTrialRequest(false)

        // Reset license info to empty/default state
        let clearedInfo = LicenseInfo(
            licenseKey: "",
            licenseStatus: .unknown,
            userName: "",
            email: "",
            profileImageData: nil
        )
        licenseInfoToEmit = clearedInfo
        licenseInfoSubject.send(clearedInfo)

        // Reset trial status
        trialHasBeenUsed = false

        #if DEBUG
            setMockActiveLicense(false)
            setCheckoutEnvironment(.production)
        #endif
    }

    public func setUserName(_ userName: String) async {
        await Task.yield() // Make truly async
        setUserNameCalls.append(userName)
        let updatedInfo = LicenseInfo(
            licenseKey: licenseInfoSubject.value.licenseKey,
            licenseStatus: licenseInfoSubject.value.licenseStatus,
            userName: userName,
            email: licenseInfoSubject.value.email,
            profileImageData: licenseInfoSubject.value.profileImageData
        )
        licenseInfoToEmit = updatedInfo
        licenseInfoSubject.send(updatedInfo)
    }

    public func setProfileImageData(_ profileImageData: Data?) async {
        await Task.yield() // Make truly async
        setProfileImageDataCalls.append(profileImageData)
        let updatedInfo = LicenseInfo(
            licenseKey: licenseInfoSubject.value.licenseKey,
            licenseStatus: licenseInfoSubject.value.licenseStatus,
            userName: licenseInfoSubject.value.userName,
            email: licenseInfoSubject.value.email,
            profileImageData: profileImageData
        )
        licenseInfoToEmit = updatedInfo
        licenseInfoSubject.send(updatedInfo)
    }

    public func hasTrialBeenUsed() -> Bool {
        hasTrialBeenUsedCalls += 1
        return trialHasBeenUsed
    }

    // MARK: - Test Helper Methods

    /// Emits license info through the publisher
    public func emitLicenseInfo(_ info: LicenseInfo) {
        licenseInfoToEmit = info
        licenseInfoSubject.send(info)
    }

    /// Resets all tracked calls
    public func reset() {
        activateLicenseCalls.removeAll()
        deactivateLicenseCallCount = 0
        checkoutSuccessCalls.removeAll()
        setEnableLicensingCalls.removeAll()
        setEnableTrialRequestCalls.removeAll()
        resetLicenseFeatureFlagsCallCount = 0
        setUserNameCalls.removeAll()
        setProfileImageDataCalls.removeAll()
        hasTrialBeenUsedCalls = 0
        getCheckoutURLCalls = 0
        getTrialCheckoutURLCalls = 0
        activateLicenseError = nil
        deactivateLicenseError = nil
        activationResult = nil

        #if DEBUG
            setMockActiveLicenseCalls.removeAll()
            setCheckoutEnvironmentCalls.removeAll()
        #endif
    }
}
