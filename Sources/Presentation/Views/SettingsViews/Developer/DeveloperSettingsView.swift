// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

#if DEBUG
    import SwiftUI

    /// Developer settings view for managing feature flags and debugging options.
    ///
    /// This view provides toggles for enabling/disabling various features during development
    /// and testing. Only available in debug builds.
    struct DeveloperSettingsView: View {
        /// The associated developer settings view model
        @StateObject private var viewModel = DependencyContainer.shared.getDeveloperSettingsViewModel()

        /// The associated navigation page
        let navigationOption: RootNavigationPage = .developer

        var body: some View {
            IntroForm(
                navigationPage: navigationOption,
                style: .compact
            ) {
                Section(LocalizedStringResource("Core Features")) {
                    VStack(alignment: .leading) {
                        FeatureFlagToggle(
                            title: String(localized: LocalizedStringResource("Enable Spaces")),
                            description: String(
                                localized: LocalizedStringResource(
                                    "Show/hide the Spaces feature in the menu bar and settings."
                                )
                            ),
                            isEnabled: viewModel.featureFlags.enableSpaces,
                            isDisabled: viewModel.areFeatureFlagsDisabled,
                            onToggle: viewModel.setEnableSpaces
                        )

                        FeatureFlagToggle(
                            title: String(localized: LocalizedStringResource("Enable Groups")),
                            description: String(
                                localized: LocalizedStringResource(
                                    "Show/hide the Groups feature in the menu bar and settings."
                                )
                            ),
                            isEnabled: viewModel.featureFlags.enableGroups,
                            isDisabled: viewModel.areFeatureFlagsDisabled,
                            onToggle: viewModel.setEnableGroups
                        )

                        FeatureFlagToggle(
                            title: String(localized: LocalizedStringResource("Enable Advanced Settings")),
                            description: String(
                                localized: LocalizedStringResource("Show/hide the Advanced Settings section.")
                            ),
                            isEnabled: viewModel.featureFlags.enableAdvancedSettings,
                            isDisabled: viewModel.areFeatureFlagsDisabled,
                            onToggle: viewModel.setEnableAdvancedSettings
                        )
                    }
                }
                .tag("developer-core-features-section")

                Section(LocalizedStringResource("Licensing")) {
                    VStack(alignment: .leading) {
                        FeatureFlagToggle(
                            title: String(localized: LocalizedStringResource("Enable Licensing")),
                            description: String(
                                localized: LocalizedStringResource(
                                    "Show/hide licensing features, trial periods, and purchase options."
                                )
                            ),
                            isEnabled: viewModel.enableLicensing,
                            onToggle: viewModel.setEnableLicensing
                        )

                        if viewModel.enableLicensing {
                            FeatureFlagToggle(
                                title: String(localized: LocalizedStringResource("Mock Active License")),
                                description: String(
                                    localized: LocalizedStringResource(
                                        "Mock an active license for development testing without a real license."
                                    )
                                ),
                                isEnabled: viewModel.mockActiveLicense,
                                onToggle: viewModel.setMockActiveLicense
                            )
                        }
                    }
                }
                .tag("developer-licensing-section")

                Section(LocalizedStringResource("Actions")) {
                    SettingsDestructiveButton(
                        title: LocalizedStringResource("Reset to Defaults"),
                        description: LocalizedStringResource("Reset all feature flags to their default values."),
                        action: viewModel.resetToDefaults
                    )
                    .tag("developer-reset-button")
                }
                .tag("developer-actions-section")
            }
            .animation(.themeEaseInOutFast, value: viewModel.enableLicensing)
            .tag("developer-settings-view")
        }
    }

    #Preview {
        DeveloperSettingsView()
    }
#endif
