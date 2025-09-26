// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

#if DEBUG
    import Combine
    import Domain
    import Foundation

    /// ViewModel for managing developer settings and feature flags.
    ///
    /// This view model provides reactive bindings for feature flag toggles
    /// and handles persistence through use cases. Only available in debug builds.
    @MainActor
    final class DeveloperSettingsViewModel: ObservableObject {
        /// The current feature flags configuration.
        ///
        /// When this property is updated, the changes are automatically persisted
        /// through the set feature flags use case.
        @Published var featureFlags: FeatureFlags

        /// Whether licensing features are enabled.
        @Published var enableLicensing: Bool

        /// Whether an active license should be mocked for development testing.
        @Published var mockActiveLicense: Bool

        /// The current license information.
        @Published var licenseInfo: LicenseInfo

        /// Use case for retrieving current feature flags.
        private let getFeatureFlagsUseCase: GetFeatureFlagsUseCase

        /// Use case for updating feature flags configuration.
        private let setFeatureFlagsUseCase: SetFeatureFlagsUseCase

        /// Use case for getting enableLicensing feature flag.
        private let getEnableLicensingUseCase: GetEnableLicensingUseCase

        /// Use case for setting enableLicensing feature flag.
        private let setEnableLicensingUseCase: SetEnableLicensingUseCase

        /// Use case for getting mockActiveLicense feature flag.
        private let getMockActiveLicenseUseCase: GetMockActiveLicenseUseCase

        /// Use case for setting mockActiveLicense feature flag.
        private let setMockActiveLicenseUseCase: SetMockActiveLicenseUseCase

        /// Use case for getting license information.
        private let getLicenseInfoUseCase: GetLicenseInfoUseCase

        /// Use case for resetting license feature flags.
        private let resetLicenseFeatureFlagsUseCase: ResetLicenseFeatureFlagsUseCase

        /// Set of cancellable subscriptions for Combine publishers.
        private var cancellables = Set<AnyCancellable>()

        /// Initializes the developer settings view model with required use cases.
        ///
        /// Sets up reactive bindings to monitor feature flag changes and loads
        /// the initial feature flags state.
        /// - Parameters:
        ///   - getFeatureFlagsUseCase: Use case for retrieving feature flags
        ///   - setFeatureFlagsUseCase: Use case for updating feature flags
        ///   - getEnableLicensingUseCase: Use case for getting enableLicensing flag
        ///   - setEnableLicensingUseCase: Use case for setting enableLicensing flag
        ///   - getMockActiveLicenseUseCase: Use case for getting mockActiveLicense flag
        ///   - setMockActiveLicenseUseCase: Use case for setting mockActiveLicense flag
        ///   - resetLicenseFeatureFlagsUseCase: Use case for resetting license feature flags
        init(
            getFeatureFlagsUseCase: GetFeatureFlagsUseCase,
            setFeatureFlagsUseCase: SetFeatureFlagsUseCase,
            getEnableLicensingUseCase: GetEnableLicensingUseCase,
            setEnableLicensingUseCase: SetEnableLicensingUseCase,
            getMockActiveLicenseUseCase: GetMockActiveLicenseUseCase,
            setMockActiveLicenseUseCase: SetMockActiveLicenseUseCase,
            getLicenseInfoUseCase: GetLicenseInfoUseCase,
            resetLicenseFeatureFlagsUseCase: ResetLicenseFeatureFlagsUseCase
        ) {
            self.getFeatureFlagsUseCase = getFeatureFlagsUseCase
            self.setFeatureFlagsUseCase = setFeatureFlagsUseCase
            self.getEnableLicensingUseCase = getEnableLicensingUseCase
            self.setEnableLicensingUseCase = setEnableLicensingUseCase
            self.getMockActiveLicenseUseCase = getMockActiveLicenseUseCase
            self.setMockActiveLicenseUseCase = setMockActiveLicenseUseCase
            self.getLicenseInfoUseCase = getLicenseInfoUseCase
            self.resetLicenseFeatureFlagsUseCase = resetLicenseFeatureFlagsUseCase

            featureFlags = getFeatureFlagsUseCase.execute().blockingFirst()
            enableLicensing = getEnableLicensingUseCase.execute().blockingFirst()
            mockActiveLicense = getMockActiveLicenseUseCase.execute().blockingFirst()
            licenseInfo = getLicenseInfoUseCase.execute().blockingFirst()

            setupSubscriptions()
        }

        /// Sets the show groups feature flag configuration.
        /// - Parameter enabled: The new show groups feature flag value
        func setEnableGroups(_ enabled: Bool) {
            if enabled == featureFlags.enableGroups { return }

            Task.detached(priority: .utility) { [self] in
                await setFeatureFlagsUseCase.execute(flags: featureFlags.copy(enableGroups: enabled))
            }
        }

        /// Sets the show spaces feature flag configuration.
        /// - Parameter enabled: The new show spaces feature
        func setEnableSpaces(_ enabled: Bool) {
            if enabled == featureFlags.enableSpaces { return }

            Task.detached(priority: .utility) { [self] in
                await setFeatureFlagsUseCase.execute(flags: featureFlags.copy(enableSpaces: enabled))
            }
        }

        /// Sets the show advanced settings feature flag configuration.
        /// - Parameter enabled: The new show advanced settings feature
        func setEnableAdvancedSettings(_ enabled: Bool) {
            if enabled == featureFlags.enableAdvancedSettings { return }

            Task.detached(priority: .utility) { [self] in
                await setFeatureFlagsUseCase.execute(flags: featureFlags.copy(enableAdvancedSettings: enabled))
            }
        }

        /// Sets the enableLicensing feature flag.
        /// - Parameter enabled: Whether licensing features should be enabled
        func setEnableLicensing(_ enabled: Bool) {
            if enabled == enableLicensing { return }

            Task.detached(priority: .utility) { [self] in
                await setEnableLicensingUseCase.execute(enabled: enabled)
            }
        }

        /// Sets the mockActiveLicense feature flag.
        /// - Parameter enabled: Whether mock license should be active
        func setMockActiveLicense(_ enabled: Bool) {
            if enabled == mockActiveLicense { return }

            Task.detached(priority: .utility) { [self] in
                await setMockActiveLicenseUseCase.execute(enabled: enabled)
            }
        }

        /// Whether feature flag toggles should be disabled due to no active license.
        var areFeatureFlagsDisabled: Bool {
            enableLicensing && !licenseInfo.isActive
        }

        /// Sets up reactive subscriptions for feature flag changes.
        ///
        /// Subscribes to changes in the license feature flags to ensure the UI
        /// stays synchronized with the underlying data changes.
        private func setupSubscriptions() {
            // Subscribe to feature flags changes
            getFeatureFlagsUseCase.execute()
                .assign(to: \.featureFlags, on: self)
                .store(in: &cancellables)

            // Subscribe to enableLicensing feature flag changes
            getEnableLicensingUseCase.execute()
                .assign(to: \.enableLicensing, on: self)
                .store(in: &cancellables)

            // Subscribe to mockActiveLicense feature flag changes
            getMockActiveLicenseUseCase.execute()
                .assign(to: \.mockActiveLicense, on: self)
                .store(in: &cancellables)

            // Subscribe to license info changes
            getLicenseInfoUseCase.execute()
                .assign(to: \.licenseInfo, on: self)
                .store(in: &cancellables)
        }

        /// Resets all feature flags to their default values and deactivates the current license.
        ///
        /// This method is typically used for development purposes to quickly reset
        /// the application to a clean state.
        func resetToDefaults() {
            setFeatureFlagsUseCase.resetToDefaults()
            resetLicenseFeatureFlagsUseCase.execute()
        }
    }
#endif
