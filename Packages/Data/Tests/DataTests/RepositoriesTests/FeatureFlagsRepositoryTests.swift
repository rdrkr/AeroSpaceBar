// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
@testable import Data
@testable import Domain
import Nimble
import XCTest

/// Tests for FeatureFlagsRepository.
///
/// These tests verify license-aware feature flag management including:
/// - Initialization with reactive setup
/// - Feature flag publishers and updates
/// - License-aware behavior (disabling flags when no active license)
/// - Integration with GetLicenseInfoUseCase and GetEnableLicensingUseCase
@MainActor
final class FeatureFlagsRepositoryTests: XCTestCase {
    private var repository: FeatureFlagsRepository?
    private var mockLicenseGateway: MockLicenseGateway?
    private var cancellables = Set<AnyCancellable>()

    override func setUp() async throws {
        try await super.setUp()
        cancellables = []

        // Create mock license gateway
        let mockGateway = MockLicenseGateway(
            licenseInfo: LicenseInfo(
                licenseStatus: .unknown,
                userName: "",
                email: ""
            ),
            enableLicensing: true
        )

        // Create real use case instances with mock gateway
        let licenseUseCase = GetLicenseInfoUseCase(licenseGateway: mockGateway)
        mockLicenseGateway = mockGateway

        let licensingUseCase = GetEnableLicensingUseCase(gateway: mockGateway)

        repository = FeatureFlagsRepository(
            getLicenseInfoUseCase: licenseUseCase,
            getEnableLicensingUseCase: licensingUseCase
        )
    }

