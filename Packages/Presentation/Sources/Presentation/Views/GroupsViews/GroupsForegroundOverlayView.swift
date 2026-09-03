// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Domain
import SwiftUI

/// A view that draws semi-transparent foreground color rectangles above system menu bar icons.
///
/// This view sits in a panel at `statusWindow` level, above the system menu bar icons.
/// For each group that has a non-default foreground color, it draws a filled rounded rectangle
/// matching the group's background frame. The foreground color tints the menu bar icons underneath.
///
/// The background layer (drawn by `GroupsCanvasView`) compensates for this overlay so that
/// the combined visible result matches the user's configured background color. The foreground
/// opacity is scaled proportionally to the background opacity to ensure accurate color matching
/// at all background opacity levels.
struct GroupsForegroundOverlayView: View, Animatable {
    /// The maximum foreground overlay opacity, used when background opacity is 1.0.
    /// The effective opacity is scaled: `foregroundOverlayOpacity × backgroundOpacity`.
    static let foregroundOverlayOpacity: Double = 0.5

    /// The groups to render foreground overlays for.
    let groups: [Domain.Group]

    /// The complete list of menu bar applications used to compute group frames.
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

    /// The selected theme preset color properties.
    let themePresetColorProperties: ThemePresetColorProperties

    /// The geometric properties for theme preset elements.
    let themePresetGeometricProperties: GeometricProperties

    /// The effect properties for theme preset elements.
    let themePresetEffectProperties: EffectProperties

    /// Animated frame data encoding all group rectangles as `[x, y, width, height]` sequences.
    var frameData: AnimatableVector

    /// The animatable data that SwiftUI interpolates during frame transitions.
    nonisolated var animatableData: AnimatableVector {
        get { frameData }
        set { frameData = newValue }
    }

    // MARK: - Initialization

    /// Creates a new foreground overlay view with pre-computed animated frame data.
    /// - Parameters:
    ///   - groups: The groups to render foreground overlays for.
    ///   - menuBarApps: The complete list of menu bar applications used to compute group frames.
    ///   - appearanceMode: The appearance mode determining which styling properties to use.
    ///   - globalGroupsColorProperties: The color properties for global groups appearance mode.
    ///   - globalGroupsGeometricProperties: The geometric properties for global groups appearance mode.
    ///   - globalGroupsEffectProperties: The effect properties for global groups appearance mode.
    ///   - globalSpacesColorProperties: The color properties for match spaces appearance mode.
    ///   - globalSpacesGeometricProperties: The geometric properties for match spaces appearance mode.
    ///   - globalSpacesEffectProperties: The effect properties for match spaces appearance mode.
    ///   - themeMode: The theme mode for visual customization.
    ///   - themePresetColorProperties: The selected theme preset color properties.
    ///   - themePresetGeometricProperties: The geometric properties for theme preset elements.
    ///   - themePresetEffectProperties: The effect properties for theme preset elements.
    init(
        groups: [Domain.Group],
        menuBarApps: [MenuBarApp],
        appearanceMode: GroupsAppearanceMode,
        globalGroupsColorProperties: ColorProperties,
        globalGroupsGeometricProperties: GeometricProperties,
        globalGroupsEffectProperties: EffectProperties,
        globalSpacesColorProperties: ColorProperties,
        globalSpacesGeometricProperties: GeometricProperties,
        globalSpacesEffectProperties: EffectProperties,
        themeMode: ThemeMode,
        themePresetColorProperties: ThemePresetColorProperties,
        themePresetGeometricProperties: GeometricProperties,
        themePresetEffectProperties: EffectProperties
    ) {
        self.groups = groups
        self.menuBarApps = menuBarApps
        self.appearanceMode = appearanceMode
        self.globalGroupsColorProperties = globalGroupsColorProperties
        self.globalGroupsGeometricProperties = globalGroupsGeometricProperties
        self.globalGroupsEffectProperties = globalGroupsEffectProperties
        self.globalSpacesColorProperties = globalSpacesColorProperties
        self.globalSpacesGeometricProperties = globalSpacesGeometricProperties
        self.globalSpacesEffectProperties = globalSpacesEffectProperties
        self.themeMode = themeMode
        self.themePresetColorProperties = themePresetColorProperties
        self.themePresetGeometricProperties = themePresetGeometricProperties
        self.themePresetEffectProperties = themePresetEffectProperties

        frameData = .zero

        var values: [Double] = []
        for group in groups {
            let frame = Self.groupFrame(
                for: group,
                menuBarApps: menuBarApps,
                borderWidth: Self.resolvedBorderWidth(
                    for: group,
                    themeMode: themeMode,
                    appearanceMode: appearanceMode,
                    globalGroupsGeometricProperties: globalGroupsGeometricProperties,
                    globalSpacesGeometricProperties: globalSpacesGeometricProperties,
                    themePresetGeometricProperties: themePresetGeometricProperties
                )
            )
            values.append(contentsOf: [frame.origin.x, frame.origin.y, frame.width, frame.height])
        }
        frameData = AnimatableVector(values: values)
    }

