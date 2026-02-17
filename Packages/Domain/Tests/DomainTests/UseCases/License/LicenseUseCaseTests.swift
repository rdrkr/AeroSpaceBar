// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
@testable import Domain
import Nimble
import XCTest

/// Comprehensive tests for all License UseCases.
///
/// These tests verify the following 16 use cases:
/// - ActivateLicenseUseCase
/// - DeactivateLicenseUseCase
/// - GetLicenseInfoUseCase
/// - GetEnableLicensingUseCase / SetEnableLicensingUseCase
/// - GetEnableTrialRequestUseCase / SetEnableTrialRequestUseCase
/// - GetMockActiveLicenseUseCase / SetMockActiveLicenseUseCase (DEBUG only)
/// - GetCheckoutEnvironmentUseCase / SetCheckoutEnvironmentUseCase (DEBUG only)
/// - HasTrialBeenUsedUseCase
/// - OpenCheckoutUseCase
/// - SetUserNameUseCase
/// - SetProfileImageDataUseCase
/// - ResetLicenseFeatureFlagsUseCase
@MainActor
final class LicenseUseCaseTests: XCTestCase {
    private var mockGateway: MockLicenseGateway?
    private var cancellables: Set<AnyCancellable>?

    override func setUp() async throws {
        try await super.setUp()
        mockGateway = MockLicenseGateway()
        cancellables = []
    }

    // MARK: - ActivateLicenseUseCase Tests

    /// Test successful license activation with valid license key.
    func testActivateLicenseSuccess() async throws {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let useCase = ActivateLicenseUseCase(licenseGateway: mockGateway)
        let licenseKey = "TEST-LICENSE-KEY-123"

        // When
        let result = try await useCase.execute(licenseKey: licenseKey)

        // Then
        expect(result.licenseKey) == licenseKey
        expect(result.licenseStatus) == .licensed
        expect(mockGateway.licenseInfoToEmit.licenseKey) == licenseKey
    }

    /// Test license activation fails with empty license key.
    func testActivateLicenseWithEmptyKey() async {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let useCase = ActivateLicenseUseCase(licenseGateway: mockGateway)
        let emptyKey = ""

        // When & Then
        do {
            _ = try await useCase.execute(licenseKey: emptyKey)
            XCTFail("Expected LicenseError.invalidLicenseKey to be thrown")
        } catch let error as LicenseError {
            expect(error) == .invalidLicenseKey
        } catch {
            XCTFail("Unexpected error type: \(type(of: error))")
        }
    }

    // MARK: - DeactivateLicenseUseCase Tests

    /// Test successful license deactivation.
    func testDeactivateLicenseSuccess() async throws {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockGateway.licenseInfoToEmit = LicenseInfo(
            licenseKey: "TEST-KEY",
            licenseStatus: .licensed
        )
        let useCase = DeactivateLicenseUseCase(licenseGateway: mockGateway)

        // When
        try await useCase.execute()

        // Then
        expect(mockGateway.licenseInfoToEmit.licenseKey.isEmpty) == true
        expect(mockGateway.licenseInfoToEmit.licenseStatus) == .unknown
    }

    // MARK: - GetLicenseInfoUseCase Tests

    /// Test getting license information via publisher.
    func testGetLicenseInfo() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockGateway.licenseInfoToEmit = LicenseInfo(
            licenseKey: "TEST-KEY",
            licenseStatus: .licensed,
            userName: "Test User"
        )
        let useCase = GetLicenseInfoUseCase(licenseGateway: mockGateway)
        var receivedInfo: LicenseInfo?

        // When
        useCase.execute()
            .sink { value in receivedInfo = value }
            .store(in: &cancellables)