    override func tearDown() async throws {
        cancellables.removeAll()
        repository = nil
        mockLicenseGateway = nil
        try await super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitializationWithNoLicense() async {
        // Given repository initialized with no license (in setUp)
        // When accessing feature flags
        var receivedFlags: FeatureFlags?

        repository?.featureFlagsPublisher
            .sink { flags in
                receivedFlags = flags
            }
            .store(in: &cancellables)

        // Allow time for initial value
        try? await Task.sleep(for: .milliseconds(100))

        // Then should have all required-license flags disabled, but software updates remain enabled
        expect(receivedFlags).toNot(beNil())
        expect(receivedFlags?.enableGroups) == false
        expect(receivedFlags?.enableSpaces) == false
        expect(receivedFlags?.enableAdvancedSettings) == false
        expect(receivedFlags?.enableSoftwareUpdates) == true
    }

    func testInitializationWithActiveLicense() async {
        // Given active license
        let activeLicenseInfo = LicenseInfo(
            licenseKey: "test-key",
            licenseStatus: .licensed,
            userName: "Test User",
            email: "test@example.com"
        )

        let mockGateway = MockLicenseGateway(
            licenseInfo: activeLicenseInfo,
            enableLicensing: true
        )

        let licenseUseCase = GetLicenseInfoUseCase(licenseGateway: mockGateway)
        let licensingUseCase = GetEnableLicensingUseCase(gateway: mockGateway)

        // When initializing repository
        repository = FeatureFlagsRepository(
            getLicenseInfoUseCase: licenseUseCase,
            getEnableLicensingUseCase: licensingUseCase
        )

        var receivedFlags: FeatureFlags?

        repository?.featureFlagsPublisher
            .sink { flags in
                receivedFlags = flags
            }
            .store(in: &cancellables)

        // Allow time for initial value
        try? await Task.sleep(for: .milliseconds(100))

        // Then should have default flags (all enabled)
        expect(receivedFlags?.enableGroups) == true
        expect(receivedFlags?.enableSpaces) == true
    }

    func testInitializationWithLicensingDisabled() async {
        // Given licensing disabled
        let mockGateway = MockLicenseGateway(
            licenseInfo: LicenseInfo(
                licenseStatus: .unknown,
                userName: "",
                email: ""
            ),
            enableLicensing: false
        )

        let licenseUseCase = GetLicenseInfoUseCase(licenseGateway: mockGateway)
        let licensingUseCase = GetEnableLicensingUseCase(gateway: mockGateway)

        // When initializing repository
        repository = FeatureFlagsRepository(
            getLicenseInfoUseCase: licenseUseCase,
            getEnableLicensingUseCase: licensingUseCase
        )

        var receivedFlags: FeatureFlags?

        repository?.featureFlagsPublisher
            .sink { flags in
                receivedFlags = flags
            }
            .store(in: &cancellables)

        // Allow time for initial value
        try? await Task.sleep(for: .milliseconds(100))

        // Then should have all flags enabled (licensing check bypassed)
        expect(receivedFlags?.enableGroups) == true
        expect(receivedFlags?.enableSpaces) == true
    }

    // MARK: - Publisher Tests

    func testFeatureFlagsPublisherEmitsUpdates() async {
        // Given repository with active license
        let mockGateway = MockLicenseGateway(
            licenseInfo: LicenseInfo(
                licenseKey: "test-key",
                licenseStatus: .licensed,
                userName: "Test User",
                email: "test@example.com"
            ),
            enableLicensing: true
        )

        let licenseUseCase = GetLicenseInfoUseCase(licenseGateway: mockGateway)
        let licensingUseCase = GetEnableLicensingUseCase(gateway: mockGateway)

        repository = FeatureFlagsRepository(
            getLicenseInfoUseCase: licenseUseCase,
            getEnableLicensingUseCase: licensingUseCase
        )

        // When subscribing to publisher
        var receivedFlags: [FeatureFlags] = []

        repository?.featureFlagsPublisher
            .sink { flags in
                receivedFlags.append(flags)
            }
            .store(in: &cancellables)

        // Allow time for initial value
        try? await Task.sleep(for: .milliseconds(100))

        // And updating flags
        let customFlags = FeatureFlags(
            enableGroups: false,
            enableSpaces: true,
            enableSoftwareUpdates: true,
            enableAdvancedSettings: false
        )
        repository?.setFeatureFlags(customFlags)

        // Allow time for update
        try? await Task.sleep(for: .milliseconds(100))

        // Then should receive initial and updated flags
        expect(receivedFlags.count) == 2
        expect(receivedFlags[0]) != receivedFlags[1]
    }

    // MARK: - SetFeatureFlags Tests

    func testSetFeatureFlagsWithActiveLicense() async {
        // Given repository with active license
        let mockGateway = MockLicenseGateway(
            licenseInfo: LicenseInfo(
                licenseKey: "test-key",
                licenseStatus: .licensed,
                userName: "Test User",
                email: "test@example.com"
            ),
            enableLicensing: true
        )

        let licenseUseCase = GetLicenseInfoUseCase(licenseGateway: mockGateway)
        let licensingUseCase = GetEnableLicensingUseCase(gateway: mockGateway)

        repository = FeatureFlagsRepository(
            getLicenseInfoUseCase: licenseUseCase,
            getEnableLicensingUseCase: licensingUseCase
        )

        // When setting custom flags
        let customFlags = FeatureFlags(
            enableGroups: false,
            enableSpaces: true,
            enableSoftwareUpdates: true,
            enableAdvancedSettings: false
        )

        var receivedFlags: FeatureFlags?
        repository?.featureFlagsPublisher
            .dropFirst() // Skip current value
            .sink { flags in
                receivedFlags = flags
            }
            .store(in: &cancellables)

        repository?.setFeatureFlags(customFlags)

        // Allow time for update
        try? await Task.sleep(for: .milliseconds(100))

        // Then should update to custom flags
        expect(receivedFlags?.enableGroups) == false
        expect(receivedFlags?.enableSpaces) == true
        expect(receivedFlags?.enableAdvancedSettings) == false
        expect(receivedFlags?.enableSoftwareUpdates) == true
    }

    func testSetFeatureFlagsWithNoLicense() async {
        // Given repository with no license (default from setUp)
        // When setting custom flags with some enabled
        let customFlags = FeatureFlags(
            enableGroups: true,
            enableSpaces: true,
            enableSoftwareUpdates: true,
            enableAdvancedSettings: true
        )

        repository?.setFeatureFlags(customFlags)

        var receivedFlags: FeatureFlags?
        repository?.featureFlagsPublisher
            .sink { flags in
                receivedFlags = flags
            }
            .store(in: &cancellables)

        // Allow time for update
        try? await Task.sleep(for: .milliseconds(100))

        // Then required-license flags should be disabled
        expect(receivedFlags?.enableGroups) == false
        expect(receivedFlags?.enableSpaces) == false
    }

    func testSetFeatureFlagsIgnoresDuplicates() async {
        // Given repository with active license
        let mockGateway = MockLicenseGateway(
            licenseInfo: LicenseInfo(
                licenseKey: "test-key",
                licenseStatus: .licensed,
                userName: "Test User",
                email: "test@example.com"
            ),
            enableLicensing: true
        )

        let licenseUseCase = GetLicenseInfoUseCase(licenseGateway: mockGateway)
        let licensingUseCase = GetEnableLicensingUseCase(gateway: mockGateway)

        repository = FeatureFlagsRepository(
            getLicenseInfoUseCase: licenseUseCase,
            getEnableLicensingUseCase: licensingUseCase
        )

        // When setting same flags twice
        let flags = FeatureFlags(
            enableGroups: true,
            enableSpaces: false,
            enableSoftwareUpdates: false,
            enableAdvancedSettings: true
        )

        repository?.setFeatureFlags(flags)
        repository?.setFeatureFlags(flags)

        // Then should only emit once
        var updateCount = 0

        repository?.featureFlagsPublisher
            .sink { _ in
                updateCount += 1
            }
            .store(in: &cancellables)

        // Allow time for updates
        try? await Task.sleep(for: .milliseconds(100))

        expect(updateCount) == 1
    }

    // MARK: - ResetToDefaults Tests

    func testResetToDefaultsWithActiveLicense() async {
        // Given repository with active license and custom flags
        let mockGateway = MockLicenseGateway(
            licenseInfo: LicenseInfo(
                licenseKey: "test-key",
                licenseStatus: .licensed,
                userName: "Test User",
                email: "test@example.com"
            ),
            enableLicensing: true
        )

        let licenseUseCase = GetLicenseInfoUseCase(licenseGateway: mockGateway)
        let licensingUseCase = GetEnableLicensingUseCase(gateway: mockGateway)

        repository = FeatureFlagsRepository(
            getLicenseInfoUseCase: licenseUseCase,
            getEnableLicensingUseCase: licensingUseCase
        )

        let customFlags = FeatureFlags(
            enableGroups: false,
            enableSpaces: false,
            enableSoftwareUpdates: false,
            enableAdvancedSettings: false
        )
        repository?.setFeatureFlags(customFlags)

        // When resetting to defaults
        var receivedFlags: FeatureFlags?

        repository?.featureFlagsPublisher
            .dropFirst() // Skip current custom flags
            .sink { flags in
                receivedFlags = flags
            }
            .store(in: &cancellables)

        repository?.resetToDefaults()

        // Allow time for update
        try? await Task.sleep(for: .milliseconds(100))

        // Then should reset to default flags
        let defaultFlags = FeatureFlags.defaultFlags()
        expect(receivedFlags?.enableGroups) == defaultFlags.enableGroups
        expect(receivedFlags?.enableSpaces) == defaultFlags.enableSpaces
        expect(receivedFlags?.enableAdvancedSettings) == defaultFlags.enableAdvancedSettings
        expect(receivedFlags?.enableSoftwareUpdates) == defaultFlags.enableSoftwareUpdates
    }

    func testResetToDefaultsWithNoLicense() async {
        // Given repository with no license
        // When resetting to defaults
        repository?.resetToDefaults()

        var receivedFlags: FeatureFlags?
        repository?.featureFlagsPublisher
            .sink { flags in
                receivedFlags = flags
            }
            .store(in: &cancellables)

        // Allow time for update
        try? await Task.sleep(for: .milliseconds(100))

        // Then required-license flags should be disabled
        expect(receivedFlags?.enableGroups) == false
        expect(receivedFlags?.enableSpaces) == false
    }

    // MARK: - License State Changes Tests

    func testLicenseActivationEnablesFlags() async {
        // Given repository with no license and custom flags set
        let mockGateway = MockLicenseGateway(
            licenseInfo: LicenseInfo(
                licenseStatus: .unknown,
                userName: "",
                email: ""
            ),
            enableLicensing: true
        )

        let licenseUseCase = GetLicenseInfoUseCase(licenseGateway: mockGateway)
        let licensingUseCase = GetEnableLicensingUseCase(gateway: mockGateway)

        repository = FeatureFlagsRepository(
            getLicenseInfoUseCase: licenseUseCase,
            getEnableLicensingUseCase: licensingUseCase
        )

        let customFlags = FeatureFlags(
            enableGroups: true,
            enableSpaces: true,
            enableSoftwareUpdates: true,
            enableAdvancedSettings: true
        )
        repository?.setFeatureFlags(customFlags)

        // When license becomes active
        var receivedFlags: FeatureFlags?

        repository?.featureFlagsPublisher
            .dropFirst() // Skip current disabled state
            .sink { flags in
                receivedFlags = flags
            }
            .store(in: &cancellables)

        mockGateway.updateLicenseInfo(
            LicenseInfo(
                licenseKey: "test-key",
                licenseStatus: .licensed,
                userName: "Test User",
                email: "test@example.com"
            )
        )

        // Allow time for update
        try? await Task.sleep(for: .milliseconds(100))

        // Then flags should become enabled
        expect(receivedFlags?.enableGroups) == true
        expect(receivedFlags?.enableSpaces) == true
    }

    func testLicenseDeactivationDisablesFlags() async {
        // Given repository with active license
        let mockGateway = MockLicenseGateway(
            licenseInfo: LicenseInfo(
                licenseKey: "test-key",
                licenseStatus: .licensed,
                userName: "Test User",
                email: "test@example.com"
            ),
            enableLicensing: true
        )

        let licenseUseCase = GetLicenseInfoUseCase(licenseGateway: mockGateway)
        let licensingUseCase = GetEnableLicensingUseCase(gateway: mockGateway)

        repository = FeatureFlagsRepository(
            getLicenseInfoUseCase: licenseUseCase,
            getEnableLicensingUseCase: licensingUseCase
        )

        let customFlags = FeatureFlags(
            enableGroups: true,
            enableSpaces: true,
            enableSoftwareUpdates: true,
            enableAdvancedSettings: true
        )
        repository?.setFeatureFlags(customFlags)

        // When license becomes inactive
        var receivedFlags: FeatureFlags?

        repository?.featureFlagsPublisher
            .dropFirst() // Skip current enabled state
            .sink { flags in
                receivedFlags = flags
            }
            .store(in: &cancellables)

        mockGateway.updateLicenseInfo(
            LicenseInfo(
                licenseKey: "",
                licenseStatus: .unknown,
                userName: "",
                email: ""
            )
        )

        // Allow time for update
        try? await Task.sleep(for: .milliseconds(100))

        // Then required-license flags should be disabled
        expect(receivedFlags?.enableGroups) == false
        expect(receivedFlags?.enableSpaces) == false
    }

    func testEnablingLicensingFeatureEnforcesLicenseCheck() async {
        // Given repository with licensing disabled and no license
        let mockGateway = MockLicenseGateway(
            licenseInfo: LicenseInfo(
                licenseKey: "",
                licenseStatus: .unknown,
                userName: "",
                email: ""
            ),
            enableLicensing: false
        )

        let licenseUseCase = GetLicenseInfoUseCase(licenseGateway: mockGateway)
        let licensingUseCase = GetEnableLicensingUseCase(gateway: mockGateway)

        repository = FeatureFlagsRepository(
            getLicenseInfoUseCase: licenseUseCase,
            getEnableLicensingUseCase: licensingUseCase
        )

        // Flags should be enabled even without license when licensing is disabled
        var initialFlags: FeatureFlags?
        repository?.featureFlagsPublisher
            .first()
            .sink { flags in
                initialFlags = flags
            }
            .store(in: &cancellables)

        // Allow time for initial value
        try? await Task.sleep(for: .milliseconds(100))
        expect(initialFlags?.enableGroups) == true

        // When enabling licensing feature
        var receivedFlags: FeatureFlags?

        repository?.featureFlagsPublisher
            .dropFirst() // Skip current state
            .sink { flags in
                receivedFlags = flags
            }
            .store(in: &cancellables)

        mockGateway.updateEnableLicensing(true)

        // Allow time for update
        try? await Task.sleep(for: .milliseconds(100))

        // Then flags should be disabled (no active license)
        expect(receivedFlags?.enableGroups) == false
    }
}

// MARK: - Mock Use Cases

/// Mock implementation of LicenseGateway for testing.
@MainActor
private final class MockLicenseGateway: LicenseGateway {
    @Published var licenseInfo: LicenseInfo
    @Published var enableLicensing: Bool
    @Published var enableTrialRequest: Bool
    @Published var mockActiveLicense: Bool
    @Published var checkoutEnvironment: CheckoutEnvironment

