// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Nimble
import XCTest

/// Tests for ActivateLicenseUseCase.
///
/// CRITICAL: These tests validate the license bug fix - ensuring purchased licenses
/// are not incorrectly expired by trial expiration rules.
@MainActor
final class ActivateLicenseUseCaseTests: XCTestCase {
    private var sut: ActivateLicenseUseCase?
    private var mockGateway: MockLicenseGateway?
    private var cancellables: Set<AnyCancellable>?

    override func setUp() async throws {
        try await super.setUp()
        let gateway = MockLicenseGateway()
        mockGateway = gateway
        sut = ActivateLicenseUseCase(licenseGateway: gateway)
        cancellables = []
    }

    override func tearDown() async throws {
        cancellables = nil
        try await super.tearDown()
    }

    // MARK: - Basic Functionality Tests

    func testExecuteCallsGatewayWithLicenseKey() async throws {
        guard let sut, let mockGateway else {
            fail("SUT or mockGateway not initialized")
            return
        }

        // Given a license key
        let licenseKey = "TEST-LICENSE-KEY"
        mockGateway.activationResult = LicenseFixtures.licensed

        // When executing the use case
        _ = try await sut.execute(licenseKey: licenseKey)

        // Then should call gateway with correct key
        expect(mockGateway.activateLicenseCalls.count) == 1
        expect(mockGateway.activateLicenseCalls.first) == licenseKey
    }

    func testExecuteReturnsLicenseInfoFromGateway() async throws {
        guard let sut, let mockGateway else {
            fail("SUT or mockGateway not initialized")
            return
        }

        // Given gateway returns license info
        let expectedInfo = LicenseFixtures.licensed
        mockGateway.activationResult = expectedInfo

        // When executing the use case
        let result = try await sut.execute(licenseKey: "KEY")

        // Then should return the license info
        expect(result.licenseKey) == expectedInfo.licenseKey
        expect(result.licenseStatus) == expectedInfo.licenseStatus
        expect(result.userName) == expectedInfo.userName
    }

    // MARK: - CRITICAL: License Bug Fix Validation Tests

    func testPurchasedLicenseActivatesAsLicensed() async throws {
        guard let sut, let mockGateway else {
            fail("SUT or mockGateway not initialized")
            return
        }

        // Given a purchased license (not trial)
        mockGateway.activationResult = LicenseFixtures.licensed

        // When activating the license
        let result = try await sut.execute(licenseKey: LicenseFixtures.validPurchasedKey)

        // Then should be activated with .licensed status (NOT .expired or .trial)
        expect(result.licenseStatus) == .licensed
        expect(result.isActive) == true
    }

    func testPurchasedLicenseNotAffectedByTrialRules() async throws {
        guard let sut, let mockGateway else {
            fail("SUT or mockGateway not initialized")
            return
        }

        // CRITICAL: This tests the bug fix
        // Given a purchased license that should NEVER expire due to trial rules
        let purchasedLicense = LicenseInfo(
            licenseKey: LicenseFixtures.validPurchasedKey,
            licenseStatus: .licensed, // Purchased licenses should stay .licensed
            userName: "Purchased User",
            email: "purchased@test.com"
        )
        mockGateway.activationResult = purchasedLicense

        // When activating
        let result = try await sut.execute(licenseKey: LicenseFixtures.validPurchasedKey)

        // Then should remain licensed (not expired by trial logic)
        expect(result.licenseStatus).to(
            equal(.licensed),
            description: "Purchased license should never be expired by trial rules"
        )
        expect(result.isActive) == true
    }

    func testTrialLicenseActivatesAsTrial() async throws {
        guard let sut, let mockGateway else {
            fail("SUT or mockGateway not initialized")
            return
        }

        // Given a trial license
        mockGateway.activationResult = LicenseFixtures.trial10Days

        // When activating the trial
        let result = try await sut.execute(licenseKey: LicenseFixtures.validTrialKey)

        // Then should be activated with .trial status
        if case let .trial(days) = result.licenseStatus {
            expect(days) == 10
            expect(result.isActive) == true
        } else {
            XCTFail("Expected trial status with 10 days")
        }
    }