    var body: some View {
        Canvas { context, _ in
            for (index, group) in groups.enumerated() {
                let baseIndex = index * 4
                guard baseIndex + 3 < frameData.values.count else { continue }

                let frame = CGRect(
                    x: frameData.values[baseIndex],
                    y: frameData.values[baseIndex + 1],
                    width: frameData.values[baseIndex + 2],
                    height: frameData.values[baseIndex + 3]
                )
                guard frame.width > 0, frame.height > 0 else { continue }

                guard let foregroundColor = resolvedForegroundColor(for: group) else { continue }

                let backgroundTintColor = resolvedBackgroundTintColor(for: group)
                let bgOpacity = resolvedBackgroundOpacity(for: group)
                let adjusted = Self.adjustedBackground(
                    wantedColor: backgroundTintColor,
                    wantedOpacity: bgOpacity,
                    foregroundColor: foregroundColor
                )

                let cornerRadius = resolvedCornerRadius(for: group)
                let path = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .path(in: frame)

                context.fill(
                    path,
                    with: .color(foregroundColor.opacity(adjusted.effectiveForegroundOpacity))
                )
            }
        }
        .animation(.themeEaseInOutFast, value: frameData)
    }

    // MARK: - Foreground Color Resolution

    /// Resolves the foreground color for a group based on theme mode and appearance mode.
    ///
    /// Returns `nil` if the foreground color is the default `.primary`, indicating
    /// no foreground overlay is needed for this group.
    /// - Parameter group: The group to resolve the foreground color for.
    /// - Returns: The resolved foreground color, or nil if default.
    private func resolvedForegroundColor(for group: Domain.Group) -> Color? {
        let color: Color = switch themeMode {
        case .preset:
            themePresetColorProperties.colorProperties.foregroundColor

        case .glass,
             .custom:
            switch appearanceMode {
            case .perGroup:
                group.colorProperties.foregroundColor
            case .allGroups:
                globalGroupsColorProperties.foregroundColor
            case .matchSpaces:
                globalSpacesColorProperties.foregroundColor
            }
        }

        return Self.isDefaultPrimaryColor(color) ? nil : color
    }

    /// Resolves the background tint color for a group based on theme mode and appearance mode.
    /// - Parameter group: The group to resolve the background tint color for.
    /// - Returns: The resolved background tint color.
    private func resolvedBackgroundTintColor(for group: Domain.Group) -> Color {
        switch themeMode {
        case .preset:
            themePresetColorProperties.colorProperties.backgroundTintColor

        case .glass,
             .custom:
            switch appearanceMode {
            case .perGroup:
                group.colorProperties.backgroundTintColor
            case .allGroups:
                globalGroupsColorProperties.backgroundTintColor
            case .matchSpaces:
                globalSpacesColorProperties.backgroundTintColor
            }
        }
    }

    /// Resolves the background opacity for a group based on theme mode and appearance mode.
    /// - Parameter group: The group to resolve the background opacity for.
    /// - Returns: The resolved background opacity.
    private func resolvedBackgroundOpacity(for group: Domain.Group) -> Double {
        switch themeMode {
        case .preset:
            themePresetEffectProperties.backgroundOpacity

        case .glass,
             .custom:
            switch appearanceMode {
            case .perGroup:
                group.effectProperties.backgroundOpacity
            case .allGroups:
                globalGroupsEffectProperties.backgroundOpacity
            case .matchSpaces:
                globalSpacesEffectProperties.backgroundOpacity
            }
        }
    }

    /// Resolves the corner radius for a group based on theme mode and appearance mode.
    /// - Parameter group: The group to resolve the corner radius for.
    /// - Returns: The resolved corner radius.
    private func resolvedCornerRadius(for group: Domain.Group) -> Double {
        switch themeMode {
        case .preset:
            themePresetGeometricProperties.cornerRadius

        case .glass,
             .custom:
            switch appearanceMode {
            case .perGroup:
                group.geometricProperties.cornerRadius
            case .allGroups:
                globalGroupsGeometricProperties.cornerRadius
            case .matchSpaces:
                globalSpacesGeometricProperties.cornerRadius
            }
        }
    }

    // MARK: - Static Helpers

