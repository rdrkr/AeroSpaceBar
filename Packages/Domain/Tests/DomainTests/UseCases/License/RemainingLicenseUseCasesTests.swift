// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Nimble
import XCTest

/// Tests for remaining License use cases.
///
/// These tests cover license-related use cases not already tested,
/// including checkout environment, trial, mock license, and user profile.
@MainActor
final class RemainingLicenseUseCasesTests: XCTestCase {
    private var mockGateway: MockLicenseGateway?
    private var cancellables: Set<AnyCancellable>?

    // Properties for capturing publisher results
    private var envResult: CheckoutEnvironment?
    private var licensingResult: Bool?
    private var mockResult: Bool?

    override func setUp() async throws {
        try await super.setUp()
        mockGateway = MockLicenseGateway()
        cancellables = []
    }

    // MARK: - CheckoutEnvironment Tests

    #if DEBUG
        func testGetCheckoutEnvironment() async {
            guard let mockGateway, var cancellables else {
                fail("Test dependencies not initialized")
                return
            }

            // Given
            mockGateway.checkoutEnvironment = .production
            let useCase = GetCheckoutEnvironmentUseCase(licenseGateway: mockGateway)

            // When
            var result: CheckoutEnvironment?
            useCase.execute()
                .sink { value in
                    result = value
                }
                .store(in: &cancellables)

            try? await Task.sleep(for: .milliseconds(100))

            // Then
            expect(result) == CheckoutEnvironment.production
        }

        func testSetCheckoutEnvironment() {
            guard let mockGateway else {
                fail("Test dependencies not initialized")
                return
            }

            // Given
            let useCase = SetCheckoutEnvironmentUseCase(licenseGateway: mockGateway)

            // When
            useCase.execute(CheckoutEnvironment.development)

            // Then
            expect(mockGateway.setCheckoutEnvironmentCalls.count) == 1
            expect(mockGateway.setCheckoutEnvironmentCalls.first) == CheckoutEnvironment.development
        }
    #endif

    // MARK: - EnableLicensing Tests

    #if DEBUG
        func testGetEnableLicensing() async {
            guard let mockGateway, var cancellables else {
                fail("Test dependencies not initialized")
                return
            }

            // Given
            mockGateway.isLicensingEnabledToEmit = true
            let useCase = GetEnableLicensingUseCase(gateway: mockGateway)

            // When
            var result: Bool?
            useCase.execute()
                .sink { value in
                    result = value
                }
                .store(in: &cancellables)

            try? await Task.sleep(for: .milliseconds(100))

            // Then
            expect(result) == true
        }

        func testSetEnableLicensing() {
            guard let mockGateway else {
                fail("Test dependencies not initialized")
                return
            }

            // Given
            let useCase = SetEnableLicensingUseCase(gateway: mockGateway)

            // When
            useCase.execute(enabled: false)

            // Then
            expect(mockGateway.setEnableLicensingCalls.count) == 1
            expect(mockGateway.setEnableLicensingCalls.first) == false
        }
    #endif

    // MARK: - EnableTrialRequest Tests

    #if DEBUG
        func testGetEnableTrialRequest() async {
            guard let mockGateway, var cancellables else {
                fail("Test dependencies not initialized")
                return
            }

            // Given
            mockGateway.isTrialRequestEnabled = true
            let useCase = GetEnableTrialRequestUseCase(gateway: mockGateway)

            // When
            var result: Bool?
            useCase.execute()
                .sink { value in
                    result = value
                }
                .store(in: &cancellables)

            try? await Task.sleep(for: .milliseconds(100))

            // Then
            expect(result) == true
        }

        func testSetEnableTrialRequest() {
            guard let mockGateway else {
                fail("Test dependencies not initialized")
                return
            }

            // Given
            let useCase = SetEnableTrialRequestUseCase(gateway: mockGateway)

            // When
            useCase.execute(enabled: true)

            // Then
            expect(mockGateway.setEnableTrialRequestCalls.count) == 1
            expect(mockGateway.setEnableTrialRequestCalls.first) == true
        }
    #endif

