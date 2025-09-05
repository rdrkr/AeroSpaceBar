// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// Displays appearance-related settings: space opacity, space blur radius, window titles, and more.
struct AppearanceSettingsView: View {
    @EnvironmentObject private var viewModel: SettingsViewModel
    private let navigationOption: SettingsNavigationOptions = .appearance

    var body: some View {
        IntroForm(
            navigationTitle: String(localized: navigationOption.name),
            style: .compact,
            image: Image(systemName: navigationOption.symbolName),
            title: String(localized: navigationOption.name),
            subtitle: "Fine-tune how AeroSpaceBar looks: opacity, blur, titles, and more."
        ) {
            Section {
                Toggle(isOn: $viewModel.showWindowTitles) {
                    VStack(alignment: .leading) {
                        Text(LocalizedStringResource("Show Window Title"))
                        Text(LocalizedStringResource("Display window title next to icons in the widget."))
                            .secondaryText()
                    }
                }.toggleStyle(.switch)
            }

            Section(LocalizedStringResource("Space Background")) {
                VStack(alignment: .leading) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(LocalizedStringResource("Tint Color"))
                            Text(LocalizedStringResource("Choose the background tint color for space elements"))
                                .secondaryText()
                        }

                        Spacer()

                        ColorPicker(
                            "Tint Color",
                            selection: $viewModel.spaceBackgroundTintColor,
                            supportsOpacity: false
                        )
                        .labelsHidden()
                    }
                }

                VStack(alignment: .leading) {
                    HStack {
                        StickySlider(
                            value: $viewModel.spaceBackgroundOpacity,
                            in: 0.0 ... 1.0,
                            defaultValue: ConfigurationDefaults.spaceBackgroundOpacity,
                            stickiness: 0.05
                        ) {
                            Text(LocalizedStringResource("Opacity"))
                        }

                        Text("\(Int(viewModel.spaceBackgroundOpacity * 100))%")
                            .valueDisplayText()
                    }

                    Text(LocalizedStringResource("Adjust the background opacity of the space elements"))
                        .secondaryText()
                }

                VStack(alignment: .leading) {
                    HStack {
                        StickySlider(
                            value: $viewModel.spaceBackgroundBlurRadius,
                            in: 0.0 ... 10.0,
                            defaultValue: ConfigurationDefaults.spaceBackgroundBlurRadius,
                            stickiness: 0.5
                        ) {
                            Text(LocalizedStringResource("Blur"))
                        }

                        Text("\(Int(viewModel.spaceBackgroundBlurRadius)) pts")
                            .valueDisplayText()
                    }

                    Text(LocalizedStringResource("Adjust the background blur radius of the space elements"))
                        .secondaryText()
                }
            }

            Section(LocalizedStringResource("Space Border")) {
                VStack(alignment: .leading) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(LocalizedStringResource("Tint Color"))
                            Text(LocalizedStringResource("Choose the border tint color for space elements"))
                                .secondaryText()
                        }

                        Spacer()

                        ColorPicker(
                            "Tint Color",
                            selection: $viewModel.spaceBorderTintColor,
                            supportsOpacity: false
                        )
                        .labelsHidden()
                    }
                }

                VStack(alignment: .leading) {
                    HStack {
                        StickySlider(
                            value: $viewModel.spaceBorderOpacity,
                            in: 0.0 ... 1.0,
                            defaultValue: ConfigurationDefaults.spaceBorderOpacity,
                            stickiness: 0.05
                        ) {
                            Text(LocalizedStringResource("Opacity"))
                        }

                        Text("\(Int(viewModel.spaceBorderOpacity * 100))%")
                            .secondaryText()
                            .frame(
                                width: 34,
                                alignment: .trailing
                            )
                    }

                    Text(LocalizedStringResource("Adjust the border opacity of the space elements"))
                        .secondaryText()
                }

                VStack(alignment: .leading) {
                    HStack {
                        StickySlider(
                            value: $viewModel.spaceBorderWidth,
                            in: 0.0 ... 5.0,
                            defaultValue: ConfigurationDefaults.spaceBorderWidth,
                            stickiness: 0.25
                        ) {
                            Text(LocalizedStringResource("Width"))
                        }

                        Text("\(Int(viewModel.spaceBorderWidth)) pts")
                            .secondaryText()
                            .frame(
                                width: 34,
                                alignment: .trailing
                            )
                    }

                    Text(LocalizedStringResource("Adjust the border width of the space elements"))
                        .secondaryText()
                }
            }

            Section(LocalizedStringResource("Space Foreground")) {
                VStack(alignment: .leading) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(LocalizedStringResource("Color"))
                            Text(LocalizedStringResource("Choose the foreground color for space text and icons"))
                                .secondaryText()
                        }

                        Spacer()

                        ColorPicker(
                            "Color",
                            selection: $viewModel.spaceForegroundColor,
                            supportsOpacity: false
                        )
                        .labelsHidden()
                    }
                }
            }

            Section(LocalizedStringResource("Space Geometry")) {
                VStack(alignment: .leading) {
                    HStack {
                        StickySlider(
                            value: $viewModel.spaceCornerRadius,
                            in: 0.0 ... ConfigurationDefaults.spaceCornerRadius,
                            defaultValue: ConfigurationDefaults.spaceCornerRadius,
                            stickiness: 1.0
                        ) {
                            Text(LocalizedStringResource("Corner Radius"))
                        }

                        Text("\(Int(viewModel.spaceCornerRadius * 100 / ConfigurationDefaults.spaceCornerRadius))%")
                            .secondaryText()
                            .frame(
                                width: 34,
                                alignment: .trailing
                            )
                    }

                    Text(LocalizedStringResource("Adjust the corner radius of space indicators"))
                        .secondaryText()
                }
            }
        }
    }
}

#Preview {
    AppearanceSettingsView().environmentObject(DependencyContainer.shared.getSettingsViewModel())
}
