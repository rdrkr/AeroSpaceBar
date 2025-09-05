// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// A slider component that "snaps" to a default value when the user drags near it.
///
/// StickySlider provides enhanced user experience by automatically snapping to default values
/// when the user drags within a specified stickiness range, making it easier to return to
/// recommended settings without requiring precise positioning.
struct StickySlider<V>: View where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
    /// The binding for the slider's current value.
    @Binding var value: V

    /// The range of possible values for the slider.
    let bounds: ClosedRange<V>

    /// The default value that the slider should snap to.
    let defaultValue: V

    /// The range around the default value where snapping occurs.
    let stickiness: V

    /// A view builder that creates the slider's label.
    @ViewBuilder var label: () -> Text

    /// Callback invoked when editing begins or ends.
    let onEditingChanged: (Bool) -> Void

    /// Initializes a sticky slider with the specified parameters.
    /// - Parameters:
    ///   - value: A binding to the slider's current value.
    ///   - bounds: The range of possible values for the slider. Defaults to 0...1.
    ///   - defaultValue: The default value that the slider should snap to.
    ///   - stickiness: The range around the default value where snapping occurs.
    ///   - label: A view builder that creates the slider's label.
    ///   - onEditingChanged: Callback invoked when editing begins or ends. Defaults to no-op.
    init(
        value: Binding<V>,
        in bounds: ClosedRange<V> = 0 ... 1,
        defaultValue: V,
        stickiness: V,
        @ViewBuilder label: @escaping () -> Text,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) {
        _value = value
        self.bounds = bounds
        self.defaultValue = defaultValue
        self.stickiness = stickiness
        self.label = label
        self.onEditingChanged = onEditingChanged
    }

    /// The body of the sticky slider view.
    /// - Returns: A Slider view with sticky behavior around the default value.
    var body: some View {
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
    }
}
