// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Domain
import SwiftUI

/// A reusable view for configuring visual properties of VisualConfigurable entities.
///
/// This view provides standardized sections for configuring background, border, foreground,
/// and geometry properties of any entity that conforms to VisualConfigurable.
struct VisualSettingsView: View {
    /// The prefix used for localized strings and tags.
    let entityPrefix: LocalizedStringResource

    /// The binding to the visual configuration being edited.
    let visualConfig: Binding<VisualContainer>

    /// The default visual configuration for reset values and range limits.
    let defaultConfig: VisualContainer

    /// Optional tag prefix for UI testing and identification.
    let tagPrefix: String?

    /// Whether to show the foreground color section.
    let showForegroundSection: Bool

    /// Whether to show the geometry section.
    let showGeometrySection: Bool

    /// Initializes the visual settings view with the provided configuration.
    /// - Parameters:
    ///   - entityPrefix: The prefix used for localized strings
    ///   - visualConfig: Binding to the visual configuration being edited
    ///   - defaultConfig: Default configuration for reset values and limits
    ///   - tagPrefix: Optional tag prefix for UI testing
    ///   - showForegroundSection: Whether to show foreground color section (default: true)
    ///   - showGeometrySection: Whether to show geometry section (default: true)
    init(
        entityPrefix: LocalizedStringResource,
        visualConfig: Binding<VisualContainer>,
        defaultConfig: VisualContainer,
        tagPrefix: String? = nil,
        showForegroundSection: Bool = true,
        showGeometrySection: Bool = true
    ) {
        self.entityPrefix = entityPrefix
        self.visualConfig = visualConfig
        self.defaultConfig = defaultConfig
        self.tagPrefix = tagPrefix
        self.showForegroundSection = showForegroundSection
        self.showGeometrySection = showGeometrySection
    }

    /// The main body of the visual settings view.
    var body: some View {
        Group {
            backgroundSection
            borderSection

            if showForegroundSection {
                foregroundSection
            }

            if showGeometrySection {
                geometrySection
            }
        }
    }

    // MARK: - Private Sections

    /// Background appearance configuration section.
    private var backgroundSection: some View {
        Section(LocalizedStringResource("\(String(localized: entityPrefix)) Background")) {
            SettingsColorPicker(
                title: LocalizedStringResource("Tint Color"),
                description: LocalizedStringResource(
                    "Choose the background tint color for \(String(localized: entityPrefix).lowercased()) elements."
                ),
                selectedColor: visualConfig.backgroundTintColor,
                supportsOpacity: false
            )
            .tag(makeTag("background-tint-color"))

            SettingsSlider(
                value: visualConfig.backgroundOpacity,
                in: 0.0 ... 1.0,
                defaultValue: defaultConfig.backgroundOpacity,
                stickiness: 0.05,
                label: LocalizedStringResource("Opacity"),
                helpText: LocalizedStringResource(
                    "Adjust the background opacity of \(String(localized: entityPrefix).lowercased()) elements."
                ),
                displayAsPercentage: true
            )
            .tag(makeTag("background-opacity"))

            SettingsSlider(
                value: visualConfig.backgroundBlurRadius,
                in: 0.0 ... 10.0,
                defaultValue: defaultConfig.backgroundBlurRadius,
                stickiness: 0.5,
                label: LocalizedStringResource("Blur Radius"),
                helpText: LocalizedStringResource(
                    "Adjust the background blur radius of \(String(localized: entityPrefix).lowercased()) elements."
                ),
                displayAsPoints: true
            )
            .tag(makeTag("background-blur-radius"))
        }
        .tag(makeTag("background-section"))
    }

    /// Border appearance configuration section.
    private var borderSection: some View {
        Section(LocalizedStringResource("\(String(localized: entityPrefix)) Border")) {
            SettingsColorPicker(
                title: LocalizedStringResource("Tint Color"),
                description: LocalizedStringResource(
                    "Choose the border tint color for \(String(localized: entityPrefix).lowercased()) elements."
                ),
                selectedColor: visualConfig.borderTintColor,
                supportsOpacity: false
            )
            .tag(makeTag("border-tint-color"))

            SettingsSlider(
                value: visualConfig.borderOpacity,
                in: 0.0 ... 1.0,
                defaultValue: defaultConfig.borderOpacity,
                stickiness: 0.05,
                label: LocalizedStringResource("Opacity"),
                helpText: LocalizedStringResource(
                    "Adjust the border opacity of \(String(localized: entityPrefix).lowercased()) elements."
                ),
                displayAsPercentage: true
            )
            .tag(makeTag("border-opacity"))

            SettingsSlider(
                value: visualConfig.borderWidth,
                in: 0.0 ... 5.0,
                defaultValue: defaultConfig.borderWidth,
                stickiness: 0.25,
                label: LocalizedStringResource("Width"),
                helpText: LocalizedStringResource(
                    "Adjust the border width of \(String(localized: entityPrefix).lowercased()) elements."
                ),
                displayAsPoints: true
            )
            .tag(makeTag("border-width"))
        }
        .tag(makeTag("border-section"))
    }

    /// Foreground appearance configuration section.
    private var foregroundSection: some View {
        Section(LocalizedStringResource("\(String(localized: entityPrefix)) Foreground")) {
            SettingsColorPicker(
                title: LocalizedStringResource("Color"),
                description: LocalizedStringResource(
                    "Choose the foreground color for \(String(localized: entityPrefix).lowercased()) text and icons."
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
        Section(LocalizedStringResource("\(String(localized: entityPrefix)) Geometry")) {
            SettingsSlider(
                value: visualConfig.cornerRadius,
                in: 0.0 ... defaultConfig.cornerRadius,
                defaultValue: defaultConfig.cornerRadius,
                stickiness: 1.0,
                label: LocalizedStringResource("Corner Radius"),
                helpText: LocalizedStringResource(
                    "Adjust the corner radius of \(String(localized: entityPrefix).lowercased()) elements."
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
        if let prefix = tagPrefix {
            return "\(prefix)-\(suffix)"
        }
        return suffix
    }
}

// MARK: - Convenience Extensions

#Preview {
    struct PreviewWrapper: View {
        @State private var sampleConfig = ConfigurationDefaults.defaultSpaceVisualConfig

        var body: some View {
            Form {
                VisualSettingsView(
                    entityPrefix: LocalizedStringResource("Space"),
                    visualConfig: $sampleConfig,
                    defaultConfig: ConfigurationDefaults.defaultSpaceVisualConfig,
                    tagPrefix: "space"
                )
            }
            .frame(width: 600, height: 500)
        }
    }

    return PreviewWrapper()
}
