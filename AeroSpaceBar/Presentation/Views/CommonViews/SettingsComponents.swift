// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

// MARK: - Settings Components

/// A reusable settings row with a toggle switch
struct SettingsToggleRow: View {
    let title: LocalizedStringResource
    let description: LocalizedStringResource
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            VStack(alignment: .leading) {
                Text(title)
                    .tag("settings-toggle-title")
                Text(description)
                    .secondaryText()
                    .tag("settings-toggle-description")
            }
        }
        .toggleStyle(.switch)
        .tag("settings-toggle-row")
    }
}

/// A reusable settings row with a color picker
struct SettingsColorRow: View {
    let title: LocalizedStringResource
    let description: LocalizedStringResource
    let accessibilityLabel: String
    @Binding var selectedColor: Color
    let supportsOpacity: Bool

    init(
        title: LocalizedStringResource,
        description: LocalizedStringResource,
        selectedColor: Binding<Color>,
        supportsOpacity: Bool = false
    ) {
        self.title = title
        self.description = description
        accessibilityLabel = String(localized: title)
        _selectedColor = selectedColor
        self.supportsOpacity = supportsOpacity
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .tag("settings-color-title")
                    Text(description)
                        .secondaryText()
                        .tag("settings-color-description")
                }

                Spacer()

                ColorPicker(
                    accessibilityLabel,
                    selection: $selectedColor,
                    supportsOpacity: supportsOpacity
                )
                .labelsHidden()
                .tag("settings-color-picker")
            }
        }
        .tag("settings-color-row")
    }
}

/// A reusable settings row with a slider
struct SettingsSliderRow: View {
    let title: LocalizedStringResource
    let description: LocalizedStringResource
    @Binding var value: Double
    let range: ClosedRange<Double>
    let displayValue: String
    let valueWidth: CGFloat

    init(
        title: LocalizedStringResource,
        description: LocalizedStringResource,
        value: Binding<Double>,
        in range: ClosedRange<Double>,
        displayValue: String,
        valueWidth: CGFloat = 34
    ) {
        self.title = title
        self.description = description
        _value = value
        self.range = range
        self.displayValue = displayValue
        self.valueWidth = valueWidth
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Slider(value: $value, in: range) {
                    Text(title)
                        .tag("settings-slider-title")
                }

                Text(displayValue)
                    .secondaryText()
                    .frame(
                        width: valueWidth,
                        alignment: .trailing
                    )
                    .tag("settings-slider-value")
            }

            Text(description)
                .secondaryText()
                .tag("settings-slider-description")
        }
        .tag("settings-slider-row")
    }
}

/// A reusable settings row with a CGFloat slider
struct SettingsCGFloatSliderRow: View {
    let title: LocalizedStringResource
    let description: LocalizedStringResource
    @Binding var value: CGFloat
    let range: ClosedRange<CGFloat>
    let displayValue: String
    let valueWidth: CGFloat

    init(
        title: LocalizedStringResource,
        description: LocalizedStringResource,
        value: Binding<CGFloat>,
        in range: ClosedRange<CGFloat>,
        displayValue: String,
        valueWidth: CGFloat = 34
    ) {
        self.title = title
        self.description = description
        _value = value
        self.range = range
        self.displayValue = displayValue
        self.valueWidth = valueWidth
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Slider(value: $value, in: range) {
                    Text(title)
                        .tag("settings-slider-title")
                }

                Text(displayValue)
                    .secondaryText()
                    .frame(
                        width: valueWidth,
                        alignment: .trailing
                    )
                    .tag("settings-slider-value")
            }

            Text(description)
                .secondaryText()
                .tag("settings-slider-description")
        }
        .tag("settings-cgfloat-slider-row")
    }
}

/// A reusable settings section header
struct SettingsSectionHeader: View {
    let title: LocalizedStringResource

    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.primary)
            .tag("settings-section-header")
    }
}

// MARK: - Previews

#Preview("Toggle Row") {
    Form {
        Section {
            SettingsToggleRow(
                title: "Show Window Titles",
                description: "Display window titles next to icons in the widget.",
                isOn: .constant(true)
            )
        }
    }
    .formStyle(.grouped)
}

#Preview("Color Row") {
    Form {
        Section {
            SettingsColorRow(
                title: "Background Color",
                description: "Choose the background color for elements",
                selectedColor: .constant(.blue)
            )
        }
    }
    .formStyle(.grouped)
}

#Preview("Slider Row") {
    Form {
        Section {
            SettingsSliderRow(
                title: "Opacity",
                description: "Adjust the opacity of elements",
                value: .constant(0.8),
                in: 0.0 ... 1.0,
                displayValue: "80%"
            )
        }
    }
    .formStyle(.grouped)
}
