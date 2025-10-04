// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Domain
import SwiftUI

/// A view that represents the group background for a set of menu bar applications.
struct GroupView: View {
    /// The group configuration containing styling and range information.
    let group: Domain.Group

    /// The complete list of menu bar applications from which to select group members.
    let menuBarApps: [MenuBarApp]

    /// The appearance mode determining which styling properties to use.
    let appearanceMode: GroupsAppearanceMode

    /// The color properties for global groups appearance mode.
    let globalGroupsColorProperties: ColorProperties

    /// The geometric properties for global groups appearance mode.
    let globalGroupsGeometricProperties: GeometricProperties

    /// The effect properties for global groups appearance mode.
    let globalGroupsEffectProperties: EffectProperties

    /// The color properties for match spaces appearance mode.
    let globalSpacesColorProperties: ColorProperties

    /// The geometric properties for match spaces appearance mode.
    let globalSpacesGeometricProperties: GeometricProperties

    /// The effect properties for match spaces appearance mode.
    let globalSpacesEffectProperties: EffectProperties

    /// The theme mode for visual customization.
    let themeMode: ThemeMode

    /// The selected theme preset.
    let themePresetColorProperties: ThemePresetColorProperties

    /// The geometric properties for theme preset elements.
    let themePresetGeometricProperties: GeometricProperties

    /// The effect properties for theme preset elements.
    let themePresetEffectProperties: EffectProperties

    /// The apps in this group that are currently visible (based on group range)
    private var groupApps: [MenuBarApp] {
        let actualEndIndex = group.getEndIndex(menuBarAppsCount: menuBarApps.count)
        guard group.startIndex > 0, actualEndIndex >= group.startIndex, actualEndIndex <= menuBarApps.count else {
            return []
        }

        let range = group.startIndex ... actualEndIndex
        return Array(menuBarApps.dropFirst(range.lowerBound - 1).prefix(range.count))
    }

    // MARK: - Appearance Properties

    /// The color properties based on the current appearance mode and theme mode
    private var currentColorProperties: ColorProperties {
        switch themeMode {
        case .preset: themePresetColorProperties.colorProperties

        case .glass,
             .custom:
            switch appearanceMode {
            case .perGroup: group.colorProperties
            case .allGroups: globalGroupsColorProperties
            case .matchSpaces: globalSpacesColorProperties
            }
        }
    }

    /// The geometric properties based on the current appearance mode and theme mode
    private var currentGeometricProperties: GeometricProperties {
        switch themeMode {
        case .preset: themePresetGeometricProperties

        case .glass,
             .custom:
            switch appearanceMode {
            case .perGroup: group.geometricProperties
            case .allGroups: globalGroupsGeometricProperties
            case .matchSpaces: globalSpacesGeometricProperties
            }
        }
    }

    /// The effect properties based on the current appearance mode and theme mode
    private var currentEffectProperties: EffectProperties {
        switch themeMode {
        case .preset: themePresetEffectProperties

        case .glass,
             .custom:
            switch appearanceMode {
            case .perGroup: group.effectProperties
            case .allGroups: globalGroupsEffectProperties
            case .matchSpaces: globalSpacesEffectProperties
            }
        }
    }

    /// The background tint color based on the current appearance mode
    private var backgroundTintColor: Color {
        currentColorProperties.backgroundTintColor
    }

    /// The background opacity based on the current appearance mode
    private var backgroundOpacity: Double {
        currentEffectProperties.backgroundOpacity
    }

    /// The background blur radius based on the current appearance mode
    private var backgroundBlurRadius: Double {
        currentEffectProperties.backgroundBlurRadius
    }

    /// The border color based on the current appearance mode
    private var borderColor: Color {
        currentColorProperties.borderTintColor
    }

    /// The border opacity based on the current appearance mode
    private var borderOpacity: Double {
        currentEffectProperties.borderOpacity
    }

    /// The border width based on the current appearance mode
    private var borderWidth: Double {
        currentGeometricProperties.borderWidth
    }

    /// The corner radius based on the current appearance mode
    private var cornerRadius: Double {
        currentGeometricProperties.cornerRadius
    }

    /// The combined frame that encompasses all apps in this group
    private var groupFrame: CGRect {
        let apps = groupApps
        guard !apps.isEmpty else { return .zero }

        let minX = apps.map(\.frame.minX).min() ?? 0
        let maxX = apps.map(\.frame.maxX).max() ?? 0
        let minY = apps.map(\.frame.minY).min() ?? 0
        let maxY = apps.map(\.frame.maxY).max() ?? 0

        let fullWidth = maxX - minX
        let fullHeight = maxY - minY
        let reduceWidth = fullWidth - ConfigurationDefaults.widgetSpacing - (borderWidth * 2)
        let reducedHeight = ConfigurationDefaults.windowIconSize + (ConfigurationDefaults.menuBarVerticalPadding * 2)
        let horizontalMargin = (fullWidth - reduceWidth) / 2
        let verticalMargin = (fullHeight - reducedHeight) / 2

        return CGRect(
            x: minX + horizontalMargin,
            y: minY + verticalMargin,
            width: reduceWidth,
            height: reducedHeight
        )
    }

    var body: some View {
        let groupBackground = Group {
            if themeMode == .glass, #available(macOS 26.0, *) {
                glassBackgroundView
            } else {
                standardBackgroundView
            }
        }

        if !menuBarApps.isEmpty {
            groupBackground
                .animation(.themeEaseInOutFast, value: groupFrame)
        } else {
            groupBackground
        }
    }

    /// The glass effect background view for macOS 26+.
    @available(macOS 26.0, *)
    private var glassBackgroundView: some View {
        Text("")
            .frame(width: groupFrame.width, height: groupFrame.height)
            .glassEffect(.clear.interactive(true))
            .position(x: groupFrame.midX, y: groupFrame.midY)
    }

    /// The standard background view with blur and opacity.
    private var standardBackgroundView: some View {
        Color.clear
            .background(
                backgroundTintColor
                    .opacity(backgroundOpacity)
                    .blur(radius: backgroundBlurRadius)
            )
            .cornerRadius(cornerRadius)
            .frame(width: groupFrame.width, height: groupFrame.height)
            .background(borderView)
            .position(x: groupFrame.midX, y: groupFrame.midY)
            .standardShadow()
    }

    /// The border view for the group.
    private var borderView: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .stroke(
                borderColor.opacity(borderOpacity),
                lineWidth: borderWidth
            )
            .frame(
                width: groupFrame.width + borderWidth,
                height: groupFrame.height + borderWidth
            )
    }
}
