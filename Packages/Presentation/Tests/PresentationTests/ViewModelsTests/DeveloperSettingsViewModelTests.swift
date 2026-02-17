// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

#if DEBUG
    import Combine
    @testable import Domain
    import Nimble
    @testable import Presentation
    import XCTest

    /// Tests for DeveloperSettingsViewModel.
    ///
    /// These tests verify developer settings and feature flag management (DEBUG only).
    @MainActor
    final class DeveloperSettingsViewModelTests: XCTestCase {
        private var viewModel: DeveloperSettingsViewModel?

        // Mock gateways
        private var mockFeatureFlagsGateway: MockFeatureFlagsGateway?
        private var mockLicenseGateway: MockLicenseGateway?
        private var mockConfigurationGateway: MockConfigurationGateway?
        private var mockSoftwareUpdateGateway: MockSoftwareUpdateGateway?

        // Real use cases with mock gateways
        private var getFeatureFlagsUseCase: GetFeatureFlagsUseCase?
        private var setFeatureFlagsUseCase: SetFeatureFlagsUseCase?
        private var getEnableLicensingUseCase: GetEnableLicensingUseCase?
        private var setEnableLicensingUseCase: SetEnableLicensingUseCase?
        private var getEnableTrialRequestUseCase: GetEnableTrialRequestUseCase?
        private var setEnableTrialRequestUseCase: SetEnableTrialRequestUseCase?
        private var getMockActiveLicenseUseCase: GetMockActiveLicenseUseCase?
        private var setMockActiveLicenseUseCase: SetMockActiveLicenseUseCase?
        private var getCheckoutEnvironmentUseCase: GetCheckoutEnvironmentUseCase?
        private var setCheckoutEnvironmentUseCase: SetCheckoutEnvironmentUseCase?
        private var getLicenseInfoUseCase: GetLicenseInfoUseCase?
        private var resetLicenseFeatureFlagsUseCase: ResetLicenseFeatureFlagsUseCase?
        private var getHasAskedForScreenCapturePermissionsUseCase: GetHasAskedForScreenCapturePermissionsUseCase?

        override func setUp() async throws {
            try await super.setUp()

            // Initialize mock gateways
            mockFeatureFlagsGateway = MockFeatureFlagsGateway(flags: FeatureFlags.defaultFlags())
            mockLicenseGateway = MockLicenseGateway(
                licenseInfo: LicenseInfo(
                    licenseKey: "",
                    licenseStatus: .unknown,
                    userName: "",
                    email: ""
                ),
                enableLicensing: false,
                enableTrialRequest: false,
                mockActiveLicense: false,
                checkoutEnvironment: .production
            )
            mockConfigurationGateway = MockConfigurationGateway()
            mockConfigurationGateway?.setHasAskedForScreenCapturePermissions(false)
            mockSoftwareUpdateGateway = MockSoftwareUpdateGateway()

            // Initialize real use cases with mock gateways
            guard
                let featureFlagsGateway = mockFeatureFlagsGateway,
                let licenseGateway = mockLicenseGateway,
                let configurationGateway = mockConfigurationGateway,
                let softwareUpdateGateway = mockSoftwareUpdateGateway
            else {
                XCTFail("Mock gateways should be initialized")
                return
            }

            getFeatureFlagsUseCase = GetFeatureFlagsUseCase(gateway: featureFlagsGateway)
            setFeatureFlagsUseCase = SetFeatureFlagsUseCase(gateway: featureFlagsGateway)
            _ = CheckForUpdatesUseCase(softwareUpdateGateway: softwareUpdateGateway)
            _ = GetLastUpdateCheckDateUseCase(softwareUpdateGateway: softwareUpdateGateway)
            getEnableLicensingUseCase = GetEnableLicensingUseCase(gateway: licenseGateway)
            setEnableLicensingUseCase = SetEnableLicensingUseCase(gateway: licenseGateway)
            getEnableTrialRequestUseCase = GetEnableTrialRequestUseCase(gateway: licenseGateway)
            setEnableTrialRequestUseCase = SetEnableTrialRequestUseCase(gateway: licenseGateway)
            getMockActiveLicenseUseCase = GetMockActiveLicenseUseCase(gateway: licenseGateway)
            setMockActiveLicenseUseCase = SetMockActiveLicenseUseCase(gateway: licenseGateway)
            getCheckoutEnvironmentUseCase = GetCheckoutEnvironmentUseCase(licenseGateway: licenseGateway)
            setCheckoutEnvironmentUseCase = SetCheckoutEnvironmentUseCase(licenseGateway: licenseGateway)
            getLicenseInfoUseCase = GetLicenseInfoUseCase(licenseGateway: licenseGateway)
            resetLicenseFeatureFlagsUseCase = ResetLicenseFeatureFlagsUseCase(gateway: licenseGateway)
            getHasAskedForScreenCapturePermissionsUseCase =
                GetHasAskedForScreenCapturePermissionsUseCase(configurationGateway: configurationGateway)

            guard
                let getFeatureFlagsUseCase,
                let setFeatureFlagsUseCase,
                let getEnableLicensingUseCase,
                let setEnableLicensingUseCase,
                let getEnableTrialRequestUseCase,
                let setEnableTrialRequestUseCase,
                let getMockActiveLicenseUseCase,
                let setMockActiveLicenseUseCase,
                let getCheckoutEnvironmentUseCase,
                let setCheckoutEnvironmentUseCase,
                let getLicenseInfoUseCase,
                let resetLicenseFeatureFlagsUseCase,
                let getHasAskedForScreenCapturePermissionsUseCase
            else {
                XCTFail("Use cases should be initialized")
                return
            }

            viewModel = DeveloperSettingsViewModel(
                getFeatureFlagsUseCase: getFeatureFlagsUseCase,
                setFeatureFlagsUseCase: setFeatureFlagsUseCase,
                getEnableLicensingUseCase: getEnableLicensingUseCase,
                setEnableLicensingUseCase: setEnableLicensingUseCase,
                getEnableTrialRequestUseCase: getEnableTrialRequestUseCase,
                setEnableTrialRequestUseCase: setEnableTrialRequestUseCase,
                getMockActiveLicenseUseCase: getMockActiveLicenseUseCase,
                setMockActiveLicenseUseCase: setMockActiveLicenseUseCase,
                getCheckoutEnvironmentUseCase: getCheckoutEnvironmentUseCase,
                setCheckoutEnvironmentUseCase: setCheckoutEnvironmentUseCase,
                getLicenseInfoUseCase: getLicenseInfoUseCase,
                resetLicenseFeatureFlagsUseCase: resetLicenseFeatureFlagsUseCase,
                getHasAskedForScreenCapturePermissionsUseCase: getHasAskedForScreenCapturePermissionsUseCase
            )
        }

        override func tearDown() async throws {
            try await super.tearDown()
            viewModel = nil
            mockFeatureFlagsGateway = nil
            mockLicenseGateway = nil
            mockConfigurationGateway = nil
            getFeatureFlagsUseCase = nil
            setFeatureFlagsUseCase = nil
            getEnableLicensingUseCase = nil
            setEnableLicensingUseCase = nil
            getEnableTrialRequestUseCase = nil
            setEnableTrialRequestUseCase = nil
            getMockActiveLicenseUseCase = nil
            setMockActiveLicenseUseCase = nil
            getCheckoutEnvironmentUseCase = nil
            setCheckoutEnvironmentUseCase = nil
            getLicenseInfoUseCase = nil
            resetLicenseFeatureFlagsUseCase = nil
            getHasAskedForScreenCapturePermissionsUseCase = nil
            try await super.tearDown()
        }

        // MARK: - Initialization Tests

        func testInitialization() {
            guard let viewModel else {
                XCTFail("ViewModel not initialized")
                return
            }

            expect(viewModel.featureFlags).toNot(beNil())
            expect(viewModel.enableLicensing) == false
            expect(viewModel.mockActiveLicense) == false
        }

        // MARK: - Feature Flag Tests

        func testSetEnableGroups() {
            guard
                let viewModel,
                let mockFeatureFlagsGateway
            else {
                XCTFail("ViewModel or mock gateway not initialized")
                return
            }

            viewModel.setEnableGroups(false)
            let lastFlags = mockFeatureFlagsGateway.lastFlags
            expect(lastFlags?.enableGroups) == false
        }

        func testSetEnableSpaces() {
            guard
                let viewModel,
                let mockFeatureFlagsGateway
            else {
                XCTFail("ViewModel or mock gateway not initialized")
                return
            }

            viewModel.setEnableSpaces(false)
            let lastFlags = mockFeatureFlagsGateway.lastFlags
            expect(lastFlags?.enableSpaces) == false
        }

        func testResetToDefaults() {
            guard
                let viewModel,
                let mockFeatureFlagsGateway
            else {
                XCTFail("ViewModel or mock gateway not initialized")
                return
            }

            viewModel.resetToDefaults()
            let resetCalled = mockFeatureFlagsGateway.resetCalled
            expect(resetCalled) == true
        }
    }

    // MARK: - Mock Gateways

    // Using shared mocks from MockGateways.swift
#endif