    // For storing mock instances to update later
    private var licenseInfoSubject: CurrentValueSubject<LicenseInfo, Never>
    private var enableLicensingSubject: CurrentValueSubject<Bool, Never>

    init(licenseInfo: LicenseInfo = LicenseInfo(), enableLicensing: Bool = true) {
        self.licenseInfo = licenseInfo
        self.enableLicensing = enableLicensing
        enableTrialRequest = false
        mockActiveLicense = false
        checkoutEnvironment = .production
        licenseInfoSubject = CurrentValueSubject(licenseInfo)
        enableLicensingSubject = CurrentValueSubject(enableLicensing)
    }

    // MARK: - LicenseGateway Properties

    var licenseInfoPublisher: AnyPublisher<LicenseInfo, Never> {
        licenseInfoSubject.eraseToAnyPublisher()
    }

    var enableLicensingPublisher: AnyPublisher<Bool, Never> {
        enableLicensingSubject.eraseToAnyPublisher()
    }

    var enableTrialRequestPublisher: AnyPublisher<Bool, Never> {
        $enableTrialRequest.eraseToAnyPublisher()
    }

    var mockActiveLicensePublisher: AnyPublisher<Bool, Never> {
        $mockActiveLicense.eraseToAnyPublisher()
    }

    var checkoutEnvironmentPublisher: AnyPublisher<CheckoutEnvironment, Never> {
        $checkoutEnvironment.eraseToAnyPublisher()
    }

