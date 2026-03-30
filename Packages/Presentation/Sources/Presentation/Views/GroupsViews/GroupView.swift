// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Domain
import SwiftUI

// MARK: - AnimatableVector

/// A variable-length vector type conforming to `VectorArithmetic` for SwiftUI animation interpolation.
///
/// This type enables smooth animation of multiple `Double` values simultaneously,
/// used to interpolate group frame rectangles during Canvas redraws. Each group's
/// frame is encoded as four consecutive values `[x, y, width, height]`.
struct AnimatableVector: VectorArithmetic, Equatable {
    /// The underlying array of animatable double values.
    var values: [Double]

    /// The zero vector (empty values array).
    static var zero: Self {
        Self(values: [])
    }

    /// Element-wise addition of two vectors, zero-padding the shorter one.
    static func + (lhs: Self, rhs: Self) -> Self {
        let count = max(lhs.values.count, rhs.values.count)
        var result = [Double](repeating: 0, count: count)
        for i in 0 ..< count {
            let l = i < lhs.values.count ? lhs.values[i] : 0
            let r = i < rhs.values.count ? rhs.values[i] : 0
            result[i] = l + r
        }
        return Self(values: result)
    }

    /// Element-wise subtraction of two vectors, zero-padding the shorter one.
    static func - (lhs: Self, rhs: Self) -> Self {
        let count = max(lhs.values.count, rhs.values.count)
        var result = [Double](repeating: 0, count: count)
        for i in 0 ..< count {
            let l = i < lhs.values.count ? lhs.values[i] : 0
            let r = i < rhs.values.count ? rhs.values[i] : 0
            result[i] = l - r
        }
        return Self(values: result)
    }

    /// Scales all values by the given factor.
    mutating func scale(by rhs: Double) {
        values = values.map { $0 * rhs }
    }

    /// The sum of squares of all values, used by SwiftUI to determine animation completion.
    var magnitudeSquared: Double {
        values.reduce(0) { $0 + $1 * $1 }
    }
}

// MARK: - GroupsCanvasView

/// A single view that renders all group backgrounds using Canvas with animated frame transitions.
///
/// This view draws all group backgrounds in a single Canvas context, bypassing
/// SwiftUI's layout engine which incorrectly divides ForEach children vertically
/// instead of overlaying them. Each group's background is drawn at its computed
/// absolute screen position using the menu bar app frame data.
///
/// Frame changes are smoothly animated via `Animatable` conformance, which encodes
/// all group frames as an `AnimatableVector` that SwiftUI interpolates between states.
struct GroupsCanvasView: View, Animatable {
    /// The groups to render backgrounds for.
    let groups: [Domain.Group]

    /// The complete list of menu bar applications used to compute group frames.
    let menuBarApps: [MenuBarApp]

    /// The appearance mode determining which styling properties to use.
    let appearanceMode: GroupsAppearanceMode

    /// Whether the foreground overlay is enabled (affects background compensation).
    let showForegroundOverlay: Bool

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

    /// Animated frame data encoding all group rectangles as `[x, y, width, height]` sequences.
    ///
    /// SwiftUI interpolates this vector during animation, producing smooth frame transitions
    /// as the Canvas redraws on each animation frame.
    var frameData: AnimatableVector

    /// The animatable data that SwiftUI interpolates during frame transitions.
    nonisolated var animatableData: AnimatableVector {
        get { frameData }
        set { frameData = newValue }
    }

    // MARK: - Initialization

    /// Creates a new groups canvas view with pre-computed animated frame data.
    /// - Parameters:
    ///   - groups: The groups to render backgrounds for.
    ///   - menuBarApps: The complete list of menu bar applications used to compute group frames.
    ///   - appearanceMode: The appearance mode determining which styling properties to use.
    ///   - showForegroundOverlay: Whether the foreground overlay is enabled.
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
        showForegroundOverlay: Bool,
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
        self.showForegroundOverlay = showForegroundOverlay
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

        // Initialize with zero so self is fully formed before computing frames
        frameData = .zero

