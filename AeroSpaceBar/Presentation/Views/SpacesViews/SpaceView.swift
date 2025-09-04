// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// A view that displays a space with its associated windows.
///
/// This view represents a single space/workspace and shows its identifier
/// along with the windows that belong to it. It provides interactive
/// functionality for switching to the space.
struct SpaceView: View {
    /// The spaces ViewModel for managing spaces data and interactions.
    @EnvironmentObject var viewModel: SpacesViewModel

    /// The space to display.
    let space: Space

    /// Whether the space view is currently being hovered.
    @State var isHovered = false

    // MARK: - Computed Properties

    /// Computed property for focus state to avoid repeated calculations
    private var isFocused: Bool {
        space.windows.contains {
            $0.isFocused
        } || space.isFocused
    }

    /// Computed property for space corner radius
    private var cornerRadius: CGFloat {
        viewModel.spaceCornerRadius
    }

    /// Computed property for widget spacing
    private var widgetSpacing: CGFloat {
        viewModel.widgetSpacing
    }

    // MARK: - Body

    /// The body of the space view.
    ///
    /// This view creates a horizontal layout showing the space identifier
    /// and its associated windows with proper styling and interactions.
    var body: some View {
        HStack(spacing: 0) {
            Spacer().frame(width: 10)

            Text(space.id)
                .font(.headline)
                .foregroundColor(viewModel.spaceForegroundColor)
                .frame(minWidth: 15)
                .fixedSize(horizontal: true, vertical: false)
                .textShadow()
                .tag("space-\(space.id)-identifier")

            Spacer().frame(width: 5)

            HStack(spacing: 2) {
                ForEach(space.windows) { window in
                    WindowView(window: window, space: space)
                        .tag("window-\(window.id)")
                }
            }
            .tag("space-\(space.id)-windows-container")

            Spacer().frame(width: widgetSpacing)
        }
        .spaceFocusState(
            isFocused,
            configuration: SpaceFocusState.Configuration(
                backgroundOpacity: viewModel.spaceBackgroundOpacity,
                backgroundBlurRadius: viewModel.spaceBackgroundBlurRadius,
                backgroundTintColor: viewModel.spaceBackgroundTintColor,
                foregroundColor: viewModel.spaceForegroundColor,
                borderTintColor: viewModel.spaceBorderTintColor,
                borderOpacity: viewModel.spaceBorderOpacity,
                borderCornerRadius: viewModel.spaceCornerRadius,
                borderWidth: viewModel.spaceBorderWidth
            )
        )
        .spaceCornerRadius(cornerRadius)
        .standardShadow()
        .blurReplaceTransition()
        .smoothAnimation(duration: viewModel.animationDuration)
        .conditionalInteraction(
            isEnabled: viewModel.focusWindowOnClick,
            isHovered: $isHovered,
            onTap: {
                DispatchQueue.main.async {
                    viewModel.switchToSpace(space, needWindowFocus: true)
                }
            }
        )
        .tag("space-\(space.id)-view")
    }
}

#Preview {
    SpaceView(space: Space(
        id: "1",
        isFocused: true,
        windows: []
    ))
    .environmentObject(DependencyContainer.shared.getSpacesViewModel())
    .padding()
}
