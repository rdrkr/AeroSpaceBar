// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import AppKit
import Combine
@testable import Domain
import Nimble
@testable import Presentation
import XCTest

/// Tests for LicenseViewModel.
///
/// These tests verify license management operations including:
/// - License activation and deactivation
/// - Trial checkout workflow
/// - Reactive license state updates
@MainActor
final class LicenseViewModelTests: XCTestCase {
    private var viewModel: LicenseViewModel?
    private var mockLicenseGateway: MockLicenseGateway?
    private var mockFeatureFlagsGateway: MockFeatureFlagsGateway?
    private var cancellables: Set<AnyCancellable>?

    override func setUp() async throws {
        try await super.setUp()
        cancellables = Set<AnyCancellable>()

        // Initialize mock gateways
        mockLicenseGateway = MockLicenseGateway()
        mockFeatureFlagsGateway = MockFeatureFlagsGateway(flags: FeatureFlags.defaultFlags())

        // Initialize real use cases with mock gateways
        guard let licenseGateway = mockLicenseGateway, mockFeatureFlagsGateway != nil else {
            XCTFail("Mock gateways should be initialized")
            return
        }

        let getLicenseInfoUseCase = GetLicenseInfoUseCase(licenseGateway: licenseGateway)
        let getEnableLicensingUseCase = GetEnableLicensingUseCase(gateway: licenseGateway)
        let getEnableTrialRequestUseCase = GetEnableTrialRequestUseCase(gateway: licenseGateway)
        let activateLicenseUseCase = ActivateLicenseUseCase(licenseGateway: licenseGateway)
        let deactivateLicenseUseCase = DeactivateLicenseUseCase(licenseGateway: licenseGateway)
        let openCheckoutUseCase = OpenCheckoutUseCase(licenseGateway: licenseGateway)
        let setUserNameUseCase = SetUserNameUseCase(licenseGateway: licenseGateway)
        let setProfileImageDataUseCase = SetProfileImageDataUseCase(licenseGateway: licenseGateway)
        let hasTrialBeenUsedUseCase = HasTrialBeenUsedUseCase(licenseGateway: licenseGateway)

        viewModel = LicenseViewModel(
            getLicenseInfoUseCase: getLicenseInfoUseCase,
            activateLicenseUseCase: activateLicenseUseCase,
            openCheckoutUseCase: openCheckoutUseCase,
            deactivateLicenseUseCase: deactivateLicenseUseCase,
            getEnableLicensingUseCase: getEnableLicensingUseCase,
            getEnableTrialRequestUseCase: getEnableTrialRequestUseCase,
            setUserNameUseCase: setUserNameUseCase,
            setProfileImageDataUseCase: setProfileImageDataUseCase,
            hasTrialBeenUsedUseCase: hasTrialBeenUsedUseCase
        )
    }

    // MARK: - Initialization Tests

    func testInitialization() {
        guard let viewModel else {
            XCTFail("ViewModel should be initialized")
            return
        }

        expect(viewModel.isLicensed) == false
        expect(viewModel.enableLicense) == false // Default mock value is false
        expect(viewModel.enableTrialRequest) == false // Default mock value is false
        expect(viewModel.isActivating) == false
        expect(viewModel.licenseKeyInput).to(beEmpty())
    }

    // MARK: - License Activation Tests

    func testActivateLicenseSuccess() {
        guard let mockLicenseGateway, let viewModel else {
            XCTFail("Mock license gateway or viewModel should be initialized")
            return
        }

        // Set up the mock to return successful activation
        mockLicenseGateway.activationResult = LicenseInfo(licenseKey: "TEST-LICENSE-KEY", licenseStatus: .licensed)

        viewModel.licenseKeyInput = "TEST-LICENSE-KEY"
        viewModel.activateLicense()

        // Wait for async operation
        expect(viewModel.isLicensed).toEventually(beTrue())
    }

    func testActivateLicenseEmptyKey() {
        guard let viewModel else {
            XCTFail("ViewModel should be initialized")
            return
        }

        viewModel.licenseKeyInput = ""
        viewModel.activateLicense()
        expect(viewModel.activationError).toEventuallyNot(beNil())
    }

    // MARK: - Checkout Tests

    func testOpenCheckout() {
        guard let viewModel else {
            XCTFail("ViewModel should be initialized")
            return
        }

        viewModel.openCheckout()
        expect(viewModel.checkoutURL).toEventuallyNot(beNil())
        expect(viewModel.showingCheckoutWebView).toEventually(beTrue())
    }

    func testOpenTrialCheckout() {
        guard let viewModel else {
            XCTFail("ViewModel should be initialized")
            return
        }

        viewModel.openTrialCheckout()
        expect(viewModel.checkoutURL).toEventuallyNot(beNil())
        expect(viewModel.showingCheckoutWebView).toEventually(beTrue())
    }

    func testOpenTrialCheckoutWhenAlreadyUsed() {
        guard let mockLicenseGateway, let viewModel else {
            XCTFail("Mock license gateway or viewModel should be initialized")
            return
        }

        // Set up trial as already used
        mockLicenseGateway.trialHasBeenUsed = true

        viewModel.openTrialCheckout()
        expect(viewModel.activationError).toEventuallyNot(beNil())
        expect(viewModel.showingCheckoutWebView).toEventually(beFalse())
    }

    func testDismissCheckoutWebView() {
        guard let viewModel else {
            XCTFail("ViewModel should be initialized")
            return
        }

        viewModel.openCheckout()
        viewModel.dismissCheckoutWebView()
        expect(viewModel.checkoutURL).toEventually(beNil())
        expect(viewModel.showingCheckoutWebView).toEventually(beFalse())
    }

    override func tearDown() async throws {
        try await super.tearDown()
        cancellables?.removeAll()
        viewModel = nil
        mockLicenseGateway = nil
        mockFeatureFlagsGateway = nil
        cancellables = nil
    }
}
