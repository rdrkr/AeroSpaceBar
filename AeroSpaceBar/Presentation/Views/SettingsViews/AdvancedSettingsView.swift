// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// Displays advanced application settings including behavior controls and development options.
///
/// This view contains settings that are more advanced or technical in nature,
/// including application behavior controls and debugging options.
struct AdvancedSettingsView: View {
    @EnvironmentObject var viewModel: SettingsViewModel
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
                    Text("Focus window on click")
                    Text("Immediately focus a window when clicking on it")
                }.toggleStyle(.switch)
            }

            Section("Diagnostics") {
                VStack(alignment: .leading) {
                    Picker("Log Level", selection: $viewModel.logLevel) {
                        ForEach(Logger.Level.allCases, id: \.self) { level in
                            Text(level.rawValue.capitalized).tag(level)
                        }
                    }
                    .pickerStyle(.menu)

                    Text("Set the verbosity of logging output")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }

                Toggle(isOn: $viewModel.enablePerformanceMetrics) {
                    Text("Enable performance metrics")
                    Text("Track and log performance data for debugging")
                }

                Toggle(isOn: $viewModel.isOptimizedPerformanceEnabled) {
                    Text("Enable optimized performance")
                    Text("Utilize AeroSpace's event system for CPU consumption optimization")
                }
            }

            Section("Reset") {
                VStack(alignment: .leading) {
                    Button("Reset All Settings") {
                        Task {
                            await viewModel.resetAllSettings()
                        }
                    }
                    .foregroundColor(.red)

                    Text("Reset all settings to their default values")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

#Preview {
    AdvancedSettingsView()
        .environmentObject(DependencyContainer.shared.getSettingsViewModel())
}
