// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Nimble
import XCTest

/// Tests for GetLicenseInfoUseCase.
///
/// These tests validate reactive license information retrieval.
/// Critical for license management and bug fix validation.
@MainActor
final class GetLicenseInfoUseCaseTests: XCTestCase {
    private var sut: GetLicenseInfoUseCase?
    private var mockGateway: MockLicenseGateway?
    private var cancellables: Set<AnyCancellable>?

    override func setUp() async throws {
        try await super.setUp()
        let gateway = MockLicenseGateway()
        mockGateway = gateway
        sut = GetLicenseInfoUseCase(licenseGateway: gateway)
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() async throws {
        try await super.tearDown()
        cancellables?.removeAll()
        sut = nil
        mockGateway = nil
        cancellables = nil
    }

    // MARK: - Basic Functionality Tests

    func testExecuteReturnsPublisher() {
        guard let sut else {
            fail("Test dependencies not initialized")
            return
        }

        // When getting the publisher
        let publisher = sut.execute()

        // Then should return a publisher
        expect(publisher).toNot(beNil())
    }

    func testPublisherEmitsInitialValue() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given initial license info
        mockGateway.emitLicenseInfo(LicenseFixtures.unknown)

        // When getting the publisher
        let publisher = sut.execute()

        // Then should emit initial value
        var receivedValue: LicenseInfo?
        let cancellable = publisher
            .first()
            .sink { value in
                receivedValue = value
            }
        try await Task.sleep(for: .milliseconds(100))
        expect(receivedValue?.licenseStatus) == .unknown
        cancellable.cancel()
    }

    func testPublisherEmitsLicensedStatus() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given licensed status
        mockGateway.emitLicenseInfo(LicenseFixtures.licensed)

        // When getting the publisher
        let publisher = sut.execute()