    // MARK: - MockActiveLicense Tests

    #if DEBUG
        func testGetMockActiveLicense() async {
            guard let mockGateway, var cancellables else {
                fail("Test dependencies not initialized")
                return
            }

            // Given
            mockGateway.mockActiveLicenseToEmit = true
            let useCase = GetMockActiveLicenseUseCase(gateway: mockGateway)

            // When
            var result: Bool?
            useCase.execute()
                .sink { value in
                    result = value
                }
                .store(in: &cancellables)

            try? await Task.sleep(for: .milliseconds(100))

            // Then
            expect(result) == true
        }

        func testSetMockActiveLicense() {
            guard let mockGateway else {
                fail("Test dependencies not initialized")
                return
            }

            // Given
            let useCase = SetMockActiveLicenseUseCase(gateway: mockGateway)

            // When
            useCase.execute(enabled: true)

            // Then
            expect(mockGateway.setMockActiveLicenseCalls.count) == 1
            expect(mockGateway.setMockActiveLicenseCalls.first) == true
        }
    #endif

    // MARK: - Trial Tests

    func testHasTrialBeenUsed() {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockGateway.hasTrialBeenUsedToReturn = true
        let useCase = HasTrialBeenUsedUseCase(licenseGateway: mockGateway)

        // When
        let result = useCase.execute()

        // Then
        expect(result) == true
        expect(mockGateway.hasTrialBeenUsedCalls) == 1
    }

    // MARK: - Checkout Tests

    func testOpenCheckoutGetCheckoutURL() {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let expectedURL = URL(string: "https://checkout.example.com")
        mockGateway.checkoutURLToReturn = expectedURL
        let useCase = OpenCheckoutUseCase(licenseGateway: mockGateway)

        // When
        let result = useCase.getCheckoutURL()

        // Then
        expect(result) == expectedURL
        expect(mockGateway.getCheckoutURLCalls) == 1
    }

    func testOpenCheckoutGetTrialCheckoutURL() {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let expectedURL = URL(string: "https://trial.example.com")
        mockGateway.trialCheckoutURLToReturn = expectedURL
        let useCase = OpenCheckoutUseCase(licenseGateway: mockGateway)

        // When
        let result = useCase.getTrialCheckoutURL()

        // Then
        expect(result) == expectedURL
        expect(mockGateway.getTrialCheckoutURLCalls) == 1
    }

    func testOpenCheckoutHandleSuccess() async {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let useCase = OpenCheckoutUseCase(licenseGateway: mockGateway)
        let testKey = "TEST-LICENSE-KEY-123"

        // When
        await useCase.handleSuccess(licenseKey: testKey)

        // Then
        expect(mockGateway.checkoutSuccessCalls.count) == 1
        expect(mockGateway.checkoutSuccessCalls.first) == testKey
    }

    // MARK: - Reset Feature Flags Tests

    func testResetLicenseFeatureFlags() async {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let useCase = ResetLicenseFeatureFlagsUseCase(gateway: mockGateway)

        // When
        await useCase.execute()

        // Then
        expect(mockGateway.resetLicenseFeatureFlagsCalls) == 1
    }

    // MARK: - User Profile Tests

    func testSetProfileImageData() async {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let imageData = Data([0x01, 0x02, 0x03])
        let useCase = SetProfileImageDataUseCase(licenseGateway: mockGateway)

        // When
        await useCase.execute(profileImageData: imageData)

        // Then
        expect(mockGateway.setProfileImageDataCalls.count) == 1
        expect(mockGateway.setProfileImageDataCalls.first) == imageData
    }

    func testSetUserName() async {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let userName = "Test User"
        let useCase = SetUserNameUseCase(licenseGateway: mockGateway)

        // When
        await useCase.execute(userName: userName)

        // Then
        expect(mockGateway.setUserNameCalls.count) == 1
        expect(mockGateway.setUserNameCalls.first) == userName
    }