        // Pre-compute all group frames and encode as animation vector
        var values: [Double] = []
        for group in groups {
            let frame = groupFrame(for: group)
            values.append(contentsOf: [frame.origin.x, frame.origin.y, frame.width, frame.height])
        }
        frameData = AnimatableVector(values: values)
    }

    var body: some View {
        Canvas { context, _ in
            // Glass mode uses SwiftUI glass effect views instead of Canvas drawing
            guard themeMode != .glass else { return }

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

                drawGroupBackground(group: group, frame: frame, in: &context)
            }
        }
        .animation(.themeEaseInOutFast, value: frameData)
    }

    // MARK: - Drawing

    /// Draws the background for a single group in the Canvas context.
    /// - Parameters:
    ///   - group: The group configuration to draw.
    ///   - frame: The animated frame rectangle to draw the background in.
    ///   - context: The Canvas graphics context to draw into.
    private func drawGroupBackground(group: Domain.Group, frame: CGRect, in context: inout GraphicsContext) {
        let properties = resolvedProperties(for: group)
        let path = RoundedRectangle(cornerRadius: properties.cornerRadius, style: .continuous)
            .path(in: frame)

        // Draw background with blur effect
        context.drawLayer { layerContext in
            layerContext.addFilter(.blur(radius: properties.backgroundBlurRadius))
            layerContext.fill(
                path,
                with: .color(properties.backgroundTintColor.opacity(properties.backgroundOpacity))
            )
        }

        // Draw shadow matching StandardShadow modifier (.themeShadow, radius: 2)
        context.drawLayer { shadowContext in
            shadowContext.addFilter(.shadow(
                color: .themeShadow,
                radius: 2
            ))
            shadowContext.fill(path, with: .color(.clear))
        }

        // Draw border
        if properties.borderWidth > 0, properties.borderOpacity > 0 {
            context.stroke(
                path,
                with: .color(properties.borderTintColor.opacity(properties.borderOpacity)),
                lineWidth: properties.borderWidth
            )
        }
    }

    // MARK: - Frame Calculation

    /// Computes the frame rectangle for a group based on its menu bar apps.
    /// - Parameter group: The group to compute the frame for.
    /// - Returns: The computed frame rectangle, or `.zero` if the group has no visible apps.
    private func groupFrame(for group: Domain.Group) -> CGRect {
        let apps = groupApps(for: group)
        guard !apps.isEmpty else { return .zero }

        let properties = resolvedProperties(for: group)

        let minX = apps.map(\.frame.minX).min() ?? 0
        let maxX = apps.map(\.frame.maxX).max() ?? 0
        let minY = apps.map(\.frame.minY).min() ?? 0
        let maxY = apps.map(\.frame.maxY).max() ?? 0

        let fullWidth = maxX - minX
        let fullHeight = maxY - minY
        let reduceWidth = fullWidth - ConfigurationDefaults.widgetSpacing - (properties.borderWidth * 2)
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

    /// Returns the apps in the specified group's range.
    /// - Parameter group: The group to get apps for.
    /// - Returns: An array of menu bar apps in the group's range.
    private func groupApps(for group: Domain.Group) -> [MenuBarApp] {
        let actualEndIndex = group.getEndIndex(menuBarAppsCount: menuBarApps.count)
        guard group.startIndex > 0, actualEndIndex >= group.startIndex, actualEndIndex <= menuBarApps.count else {
            return []
        }

        let range = group.startIndex ... actualEndIndex
        return Array(menuBarApps.dropFirst(range.lowerBound - 1).prefix(range.count))
    }

    // MARK: - Appearance Resolution

    /// Resolved appearance properties for a group, combining theme mode and appearance mode settings.
    private struct ResolvedProperties {
        /// The background tint color, adjusted for any foreground overlay compensation.
        let backgroundTintColor: Color
        /// The background opacity level.
        let backgroundOpacity: Double
        /// The background blur radius.
        let backgroundBlurRadius: Double
        /// The border tint color.
        let borderTintColor: Color
        /// The border opacity level.
        let borderOpacity: Double
        /// The border line width.
        let borderWidth: Double
        /// The corner radius for rounded rectangles.
        let cornerRadius: Double
    }

    /// Resolves the appearance properties for a group based on theme mode and appearance mode.
    ///
    /// When a non-default foreground color is configured, the background tint color is adjusted
    /// to compensate for the foreground overlay so the combined visible result matches
    /// the user's configured background color.
    /// - Parameter group: The group to resolve properties for.
    /// - Returns: The resolved appearance properties.
    private func resolvedProperties(for group: Domain.Group) -> ResolvedProperties {
        let colorProps: ColorProperties
        let geometricProps: GeometricProperties
        let effectProps: EffectProperties

        switch themeMode {
        case .preset:
            colorProps = themePresetColorProperties.colorProperties
            geometricProps = themePresetGeometricProperties
            effectProps = themePresetEffectProperties

        case .glass,
             .custom:
            switch appearanceMode {
            case .perGroup:
                colorProps = group.colorProperties
                geometricProps = group.geometricProperties
                effectProps = group.effectProperties

            case .allGroups:
                colorProps = globalGroupsColorProperties
                geometricProps = globalGroupsGeometricProperties
                effectProps = globalGroupsEffectProperties

            case .matchSpaces:
                colorProps = globalSpacesColorProperties
                geometricProps = globalSpacesGeometricProperties
                effectProps = globalSpacesEffectProperties
            }
        }

        // Adjust background color and opacity to compensate for the foreground overlay
        let hasForeground = showForegroundOverlay
            && !GroupsForegroundOverlayView.isDefaultPrimaryColor(colorProps.foregroundColor)

        let adjustedBgColor: Color
        let adjustedBgOpacity: Double

        if hasForeground {
            let adjusted = GroupsForegroundOverlayView.adjustedBackground(
                wantedColor: colorProps.backgroundTintColor,
                wantedOpacity: effectProps.backgroundOpacity,
                foregroundColor: colorProps.foregroundColor
            )
            adjustedBgColor = adjusted.color
            adjustedBgOpacity = adjusted.opacity
        } else {
            adjustedBgColor = colorProps.backgroundTintColor
            adjustedBgOpacity = effectProps.backgroundOpacity
        }

        return ResolvedProperties(
            backgroundTintColor: adjustedBgColor,
            backgroundOpacity: adjustedBgOpacity,
            backgroundBlurRadius: effectProps.backgroundBlurRadius,
            borderTintColor: colorProps.borderTintColor,
            borderOpacity: effectProps.borderOpacity,
            borderWidth: geometricProps.borderWidth,
            cornerRadius: geometricProps.cornerRadius
        )
    }
}
