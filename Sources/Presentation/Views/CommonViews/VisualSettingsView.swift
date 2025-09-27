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

    /// The binding to the visual configuration being edited.
    let visualConfig: Binding<VisualProperties>

    /// Initializes the visual settings view with the provided configuration.
    /// - Parameters:
    ///   - metadata: The metadata configuration for the visual container entity
    ///   - visualConfig: Binding to the visual configuration being edited
    init(
        metadata: VisualContainerMetadata,
        visualConfig: Binding<VisualProperties>
    ) {
        self.metadata = metadata
        self.visualConfig = visualConfig
    }

    /// The main body of the visual settings view.
    var body: some View {
        Group {
            backgroundSection
            borderSection

            if metadata.showForegroundSection {
                foregroundSection
            }

            geometrySection
        }
    }

    // MARK: - Private Sections

    /// Background appearance configuration section.
    private var backgroundSection: some View {
        Section(LocalizedStringResource(stringLiteral: "\(metadata.entityName) Background")) {
            SettingsColorPicker(
                title: LocalizedStringResource("Tint Color"),
                description: LocalizedStringResource(stringLiteral:
                    "Choose the background tint color for \(metadata.entityName.lowercased()) " +
                        "elements."
                ),
                selectedColor: visualConfig.backgroundTintColor,
                supportsOpacity: false
            )
            .tag(makeTag("background-tint-color"))

            SettingsSlider(
                value: visualConfig.backgroundOpacity,
                in: 0.0 ... 1.0,
                defaultValue: metadata.defaultGlobalVisualConfig.backgroundOpacity,
                stickiness: 0.05,
                label: LocalizedStringResource("Opacity"),
                helpText: LocalizedStringResource(stringLiteral:
                    "Adjust the background opacity of \(metadata.entityName.lowercased()) elements."
                ),
                displayAsPercentage: true
            )
            .tag(makeTag("background-opacity"))

            SettingsSlider(
                value: visualConfig.backgroundBlurRadius,
                in: 0.0 ... 10.0,
                defaultValue: metadata.defaultGlobalVisualConfig.backgroundBlurRadius,
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
        .tag(makeTag("background-section"))
    }

    /// Border appearance configuration section.
    private var borderSection: some View {
        Section(LocalizedStringResource(stringLiteral: "\(metadata.entityName) Border")) {
            SettingsColorPicker(
                title: LocalizedStringResource("Tint Color"),
                description: LocalizedStringResource(stringLiteral:
                    "Choose the border tint color for \(metadata.entityName.lowercased())) elements."
                ),
                selectedColor: visualConfig.borderTintColor,
                supportsOpacity: false
            )
            .tag(makeTag("border-tint-color"))

            SettingsSlider(
                value: visualConfig.borderOpacity,
                in: 0.0 ... 1.0,
                defaultValue: metadata.defaultGlobalVisualConfig.borderOpacity,
                stickiness: 0.05,
                label: LocalizedStringResource("Opacity"),
                helpText: LocalizedStringResource(stringLiteral:
                    "Adjust the border opacity of \(metadata.entityName.lowercased())) elements."
                ),
                displayAsPercentage: true
            )
            .tag(makeTag("border-opacity"))

            SettingsSlider(
                value: visualConfig.borderWidth,
                in: 0.0 ... 5.0,
                defaultValue: metadata.defaultGlobalVisualConfig.borderWidth,
                stickiness: 0.25,
                label: LocalizedStringResource("Width"),
                helpText: LocalizedStringResource(stringLiteral:
                    "Adjust the border width of \(metadata.entityName.lowercased())) elements."
                ),
                displayAsPoints: true
            )
            .tag(makeTag("border-width"))
        }
        .tag(makeTag("border-section"))
    }

    /// Foreground appearance configuration section.
    private var foregroundSection: some View {
        Section(LocalizedStringResource(stringLiteral: "\(metadata.entityName) Foreground")) {
            SettingsColorPicker(
                title: LocalizedStringResource("Color"),
                description: LocalizedStringResource(stringLiteral:
                    "Choose the foreground color for \(metadata.entityName.lowercased())) " +
                        "text and icons."
                ),
                selectedColor: visualConfig.foregroundColor,
                supportsOpacity: false
            )
            .tag(makeTag("foreground-color"))
        }
        .tag(makeTag("foreground-section"))
    }

    /// Geometry configuration section.
    private var geometrySection: some View {
        Section(LocalizedStringResource(stringLiteral: "\(metadata.entityName) Geometry")) {
            SettingsSlider(
                value: visualConfig.cornerRadius,
                in: 0.0 ... metadata.defaultGlobalVisualConfig.cornerRadius,
                defaultValue: metadata.defaultGlobalVisualConfig.cornerRadius,
                stickiness: 1.0,
                label: LocalizedStringResource("Corner Radius"),
                helpText: LocalizedStringResource(stringLiteral:
                    "Adjust the corner radius of \(metadata.entityName.lowercased())) elements."
                ),
                displayAsPoints: true
            )
            .tag(makeTag("corner-radius"))
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
