// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
@testable import Domain
import Foundation
import Nimble
import XCTest

/// Tests for LicenseGateway protocol.
///
/// These tests verify:
/// - Protocol conformance
/// - Publisher requirements
/// - License activation/deactivation
/// - Checkout URL generation
/// - Feature flag management
/// - Profile management
/// - Trial tracking
@MainActor
final class LicenseGatewayTests: XCTestCase {
    private var sut: MockLicenseGateway?
    private var cancellables = Set<AnyCancellable>()

    override func setUp() async throws {
        try await super.setUp()
        sut = MockLicenseGateway()
    }

    override func tearDown() async throws {
        cancellables.removeAll()
        try await super.tearDown()
    }

    // MARK: - Publisher Tests

    func testLicenseInfoPublisher() async {
        guard let sut else { XCTFail("SUT not initialized")
            return
        }

        let expectation = expectation(description: "Publisher emits license info")
        var receivedInfo: LicenseInfo?

        sut.licenseInfoPublisher
            .sink { info in
                receivedInfo = info
                expectation.fulfill()
            }
            .store(in: &cancellables)

        await fulfillment(of: [expectation], timeout: 1.0)
        expect(receivedInfo).toNot(beNil())
    }

    func testEnableLicensingPublisher() async {
        guard let sut else { XCTFail("SUT not initialized")
            return
        }

        let expectation = expectation(description: "Publisher emits licensing enabled state")
        var receivedState: Bool?

        sut.enableLicensingPublisher
            .sink { enabled in
                receivedState = enabled
                expectation.fulfill()
            }
            .store(in: &cancellables)

        await fulfillment(of: [expectation], timeout: 1.0)
        expect(receivedState).toNot(beNil())
    }

    func testEnableTrialRequestPublisher() async {
        guard let sut else { XCTFail("SUT not initialized")
            return
        }

        let expectation = expectation(description: "Publisher emits trial request enabled state")
        var receivedState: Bool?

        sut.enableTrialRequestPublisher
            .sink { enabled in
                receivedState = enabled
                expectation.fulfill()
            }
            .store(in: &cancellables)

        await fulfillment(of: [expectation], timeout: 1.0)
        expect(receivedState).toNot(beNil())
    }

    #if DEBUG
        func testMockActiveLicensePublisher() async {
            guard let sut else { XCTFail("SUT not initialized")
                return
            }

            let expectation = expectation(description: "Publisher emits mock license state")
            var receivedState: Bool?

            sut.mockActiveLicensePublisher
                .sink { enabled in
                    receivedState = enabled
                    expectation.fulfill()
                }
                .store(in: &cancellables)

            await fulfillment(of: [expectation], timeout: 1.0)
            expect(receivedState).toNot(beNil())
        }

        func testCheckoutEnvironmentPublisher() async {
            guard let sut else { XCTFail("SUT not initialized")
                return
            }

            let expectation = expectation(description: "Publisher emits checkout environment")
            var receivedEnvironment: CheckoutEnvironment?

            sut.checkoutEnvironmentPublisher
                .sink { env in
                    receivedEnvironment = env
                    expectation.fulfill()
                }
                .store(in: &cancellables)

            await fulfillment(of: [expectation], timeout: 1.0)
            expect(receivedEnvironment).toNot(beNil())
        }
    #endif

    // MARK: - License Activation Tests

    func testActivateLicense() async throws {
        guard let sut else { XCTFail("SUT not initialized")
            return
        }

        let licenseKey = "TEST-KEY-1234"

        let licenseInfo = try await sut.activateLicense(licenseKey)

        expect(licenseInfo.licenseKey) == licenseKey
        expect(licenseInfo.licenseStatus) == LicenseStatus.licensed
    }

    func testDeactivateLicense() async throws {
        guard let sut else { XCTFail("SUT not initialized")
            return
        }

        _ = try await sut.activateLicense("TEST-KEY-1234")

        try await sut.deactivateLicense()
    }

    // MARK: - Checkout URL Tests

    func testGetCheckoutURL() {
        guard let sut else { XCTFail("SUT not initialized")
            return
        }

        let url = sut.getCheckoutURL()

        expect(url).toNot(beNil())
        expect(url.absoluteString.isEmpty) == false
    }

    func testGetTrialCheckoutURL() {
        guard let sut else { XCTFail("SUT not initialized")
            return
        }

        let url = sut.getTrialCheckoutURL()

        expect(url).toNot(beNil())
        expect(url.absoluteString.isEmpty) == false
    }

    // MARK: - Checkout Success Tests

    func testHandleCheckoutSuccess() async {
        guard let sut else { XCTFail("SUT not initialized")
            return
        }

        let licenseKey = "CHECKOUT-SUCCESS-KEY"

        await sut.handleCheckoutSuccess(licenseKey: licenseKey)
    }

    // MARK: - Feature Flag Tests

    func testSetEnableLicensing() {
        guard let sut else { XCTFail("SUT not initialized")
            return
        }

        sut.setEnableLicensing(true)
        sut.setEnableLicensing(false)
    }

    func testSetEnableTrialRequest() {
        guard let sut else { XCTFail("SUT not initialized")
            return
        }

        sut.setEnableTrialRequest(true)
        sut.setEnableTrialRequest(false)
    }

    #if DEBUG
        func testSetMockActiveLicense() {
            guard let sut else { XCTFail("SUT not initialized")
                return
            }

            sut.setMockActiveLicense(true)
            sut.setMockActiveLicense(false)
        }

        func testSetCheckoutEnvironment() {
            guard let sut else { XCTFail("SUT not initialized")
                return
            }

            sut.setCheckoutEnvironment(.production)
            sut.setCheckoutEnvironment(.development)
        }
    #endif

    func testResetLicenseFeatureFlags() async {
        guard let sut else { XCTFail("SUT not initialized")
            return
        }

        await sut.resetLicenseFeatureFlags()
    }

    // MARK: - Profile Management Tests

    func testSetUserName() async {
        guard let sut else { XCTFail("SUT not initialized")
            return
        }

        let userName = "Test User"

        await sut.setUserName(userName)
    }

    func testSetProfileImageData() async {
        guard let sut else { XCTFail("SUT not initialized")
            return
        }

        let imageData = Data([0x00, 0x01, 0x02])

        await sut.setProfileImageData(imageData)
    }

    func testSetProfileImageDataNil() async {
        guard let sut else { XCTFail("SUT not initialized")
            return
        }

        await sut.setProfileImageData(nil)
    }

    // MARK: - Trial Tracking Tests

    func testHasTrialBeenUsedDefault() {
        guard let sut else { XCTFail("SUT not initialized")
            return
        }

        let hasTrialBeenUsed = sut.hasTrialBeenUsed()

        expect(hasTrialBeenUsed) == false
    }

    func testHasTrialBeenUsedAfterActivation() async throws {
        guard let sut else { XCTFail("SUT not initialized")
            return
        }

        _ = try await sut.activateLicense("TRIAL-KEY")
        sut.trialHasBeenUsed = true

        let hasTrialBeenUsed = sut.hasTrialBeenUsed()

        expect(hasTrialBeenUsed) == true
    }

    // MARK: - Protocol Conformance Tests

    func testProtocolConformance() {
        guard let sut else { XCTFail("SUT not initialized")
            return
        }

        let gateway: any LicenseGateway = sut

        // Should compile and have required publishers
        _ = gateway.licenseInfoPublisher
        _ = gateway.enableLicensingPublisher
        _ = gateway.enableTrialRequestPublisher
    }
}