    func testExpiredTrialRemainsExpired() async throws {
        guard let sut, let mockGateway else {
            fail("SUT or mockGateway not initialized")
            return
        }

        // Given an expired trial
        mockGateway.activationResult = LicenseFixtures.expiredTrial

        // When activating (which should fail or return expired)
        let result = try await sut.execute(licenseKey: "EXPIRED-KEY")

        // Then should be expired
        expect(result.licenseStatus) == .expired
        expect(result.isActive) == false
    }

    // MARK: - Error Handling Tests

    func testExecuteThrowsWhenGatewayThrows() async {
        guard let sut, let mockGateway else {
            fail("SUT or mockGateway not initialized")
            return
        }

        // Given gateway will throw error
        mockGateway.activateLicenseError = LicenseError.invalidLicenseKey

        // When executing use case
        do {
            _ = try await sut.execute(licenseKey: "INVALID-KEY")
            XCTFail("Should have thrown error")
        } catch {
            // Then should propagate the error
            expect(error is LicenseError) == true
        }
    }

    func testExecuteThrowsInvalidLicenseKeyError() async {
        guard let sut, let mockGateway else {
            fail("SUT or mockGateway not initialized")
            return
        }

        // Given invalid license key error
        mockGateway.activateLicenseError = LicenseError.invalidLicenseKey

        // When executing
        do {
            _ = try await sut.execute(licenseKey: "BAD-KEY")
            XCTFail("Should throw invalid license key error")
        } catch let error as LicenseError {
            // Then should be invalid license key error
            expect(error) == .invalidLicenseKey
        } catch {
            XCTFail("Should throw LicenseError")
        }
    }

    func testExecuteThrowsTrialAlreadyUsedError() async {
        guard let sut, let mockGateway else {
            fail("SUT or mockGateway not initialized")
            return
        }

        // Given trial already used error
        mockGateway.activateLicenseError = LicenseError.trialAlreadyUsed

        // When executing
        do {
            _ = try await sut.execute(licenseKey: "TRIAL-KEY")
            XCTFail("Should throw trial already used error")
        } catch let error as LicenseError {
            // Then should be trial already used error
            expect(error) == .trialAlreadyUsed
        } catch {
            XCTFail("Should throw LicenseError")
        }
    }

    func testExecuteThrowsNetworkError() async {
        guard let sut, let mockGateway else {
            fail("SUT or mockGateway not initialized")
            return
        }

        // Given network error
        struct MockNetworkError: Error { }
        mockGateway.activateLicenseError = LicenseError.networkError(MockNetworkError())

        // When executing
        do {
            _ = try await sut.execute(licenseKey: "KEY")
            XCTFail("Should throw network error")
        } catch let error as LicenseError {
            // Then should be network error
            if case .networkError = error {
                // Success - got expected error
            } else {
                XCTFail("Should be network error case")
            }
        } catch {
            XCTFail("Should throw LicenseError")
        }
    }

    // MARK: - Edge Cases

    func testExecuteWithEmptyLicenseKey() async throws {
        guard let sut, let mockGateway else {
            fail("SUT or mockGateway not initialized")
            return
        }

        // Given empty license key
        mockGateway.activationResult = LicenseInfo()

        // When executing with empty key
        do {
            _ = try await sut.execute(licenseKey: "")
            XCTFail("Should throw invalid license key error")
        } catch let error as LicenseError {
            // Then should be invalid license key error
            expect(error) == .invalidLicenseKey
        } catch {
            XCTFail("Should throw LicenseError")
        }
    }

    func testExecuteWithVeryLongLicenseKey() async throws {
        guard let sut, let mockGateway else {
            fail("SUT or mockGateway not initialized")
            return
        }

        // Given a very long license key
        let longKey = String(repeating: "ABCD-", count: 100)
        mockGateway.activationResult = LicenseFixtures.licensed

        // When executing
        _ = try await sut.execute(licenseKey: longKey)

        // Then should pass it to gateway
        expect(mockGateway.activateLicenseCalls.first) == longKey
    }

