// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// A view for configuring the range of apps in a group.
struct GroupAppRangePicker: View {
    @Binding var startIndex: Int
    @Binding var endIndex: Int
    let totalApps: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(LocalizedStringResource("Range"))
                Text("Select which menu bar applications to include (right to left)")
                    .secondaryText()
            }

            Spacer()

            VStack(alignment: .trailing) {
                Picker(LocalizedStringResource("From"), selection: $startIndex) {
                    ForEach(1 ... min(endIndex, totalApps), id: \.self) { index in
                        Text("\(index)").tag(index)
                    }
                }

                Spacer()

                Picker(LocalizedStringResource("To"), selection: $endIndex) {
                    ForEach(startIndex ... max(startIndex, totalApps), id: \.self) { index in
                        Text("\(index)").tag(index)
                    }
                }
            }
            .frame(width: 100)
        }
        .onChange(of: startIndex) { _, newValue in
            if endIndex < newValue {
                endIndex = newValue
            }
        }
    }
}