        // Then should emit licensed info
        var receivedValue: LicenseInfo?
        let cancellable = publisher
            .first()
            .sink { value in
                receivedValue = value
            }
        try await Task.sleep(for: .milliseconds(100))
        expect(receivedValue?.licenseStatus) == .licensed
        expect(receivedValue?.isActive) == true
        expect(receivedValue?.licenseKey) == LicenseFixtures.validPurchasedKey
        cancellable.cancel()
    }

    func testPublisherEmitsTrialStatus() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given trial status
        mockGateway.emitLicenseInfo(LicenseFixtures.trial1Day)

        // When getting the publisher
        let publisher = sut.execute()

        // Then should emit trial info
        var receivedValue: LicenseInfo?
        let cancellable = publisher
            .first()
            .sink { value in
                receivedValue = value
            }
        try await Task.sleep(for: .milliseconds(100))
        if case let .trial(days) = receivedValue?.licenseStatus {
            expect(days) == 1
            expect(receivedValue?.isActive) == true
        } else {
            XCTFail("Expected trial status")
        }
        cancellable.cancel()
    }

    func testPublisherEmitsExpiredStatus() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given expired status
        mockGateway.emitLicenseInfo(LicenseFixtures.expiredTrial)

        // When getting the publisher
        let publisher = sut.execute()

        // Then should emit expired info
        var value: LicenseInfo?
        let cancellable = publisher
            .first()
            .sink { licenseInfo in
                value = licenseInfo
            }
        try await Task.sleep(for: .milliseconds(100))
        expect(value?.licenseStatus) == .expired
        expect(value?.isActive) == false
        cancellable.cancel()
    }

    // MARK: - Reactive Updates Tests

    // MARK: - CRITICAL: License Bug Fix Validation Tests

    func testPublisherEmitsPurchasedLicenseNotExpired() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // CRITICAL: Validates that purchased licenses are never expired
        // Given a purchased license (not trial)
        mockGateway.emitLicenseInfo(LicenseFixtures.licensed)

        // When getting license info
        let publisher = sut.execute()

        // Then should be licensed, NOT expired
        var value: LicenseInfo?
        let cancellable = publisher
            .first()
            .sink { licenseInfo in
                value = licenseInfo
            }
        try await Task.sleep(for: .milliseconds(100))
        expect(value?.licenseStatus) == .licensed
        expect(value?.isActive) == true
        cancellable.cancel()
    }

    // MARK: - Publisher Behavior Tests

    func testMultipleSubscribersReceiveSameValue() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given licensed status
        mockGateway.emitLicenseInfo(LicenseFixtures.licensed)

        // When multiple subscribers subscribe
        let publisher = sut.execute()

        // Then both should receive the same value
        var value1: LicenseInfo?
        var value2: LicenseInfo?
        let cancellable1 = publisher
            .first()
            .sink { licenseInfo in
                value1 = licenseInfo
            }
        let cancellable2 = publisher
            .first()
            .sink { licenseInfo in
                value2 = licenseInfo
            }
        try await Task.sleep(for: .milliseconds(100))
        expect(value1?.licenseKey) == value2?.licenseKey
        expect(value1?.licenseStatus) == value2?.licenseStatus
        cancellable1.cancel()
        cancellable2.cancel()
    }

    func testPublisherNeverFails() {
        guard let sut, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given publisher (should use Never as failure type)
        let publisher = sut.execute()

        // Then failure type should be Never
        publisher.sink { _ in }
            .store(in: &cancellables)

        // Type system enforces this - if this compiles, test passes
    }

    func testCancellingSubscriptionStopsUpdates() async {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given a subscription
        mockGateway.emitLicenseInfo(LicenseFixtures.unknown)

        var receivedCount = 0
        let cancellable = sut.execute()
            .sink { _ in
                receivedCount += 1
            }

        // When cancelling after first emission
        cancellable.cancel()

        // And gateway emits new values
        mockGateway.emitLicenseInfo(LicenseFixtures.licensed)
        mockGateway.emitLicenseInfo(LicenseFixtures.trial10Days)

        // Then should only have received initial value
        // Wait a bit to ensure no more emissions
        try? await Task.sleep(for: .milliseconds(100))
        expect(receivedCount) == 1
    }

    // MARK: - Integration with Fixtures Tests

    func testAllLicenseFixtures() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given all license fixtures
        let fixtures = [
            LicenseFixtures.unknown,
            LicenseFixtures.licensed,
            LicenseFixtures.licensedWithProfile,
            LicenseFixtures.trial10Days,
            LicenseFixtures.trial3Days,
            LicenseFixtures.trial1Day,
            LicenseFixtures.expiredTrial
        ]

        for fixture in fixtures {
            // When setting fixture
            mockGateway.emitLicenseInfo(fixture)

            // Then publisher should emit fixture
            var value: LicenseInfo?
            let cancellable = sut.execute()
                .first()
                .sink { licenseInfo in
                    value = licenseInfo
                }
            try await Task.sleep(for: .milliseconds(100))
            expect(value?.licenseStatus) == fixture.licenseStatus
            cancellable.cancel()
        }
    }

    func testCustomFixtures() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given custom license fixtures
        let customLicensed = LicenseFixtures.licensed(
            key: "CUSTOM-KEY",
            userName: "Custom User",
            email: "custom@test.com"
        )
        mockGateway.emitLicenseInfo(customLicensed)

        // When getting license info
        var value: LicenseInfo?
        let cancellable = sut.execute()
            .first()
            .sink { licenseInfo in
                value = licenseInfo
            }
        try await Task.sleep(for: .milliseconds(100))

        // Then should match custom fixture
        expect(value?.licenseKey) == "CUSTOM-KEY"
        expect(value?.userName) == "Custom User"
        expect(value?.email) == "custom@test.com"
        expect(value?.licenseStatus) == .licensed
        cancellable.cancel()
    }

    // MARK: - Edge Cases

    func testEmptyLicenseKey() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given license with empty key
        let emptyKeyLicense = LicenseInfo(licenseKey: "")
        mockGateway.emitLicenseInfo(emptyKeyLicense)

        // When getting license info
        var value: LicenseInfo?
        let cancellable = sut.execute()
            .first()
            .sink { licenseInfo in
                value = licenseInfo
            }
        try await Task.sleep(for: .milliseconds(100))

        // Then should handle empty key
        expect(value?.licenseKey.isEmpty) == true
        cancellable.cancel()
    }

    func testLicenseWithAllFieldsPopulated() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given license with all fields
        let fullLicense = LicenseFixtures.licensedWithProfile
        mockGateway.emitLicenseInfo(fullLicense)

        // When getting license info
        var value: LicenseInfo?
        let cancellable = sut.execute()
            .first()
            .sink { licenseInfo in
                value = licenseInfo
            }
        try await Task.sleep(for: .milliseconds(100))

        // Then all fields should be present
        expect(value?.licenseKey.isEmpty) == false
        expect(value?.userName.isEmpty) == false
        expect(value?.email.isEmpty) == false
        expect(value?.profileImageData).toNot(beNil())
        cancellable.cancel()
    }

    // MARK: - State Transition Tests

    // MARK: - Memory Management Tests

    func testPublisherDoesNotRetainUseCase() {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given a publisher
        weak var weakSut: GetLicenseInfoUseCase?

        autoreleasepool {
            let localSut = GetLicenseInfoUseCase(licenseGateway: mockGateway)
            weakSut = localSut
            _ = localSut.execute()
        }

        // Then use case should be deallocated
        // (Publisher shouldn't create retain cycle)
        expect(weakSut).to(beNil())
    }

    // MARK: - Concurrent Access Tests

    func testConcurrentSubscriptions() async throws {
        guard let sut, let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given multiple concurrent subscriptions
        mockGateway.emitLicenseInfo(LicenseFixtures.licensed)

        // When subscribing concurrently
        var value1: LicenseInfo?
        var value2: LicenseInfo?
        var value3: LicenseInfo?

        let cancellable1 = sut.execute()
            .first()
            .sink { licenseInfo in
                value1 = licenseInfo
            }
        let cancellable2 = sut.execute()
            .first()
            .sink { licenseInfo in
                value2 = licenseInfo
            }
        let cancellable3 = sut.execute()
            .first()
            .sink { licenseInfo in
                value3 = licenseInfo
            }

        try await Task.sleep(for: .milliseconds(100))

        cancellable1.cancel()
        cancellable2.cancel()
        cancellable3.cancel()

        guard let value1, let value2, let value3 else {
            fail("All values should be present")
            return
        }

        let values = [value1, value2, value3]

        // Then all should receive the same value
        expect(values[0].licenseKey) == values[1].licenseKey
        expect(values[1].licenseKey) == values[2].licenseKey
    }
}