    // MARK: - Integration Tests

    func testCheckoutWorkflow() async {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let useCase = OpenCheckoutUseCase(licenseGateway: mockGateway)

        // When - Get checkout URL
        let checkoutURL = useCase.getCheckoutURL()
        expect(checkoutURL.absoluteString) == "https://test.lemonsqueezy.com/checkout/purchase"

        // And - Handle successful checkout
        await useCase.handleSuccess(licenseKey: "NEW-KEY")

        // Then - Should track both operations
        expect(mockGateway.getCheckoutURLCalls) == 1
        expect(mockGateway.checkoutSuccessCalls.count) == 1
    }

    func testTrialWorkflow() {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let openCheckoutUseCase = OpenCheckoutUseCase(licenseGateway: mockGateway)
        let hasTrialUseCase = HasTrialBeenUsedUseCase(licenseGateway: mockGateway)

        // When - Check if trial used
        mockGateway.hasTrialBeenUsedToReturn = false
        let trialUsed = hasTrialUseCase.execute()
        expect(trialUsed) == false

        // And - Get trial checkout URL
        let trialURL = openCheckoutUseCase.getTrialCheckoutURL()
        expect(trialURL.absoluteString) == "https://test.lemonsqueezy.com/checkout/trial"

        // Then - Should track both operations
        expect(mockGateway.hasTrialBeenUsedCalls) == 1
        expect(mockGateway.getTrialCheckoutURLCalls) == 1
    }

    #if DEBUG
        func testDevelopmentConfiguration() async {
            guard let mockGateway, var cancellables else {
                fail("Test dependencies not initialized")
                return
            }

            // Given development-only use cases
            let getEnvUseCase = GetCheckoutEnvironmentUseCase(licenseGateway: mockGateway)
            let setEnvUseCase = SetCheckoutEnvironmentUseCase(licenseGateway: mockGateway)
            let getEnableLicensingUseCase = GetEnableLicensingUseCase(gateway: mockGateway)
            let setEnableLicensingUseCase = SetEnableLicensingUseCase(gateway: mockGateway)

            // When - Configure for development testing
            setEnvUseCase.execute(CheckoutEnvironment.development)
            setEnableLicensingUseCase.execute(enabled: true)

            // And - Verify configuration
            mockGateway.checkoutEnvironmentToEmit = CheckoutEnvironment.development
            mockGateway.isLicensingEnabledToEmit = true

            getEnvUseCase.execute()
                .sink { value in
                    self.envResult = value
                }
                .store(in: &cancellables)

            getEnableLicensingUseCase.execute()
                .sink { value in
                    self.licensingResult = value
                }
                .store(in: &cancellables)

            // Then - Should configure properly
            try? await Task.sleep(for: .milliseconds(100))
            expect(self.envResult) == CheckoutEnvironment.development
            expect(self.licensingResult) == true
            expect(mockGateway.setCheckoutEnvironmentCalls.count) == 1
            expect(mockGateway.setEnableLicensingCalls.count) == 1
        }

        func testMockLicenseConfiguration() async {
            guard let mockGateway, var cancellables else {
                fail("Test dependencies not initialized")
                return
            }

            // Given mock license use cases
            let getMockUseCase = GetMockActiveLicenseUseCase(gateway: mockGateway)
            let setMockUseCase = SetMockActiveLicenseUseCase(gateway: mockGateway)

            // When - Enable mock license
            setMockUseCase.execute(enabled: true)
            mockGateway.mockActiveLicenseToEmit = true

            // And - Verify mock is enabled
            getMockUseCase.execute()
                .sink { value in
                    self.mockResult = value
                }
                .store(in: &cancellables)

            // Then - Should enable mock license
            try? await Task.sleep(for: .milliseconds(100))
            expect(self.mockResult) == true
            expect(mockGateway.setMockActiveLicenseCalls.count) == 1
        }
    #endif
}
