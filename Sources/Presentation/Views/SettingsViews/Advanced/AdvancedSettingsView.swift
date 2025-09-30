// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Domain
import SwiftUI
import UniformTypeIdentifiers

/// Displays advanced application settings including behavior controls and development options.
///
/// This view contains settings that are more advanced or technical in nature,
/// including application behavior controls and debugging options.
struct AdvancedSettingsView: View {
    /// The main settings view model containing application-wide settings
    @EnvironmentObject var viewModel: SettingsViewModel

    /// The spaces view model managing AeroSpace window and space configurations
    @EnvironmentObject var spacesViewModel: SpacesViewModel

    /// The groups view model managing group configurations and visual settings
    @EnvironmentObject var groupsViewModel: GroupsViewModel

    /// Controls the presentation state of the reset confirmation alert
    @State private var showingResetConfirmation = false

    /// The associated navigation page
    let navigationOption: RootNavigationPage = .advanced

    // MARK: - Computed Properties

    /// Determines if advanced settings are enabled based on feature flags.
    private var isAdvancedSettingsEnabled: Bool {
        viewModel.rootPages.contains(.advanced)
    }

    /// Handles config file path submission when user presses enter or leaves focus.
    private func handleConfigFilePathSubmission() {
        let trimmedPath = viewModel.configFilePath.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedPath.isEmpty {
            viewModel.configFilePath = ConfigurationDefaults.configFilePath
        }
    }

    /// The main view content displaying advanced settings sections including behavior controls,
    /// diagnostics options, and reset functionality
    var body: some View {
        IntroForm(
            navigationPage: navigationOption,
            style: .compact
        ) {
            Section {
                SettingsToggle(
                    title: LocalizedStringResource("Focus Window on Click"),
                    description: LocalizedStringResource("Immediately focus a window when clicking on it."),
                    isOn: $spacesViewModel.focusWindowOnClick
                )
                .tag("advanced-focus-window-toggle")
            }
            .tag("advanced-behavior-section")

            Section(LocalizedStringResource("Diagnostics")) {
                VStack(alignment: .leading) {
                    Picker(LocalizedStringResource("Log Level"), selection: $viewModel.logLevel) {
                        ForEach(Logger.Level.allCases, id: \.self) { level in
                            Text(level.rawValue.capitalized).tag(level)
                        }
                    }
                    .pickerStyle(.menu)
                    .tag("advanced-log-level-picker")

                    Text(LocalizedStringResource("Set the verbosity of logging output."))
                        .secondaryText()
                        .tag("advanced-log-level-help")
                }

                SettingsToggle(
                    title: LocalizedStringResource("Enable Performance Metrics"),
                    description: LocalizedStringResource("Track and log performance data for debugging."),
                    isOn: $viewModel.enablePerformanceMetrics
                )
                .tag("advanced-performance-metrics-toggle")

                SettingsToggle(
                    title: LocalizedStringResource("Enable Optimized Performance"),
                    description: LocalizedStringResource(
                        "Utilize AeroSpace's event system for CPU consumption optimization."
                    ),
                    isOn: $viewModel.isOptimizedPerformanceEnabled
                )
                .tag("advanced-optimized-performance-toggle")
            }
            .tag("advanced-diagnostics-section")

            Section {
                VStack(alignment: .leading) {
                    HStack {
                        Text(LocalizedStringResource("Path"))
                            .tag("advanced-config-path-label")

                        TextField(
                            String(localized: LocalizedStringResource("Path")),
                            text: $viewModel.configFilePath
                        )
                        .labelsHidden()
                        .textFieldStyle(.roundedBorder)
                        .onSubmit {
                            handleConfigFilePathSubmission()
                        }
                        .onChange(of: viewModel.configFilePath) { _, newValue in
                            // Detect if field was cleared and reset to default
                            if newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                viewModel.configFilePath = ConfigurationDefaults.configFilePath
                            }
                        }
                        .tag("advanced-config-path-textfield")

                        Button(LocalizedStringResource("Browse…")) {
                            let panel = NSSavePanel()
                            panel.canCreateDirectories = true
                            panel.nameFieldStringValue = "aerospacebar.toml"
                            if let tomlType = UTType(filenameExtension: "toml") {
                                panel.allowedContentTypes = [tomlType]
                            }
                            if panel.runModal() == .OK, let url = panel.url {
                                viewModel.configFilePath = url.path
                            }
                        }
                        .tag("advanced-config-browse-button")
                    }

                    if let error = viewModel.configFilePathValidationError {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .tag("advanced-config-path-error-icon")
                            Text(error)
                                .secondaryText()
                                .tag("advanced-config-path-error-text")
                        }
                        .tag("advanced-config-path-error-container")
                    }

                    Text(
                        LocalizedStringResource(
                            "Path to the configuration file. This file stores all your settings in TOML format."
                        )
                    )
                    .secondaryText()
                    .tag("advanced-config-path-help-text")

                    Spacer(minLength: 8)

                    Button(LocalizedStringResource("Open Configuration File…")) {
                        Task.detached(priority: .utility) {
                            await viewModel.openConfigFile()
                        }
                    }
                    .tag("advanced-open-config-button")
                }
                .tag("advanced-config-file-section")
            } header: {
                Text(LocalizedStringResource("Configuration File"))
            } footer: {
                Text(
                    LocalizedStringResource(
                        stringLiteral: "Configuration file changes are automatically reloaded " +
                            "while this settings window is open. You can edit the TOML file " +
                            "externally and see changes reflected immediately."
                    )
                )
            }
            .tag("advanced-config-section")

            Section(LocalizedStringResource("Reset")) {
                SettingsDestructiveButton(
                    title: LocalizedStringResource("Reset All Settings"),
                    description: LocalizedStringResource("Reset all settings to their default values."),
                    action: { showingResetConfirmation = true }
                )
                .tag("advanced-reset-settings-button")
            }
            .tag("advanced-reset-section")
        }
        .alert(
            String(localized: LocalizedStringResource("Reset All Settings")),
            isPresented: $showingResetConfirmation
        ) {
            Button(LocalizedStringResource("Cancel"), role: .cancel) { }
            Button(LocalizedStringResource("Reset"), role: .destructive) {
                Task {
                    withAnimation(.themeEaseInOutFast) {
                        Task {
                            await viewModel.resetSettingsToDefaults()
                            await spacesViewModel.resetSpacesToDefaults()
                            await groupsViewModel.resetGroupsToDefaults()
                        }
                    }
                }
            }
        } message: {
            Text(
                LocalizedStringResource(
                    "Are you sure you want to reset all settings to their default values? This action cannot be undone."
                )
            )
        }
        .disabled(!isAdvancedSettingsEnabled)
        .tag("advanced-settings-view")
    }
}

#Preview {
    AdvancedSettingsView()
        .environmentObject(DependencyContainer.shared.getSettingsViewModel())
}