    /// Checks whether a color is effectively the default primary color.
    /// - Parameter color: The color to check.
    /// - Returns: True if the color matches the default primary color components.
    static func isDefaultPrimaryColor(_ color: Color) -> Bool {
        let environment = EnvironmentValues()
        let resolved = color.resolve(in: environment)
        let primaryResolved = Color.primary.resolve(in: environment)

        let tolerance: Float = 0.01
        return abs(resolved.red - primaryResolved.red) < tolerance
            && abs(resolved.green - primaryResolved.green) < tolerance
            && abs(resolved.blue - primaryResolved.blue) < tolerance
    }

    /// The renderable extended sRGB range lower bound.
    ///
    /// Values below this are clamped by the rendering pipeline.
    private static let renderableRangeLow: Float = -1.5

    /// The renderable extended sRGB range upper bound.
    ///
    /// Values above this are clamped by the rendering pipeline.
    private static let renderableRangeHigh: Float = 2.5

    /// Computes the effective foreground opacity scaled proportionally to the background opacity.
    ///
    /// Scaling the foreground opacity ensures that at lower background opacities the foreground
    /// overlay doesn't dominate and the wallpaper pass-through remains accurate.
    /// - Parameter backgroundOpacity: The background opacity (0.0 to 1.0).
    /// - Returns: The effective foreground opacity to apply.
    static func effectiveForegroundOpacity(backgroundOpacity: Double) -> Double {
        foregroundOverlayOpacity * backgroundOpacity
    }

    /// The adjusted background properties that compensate for the foreground overlay.
    ///
    /// Contains the adjusted background color and opacity needed so that the combined
    /// foreground + background composite matches the user's desired appearance, plus
    /// the effective foreground opacity (which may be lower than the proportional value
    /// when the color difference requires it to keep the background in renderable range).
    struct AdjustedBackground {
        /// The adjusted background tint color.
        let color: Color
        /// The adjusted background opacity.
        let opacity: Double
        /// The effective foreground opacity to use for the overlay.
        let effectiveForegroundOpacity: Double
    }

    /// Computes the adjusted background color, opacity, and effective foreground opacity.
    ///
    /// The compositing stack is: wallpaper → background → foreground.
    /// The foreground opacity starts at `foregroundOverlayOpacity × bgOpacity` and is
    /// reduced if needed so the adjusted background stays within the renderable extended
    /// sRGB range. This ensures the background color matches exactly; the foreground
    /// tinting is best-effort.
    ///
    /// With effective foreground opacity `fgEff`:
    ///
    /// 1. Wallpaper pass-through matching:
    ///    `adjBgOpacity = 1 - (1 - bgOpacity) / (1 - fgEff)`
    ///
    /// 2. Color contribution matching:
    ///    `adjColor = (wanted × bgOpacity - fg × fgEff) / (bgOp - fgEff)`
    ///
    /// 3. Foreground opacity capping per component:
    ///    `fgEff ≤ bgOp × (wanted - lo) / (fg - lo)` when `fg > lo`
    ///    `fgEff ≤ bgOp × (hi - wanted) / (hi - fg)` when `fg < hi`
    ///
    /// - Parameters:
    ///   - wantedColor: The background color the user configured.
    ///   - wantedOpacity: The background opacity the user configured.
    ///   - foregroundColor: The foreground overlay color.
    /// - Returns: The adjusted background color, opacity, and effective foreground opacity.
    static func adjustedBackground(
        wantedColor: Color,
        wantedOpacity: Double,
        foregroundColor: Color
    ) -> AdjustedBackground {
        let environment = EnvironmentValues()
        let wantedResolved = wantedColor.resolve(in: environment)
        let fgResolved = foregroundColor.resolve(in: environment)

        // Cap foreground opacity so adjusted background stays in renderable range
        let fgEff = cappedForegroundOpacity(
            wanted: wantedResolved,
            foreground: fgResolved,
            backgroundOpacity: wantedOpacity
        )

        // Avoid division by zero when foreground is fully opaque
        guard (1.0 - fgEff) > .ulpOfOne else {
            return AdjustedBackground(
                color: wantedColor,
                opacity: wantedOpacity,
                effectiveForegroundOpacity: 0
            )
        }

        // Step 1: Adjust background opacity so wallpaper pass-through matches
        let adjBgOpacity = 1.0 - (1.0 - wantedOpacity) / (1.0 - fgEff)

        // denominator simplifies to bgOp - fgEff
        let denominator = wantedOpacity - fgEff
        guard denominator > .ulpOfOne else {
            return AdjustedBackground(
                color: wantedColor,
                opacity: adjBgOpacity,
                effectiveForegroundOpacity: fgEff
            )
        }

        // Step 2: Adjust background color so color contribution matches
        let fgEffFloat = Float(fgEff)
        let bgOpFloat = Float(wantedOpacity)
        let denomFloat = Float(denominator)

        let r = (wantedResolved.red * bgOpFloat - fgResolved.red * fgEffFloat) / denomFloat
        let g = (wantedResolved.green * bgOpFloat - fgResolved.green * fgEffFloat) / denomFloat
        let b = (wantedResolved.blue * bgOpFloat - fgResolved.blue * fgEffFloat) / denomFloat

        let adjColor = Color(
            .sRGB,
            red: Double(r),
            green: Double(g),
            blue: Double(b),
            opacity: Double(wantedResolved.opacity)
        )

        return AdjustedBackground(
            color: adjColor,
            opacity: adjBgOpacity,
            effectiveForegroundOpacity: fgEff
        )
    }

