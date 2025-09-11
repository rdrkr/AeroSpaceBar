// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// A slider component that "snaps" to a default value when the user drags near it.
///
/// StickySlider provides enhanced user experience by automatically snapping to default values
/// when the user drags within a specified stickiness range, making it easier to return to
/// recommended settings without requiring precise positioning.
struct StickySlider<V, Label>: View where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint, Label: View {
    /// The binding for the slider's current value.
    @Binding var value: V

    /// The range of possible values for the slider.
    let bounds: ClosedRange<V>

    /// The default value that the slider should snap to.
    let defaultValue: V

    /// The range around the default value where snapping occurs.
    let stickiness: V

    /// The width of the label view, used for positioning the tick mark.
    let labelWidth: Double

    /// A view builder that creates the slider's label.
    @ViewBuilder var label: () -> Label

    /// Callback invoked when editing begins or ends.
    let onEditingChanged: (Bool) -> Void

    /// Initializes a sticky slider with the specified parameters.
    /// - Parameters:
    ///   - value: A binding to the slider's current value.
    ///   - bounds: The range of possible values for the slider. Defaults to 0...1.
    ///   - defaultValue: The default value that the slider should snap to.
    ///   - stickiness: The range around the default value where snapping occurs.
    ///   - labelWidth: The width of the label view, used for positioning the tick mark.
    ///   - label: A view builder that creates the slider's label.
    ///   - onEditingChanged: Callback invoked when editing begins or ends. Defaults to no-op.
    init(
        value: Binding<V>,
        in bounds: ClosedRange<V> = 0 ... 1,
        defaultValue: V,
        stickiness: V,
        labelWidth: Double,
        @ViewBuilder label: @escaping () -> Label,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) {
        _value = value
        self.bounds = bounds
        self.defaultValue = defaultValue
        self.stickiness = stickiness
        self.labelWidth = labelWidth
        self.label = label
        self.onEditingChanged = onEditingChanged
    }

    /// The body of the sticky slider view.
    /// - Returns: A VStack with a Slider and a tick mark indicating the default position.
    var body: some View {
        ZStack {
            Slider(
                value: Binding(
                    get: { value },
                    set: { newValue in
                        // If the new value is within the stickiness range of the default value,
                        // snap to the default value instead
                        if abs(newValue - defaultValue) < stickiness {
                            value = defaultValue
                        } else {
                            value = newValue
                        }
                    }
                ),
                in: bounds,
                label: label,
                onEditingChanged: onEditingChanged
            )

            // Tick mark to indicate default/sticky position
            GeometryReader { geometry in
                let tickWidth = 3.0
                let sliderPointerWidth = 20.0
                let sliderPointerHeight = 16.0
                let normalizedPosition =
                    Double((defaultValue - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound))
                let tickRelativePosition = labelWidth +
                    ((geometry.size.width - labelWidth) * normalizedPosition)

                let sliderPointerOffset = if defaultValue == bounds.lowerBound {
                    (sliderPointerWidth / 2) - (tickWidth / 2)
                } else if defaultValue == bounds.upperBound {
                    -(sliderPointerWidth / 2)
                } else {
                    tickWidth / 2
                }

                Rectangle()
                    .fill(Color.secondary)
                    .frame(width: tickWidth, height: 2)
                    .offset(
                        x: tickRelativePosition + sliderPointerOffset,
                        y: (sliderPointerHeight / 2) + 12
                    )
            }
        }
    }
}