    // MARK: - LicenseGateway Required Methods

    func activateLicense(_: String) throws -> LicenseInfo {
        // Mock implementation - return current license info
        licenseInfo
    }

    func deactivateLicense() throws {
        // Mock implementation - update license to inactive
        let inactiveInfo = LicenseInfo(
            licenseKey: "",
            licenseStatus: .expired,
            userName: "",
            email: ""
        )
        updateLicenseInfo(inactiveInfo)
    }

    func getCheckoutURL() -> URL {
        // Mock URL
        guard let url = URL(string: "https://example.com/checkout") else {
            fatalError("Invalid checkout URL string")
        }

        return url
    }

    func getTrialCheckoutURL() -> URL {
        // Mock trial URL
        guard let url = URL(string: "https://example.com/trial") else {
            fatalError("Invalid trial checkout URL string")
        }

        return url
    }

    func handleCheckoutSuccess(licenseKey: String) {
        // Mock implementation - update with new license
        let newInfo = LicenseInfo(
            licenseKey: licenseKey,
            licenseStatus: .licensed,
            userName: "Test User",
            email: "test@example.com"
        )
        updateLicenseInfo(newInfo)
    }

    func setEnableLicensing(_ enabled: Bool) {
        updateEnableLicensing(enabled)
    }

    func setEnableTrialRequest(_ enabled: Bool) {
        enableTrialRequest = enabled
    }

