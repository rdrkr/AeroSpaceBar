// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// A standardized slider component for settings views with consistent styling and layout.
///
/// SettingsSlider provides a unified interface for sliders used in settings screens,
/// including the slider control, value display, and help text with consistent spacing and alignment.
struct SettingsSlider<V: BinaryFloatingPoint>: View where V.Stride: BinaryFloatingPoint {
    /// The binding for the slider's current value.
    @Binding var value: V

    /// The range of possible values for the slider.
    let bounds: ClosedRange<V>

    /// The default value that the slider should snap to.
    let defaultValue: V

    /// The range around the default value where snapping occurs.
    let stickiness: V

    /// The label text for the slider.
    let label: LocalizedStringResource

    /// The help text displayed below the slider.
    let helpText: LocalizedStringResource

    /// A closure that formats the current value for display.
    let valueFormatter: (V) -> String

    /// Callback invoked when editing begins or ends.
    let onEditingChanged: (Bool) -> Void

    /// Initializes a settings slider with the specified parameters.
    /// - Parameters:
    ///   - value: A binding to the slider's current value.
    ///   - bounds: The range of possible values for the slider.
    ///   - defaultValue: The default value that the slider should snap to.
    ///   - stickiness: The range around the default value where snapping occurs.
    ///   - label: The label text for the slider.
    ///   - helpText: The help text displayed below the slider.
    ///   - valueFormatter: A closure that formats the current value for display.
    ///   - onEditingChanged: Callback invoked when editing begins or ends. Defaults to no-op.
    init(
        value: Binding<V>,
        in bounds: ClosedRange<V>,
        defaultValue: V,
        stickiness: V,
        label: LocalizedStringResource,
        helpText: LocalizedStringResource,
        valueFormatter: @escaping (V) -> String,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) {
        _value = value
        self.bounds = bounds
        self.defaultValue = defaultValue
        self.stickiness = stickiness
        self.label = label
        self.helpText = helpText
        self.valueFormatter = valueFormatter
        self.onEditingChanged = onEditingChanged
    }

    /// Initializer for percentage values (0.0-1.0 displayed as 0-100%)
    init(
        value: Binding<V>,
        in bounds: ClosedRange<V>,
        defaultValue: V,
        stickiness: V,
        label: LocalizedStringResource,
        helpText: LocalizedStringResource,
        displayAsPercentage asPercentage: Bool = true,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
        self.init(
            value: value,
            in: bounds,
            defaultValue: defaultValue,
            stickiness: stickiness,
            label: label,
            helpText: helpText,
            valueFormatter: { value in
                asPercentage ? "\(Int(value * 100 / bounds.upperBound))%" : "\(Int(value))"
            },
            onEditingChanged: onEditingChanged
        )
    }

    /// Initializer for point values with "pts" suffix
    init(
        value: Binding<V>,
        in bounds: ClosedRange<V>,
        defaultValue: V,
        stickiness: V,
        label: LocalizedStringResource,
        helpText: LocalizedStringResource,
        displayAsPoints asPoints: Bool = true,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
        self.init(
            value: value,
            in: bounds,
            defaultValue: defaultValue,
            stickiness: stickiness,
            label: label,
            helpText: helpText,
            valueFormatter: { value in
                asPoints ? "\(Int(value)) pts" : "\(Int(value))"
            },
            onEditingChanged: onEditingChanged
        )
    }

    /// The body of the settings slider view.
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                StickySlider(
                    value: $value,
                    in: bounds,
                    defaultValue: defaultValue,
                    stickiness: stickiness,
                    labelWidth: 174.0
                ) {
                    Text(label)
                }

                Text(valueFormatter(value))
                    .secondaryText()
                    .frame(
                        width: 34,
                        alignment: .trailing
                    )
            }

            Text(helpText)
                .secondaryText()
        }
    }
}
