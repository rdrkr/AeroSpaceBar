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
        @Published var enableGroups: Bool = false
        @Published var enableSpaces: Bool = false
        @Published var enableAdvancedSettings: Bool = false
        @Published var enableLicensing: Bool = false
        @Published var mockActiveLicense: Bool = false

        private let getFeatureFlagsUseCase: GetFeatureFlagsUseCase
        private let setFeatureFlagsUseCase: SetFeatureFlagsUseCase
        private let deactivateLicenseUseCase: DeactivateLicenseUseCase
        private var cancellables = Set<AnyCancellable>()

        init(
            getFeatureFlagsUseCase: GetFeatureFlagsUseCase,
            setFeatureFlagsUseCase: SetFeatureFlagsUseCase,
            deactivateLicenseUseCase: DeactivateLicenseUseCase
        ) {
            self.getFeatureFlagsUseCase = getFeatureFlagsUseCase
            self.setFeatureFlagsUseCase = setFeatureFlagsUseCase
            self.deactivateLicenseUseCase = deactivateLicenseUseCase

            bindFeatureFlags()
            loadInitialState()
        }

        private func bindFeatureFlags() {
            // Subscribe to feature flag changes
            getFeatureFlagsUseCase.execute()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] flags in
                    self?.updatePublishedProperties(from: flags)
                }
                .store(in: &cancellables)

            // Bind property changes to use case updates
            Publishers.CombineLatest($enableSpaces, $enableGroups)
                .combineLatest(Publishers.CombineLatest($enableAdvancedSettings, $enableLicensing))
                .combineLatest($mockActiveLicense)
                .dropFirst() // Skip initial values
                .debounce(for: DispatchQueue.SchedulerTimeType.Stride.milliseconds(300), scheduler: DispatchQueue.main)
                .sink { [weak self] _, mockLicense in
                    guard let self else { return }

                    let flags = FeatureFlags(
                        enableGroups: enableGroups,
                        enableSpaces: enableSpaces,
                        enableAdvancedSettings: enableAdvancedSettings,
                        enableLicensing: enableLicensing,
                        mockActiveLicense: mockLicense
                    )

                    Task {
                        await self.setFeatureFlagsUseCase.execute(flags)
                    }
                }
                .store(in: &cancellables)
        }

        private func loadInitialState() {
            let currentFlags = getFeatureFlagsUseCase.execute().blockingFirst()
            updatePublishedProperties(from: currentFlags)
        }

        private func updatePublishedProperties(from flags: FeatureFlags) {
            enableGroups = flags.enableGroups
            enableSpaces = flags.enableSpaces
            enableAdvancedSettings = flags.enableAdvancedSettings
            enableLicensing = flags.enableLicensing
            mockActiveLicense = flags.mockActiveLicense
        }

        func resetToDefaults() async {
            await setFeatureFlagsUseCase.resetToDefaults()
            await deactivateLicenseUseCase.execute()
        }
    }
#endif
