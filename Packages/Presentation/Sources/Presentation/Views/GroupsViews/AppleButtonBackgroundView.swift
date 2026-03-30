// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Domain
import SwiftUI

/// A view that renders a background behind the macOS Apple menu icon.
///
/// This view is similar to `GroupView` but specifically targets the Apple Button
/// in the menu bar. It renders the same glass/standard background using the
/// spaces visual system based on the current appearance mode and theme.
struct AppleButtonBackgroundView: View {
    /// The detected Apple Button frame from the system menu bar.
    let frame: CGRect

    /// Whether the foreground overlay is enabled (affects background compensation).
    let showForegroundOverlay: Bool

    /// The color properties for the Apple Button.
    let colorProperties: ColorProperties

    /// The geometric properties for the Apple Button.
    let geometricProperties: GeometricProperties

    /// The effect properties for the Apple Button.
    let effectProperties: EffectProperties

    /// The theme mode for visual customization.
    let themeMode: ThemeMode

    /// The selected theme preset color properties.
    let themePresetColorProperties: ThemePresetColorProperties

    /// The geometric properties for theme preset elements.
    let themePresetGeometricProperties: GeometricProperties

    /// The effect properties for theme preset elements.
    let themePresetEffectProperties: EffectProperties

    // MARK: - Appearance Properties

    /// The resolved color properties based on the current theme mode.
    private var currentColorProperties: ColorProperties {
        switch themeMode {
        case .preset: themePresetColorProperties.colorProperties
        case .glass,
             .custom: colorProperties
        }
    }

    /// The resolved geometric properties based on the current theme mode.
    private var currentGeometricProperties: GeometricProperties {
        switch themeMode {
        case .preset: themePresetGeometricProperties
        case .glass,
             .custom: geometricProperties
        }
    }

    /// The resolved effect properties based on the current theme mode.
    private var currentEffectProperties: EffectProperties {
        switch themeMode {
        case .preset: themePresetEffectProperties
        case .glass,
             .custom: effectProperties
        }
    }

    /// The background tint color, adjusted for foreground overlay compensation if needed.
    private var backgroundTintColor: Color {
        let fgColor = currentColorProperties.foregroundColor
        guard showForegroundOverlay, !GroupsForegroundOverlayView.isDefaultPrimaryColor(fgColor) else {
            return currentColorProperties.backgroundTintColor
        }

        return GroupsForegroundOverlayView.adjustedBackground(
            wantedColor: currentColorProperties.backgroundTintColor,
            wantedOpacity: currentEffectProperties.backgroundOpacity,
            foregroundColor: fgColor
        )
        .color
    }

    /// The background opacity, adjusted for foreground overlay compensation if needed.
    private var backgroundOpacity: Double {
        let fgColor = currentColorProperties.foregroundColor
        guard showForegroundOverlay, !GroupsForegroundOverlayView.isDefaultPrimaryColor(fgColor) else {
            return currentEffectProperties.backgroundOpacity
        }

        return GroupsForegroundOverlayView.adjustedBackground(
            wantedColor: currentColorProperties.backgroundTintColor,
            wantedOpacity: currentEffectProperties.backgroundOpacity,
            foregroundColor: fgColor
        )
        .opacity
    }

    /// The background blur radius.
    private var backgroundBlurRadius: Double {
        currentEffectProperties.backgroundBlurRadius
    }

    /// The border color.
    private var borderColor: Color {
        currentColorProperties.borderTintColor
    }

    /// The border opacity.
    private var borderOpacity: Double {
        currentEffectProperties.borderOpacity
    }

    /// The border width.
    private var borderWidth: Double {
        currentGeometricProperties.borderWidth
    }

    /// The corner radius.
    private var cornerRadius: Double {
        currentGeometricProperties.cornerRadius
    }

    /// The adjusted frame that fits within the menu bar area.
    private var adjustedFrame: CGRect {
        guard frame != .zero else { return .zero }

        let fullWidth = frame.width
        let fullHeight = frame.height
        let reducedWidth = fullWidth - ConfigurationDefaults.widgetSpacing - (borderWidth * 2)
        let reducedHeight = ConfigurationDefaults.windowIconSize + (ConfigurationDefaults.menuBarVerticalPadding * 2)
        let horizontalMargin = (fullWidth - reducedWidth) / 2
        let verticalMargin = (fullHeight - reducedHeight) / 2

        return CGRect(
            x: frame.origin.x + horizontalMargin,
            y: frame.origin.y + verticalMargin,
            width: reducedWidth,
            height: reducedHeight
        )
    }

    var body: some View {
        let background = Group {
            if themeMode == .glass, #available(macOS 26.0, *) {
                glassBackgroundView
            } else {
                standardBackgroundView
            }
        }

        background
            .animation(.themeEaseInOutFast, value: adjustedFrame)
    }

    /// The glass effect background view for macOS 26+.
    @available(macOS 26.0, *)
    private var glassBackgroundView: some View {
        Text("")
            .frame(width: adjustedFrame.width, height: adjustedFrame.height)
            .glassEffect(.clear.interactive(true))
            .position(x: adjustedFrame.midX, y: adjustedFrame.midY)
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
            .frame(width: adjustedFrame.width, height: adjustedFrame.height)
            .background(borderView)
            .position(x: adjustedFrame.midX, y: adjustedFrame.midY)
            .standardShadow()
    }

    /// The border view for the Apple Button background.
    private var borderView: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .stroke(
                borderColor.opacity(borderOpacity),
                lineWidth: borderWidth
            )
            .frame(
                width: adjustedFrame.width + borderWidth,
                height: adjustedFrame.height + borderWidth
            )
    }
}
