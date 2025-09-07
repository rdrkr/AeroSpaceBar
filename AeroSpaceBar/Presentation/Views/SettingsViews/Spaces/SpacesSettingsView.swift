// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// Displays spaces-related settings: space opacity, space blur radius, window titles, and more.
struct SpacesSettingsView: View {
    @EnvironmentObject private var viewModel: SettingsViewModel
    private let navigationOption: RootNavigationPage = .spaces

    var body: some View {
        IntroForm(
            navigationTitle: String(localized: navigationOption.name),
            style: .compact,
            image: Image(systemName: navigationOption.symbolName),
            title: String(localized: navigationOption.name),
            subtitle: String(
                localized: LocalizedStringResource(
                    "Fine-tune how spaces look and behave: opacity, blur, titles, and more."
                )
            )
        ) {
            Section {
                SettingsToggle(
                    title: LocalizedStringResource("Show Window Title"),
                    description: LocalizedStringResource("Display window title next to icons in the widget."),
                    isOn: $viewModel.showWindowTitles
                )

                SettingsToggle(
                    title: LocalizedStringResource("Show Empty Spaces"),
                    description: LocalizedStringResource("Display spaces that contain no windows in the interface"),
                    isOn: $viewModel.showEmptySpaces
                )
                .tag("advanced-show-empty-spaces-toggle")
            }

            Section(LocalizedStringResource("Space Background")) {
                SettingsColorPicker(
                    title: LocalizedStringResource("Tint Color"),
                    description: LocalizedStringResource("Choose the background tint color for space elements"),
                    selectedColor: $viewModel.spaceBackgroundTintColor,
                    supportsOpacity: false
                )

                SettingsSlider(
                    value: $viewModel.spaceBackgroundOpacity,
                    in: 0.0 ... 1.0,
                    defaultValue: ConfigurationDefaults.spaceBackgroundOpacity,
                    stickiness: 0.05,
                    label: LocalizedStringResource("Opacity"),
                    helpText: LocalizedStringResource("Adjust the background opacity of the space elements"),
                    displayAsPercentage: true
                )

                SettingsSlider(
                    value: $viewModel.spaceBackgroundBlurRadius,
                    in: 0.0 ... 10.0,
                    defaultValue: ConfigurationDefaults.spaceBackgroundBlurRadius,
                    stickiness: 0.5,
                    label: LocalizedStringResource("Blur"),
                    helpText: LocalizedStringResource("Adjust the background blur radius of the space elements"),
                    displayAsPoints: true
                )
            }

            Section(LocalizedStringResource("Space Border")) {
                SettingsColorPicker(
                    title: LocalizedStringResource("Tint Color"),
                    description: LocalizedStringResource("Choose the border tint color for space elements"),
                    selectedColor: $viewModel.spaceBorderTintColor,
                    supportsOpacity: false
                )

                SettingsSlider(
                    value: $viewModel.spaceBorderOpacity,
                    in: 0.0 ... 1.0,
                    defaultValue: ConfigurationDefaults.spaceBorderOpacity,
                    stickiness: 0.05,
                    label: LocalizedStringResource("Opacity"),
                    helpText: LocalizedStringResource("Adjust the border opacity of the space elements"),
                    displayAsPercentage: true
                )

                SettingsSlider(
                    value: $viewModel.spaceBorderWidth,
                    in: 0.0 ... 5.0,
                    defaultValue: ConfigurationDefaults.spaceBorderWidth,
                    stickiness: 0.25,
                    label: LocalizedStringResource("Width"),
                    helpText: LocalizedStringResource("Adjust the border width of the space elements"),
                    displayAsPoints: true
                )
            }

            Section(LocalizedStringResource("Space Foreground")) {
                SettingsColorPicker(
                    title: LocalizedStringResource("Color"),
                    description: LocalizedStringResource("Choose the foreground color for space text and icons"),
                    selectedColor: $viewModel.spaceForegroundColor,
                    supportsOpacity: false
                )
            }

            Section(LocalizedStringResource("Space Geometry")) {
                SettingsSlider(
                    value: $viewModel.spaceCornerRadius,
                    in: 0.0 ... ConfigurationDefaults.spaceCornerRadius,
                    defaultValue: ConfigurationDefaults.spaceCornerRadius,
                    stickiness: 1.0,
                    label: LocalizedStringResource("Corner Radius"),
                    helpText: LocalizedStringResource("Adjust the corner radius of space indicators"),
                    displayAsPercentage: true
                )
            }
        }
    }
}

#Preview {
    SpacesSettingsView().environmentObject(DependencyContainer.shared.getSettingsViewModel())
}