    #if DEBUG
        func setMockActiveLicense(_ enabled: Bool) {
            mockActiveLicense = enabled
        }

        func setCheckoutEnvironment(_ environment: CheckoutEnvironment) {
            checkoutEnvironment = environment
        }
    #endif

    func resetLicenseFeatureFlags() {
        // Mock implementation - reset to defaults
        enableTrialRequest = false
        #if DEBUG
            mockActiveLicense = false
            checkoutEnvironment = .production
        #endif
    }

    func setUserName(_ userName: String) {
        // Mock implementation - update current license info with new user name
        let updatedInfo = LicenseInfo(
            licenseKey: licenseInfo.licenseKey,
            licenseStatus: licenseInfo.licenseStatus,
            userName: userName,
            email: licenseInfo.email,
            profileImageData: licenseInfo.profileImageData
        )
        updateLicenseInfo(updatedInfo)
    }

    func setProfileImageData(_ profileImageData: Data?) {
        // Mock implementation - update current license info with new profile image
        let updatedInfo = LicenseInfo(
            licenseKey: licenseInfo.licenseKey,
            licenseStatus: licenseInfo.licenseStatus,
            userName: licenseInfo.userName,
            email: licenseInfo.email,
            profileImageData: profileImageData
        )
        updateLicenseInfo(updatedInfo)
    }

    func hasTrialBeenUsed() -> Bool {
        // Mock implementation
        false
    }

    // MARK: - Update Methods for Testing

    func updateLicenseInfo(_ info: LicenseInfo) {
        licenseInfo = info
        licenseInfoSubject.send(info)
    }

    func updateEnableLicensing(_ enabled: Bool) {
        enableLicensing = enabled
        enableLicensingSubject.send(enabled)
    }
}