    /// Computes the maximum foreground opacity where the adjusted background stays
    /// within the renderable extended sRGB range.
    ///
    /// For each RGB component, derives an upper bound on `fgEff` from the requirement
    /// that `adjColor_c = (wanted_c × bgOp - fg_c × fgEff) / (bgOp - fgEff)` stays
    /// in `[renderableRangeLow, renderableRangeHigh]`:
    /// - `adjColor_c ≥ lo`: when `fg_c > lo` → `fgEff ≤ bgOp × (w - lo) / (f - lo)`
    /// - `adjColor_c ≤ hi`: when `fg_c < hi` → `fgEff ≤ bgOp × (hi - w) / (hi - f)`
    ///
    /// Returns the minimum across all components, capped at the proportional maximum.
    /// - Parameters:
    ///   - wanted: The resolved wanted background color.
    ///   - foreground: The resolved foreground color.
    ///   - backgroundOpacity: The background opacity.
    /// - Returns: The capped effective foreground opacity.
    private static func cappedForegroundOpacity(
        wanted: Color.Resolved,
        foreground: Color.Resolved,
        backgroundOpacity: Double
    ) -> Double {
        let lo = renderableRangeLow
        let hi = renderableRangeHigh
        let bgOp = Float(backgroundOpacity)
        var maxFgEff = Float(effectiveForegroundOpacity(backgroundOpacity: backgroundOpacity))

        let components: [(Float, Float)] = [
            (wanted.red, foreground.red),
            (wanted.green, foreground.green),
            (wanted.blue, foreground.blue)
        ]

        for (w, f) in components {
            if f > lo {
                let limit = bgOp * (w - lo) / (f - lo)
                if limit < maxFgEff {
                    maxFgEff = limit
                }
            }
            if f < hi {
                let limit = bgOp * (hi - w) / (hi - f)
                if limit < maxFgEff {
                    maxFgEff = limit
                }
            }
        }

        return Double(max(maxFgEff, 0))
    }

    /// Resolves the border width for a group.
    private static func resolvedBorderWidth(
        for group: Domain.Group,
        themeMode: ThemeMode,
        appearanceMode: GroupsAppearanceMode,
        globalGroupsGeometricProperties: GeometricProperties,
        globalSpacesGeometricProperties: GeometricProperties,
        themePresetGeometricProperties: GeometricProperties
    ) -> Double {
        switch themeMode {
        case .preset:
            themePresetGeometricProperties.borderWidth
        case .glass,
             .custom:
            switch appearanceMode {
            case .perGroup: group.geometricProperties.borderWidth
            case .allGroups: globalGroupsGeometricProperties.borderWidth
            case .matchSpaces: globalSpacesGeometricProperties.borderWidth
            }
        }
    }

    // MARK: - Frame Calculation

    /// Computes the frame rectangle for a group based on its menu bar apps.
    /// - Parameters:
    ///   - group: The group to compute the frame for.
    ///   - menuBarApps: The menu bar apps to reference.
    ///   - borderWidth: The border width for spacing calculation.
    /// - Returns: The computed frame rectangle, or `.zero` if the group has no visible apps.
    private static func groupFrame(for group: Domain.Group, menuBarApps: [MenuBarApp], borderWidth: Double) -> CGRect {
        let actualEndIndex = group.getEndIndex(menuBarAppsCount: menuBarApps.count)
        guard group.startIndex > 0, actualEndIndex >= group.startIndex, actualEndIndex <= menuBarApps.count else {
            return .zero
        }

        let range = group.startIndex ... actualEndIndex
        let apps = Array(menuBarApps.dropFirst(range.lowerBound - 1).prefix(range.count))
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
}
