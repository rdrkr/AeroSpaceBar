// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

#if DEBUG
    import SwiftUI

    /// Developer settings view for managing feature flags and debugging options.
    ///
    /// This view provides toggles for enabling/disabling various features during development
    /// and testing. Only available in debug builds.
    struct DeveloperSettingsView: View {
        @StateObject private var viewModel = DependencyContainer.shared.getDeveloperSettingsViewModel()

        let navigationOption: RootNavigationPage = .developer

        var body: some View {
            IntroForm(
                navigationTitle: String(localized: navigationOption.name),
                style: .compact,
                image: Image(systemName: navigationOption.symbolName),
                title: String(localized: navigationOption.name),
                subtitle: String(
                    localized: LocalizedStringResource(
                        "Configure feature flags and development settings for testing new functionality."
                    )
                )
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
                            isEnabled: $viewModel.enableSpaces
                        )

                        FeatureFlagToggle(
                            title: String(localized: LocalizedStringResource("Enable Groups")),
                            description: String(
                                localized: LocalizedStringResource(
                                    "Show/hide the Groups feature in the menu bar and settings."
                                )
                            ),
                            isEnabled: $viewModel.enableGroups
                        )

                        FeatureFlagToggle(
                            title: String(localized: LocalizedStringResource("Enable Advanced Settings")),
                            description: String(
                                localized: LocalizedStringResource("Show/hide the Advanced Settings section.")
                            ),
                            isEnabled: $viewModel.enableAdvancedSettings
                        )
                    }
                }
                .tag("developer-core-features-section")

                Section(LocalizedStringResource("Actions")) {
                    SettingsDestructiveButton(
                        title: LocalizedStringResource("Reset to Defaults"),
                        description: LocalizedStringResource("Reset all feature flags to their default values."),
                        action: {
                            Task {
                                await viewModel.resetToDefaults()
                            }
                        }
                    )
                    .tag("developer-reset-button")
                }
                .tag("developer-actions-section")
            }
            .tag("developer-settings-view")
        }
    }

    #Preview {
        DeveloperSettingsView()
    }
#endif
