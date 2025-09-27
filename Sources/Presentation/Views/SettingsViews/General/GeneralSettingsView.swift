// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import SwiftUI

/// Displays general application settings including display options and appearance settings.
///
/// This view contains settings that affect the basic functionality and appearance
/// of the AeroSpaceBar application, such as:
/// - Launch at Login
/// - AeroSpace path
/// - Appearance settings
struct GeneralSettingsView: View {
    /// The settings view model
    @EnvironmentObject private var viewModel: SettingsViewModel
    @State private var launchAtLoginUpdateTask: Task<Void, Never>?

    /// The associated navigation page
    let navigationOption: RootNavigationPage = .general

    var body: some View {
        IntroForm(
            navigationTitle: navigationOption.name,
            style: .intro,
            icon: AnyView(Image(nsImage: NSApplication.shared.applicationIconImage)
                .resizable()
            ),
            title: navigationOption.name,
            subtitle: navigationOption.description
        ) {
            Section {
                SettingsToggle(
                    title: LocalizedStringResource("Launch at Login"),
                    description: LocalizedStringResource("Automatically start AeroSpaceBar when you log in."),
                    isOn: $viewModel.launchAtLogin
                )
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
                                .secondaryText()
                                .tag("general-path-error-text")
                        }
                        .tag("general-path-error-container")
                    }

                    Text(
                        LocalizedStringResource(
                            "Path to the AeroSpace binary. Leave empty to auto-detect from common locations."
                        )
                    )
                    .secondaryText()
                    .tag("general-path-help-text")

                    Spacer(minLength: 8)

                    // Show resolved AeroSpace path and status
                    HStack {
                        if let version = viewModel.aeroSpaceVersion {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .tag("general-aerospace-status-success-icon")

                            Text(LocalizedStringResource("AeroSpace version: \(version)"))
                                .successText(isSelectable: true)
                                .tag("general-aerospace-version-success")
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                                .tag("general-aerospace-status-error-icon")

                            Text(LocalizedStringResource("AeroSpace Not Found"))
                                .errorText(isSelectable: true)
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

            Section(LocalizedStringResource("Tips")) {
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.orange)
                            .font(.system(size: 14))
                            .tag("general-tip-icon")

                        VStack(alignment: .leading) {
                            Text(LocalizedStringResource("Quick Hide Feature"))
                                .font(.callout)
                                .tag("general-tip-title")

                            Group {
                                HStack(alignment: .firstTextBaseline) {
                                    Text(LocalizedStringResource("Hold"))
                                    Image(systemName: "globe").foregroundColor(.secondary)
                                    Text(
                                        LocalizedStringResource(
                                            "(Globe or Fn key) and hover over the menu bar to hide spaces."
                                        )
                                    )
                                }

                                Text(LocalizedStringResource("Release to show."))
                            }
                            .secondaryText()
                            .fixedSize(horizontal: false, vertical: true)
                            .tag("general-tip-description")
                        }
                    }
                }
                .tag("general-tips-container")
            }
            .tag("general-tips-section")
        }
        .tag("general-settings-view")
    }
}

#Preview {
    GeneralSettingsView()
        .environmentObject(DependencyContainer.shared.getSettingsViewModel())
}
