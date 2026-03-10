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

    /// Whether this page is configuring the Apple Button virtual space.
    private var isAppleButton: Bool {
        spaceId == Space.appleButtonId
    }

    /// The current space configuration for this space ID.
    /// Returns a default instance if the space is not found.
    /// Handles the Apple Button ID specially by reading/writing from the view model's apple button properties.
    private var space: Binding<Domain.Space> {
        Binding(
            get: {
                if isAppleButton {
                    return Domain.Space(
                        id: Space.appleButtonId,
                        isFocused: false,
                        windows: [],
                        colorProperties: spacesViewModel.appleButtonColorProperties,
                        geometricProperties: spacesViewModel.appleButtonGeometricProperties,
                        effectProperties: spacesViewModel.appleButtonEffectProperties
                    )
                }

                guard let foundSpace = spacesViewModel.allSpaces.first(where: { $0.id == spaceId }) else {
                    // Return a default space if not found
                    return Domain.Space(
                        id: spaceId,
                        isFocused: false,
                        windows: [],
                        colorProperties: ConfigurationDefaults.spaceColorProperties,
                        geometricProperties: ConfigurationDefaults.spaceGeometricProperties
                    )
                }

                return foundSpace
            },
            set: { newSpace in
                if isAppleButton {
                    spacesViewModel.updateAppleButtonColorProperties(newSpace.colorProperties)
                    spacesViewModel.updateAppleButtonEffectProperties(newSpace.effectProperties)
                    spacesViewModel.updateAppleButtonGeometricProperties(newSpace.geometricProperties)
                    return
                }

                spacesViewModel.updateSpaceColorProperties(
                    spaceId: spaceId,
                    colorProperties: newSpace.colorProperties
                )

                spacesViewModel.updateSpaceEffectProperties(
                    spaceId: spaceId,
                    effectProperties: newSpace.effectProperties
                )

                spacesViewModel.updateSpaceGeometricProperties(
                    spaceId: spaceId,
                    geometricProperties: newSpace.geometricProperties
                )
            }
        )
    }

    /// The main body of the space configuration view.
    var body: some View {
        Form {
            if
                spacesViewModel.spacesAppearanceMode == .perSpace,
                spacesViewModel.themeMode.isColorCustomizable
            {
                VisualSettingsView(
                    metadata: Space.metadata,
                    themeMode: spacesViewModel.themeMode,
                    colorProperties: space.colorProperties,
                    geometricProperties: space.geometricProperties,
                    effectProperties: space.effectProperties
                )
            }
        }
        .settingsFormStyle()
        .navigationTitle(isAppleButton ? "\u{F8FF} Apple Button" : "Space \(spaceId)")
    }
}