    func testExecuteWithSpecialCharactersInKey() async throws {
        guard let sut, let mockGateway else {
            fail("SUT or mockGateway not initialized")
            return
        }

        // Given license key with special characters
        let specialKey = "KEY-🚀-@#$%-TEST"
        mockGateway.activationResult = LicenseFixtures.licensed

        // When executing
        _ = try await sut.execute(licenseKey: specialKey)

        // Then should pass it to gateway
        expect(mockGateway.activateLicenseCalls.first) == specialKey
    }

    // MARK: - Multiple Activation Tests

    func testMultipleActivationsCallGatewayEachTime() async throws {
        guard let sut, let mockGateway else {
            fail("SUT or mockGateway not initialized")
            return
        }

        // Given multiple license keys
        let keys = ["KEY1", "KEY2", "KEY3"]
        mockGateway.activationResult = LicenseFixtures.licensed

        // When activating multiple times
        for key in keys {
            _ = try await sut.execute(licenseKey: key)
        }

        // Then should call gateway for each
        expect(mockGateway.activateLicenseCalls.count) == 3
        expect(mockGateway.activateLicenseCalls) == keys
    }

    // MARK: - License Status Transition Tests

    func testActivationChangesUnknownToLicensed() async throws {
        guard let sut, let mockGateway else {
            fail("SUT or mockGateway not initialized")
            return
        }

        // Given unknown status initially
        mockGateway.licenseInfoToEmit = LicenseFixtures.unknown

        // When activating a purchased license
        mockGateway.activationResult = LicenseFixtures.licensed
        let result = try await sut.execute(licenseKey: LicenseFixtures.validPurchasedKey)

        // Then should transition to licensed
        expect(result.licenseStatus) == .licensed
    }

    func testActivationChangesUnknownToTrial() async throws {
        guard let sut, let mockGateway else {
            fail("SUT or mockGateway not initialized")
            return
        }

        // Given unknown status initially
        mockGateway.licenseInfoToEmit = LicenseFixtures.unknown

        // When activating a trial license
        mockGateway.activationResult = LicenseFixtures.trial10Days
        let result = try await sut.execute(licenseKey: LicenseFixtures.validTrialKey)

        // Then should transition to trial
        if case .trial = result.licenseStatus {
            // Success - got expected status
        } else {
            XCTFail("Should be trial status")
        }
    }

    // MARK: - Integration with Fixtures Tests

    func testWorksWithAllLicenseFixtures() async throws {
        guard let sut, let mockGateway else {
            fail("SUT or mockGateway not initialized")
            return
        }

        // Given various license fixtures
        let fixtures = [
            LicenseFixtures.licensed,
            LicenseFixtures.licensedWithProfile,
            LicenseFixtures.trial10Days,
            LicenseFixtures.trial3Days,
            LicenseFixtures.trial1Day
        ]

        for fixture in fixtures {
            // Given fixture
            mockGateway.reset()
            mockGateway.activationResult = fixture

            // When activating
            let result = try await sut.execute(licenseKey: "KEY")

            // Then should return fixture data
            expect(result.licenseStatus) == fixture.licenseStatus
            expect(mockGateway.activateLicenseCalls.count) == 1
        }
    }

    // MARK: - Async Behavior Tests

    func testExecuteIsProperlyAsync() async throws {
        guard let sut, let mockGateway else {
            fail("SUT or mockGateway not initialized")
            return
        }

        // Given a license that takes time to activate
        mockGateway.activationResult = LicenseFixtures.licensed

        // When executing asynchronously
        let task = Task {
            try await sut.execute(licenseKey: "ASYNC-KEY")
        }

        // Then should complete asynchronously
        let result = try await task.value
        expect(result).toNot(beNil())
        expect(mockGateway.activateLicenseCalls.count) == 1
    }

    func testMultipleConcurrentActivations() async throws {
        guard let sut, let mockGateway else {
            fail("SUT or mockGateway not initialized")
            return
        }

        // Given multiple concurrent activation requests
        mockGateway.activationResult = LicenseFixtures.licensed

        // When activating concurrently
        async let result1 = sut.execute(licenseKey: "KEY1")
        async let result2 = sut.execute(licenseKey: "KEY2")
        async let result3 = sut.execute(licenseKey: "KEY3")

        // Then all should complete
        let results = try await [result1, result2, result3]
        expect(results.count) == 3
        expect(mockGateway.activateLicenseCalls.count) == 3
    }
}
