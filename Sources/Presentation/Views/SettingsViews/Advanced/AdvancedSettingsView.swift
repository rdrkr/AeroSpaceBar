// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Domain
import SwiftUI

/// Displays advanced application settings including behavior controls and development options.
///
/// This view contains settings that are more advanced or technical in nature,
/// including application behavior controls and debugging options.
struct AdvancedSettingsView: View {
    @EnvironmentObject var viewModel: SettingsViewModel
    @State private var showingResetConfirmation = false
    let navigationOption: RootNavigationPage = .advanced

    // MARK: - Computed Properties

    /// Determines if advanced settings are enabled based on feature flags.
    private var isAdvancedSettingsEnabled: Bool {
        viewModel.rootPages.contains(.advanced)
    }

    /// Animation duration for UI transitions.
    private var animationDuration: Double {
        viewModel.animationDuration
    }

    var body: some View {
        advancedSettingsContent
            .opacity(isAdvancedSettingsEnabled ? 1.0 : 0.3)
            .animation(.smooth(duration: animationDuration), value: isAdvancedSettingsEnabled)
            .disabled(!isAdvancedSettingsEnabled)
    }

    private var advancedSettingsContent: some View {
        IntroForm(
            navigationTitle: String(localized: navigationOption.name),
            style: .compact,
            image: Image(systemName: navigationOption.symbolName),
            title: String(localized: navigationOption.name),
            subtitle: String(
                localized: LocalizedStringResource(
                    "Configure advanced behaviors, logging, performance metrics, and reset options."
                )
            )
        ) {
            Section {
                SettingsToggle(
                    title: LocalizedStringResource("Focus Window on Click"),
                    description: LocalizedStringResource("Immediately focus a window when clicking on it."),
                    isOn: $viewModel.focusWindowOnClick
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
        .tag("advanced-settings-view")
        .alert(
            String(localized: LocalizedStringResource("Reset All Settings")),
            isPresented: $showingResetConfirmation
        ) {
            Button(LocalizedStringResource("Cancel"), role: .cancel) { }
            Button(LocalizedStringResource("Reset"), role: .destructive) {
                Task {
                    await viewModel.resetAllSettings()
                }
            }
        } message: {
            Text(
                LocalizedStringResource(
                    "Are you sure you want to reset all settings to their default values? This action cannot be undone."
                )
            )
        }
    }
}

#Preview {
    AdvancedSettingsView()
        .environmentObject(DependencyContainer.shared.getSettingsViewModel())
}
