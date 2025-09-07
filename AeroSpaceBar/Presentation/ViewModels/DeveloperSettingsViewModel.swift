// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

#if DEBUG
    import Combine
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

        private let getFeatureFlagsUseCase: GetFeatureFlagsUseCase
        private let setFeatureFlagsUseCase: SetFeatureFlagsUseCase
        private var cancellables = Set<AnyCancellable>()

        init(
            getFeatureFlagsUseCase: GetFeatureFlagsUseCase,
            setFeatureFlagsUseCase: SetFeatureFlagsUseCase
        ) {
            self.getFeatureFlagsUseCase = getFeatureFlagsUseCase
            self.setFeatureFlagsUseCase = setFeatureFlagsUseCase

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
            Publishers.CombineLatest3($enableSpaces, $enableGroups, $enableAdvancedSettings)
                .dropFirst() // Skip initial values
                .debounce(for: DispatchQueue.SchedulerTimeType.Stride.milliseconds(300), scheduler: DispatchQueue.main)
                .sink { [weak self] spaces, groups, advanced in
                    guard let self else { return }

                    let flags = FeatureFlags(
                        enableGroups: groups,
                        enableSpaces: spaces,
                        enableAdvancedSettings: advanced
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
        }

        func resetToDefaults() async {
            await setFeatureFlagsUseCase.resetToDefaults()
        }
    }
#endif