        // Then
        expect(receivedInfo).toNot(beNil())
        expect(receivedInfo?.licenseKey) == "TEST-KEY"
        expect(receivedInfo?.userName) == "Test User"
    }

    // MARK: - EnableLicensing Tests

    /// Test getting enableLicensing feature flag via publisher.
    func testGetEnableLicensing() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockGateway.isLicensingEnabled = true
        let useCase = GetEnableLicensingUseCase(gateway: mockGateway)
        var receivedValue: Bool?

        // When
        useCase.execute()
            .sink { value in receivedValue = value }
            .store(in: &cancellables)

        // Then
        expect(receivedValue).toNot(beNil())
        expect(receivedValue) == true
    }

    /// Test setting enableLicensing feature flag.
    func testSetEnableLicensing() {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let useCase = SetEnableLicensingUseCase(gateway: mockGateway)
        let newValue = true

        // When
        useCase.execute(enabled: newValue)

        // Then
        expect(mockGateway.isLicensingEnabled) == newValue
    }

    // MARK: - EnableTrialRequest Tests

    /// Test getting enableTrialRequest feature flag via publisher.
    func testGetEnableTrialRequest() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockGateway.isTrialRequestEnabled = true
        let useCase = GetEnableTrialRequestUseCase(gateway: mockGateway)
        var receivedValue: Bool?

        // When
        useCase.execute()
            .sink { value in receivedValue = value }
            .store(in: &cancellables)

        // Then
        expect(receivedValue).toNot(beNil())
        expect(receivedValue) == true
    }

    /// Test setting enableTrialRequest feature flag.
    func testSetEnableTrialRequest() {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let useCase = SetEnableTrialRequestUseCase(gateway: mockGateway)
        let newValue = true

        // When
        useCase.execute(enabled: newValue)

        // Then
        expect(mockGateway.isTrialRequestEnabled) == newValue
    }

    // MARK: - MockActiveLicense Tests (DEBUG only)

    #if DEBUG
        /// Test getting mockActiveLicense feature flag via publisher (DEBUG only).
        func testGetMockActiveLicense() {
            guard let mockGateway, var cancellables else {
                fail("Test dependencies not initialized")
                return
            }

            // Given
            mockGateway.isMockActiveLicenseEnabled = true
            let useCase = GetMockActiveLicenseUseCase(gateway: mockGateway)
            var receivedValue: Bool?

            // When
            useCase.execute()
                .sink { value in receivedValue = value }
                .store(in: &cancellables)

            // Then
            expect(receivedValue).toNot(beNil())
            expect(receivedValue) == true
        }

        /// Test setting mockActiveLicense feature flag (DEBUG only).
        func testSetMockActiveLicense() {
            guard let mockGateway else {
                fail("Test dependencies not initialized")
                return
            }

            // Given
            let useCase = SetMockActiveLicenseUseCase(gateway: mockGateway)
            let newValue = true

            // When
            useCase.execute(enabled: newValue)

            // Then
            expect(mockGateway.isMockActiveLicenseEnabled) == newValue
        }
    #endif

    // MARK: - CheckoutEnvironment Tests (DEBUG only)

    #if DEBUG
        /// Test getting checkout environment via publisher (DEBUG only).
        func testGetCheckoutEnvironment() {
            guard let mockGateway, var cancellables else {
                fail("Test dependencies not initialized")
                return
            }

            // Given
            mockGateway.checkoutEnvironment = .development
            let useCase = GetCheckoutEnvironmentUseCase(licenseGateway: mockGateway)
            var receivedEnvironment: CheckoutEnvironment?

            // When
            useCase.execute()
                .sink { value in receivedEnvironment = value }
                .store(in: &cancellables)

            // Then
            expect(receivedEnvironment).toNot(beNil())
            expect(receivedEnvironment) == .development
        }

        /// Test setting checkout environment (DEBUG only).
        func testSetCheckoutEnvironment() {
            guard let mockGateway else {
                fail("Test dependencies not initialized")
                return
            }

            // Given
            let useCase = SetCheckoutEnvironmentUseCase(licenseGateway: mockGateway)
            let newEnvironment = CheckoutEnvironment.development

            // When
            useCase.execute(newEnvironment)

            // Then
            expect(mockGateway.checkoutEnvironment) == newEnvironment
        }
    #endif

    // MARK: - HasTrialBeenUsedUseCase Tests

    /// Test checking if trial has been used.
    func testHasTrialBeenUsedReturnsFalse() {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockGateway.trialHasBeenUsed = false
        let useCase = HasTrialBeenUsedUseCase(licenseGateway: mockGateway)

        // When
        let result = useCase.execute()

        // Then
        expect(result) == false
    }

    /// Test checking if trial has been used returns true.
    func testHasTrialBeenUsedReturnsTrue() {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockGateway.trialHasBeenUsed = true
        let useCase = HasTrialBeenUsedUseCase(licenseGateway: mockGateway)

        // When
        let result = useCase.execute()

        // Then
        expect(result) == true
    }

    // MARK: - OpenCheckoutUseCase Tests

    /// Test getting checkout URL.
    func testOpenCheckoutGetCheckoutURL() {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let useCase = OpenCheckoutUseCase(licenseGateway: mockGateway)

        // When
        let url = useCase.getCheckoutURL()

        // Then
        expect(url).toNot(beNil())
        expect(url.scheme) == "https"
    }

    /// Test getting trial checkout URL.
    func testOpenCheckoutGetTrialCheckoutURL() {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let useCase = OpenCheckoutUseCase(licenseGateway: mockGateway)

        // When
        let url = useCase.getTrialCheckoutURL()

        // Then
        expect(url).toNot(beNil())
        expect(url.scheme) == "https"
    }

    /// Test handling successful checkout.
    func testOpenCheckoutHandleSuccess() async {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let useCase = OpenCheckoutUseCase(licenseGateway: mockGateway)
        let licenseKey = "SUCCESS-LICENSE-KEY"

        // When
        await useCase.handleSuccess(licenseKey: licenseKey)

        // Then
        expect(mockGateway.licenseInfoToEmit.licenseKey) == licenseKey
    }

    // MARK: - SetUserNameUseCase Tests

    /// Test setting user name updates license info.
    func testSetUserName() async {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let useCase = SetUserNameUseCase(licenseGateway: mockGateway)
        let newUserName = "New Test User"

        // When
        await useCase.execute(userName: newUserName)

        // Then
        expect(mockGateway.licenseInfoToEmit.userName) == newUserName
        expect(mockGateway.userName) == newUserName
    }

    /// Test setting empty user name.
    func testSetEmptyUserName() async {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let useCase = SetUserNameUseCase(licenseGateway: mockGateway)
        let emptyUserName = ""

        // When
        await useCase.execute(userName: emptyUserName)

        // Then
        expect(mockGateway.licenseInfoToEmit.userName) == emptyUserName
    }

    // MARK: - SetProfileImageDataUseCase Tests

    /// Test setting profile image data.
    func testSetProfileImageData() async {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let useCase = SetProfileImageDataUseCase(licenseGateway: mockGateway)
        let testImageData = Data("test-image-data".utf8)

        // When
        await useCase.execute(profileImageData: testImageData)

        // Then
        expect(mockGateway.licenseInfoToEmit.profileImageData) == testImageData
        expect(mockGateway.licenseInfoToEmit.profileImageData) == testImageData
    }

    /// Test clearing profile image data by setting to nil.
    func testSetProfileImageDataToNil() async {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockGateway.licenseInfoToEmit.profileImageData = Data("existing-image".utf8)
        let useCase = SetProfileImageDataUseCase(licenseGateway: mockGateway)

        // When
        await useCase.execute(profileImageData: nil)

        // Then
        expect(mockGateway.licenseInfoToEmit.profileImageData).to(beNil())
        expect(mockGateway.licenseInfoToEmit.profileImageData).to(beNil())
    }

    // MARK: - ResetLicenseFeatureFlagsUseCase Tests

    /// Test resetting all license feature flags to default values.
    func testResetLicenseFeatureFlags() async {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockGateway.isLicensingEnabled = true
        mockGateway.isTrialRequestEnabled = true
        mockGateway.licenseInfoToEmit = LicenseInfo(
            licenseKey: "TEST-KEY",
            licenseStatus: .licensed
        )
        mockGateway.userName = "Test User"
        mockGateway.licenseInfoToEmit.profileImageData = Data("test-data".utf8)
        mockGateway.trialHasBeenUsed = true

        #if DEBUG
            mockGateway.isMockActiveLicenseEnabled = true
            mockGateway.checkoutEnvironment = .development
        #endif

        let useCase = ResetLicenseFeatureFlagsUseCase(gateway: mockGateway)

        // When
        await useCase.execute()

        // Then
        expect(mockGateway.isLicensingEnabled) == false
        expect(mockGateway.isTrialRequestEnabled) == false
        expect(mockGateway.licenseInfoToEmit.licenseKey.isEmpty) == true
        expect(mockGateway.userName?.isEmpty) == true
        expect(mockGateway.licenseInfoToEmit.profileImageData).to(beNil())
        expect(mockGateway.trialHasBeenUsed) == false

        #if DEBUG
            expect(mockGateway.isMockActiveLicenseEnabled) == false
            expect(mockGateway.checkoutEnvironment) == .production
        #endif
    }

    // MARK: - Integration Tests

    /// Test a complete workflow: activate license, set user info, then reset.
    func testCompleteWorkflow() async throws {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let activateUseCase = ActivateLicenseUseCase(licenseGateway: mockGateway)
        let setUserNameUseCase = SetUserNameUseCase(licenseGateway: mockGateway)
        let setEnableLicensingUseCase = SetEnableLicensingUseCase(gateway: mockGateway)
        let resetUseCase = ResetLicenseFeatureFlagsUseCase(gateway: mockGateway)

        // When - Step 1: Activate license
        _ = try await activateUseCase.execute(licenseKey: "INTEGRATION-TEST-KEY")
        expect(mockGateway.licenseInfoToEmit.licenseKey) == "INTEGRATION-TEST-KEY"

        // When - Step 2: Set user name
        await setUserNameUseCase.execute(userName: "Integration Test User")
        expect(mockGateway.licenseInfoToEmit.userName) == "Integration Test User"

        // When - Step 3: Enable licensing
        setEnableLicensingUseCase.execute(enabled: true)
        expect(mockGateway.isLicensingEnabled) == true

        // When - Step 4: Reset all flags
        await resetUseCase.execute()

        // Then - Verify everything is reset
        expect(mockGateway.licenseInfoToEmit.licenseKey.isEmpty) == true
        expect(mockGateway.licenseInfoToEmit.userName.isEmpty) == true
        expect(mockGateway.isLicensingEnabled) == false
    }

    /// Test publisher emissions for multiple subscriptions.
    func testMultiplePublisherSubscriptions() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockGateway.licenseInfoToEmit = LicenseInfo(
            licenseKey: "TEST-KEY",
            licenseStatus: .licensed
        )
        mockGateway.isLicensingEnabled = true

        let getLicenseInfoUseCase = GetLicenseInfoUseCase(licenseGateway: mockGateway)
        let getEnableLicensingUseCase = GetEnableLicensingUseCase(gateway: mockGateway)

        var receivedLicenseInfo: LicenseInfo?
        var receivedEnableLicensing: Bool?

        // When
        getLicenseInfoUseCase.execute()
            .sink { value in receivedLicenseInfo = value }
            .store(in: &cancellables)

        getEnableLicensingUseCase.execute()
            .sink { value in receivedEnableLicensing = value }
            .store(in: &cancellables)

        // Then
        expect(receivedLicenseInfo).toNot(beNil())
        expect(receivedLicenseInfo?.licenseKey) == "TEST-KEY"
        expect(receivedEnableLicensing).toNot(beNil())
        expect(receivedEnableLicensing) == true
    }
}
