// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// A container view that displays all spaces in a horizontal layout.
///
/// This view manages the layout of individual SpaceView instances,
/// providing consistent spacing and organization for all spaces.
struct SpacesContainerView: View {
    /// The spaces to display
    let spaces: [Space]

    /// The spacing between spaces
    let widgetSpacing: CGFloat

    // MARK: - Body

    var body: some View {
        HStack(spacing: widgetSpacing) {
            ForEach(spaces) { space in
                SpaceView(space: space)
                    .tag("space-\(space.id)")
            }
        }
        .tag("spaces-container")
    }
}

#Preview {
    let spaces = [
        Space(id: "1", isFocused: true, windows: []),
        Space(id: "2", isFocused: false, windows: []),
        Space(id: "3", isFocused: false, windows: [])
    ]

    SpacesContainerView(spaces: spaces, widgetSpacing: 8)
        .environmentObject(DependencyContainer.shared.getSpacesViewModel())
        .padding()
}
