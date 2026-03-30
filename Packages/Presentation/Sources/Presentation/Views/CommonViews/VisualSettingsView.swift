// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Domain
import SwiftUI

/// A reusable view for configuring visual properties of VisualContainer entities.
///
/// This view provides standardized sections for configuring background, border, foreground,
/// and geometry properties of any entity that conforms to VisualContainer.
struct VisualSettingsView: View {
    /// The metadata configuration for the visual container entity.
    let metadata: VisualContainerMetadata

    /// The current theme mode.
    let themeMode: ThemeMode

    /// The binding to the color properties being edited.
    let colorProperties: Binding<ColorProperties>

    /// The binding to the geometric properties being edited.
    let geometricProperties: Binding<GeometricProperties>

    /// The binding to the effect properties being edited.
    let effectProperties: Binding<EffectProperties>

    /// The default geometric properties for the entity.
    private var defaultGeometricProperties: GeometricProperties {
        if themeMode.isColorCustomizable {
            metadata.defaultGlobalGeometricProperties
        } else {
            metadata.defaultThemeGeometricProperties
        }
    }

    /// The default effect properties for the entity.
    private var defaultEffectProperties: EffectProperties {
        if themeMode.isColorCustomizable {
            metadata.defaultGlobalEffectProperties
        } else {
            metadata.defaultThemeEffectProperties
        }
    }

    /// The main body of the visual settings view.
    var body: some View {
        Group {
            if themeMode.isColorCustomizable || themeMode.isEffectCustomizable {
                backgroundSection
                borderSection
            }

            if metadata.showForegroundSection, themeMode.isColorCustomizable {
                foregroundSection
            }

            if themeMode.isGeometryCustomizable {
                geometrySection
            }
        }
    }

    // MARK: - Private Sections

    /// Background appearance configuration section.
    private var backgroundSection: some View {
        Section(LocalizedStringResource(stringLiteral: "\(metadata.entityName) Background")) {
            if themeMode.isColorCustomizable {
                SettingsColorPicker(
                    title: LocalizedStringResource("Tint Color"),
                    description: LocalizedStringResource(stringLiteral:
                        "Choose the background tint color for \(metadata.entityName.lowercased()) " +
                            "elements."
                    ),
                    selectedColor: colorProperties.backgroundTintColor,
                    supportsOpacity: false
                )
                .tag(makeTag("background-tint-color"))
            }

            if themeMode.isEffectCustomizable {
                SettingsSlider(
                    value: effectProperties.backgroundOpacity,
                    in: 0.0 ... 1.0,
                    defaultValue: defaultEffectProperties.backgroundOpacity,
                    stickiness: 0.05,
                    label: LocalizedStringResource("Opacity"),
                    helpText: LocalizedStringResource(stringLiteral:
                        "Adjust the background opacity of \(metadata.entityName.lowercased()) elements."
                    ),
                    displayAsPercentage: true
                )
                .tag(makeTag("background-opacity"))
            }

            if themeMode.isColorCustomizable {
                SettingsSlider(
                    value: effectProperties.backgroundBlurRadius,
                    in: 0.0 ... 10.0,
                    defaultValue: defaultEffectProperties.backgroundBlurRadius,
                    stickiness: 0.5,
                    label: LocalizedStringResource("Blur Radius"),
                    helpText: LocalizedStringResource(stringLiteral:
                        "Adjust the background blur radius of \(metadata.entityName.lowercased())) " +
                            "elements."
                    ),
                    displayAsPoints: true
                )
                .tag(makeTag("background-blur-radius"))
            }
        }
        .tag(makeTag("background-section"))
    }

    /// Border appearance configuration section.
    private var borderSection: some View {
        Section(LocalizedStringResource(stringLiteral: "\(metadata.entityName) Border")) {
            if themeMode.isColorCustomizable {
                SettingsColorPicker(
                    title: LocalizedStringResource("Tint Color"),
                    description: LocalizedStringResource(stringLiteral:
                        "Choose the border tint color for \(metadata.entityName.lowercased())) elements."
                    ),
                    selectedColor: colorProperties.borderTintColor,
                    supportsOpacity: false
                )
                .tag(makeTag("border-tint-color"))
            }

            if themeMode.isEffectCustomizable {
                SettingsSlider(
                    value: effectProperties.borderOpacity,
                    in: 0.0 ... 1.0,
                    defaultValue: defaultEffectProperties.borderOpacity,
                    stickiness: 0.05,
                    label: LocalizedStringResource("Opacity"),
                    helpText: LocalizedStringResource(stringLiteral:
                        "Adjust the border opacity of \(metadata.entityName.lowercased())) elements."
                    ),
                    displayAsPercentage: true
                )
                .tag(makeTag("border-opacity"))
            }
        }
        .tag(makeTag("border-section"))
    }

    /// Foreground appearance configuration section.
    private var foregroundSection: some View {
        Section(LocalizedStringResource(stringLiteral: "\(metadata.entityName) Foreground")) {
            SettingsColorPicker(
                title: LocalizedStringResource("Tint Color"),
                description: LocalizedStringResource(stringLiteral:
                    "Choose the foreground tint color for \(metadata.entityName.lowercased()) " +
                        "text and icons."
                ),
                selectedColor: colorProperties.foregroundColor,
                supportsOpacity: false
            )
            .tag(makeTag("foreground-color"))
        }
        .tag(makeTag("foreground-section"))
    }

    private var geometrySection: some View {
        Section(LocalizedStringResource(stringLiteral: "\(metadata.entityName) Shape")) {
            GeometrySettingsView(
                entityName: metadata.entityName,
                geometricProperties: geometricProperties,
                defaultGeometricProperties: defaultGeometricProperties
            )
        }
        .tag(makeTag("geometry-section"))
    }

    // MARK: - Helper Methods

    /// Creates a tag string with optional prefix.
    /// - Parameter suffix: The suffix to append to the tag
    /// - Returns: A formatted tag string
    private func makeTag(_ suffix: String) -> String {
        let prefix = metadata.tagPrefix

        return "\(prefix)-\(suffix)"
    }
}
