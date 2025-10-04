// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Domain
import SwiftUI

/// Displays software update settings and controls.
///
/// This view provides controls for automatic update checking, automatic downloading,
/// and manual update checking functionality.
struct UpdatesSettingsView: View {
    /// The main settings view model containing application-wide settings
    @EnvironmentObject var viewModel: SettingsViewModel

    /// The associated navigation page
    let navigationOption: RootNavigationPage = .updates

    /// The main view content displaying update settings
    var body: some View {
        IntroForm(
            navigationPage: navigationOption,
            style: .compact
        ) {
            Section {
                SettingsToggle(
                    title: LocalizedStringResource("Automatically Check for Updates"),
                    description: LocalizedStringResource(
                        "Periodically check for new versions of AeroSpaceBar."
                    ),
                    isOn: $viewModel.automaticCheckForUpdatesEnabled
                )
                .tag("updates-auto-check-toggle")

                SettingsToggle(
                    title: LocalizedStringResource("Automatically Download Updates"),
                    description: LocalizedStringResource(
                        "Download updates automatically when they become available."
                    ),
                    isOn: $viewModel.automaticDownloadUpdatesEnabled
                )
                .disabled(!viewModel.automaticCheckForUpdatesEnabled)
                .tag("updates-auto-download-toggle")
            }
            .tag("updates-automatic-section")

            Section {
                HStack {
                    Button(LocalizedStringResource("Check for Updates...")) {
                        Task.detached(priority: .userInitiated) {
                            await viewModel.checkForUpdates()
                        }
                    }
                    .tag("updates-check-now-button")

                    Spacer()

                    if let lastCheckDate = viewModel.lastUpdateCheckDate {
                        HStack {
                            Text(LocalizedStringResource("Last checked:"))
                                .tag("updates-last-check-label")
                            Text(lastCheckDate, format: .dateTime)
                                .foregroundColor(.secondary)
                                .tag("updates-last-check-date")
                        }
                        .tag("updates-last-check-container")
                    }
                }
                .tag("updates-manual-check-content")
            }
            .tag("updates-manual-section")
        }
        .tag("updates-settings-view")
    }
}

#Preview {
    UpdatesSettingsView()
        .environmentObject(DependencyContainer.shared.getSettingsViewModel())
}
