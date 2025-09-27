// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Domain
import SwiftUI

/// A detailed view for configuring a specific space.
///
/// This view provides a comprehensive interface for customizing space settings including:
/// - Background appearance (color, opacity, blur)
/// - Border styling (color, opacity, width)
/// - Geometry configuration (corner radius)
/// - Foreground color settings
///
/// Unlike groups, spaces cannot be deleted or have their range modified as they are managed by AeroSpace.
struct SpacePageView: View {
    /// The settings view model for navigation management.
    @EnvironmentObject private var settingsViewModel: SettingsViewModel

    /// The spaces view model for space configuration management.
    @EnvironmentObject private var spacesViewModel: SpacesViewModel

    /// The unique identifier of the space being configured.
    let spaceId: String

    /// The current space configuration for this space ID.
    /// Returns a default instance if the space is not found.
    private var space: Binding<Domain.Space> {
        Binding(
            get: {
                guard let foundSpace = spacesViewModel.spaces.first(where: { $0.id == spaceId }) else {
                    // Return a default space if not found
                    return Domain.Space(
                        id: spaceId,
                        isFocused: false,
                        windows: [],
                        visualConfig: ConfigurationDefaults.defaultSpaceVisualConfig
                    )
                }

                return foundSpace
            },
            set: { newSpace in
                spacesViewModel.updateSpaceVisualConfig(spaceId: spaceId, visualConfig: newSpace.visualConfig)
            }
        )
    }

    /// The main body of the space configuration view.
    var body: some View {
        Form {
            if spacesViewModel.spacesAppearanceMode == .perSpace {
                VisualSettingsView(
                    metadata: Space.metadata,
                    visualConfig: space.visualConfig
                )
            }
        }
        .settingsFormStyle()
        .navigationTitle("Space \(spaceId)")
    }
}
