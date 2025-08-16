// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// Displays general application settings including display options and appearance settings.
///
/// This view contains settings that affect the basic functionality and appearance
/// of the AeroSpaceBar application, such as:
/// - Launch at login
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
                    Text("Launch at login")
                    Text("Automatically start AeroSpaceBar when you log in")
                }
                .toggleStyle(.switch)
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

            Section("AeroSpace") {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Path")

                        TextField(
                            "Path",
                            text: $viewModel.aeroSpacePath
                        )
                        .labelsHidden()
                        .textFieldStyle(.roundedBorder)

                        Button("Browse…") {
                            let panel = NSOpenPanel()
                            panel.canChooseDirectories = false
                            panel.canChooseFiles = true
                            panel.allowsMultipleSelection = false
                            if panel.runModal() == .OK, let url = panel.url {
                                viewModel.aeroSpacePath = url.path
                            }
                        }
                    }

                    if let error = viewModel.customPathValidationError {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text(error)
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                    }

                    Text("Path to the AeroSpace binary. Leave empty to auto-detect from common locations.")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)

                    Spacer(minLength: 8)

                    // Show resolved AeroSpace path and status
                    HStack {
                        if let version = viewModel.aeroSpaceVersion {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)

                            Text("AeroSpace version: \(version)")
                                .font(.system(size: 11))
                                .foregroundColor(.green)
                                .textSelection(.enabled)
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)

                            Text("AeroSpace Not Found")
                                .font(.system(size: 11))
                                .foregroundColor(.red)
                                .textSelection(.enabled)
                        }
                    }

                    Spacer(minLength: 8)

                    Button("Open Configuration…") {
                        Task {
                            await viewModel.openAeroSpaceConfig()
                        }
                    }
                }
                .onChange(of: viewModel.aeroSpacePath) { _, _ in
                    // Trigger version update when path changes
                    viewModel.objectWillChange.send()
                }
            }

            Section("Appearance") {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Transparency")

                        Slider(
                            value: $viewModel.transparency,
                            in: 0.1 ... 1.0
                        )

                        Text("\(Int(viewModel.transparency * 100))%")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }

                    Text("Adjust the transparency of the menu bar panel")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

#Preview {
    GeneralSettingsView()
        .environmentObject(DependencyContainer.shared.getSettingsViewModel())
}
