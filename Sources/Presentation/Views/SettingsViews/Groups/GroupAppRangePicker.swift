// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// A view for configuring the range of apps in a group.
struct GroupAppRangePicker: View {
    /// Picker application start index.
    @Binding var startIndex: Int

    /// Picker application end index.
    @Binding var endIndex: Int

    /// The number of apps in system menu bar.
    let totalApps: Int

    /// The minimum allowed start index (based on previous group's end index + 1).
    let minimumStartIndex: Int

    /// The maximum allowed end index (based on next group's start index - 1).
    let maximumEndIndex: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(LocalizedStringResource("Range"))
                Text("Select which menu bar applications to include (right to left).")
                    .secondaryText()
            }

            Spacer()

            VStack(alignment: .trailing) {
                Picker(LocalizedStringResource("From"), selection: $startIndex) {
                    let upperBound = min(endIndex, totalApps)
                    let validRange = minimumStartIndex <= upperBound
                    ForEach(
                        validRange ? minimumStartIndex ... upperBound : minimumStartIndex ... minimumStartIndex,
                        id: \.self
                    ) { index in
                        Text("\(index)").tag(index)
                    }
                }

                Spacer()

                Picker(LocalizedStringResource("To"), selection: $endIndex) {
                    let upperBound = min(maximumEndIndex, totalApps)
                    let validRange = startIndex <= upperBound
                    ForEach(validRange ? startIndex ... upperBound : startIndex ... startIndex, id: \.self) { index in
                        Text("\(index)").tag(index)
                    }
                }
            }
            .frame(width: 100)
        }
        .onChange(of: startIndex) { _, newValue in
            // Ensure startIndex is not below minimum
            let constrainedValue = max(newValue, minimumStartIndex)
            if constrainedValue != newValue {
                startIndex = constrainedValue
                return
            }

            // Ensure endIndex is at least startIndex and not above maximum
            if endIndex < newValue {
                endIndex = newValue
            } else if endIndex > maximumEndIndex {
                endIndex = maximumEndIndex
            }
        }
        .onChange(of: endIndex) { _, newValue in
            // Ensure endIndex is not above maximum
            let constrainedValue = min(newValue, maximumEndIndex)
            if constrainedValue != newValue {
                endIndex = constrainedValue
                return
            }

            // Ensure startIndex is at most endIndex
            if startIndex > newValue {
                startIndex = max(newValue, minimumStartIndex)
            }
        }
    }
}
