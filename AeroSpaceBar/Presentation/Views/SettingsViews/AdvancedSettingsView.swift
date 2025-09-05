// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// Displays advanced application settings including behavior controls and development options.
///
/// This view contains settings that are more advanced or technical in nature,
/// including application behavior controls and debugging options.
struct AdvancedSettingsView: View {
    @EnvironmentObject var viewModel: SettingsViewModel
    @State private var showingResetConfirmation = false
    let navigationOption: SettingsNavigationOptions = .advanced

    var body: some View {
        IntroForm(
            navigationTitle: String(localized: navigationOption.name),
            style: .compact,
            image: Image(systemName: navigationOption.symbolName),
            title: String(localized: navigationOption.name),
            subtitle: "Configure advanced behaviors, logging, performance metrics, and reset options."
        ) {
            Section {
                Toggle(isOn: $viewModel.focusWindowOnClick) {
                    Text(LocalizedStringResource("Focus Window on Click"))
                    Text(LocalizedStringResource("Immediately focus a window when clicking on it"))
                }
                .toggleStyle(.switch)
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

                    Text(LocalizedStringResource("Set the verbosity of logging output"))
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .tag("advanced-log-level-help")
                }

                Toggle(isOn: $viewModel.enablePerformanceMetrics) {
                    Text(LocalizedStringResource("Enable Performance Metrics"))
                    Text(LocalizedStringResource("Track and log performance data for debugging"))
                }
                .toggleStyle(.switch)
                .tag("advanced-performance-metrics-toggle")

                Toggle(isOn: $viewModel.isOptimizedPerformanceEnabled) {
                    Text(LocalizedStringResource("Enable Optimized Performance"))
                    Text(LocalizedStringResource("Utilize AeroSpace's event system for CPU consumption optimization"))
                }
                .toggleStyle(.switch)
                .tag("advanced-optimized-performance-toggle")
            }
            .tag("advanced-diagnostics-section")

            Section(LocalizedStringResource("Reset")) {
                VStack(alignment: .leading) {
                    Button(LocalizedStringResource("Reset All Settings")) {
                        showingResetConfirmation = true
                    }
                    .foregroundColor(.red)
                    .tag("advanced-reset-settings-button")

                    Text(LocalizedStringResource("Reset all settings to their default values"))
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .tag("advanced-reset-help-text")
                }
            }
            .tag("advanced-reset-section")
        }
        .tag("advanced-settings-view")
        .alert("Reset All Settings", isPresented: $showingResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                Task {
                    await viewModel.resetAllSettings()
                }
            }
        } message: {
            Text("Are you sure you want to reset all settings to their default values? This action cannot be undone.")
        }
    }
}

#Preview {
    AdvancedSettingsView()
        .environmentObject(DependencyContainer.shared.getSettingsViewModel())
}
