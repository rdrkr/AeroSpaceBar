// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Domain
import SwiftUI

/// Displays spaces-related settings: space opacity, space blur radius, window titles, and more.
struct SpacesSettingsView: View {
    @EnvironmentObject private var viewModel: SettingsViewModel

    /// The associated navigation page
    private let navigationOption: RootNavigationPage = .spaces

    var body: some View {
        IntroForm(
            navigationPage: navigationOption,
            style: .compact
        ) {
            Section {
                SettingsToggle(
                    title: LocalizedStringResource("Show Window Title"),
                    description: LocalizedStringResource("Display window title next to icons in the widget."),
                    isOn: $viewModel.showWindowTitles
                )

                SettingsToggle(
                    title: LocalizedStringResource("Show Empty Spaces"),
                    description: LocalizedStringResource("Display spaces that contain no windows in the interface."),
                    isOn: $viewModel.showEmptySpaces
                )
                .tag("advanced-show-empty-spaces-toggle")
            }

            VisualSettingsView(
                entityPrefix: LocalizedStringResource("Space"),
                visualConfig: $viewModel.globalSpacesVisualConfig,
                defaultConfig: ConfigurationDefaults.defaultSpaceVisualConfig,
                tagPrefix: "space"
            )
        }
    }
}

#Preview {
    SpacesSettingsView().environmentObject(DependencyContainer.shared.getSettingsViewModel())
}
