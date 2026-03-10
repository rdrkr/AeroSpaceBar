// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
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
    private let navigationOption: RootNavigationPage = .general

    /// Whether or not to show the theme preset picker
    private var shouldShowThemePresetColorProperties: Bool {
        viewModel.themeMode == .preset
    }

    /// A comma-separated list of all Quick Hide trigger keys with their unicode symbols and display names.
    private var quickHideTriggerKeyList: Text {
        QuickHideTriggerKey.allCases
            .enumerated()
            .map { index, key -> Text in
                let entry = Text(Image(systemName: key.systemImageName)) + Text(verbatim: " ") + Text(key.displayName)
                return index == 0 ? entry : Text(verbatim: ", ") + entry
            }
            .reduce(Text(verbatim: ""), +)
    }

    /// The footer description for the Quick Hide section, including all available modifier keys.
    private var quickHideFooterDescription: Text {
        Text(LocalizedStringResource("Hold the selected modifier key (")) +
            quickHideTriggerKeyList +
            Text(
                LocalizedStringResource(
                    ") and hover over the menu bar to temporarily hide spaces. Release to show them again."
                )
            )
    }

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

            Section {
                Picker(
                    LocalizedStringResource("Mode"),
                    selection: $viewModel.themeMode
                ) {
                    ForEach(ThemeMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue.capitalized)
                            .selectionDisabled(!mode.isAvailable)
                            .tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .tag("general-theme-mode-picker")

                if shouldShowThemePresetColorProperties {
                    Picker(
                        LocalizedStringResource("Theme"),
                        selection: $viewModel.themePresetColorProperties
                    ) {
                        ForEach(ThemePresetColorProperties.allCases, id: \.self) { preset in
                            Text(preset.displayName).tag(preset)
                        }
                    }
                    .tag("general-theme-preset-picker")
                }
            } header: {
                Text(LocalizedStringResource("Appearance"))
            } footer: {
                Text(
                    LocalizedStringResource(
                        """
                        Appearance and style of spaces and groups.
                        - Liquid Glass (macOS 26+ Only).
                        - Preset color themes.
                        - Custom colors of your choosing for Spaces and Groups.
                        """
                    )
                )
                .tag("theme-picker-description")
            }
            .tag("general-appearance-mode-section")

            Section {
                HStack {
                    Image(systemName: viewModel
                        .screenCapturePermissionGranted ? "checkmark.circle.fill" : "xmark.circle.fill"
                    )
                    .foregroundColor(viewModel.screenCapturePermissionGranted ? .green : .red)
                    .tag("general-permissions-status-icon")

                    HStack {
                        Text(
                            viewModel.screenCapturePermissionGranted
                                ? LocalizedStringResource("Screen capture permissions granted")
                                : LocalizedStringResource("Screen capture permissions denied")
                        )
                        .tag("general-permissions-status-text")

                        Spacer()

                        if !viewModel.screenCapturePermissionGranted {
                            Button(LocalizedStringResource("Grant Permissions…")) {
                                Task.detached(priority: .utility) {
                                    await viewModel.requestScreenCapturePermissions()
                                }
                            }
                            .tag("general-permissions-grant-button")
                        }
                    }
                }
                .tag("general-permissions-status")
            } header: {
                Text(LocalizedStringResource("Permissions"))
            } footer: {
                Text(
                    LocalizedStringResource(
                        """
                        Screen capture permissions are required for optimal visual quality. \
                        Without permission, visual artifacts may appear on Spaces with certain wallpapers.
                        """
                    )
                )
                .tag("general-permissions-description")
            }
            .tag("general-permissions-section")

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

            Section {
                SettingsToggle(
                    title: LocalizedStringResource("Quick Hide"),
                    description: LocalizedStringResource(
                        "Hold the trigger key and hover over the menu bar to temporarily hide spaces."
                    ),
                    isOn: $viewModel.quickHideEnabled
                )
                .tag("general-quick-hide-toggle")

                TriggerKeyRecorderView(triggerKey: $viewModel.quickHideTriggerKey)
                    .disabled(!viewModel.quickHideEnabled)
                    .opacity(viewModel.quickHideEnabled ? 1.0 : 0.5)
                    .tag("general-quick-hide-trigger-key")
            } header: {
                Text(LocalizedStringResource("Quick Hide"))
            } footer: {
                quickHideFooterDescription
                    .tag("general-quick-hide-description")
            }
            .tag("general-quick-hide-section")
        }
        .animation(.themeEaseInOutFast, value: shouldShowThemePresetColorProperties)
        .tag("general-settings-view")
    }
}

#Preview {
    GeneralSettingsView()
        .environmentObject(DependencyContainer.shared.getSettingsViewModel())
}
