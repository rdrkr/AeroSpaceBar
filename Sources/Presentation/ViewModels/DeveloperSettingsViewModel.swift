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
        @Published var featureFlags: FeatureFlags {
            didSet {
                Task.detached(priority: .utility) { [self] in
                    await setFeatureFlagsUseCase.execute(flags: featureFlags)
                }
            }
        }

        /// Use case for retrieving current feature flags.
        private let getFeatureFlagsUseCase: GetFeatureFlagsUseCase

        /// Use case for updating feature flags configuration.
        private let setFeatureFlagsUseCase: SetFeatureFlagsUseCase

        /// Use case for deactivating the current license.
        private let deactivateLicenseUseCase: DeactivateLicenseUseCase

        /// Set of cancellable subscriptions for Combine publishers.
        private var cancellables = Set<AnyCancellable>()

        /// Initializes the developer settings view model with required use cases.
        ///
        /// Sets up reactive bindings to monitor feature flag changes and loads
        /// the initial feature flags state.
        /// - Parameters:
        ///   - getFeatureFlagsUseCase: Use case for retrieving feature flags
        ///   - setFeatureFlagsUseCase: Use case for updating feature flags
        ///   - deactivateLicenseUseCase: Use case for deactivating licenses
        init(
            getFeatureFlagsUseCase: GetFeatureFlagsUseCase,
            setFeatureFlagsUseCase: SetFeatureFlagsUseCase,
            deactivateLicenseUseCase: DeactivateLicenseUseCase
        ) {
            self.getFeatureFlagsUseCase = getFeatureFlagsUseCase
            self.setFeatureFlagsUseCase = setFeatureFlagsUseCase
            self.deactivateLicenseUseCase = deactivateLicenseUseCase

            featureFlags = getFeatureFlagsUseCase.execute().blockingFirst()
        }

        /// Resets all feature flags to their default values and deactivates the current license.
        ///
        /// This method is typically used for development purposes to quickly reset
        /// the application to a clean state.
        func resetToDefaults() async {
            setFeatureFlagsUseCase.resetToDefaults()
            await deactivateLicenseUseCase.execute()
        }
    }
#endif
