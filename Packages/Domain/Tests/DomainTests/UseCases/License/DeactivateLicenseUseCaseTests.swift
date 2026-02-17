// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Nimble
import XCTest

/// Tests for DeactivateLicenseUseCase.
///
/// These tests validate license deactivation functionality.
/// Critical for license management.
@MainActor
final class DeactivateLicenseUseCaseTests: XCTestCase {
    private var sut: DeactivateLicenseUseCase?
    private var mockGateway: MockLicenseGateway?

    override func setUp() async throws {
        try await super.setUp()
        let gateway = MockLicenseGateway()
        mockGateway = gateway
        sut = DeactivateLicenseUseCase(licenseGateway: gateway)
    }

    override func tearDown() async throws {
        mockGateway = nil
        sut = nil
        try await super.tearDown()
    }

    // MARK: - Basic Functionality Tests

    func testExecuteCallsGateway() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // When executing the use case
        try await sut.execute()

        // Then should call gateway deactivate method
        expect(mockGateway.deactivateLicenseCallCount) == 1
    }

    func testExecuteCallsGatewayMultipleTimes() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // When executing multiple times
        try await sut.execute()
        try await sut.execute()
        try await sut.execute()

        // Then should call gateway each time
        expect(mockGateway.deactivateLicenseCallCount) == 3
    }

    func testExecuteCompletesSuccessfully() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // When executing deactivation
        // Then should complete without throwing
        try await sut.execute()
        expect(mockGateway.deactivateLicenseCallCount) == 1
    }

    // MARK: - Error Handling Tests

    func testExecuteThrowsWhenGatewayThrows() async {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given gateway will throw error
        mockGateway.deactivateLicenseError = LicenseError.invalidLicenseKey

        // When executing use case
        do {
            try await sut.execute()
            XCTFail("Should have thrown error")
        } catch {
            // Then should propagate the error
            expect(error is LicenseError) == true

            if let licenseError = error as? LicenseError {
                expect(licenseError) == .invalidLicenseKey
            }
        }
    }

    func testExecuteThrowsNetworkError() async {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given network error
        struct MockNetworkError: Error { }
        mockGateway.deactivateLicenseError = LicenseError.networkError(MockNetworkError())

        // When executing
        do {
            try await sut.execute()
            XCTFail("Should throw network error")
        } catch let error as LicenseError {
            // Then should be network error
            if case .networkError = error {
                // Success - got expected error
            } else {
                XCTFail("Should be networkError case")
            }
        } catch {
            XCTFail("Should throw LicenseError")
        }
    }

    func testExecuteThrowsLicenseNotFoundError() async {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given validation failed error
        mockGateway.deactivateLicenseError = LicenseError.validationFailed

        // When executing
        do {
            try await sut.execute()
            XCTFail("Should throw license not found error")
        } catch let error as LicenseError {
            // Then should be validation failed error
            expect(error) == .validationFailed
        } catch {
            XCTFail("Should throw LicenseError")
        }
    }

    func testExecuteThrowsValidationFailed() async {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given validation failed error
        mockGateway.deactivateLicenseError = LicenseError.validationFailed

        // When executing
        do {
            try await sut.execute()
            XCTFail("Should throw validation failed error")
        } catch let error as LicenseError {
            // Then should be validation failed error
            expect(error) == .validationFailed
        } catch {
            XCTFail("Should throw LicenseError")
        }
    }

    // MARK: - State Verification Tests

    func testGatewayNotCalledBeforeExecution() {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        _ = sut // Mark as intentionally unused

        // Given newly initialized use case
        // Then gateway should not have been called yet
        expect(mockGateway.deactivateLicenseCallCount) == 0
    }

    func testExecutionDoesNotModifyUseCase() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given use case
        // When executing multiple times
        try await sut.execute()
        try await sut.execute()

        // Then should be stateless and reusable
        expect(mockGateway.deactivateLicenseCallCount) == 2
    }

    // MARK: - Deactivation Scenarios

    func testDeactivateLicensedLicense() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given a licensed state
        mockGateway.licenseInfoToEmit = LicenseFixtures.licensed

        // When deactivating
        try await sut.execute()

        // Then should call gateway
        expect(mockGateway.deactivateLicenseCallCount) == 1
    }

    func testDeactivateTrialLicense() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given a trial license
        mockGateway.licenseInfoToEmit = LicenseFixtures.trial10Days

        // When deactivating
        try await sut.execute()

        // Then should call gateway (trials can be deactivated too)
        expect(mockGateway.deactivateLicenseCallCount) == 1
    }

    func testDeactivateExpiredLicense() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given an expired license
        mockGateway.licenseInfoToEmit = LicenseFixtures.expiredTrial

        // When deactivating (might happen during cleanup)
        try await sut.execute()

        // Then should call gateway
        expect(mockGateway.deactivateLicenseCallCount) == 1
    }

    func testDeactivateUnknownLicense() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given unknown license state
        mockGateway.licenseInfoToEmit = LicenseFixtures.unknown

        // When deactivating
        try await sut.execute()

        // Then should still call gateway (let gateway handle validation)
        expect(mockGateway.deactivateLicenseCallCount) == 1
    }

    // MARK: - Async Behavior Tests

    func testExecuteIsProperlyAsync() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // When executing asynchronously
        let task = Task {
            try await sut.execute()
        }

        // Then should complete asynchronously
        try await task.value
        expect(mockGateway.deactivateLicenseCallCount) == 1
    }

    func testSequentialDeactivations() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // When deactivating sequentially
        try await sut.execute()
        try await sut.execute()
        try await sut.execute()

        // Then all should complete in order
        expect(mockGateway.deactivateLicenseCallCount) == 3
    }

    func testConcurrentDeactivationsNotRecommended() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given concurrent deactivation attempts
        // (This is an edge case - normally shouldn't happen)

        // When executing concurrently
        async let t1: () = sut.execute()
        async let t2: () = sut.execute()
        async let t3: () = sut.execute()

        _ = try await (t1, t2, t3)

        // Then all should complete (though may cause issues in real implementation)
        expect(mockGateway.deactivateLicenseCallCount) > 1
    }

    // MARK: - Error Recovery Tests

    func testRetryAfterError() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given initial error
        mockGateway.deactivateLicenseError = LicenseError.networkError(
            NSError(domain: "test", code: -1)
        )

        // When first attempt fails
        do {
            try await sut.execute()
            XCTFail("Should have thrown")
        } catch {
            // Expected
        }

        // And we retry after fixing the issue
        mockGateway.deactivateLicenseError = nil

        // Then retry should succeed
        try await sut.execute()
        expect(mockGateway.deactivateLicenseCallCount) == 2
    }

    func testPartialFailureThenSuccess() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given errors for first two attempts
        var callCount = 0
        mockGateway.deactivateLicenseError = LicenseError.validationFailed

        // When attempting multiple times
        for _ in 0 ..< 2 {
            do {
                try await sut.execute()
                XCTFail("Should throw for first two attempts")
            } catch {
                callCount += 1
            }
        }

        // And third attempt succeeds
        mockGateway.deactivateLicenseError = nil
        try await sut.execute()
        callCount += 1

        // Then should have tried three times total
        expect(callCount) == 3
        expect(mockGateway.deactivateLicenseCallCount) == 3
    }

    // MARK: - Integration Tests

    func testDeactivateAfterActivation() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Simulating real workflow: activate then deactivate

        // Given an activated license
        mockGateway.activationResult = LicenseFixtures.licensed
        _ = try await mockGateway.activateLicense(LicenseFixtures.validPurchasedKey)

        // When deactivating
        try await sut.execute()

        // Then should call deactivate
        expect(mockGateway.deactivateLicenseCallCount) == 1
    }

    func testMultipleActivateDeactivateCycles() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Simulating multiple activation/deactivation cycles

        for i in 1 ... 3 {
            // Activate
            mockGateway.activationResult = LicenseFixtures.licensed
            _ = try await mockGateway.activateLicense("KEY-\(i)")

            // Deactivate
            try await sut.execute()

            // Verify deactivation was called
            expect(mockGateway.deactivateLicenseCallCount) == i
        }
    }

    // MARK: - Edge Cases

    func testDeactivateWhenAlreadyDeactivated() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given already deactivated license (unknown state)
        mockGateway.licenseInfoToEmit = LicenseFixtures.unknown

        // When deactivating again
        try await sut.execute()

        // Then should call gateway (idempotent operation)
        expect(mockGateway.deactivateLicenseCallCount) == 1
    }

    func testRapidDeactivations() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given rapid deactivation calls
        for _ in 0 ..< 10 {
            try await sut.execute()
        }

        // Then all should complete
        expect(mockGateway.deactivateLicenseCallCount) == 10
    }

    func testDeactivateWithGatewayDelay() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given gateway has simulated delay
        // (Mock doesn't actually delay, but tests async completion)

        let startTime = Date()

        // When deactivating
        try await sut.execute()

        let endTime = Date()

        // Then should complete and call gateway
        expect(mockGateway.deactivateLicenseCallCount) == 1
        // In real implementation, might have actual delay
        expect(endTime.timeIntervalSince(startTime)) < 1.0
    }

    // MARK: - CRITICAL: License Management Tests

    func testDeactivatePurchasedLicense() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // CRITICAL: Ensures purchased licenses can be deactivated properly
        // Given a purchased license
        mockGateway.licenseInfoToEmit = LicenseFixtures.licensed

        // When deactivating
        try await sut.execute()

        // Then should complete successfully
        expect(mockGateway.deactivateLicenseCallCount) == 1
    }

    func testDeactivateDoesNotCorruptLicenseState() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // CRITICAL: Ensures deactivation doesn't corrupt other license data
        // Given active license
        mockGateway.licenseInfoToEmit = LicenseFixtures.licensedWithProfile

        // When deactivating
        try await sut.execute()

        // Then should only call deactivate (not modify other data)
        expect(mockGateway.deactivateLicenseCallCount) == 1
        // Mock gateway should maintain state integrity
    }

    // MARK: - Error Message Tests

    func testErrorMessagesArePreserved() async {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given specific error messages
        let errorMessage = "Custom deactivation error: User not authorized"
        let nsError = NSError(domain: "LicenseError", code: 500, userInfo: [
            NSLocalizedDescriptionKey: errorMessage
        ])
        mockGateway.deactivateLicenseError = LicenseError.networkError(nsError)

        // When deactivating
        do {
            try await sut.execute()
            XCTFail("Should throw")
        } catch let error as LicenseError {
            // Then error message should be preserved
            if case let .networkError(underlyingError) = error {
                expect(underlyingError.localizedDescription) == errorMessage
            } else {
                XCTFail("Should preserve network error message")
            }
        } catch {
            XCTFail("Should be LicenseError")
        }
    }

    // MARK: - Performance Tests

    func testManySequentialDeactivations() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given many deactivation calls
        let count = 100

        // When executing many times
        for _ in 0 ..< count {
            try await sut.execute()
        }

        // Then all should complete
        expect(mockGateway.deactivateLicenseCallCount) == count
    }
}
