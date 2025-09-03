// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// Displays general application settings including display options and appearance settings.
///
/// This view contains settings that affect the basic functionality and appearance
/// of the AeroSpaceBar application, such as:
/// - Launch at Login
/// - AeroSpace path
/// - Appearance settings
struct GeneralSettingsView: View {
    @EnvironmentObject private var viewModel: SettingsViewModel
    @State private var launchAtLoginUpdateTask: Task<Void, Never>?

    let navigationOption: SettingsNavigationOptions = .general

    var body: some View {
        IntroForm(
            navigationTitle: String(localized: navigationOption.name),
            style: .intro,
            image: Image(nsImage: NSApplication.shared.applicationIconImage),
            title: String(localized: navigationOption.name),
            subtitle: "Manage your overall setup and preferences for " +
                "AeroSpaceBar, such as AeroSpace path and Appearance settings."
        ) {
            Section {
                Toggle(isOn: $viewModel.launchAtLogin) {
                    Text(LocalizedStringResource("Launch at Login"))
                    Text(LocalizedStringResource("Automatically start AeroSpaceBar when you log in"))
                }
                .toggleStyle(.switch)
                .tag("general-launch-at-login-toggle")
                .onAppear {
                    // Update launch at login status every second until the view disappears
                    // This is necessary because the user can change the launch at login setting
                    // from System Settings, while the view is still visible.
                    launchAtLoginUpdateTask?.cancel()
                    launchAtLoginUpdateTask = Task {
                        repeat {
                            // Check for updates
                            _ = viewModel.launchAtLogin
                            try? await Task.sleep(for: .seconds(1))
                        } while launchAtLoginUpdateTask?.isCancelled == false
                    }
                }
                .onDisappear {
                    launchAtLoginUpdateTask?.cancel()
                }
            }
            .tag("general-launch-section")

            Section(LocalizedStringResource("AeroSpace")) {
                VStack(alignment: .leading) {
                    HStack {
                        Text(LocalizedStringResource("Path"))
                            .tag("general-path-label")

                        TextField(
                            String(localized: LocalizedStringResource("Path")),
                            text: $viewModel.aeroSpacePath
                        )
                        .labelsHidden()
                        .textFieldStyle(.roundedBorder)
                        .tag("general-path-textfield")

                        Button(LocalizedStringResource("Browse…")) {
                            let panel = NSOpenPanel()
                            panel.canChooseDirectories = false
                            panel.canChooseFiles = true
                            panel.allowsMultipleSelection = false
                            if panel.runModal() == .OK, let url = panel.url {
                                viewModel.aeroSpacePath = url.path
                            }
                        }
                        .tag("general-browse-button")
                    }

                    if let error = viewModel.customPathValidationError {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .tag("general-path-error-icon")
                            Text(error)
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                                .tag("general-path-error-text")
                        }
                        .tag("general-path-error-container")
                    }

                    Text(
                        LocalizedStringResource(
                            "Path to the AeroSpace binary. Leave empty to auto-detect from common locations."
                        )
                    )
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .tag("general-path-help-text")

                    Spacer(minLength: 8)

                    // Show resolved AeroSpace path and status
                    HStack {
                        if let version = viewModel.aeroSpaceVersion {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .tag("general-aerospace-status-success-icon")

                            Text(LocalizedStringResource("AeroSpace version: \(version)"))
                                .font(.system(size: 11))
                                .foregroundColor(.green)
                                .textSelection(.enabled)
                                .tag("general-aerospace-version-success")
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                                .tag("general-aerospace-status-error-icon")

                            Text(LocalizedStringResource("AeroSpace Not Found"))
                                .font(.system(size: 11))
                                .foregroundColor(.red)
                                .textSelection(.enabled)
                                .tag("general-aerospace-not-found-error")
                        }
                    }
                    .tag("general-aerospace-status-container")

                    Spacer(minLength: 8)

                    Button(LocalizedStringResource("Open Configuration…")) {
                        Task.detached(priority: .utility) {
                            await viewModel.openAeroSpaceConfig()
                        }
                    }
                    .tag("general-open-config-button")
                }
                .onChange(of: viewModel.aeroSpacePath) { _, _ in
                    // Trigger version update when path changes
                    viewModel.objectWillChange.send()
                }
                .tag("general-aerospace-section")
            }
        }
        .tag("general-settings-view")
    }
}

#Preview {
    GeneralSettingsView()
        .environmentObject(DependencyContainer.shared.getSettingsViewModel())
}
