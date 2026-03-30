// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Domain
import SwiftUI

/// A host view that bridges the `GroupsViewModel` to the foreground overlay views.
///
/// This view reads the required properties from the groups ViewModel and renders
/// foreground overlay rectangles for both regular groups and the Apple Button.
/// It controls visibility based on the groups feature state and only renders
/// overlays when groups are visible and the foreground color differs from the system default.
struct GroupsForegroundOverlayHostView: View {
    /// The groups ViewModel for accessing group configuration and menu bar app data.
    @EnvironmentObject private var viewModel: GroupsViewModel

    /// Whether the groups overlay should be shown.
    private var shouldShowGroupsOverlay: Bool {
        viewModel.showForegroundOverlay
            && viewModel.themeMode != .glass
            && viewModel.isGroupsFeatureEnabled
            && viewModel.showGroups
            && !viewModel.menuBarApps.isEmpty
    }

    /// Whether the Apple Button foreground overlay should be shown.
    private var shouldShowAppleButtonOverlay: Bool {
        viewModel.showForegroundOverlay
            && viewModel.themeMode != .glass
            && viewModel.showAppleButtonAsSpace
            && viewModel.appleButtonFrame != .zero
    }

    // MARK: - Apple Button Property Resolution

    /// The resolved color properties for the Apple Button based on theme mode and spaces appearance mode.
    private var appleButtonResolvedColorProperties: ColorProperties {
        switch viewModel.themeMode {
        case .preset:
            viewModel.themePresetColorProperties.colorProperties
        case .glass,
             .custom:
            switch viewModel.spacesAppearanceMode {
            case .perSpace: viewModel.appleButtonColorProperties
            case .allSpaces: viewModel.globalSpacesColorProperties
            }
        }
    }

    /// The resolved geometric properties for the Apple Button based on theme mode and spaces appearance mode.
    private var appleButtonResolvedGeometricProperties: GeometricProperties {
        switch viewModel.themeMode {
        case .preset:
            viewModel.themePresetGeometricProperties
        case .glass,
             .custom:
            switch viewModel.spacesAppearanceMode {
            case .perSpace: viewModel.appleButtonGeometricProperties
            case .allSpaces: viewModel.globalSpacesGeometricProperties
            }
        }
    }

    /// The resolved effect properties for the Apple Button based on theme mode and spaces appearance mode.
    private var appleButtonResolvedEffectProperties: EffectProperties {
        switch viewModel.themeMode {
        case .preset:
            viewModel.themePresetEffectProperties
        case .glass,
             .custom:
            switch viewModel.spacesAppearanceMode {
            case .perSpace: viewModel.appleButtonEffectProperties
            case .allSpaces: viewModel.globalSpacesEffectProperties
            }
        }
    }

    /// The resolved foreground color for the Apple Button, or nil if it is the default primary color.
    private var appleButtonForegroundColor: Color? {
        let color = appleButtonResolvedColorProperties.foregroundColor
        return GroupsForegroundOverlayView.isDefaultPrimaryColor(color) ? nil : color
    }

    /// The adjusted frame for the Apple Button foreground overlay.
    private var appleButtonAdjustedFrame: CGRect {
        let frame = viewModel.appleButtonFrame
        guard frame != .zero else { return .zero }

        let borderWidth = appleButtonResolvedGeometricProperties.borderWidth
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

    /// The body of the host view.
    var body: some View {
        ZStack {
            // Groups foreground overlay
            GroupsForegroundOverlayView(
                groups: viewModel.groups,
                menuBarApps: viewModel.menuBarApps,
                appearanceMode: viewModel.groupsAppearanceMode,
                globalGroupsColorProperties: viewModel.globalGroupsColorProperties,
                globalGroupsGeometricProperties: viewModel.globalGroupsGeometricProperties,
                globalGroupsEffectProperties: viewModel.globalGroupsEffectProperties,
                globalSpacesColorProperties: viewModel.globalSpacesColorProperties,
                globalSpacesGeometricProperties: viewModel.globalSpacesGeometricProperties,
                globalSpacesEffectProperties: viewModel.globalSpacesEffectProperties,
                themeMode: viewModel.themeMode,
                themePresetColorProperties: viewModel.themePresetColorProperties,
                themePresetGeometricProperties: viewModel.themePresetGeometricProperties,
                themePresetEffectProperties: viewModel.themePresetEffectProperties
            )
            .opacity(shouldShowGroupsOverlay ? 1.0 : 0.0)
            .animation(.themeEaseInOutFast, value: shouldShowGroupsOverlay)
            .animation(.themeEaseInOutFast, value: viewModel.groups)
            .animation(.themeEaseInOutFast, value: viewModel.menuBarApps)
            .animation(.themeEaseInOutFast, value: viewModel.groupsAppearanceMode)
            .animation(.themeEaseInOutFast, value: viewModel.themeMode)

            // Apple Button foreground overlay
            appleButtonForegroundOverlay
                .opacity(shouldShowAppleButtonOverlay ? 1.0 : 0.0)
                .animation(.themeEaseInOutFast, value: shouldShowAppleButtonOverlay)
                .animation(.themeEaseInOutFast, value: viewModel.appleButtonFrame)
                .animation(.themeEaseInOutFast, value: viewModel.themeMode)
                .animation(.themeEaseInOutFast, value: viewModel.spacesAppearanceMode)
        }
        .ignoresSafeArea()
        .tag("groups-foreground-overlay-container")
    }

    /// The foreground overlay view for the Apple Button.
    @ViewBuilder
    private var appleButtonForegroundOverlay: some View {
        if let foregroundColor = appleButtonForegroundColor {
            let adjusted = GroupsForegroundOverlayView.adjustedBackground(
                wantedColor: appleButtonResolvedColorProperties.backgroundTintColor,
                wantedOpacity: appleButtonResolvedEffectProperties.backgroundOpacity,
                foregroundColor: foregroundColor
            )
            let cornerRadius = appleButtonResolvedGeometricProperties.cornerRadius
            let frame = appleButtonAdjustedFrame

            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(foregroundColor.opacity(adjusted.effectiveForegroundOpacity))
                .frame(width: frame.width, height: frame.height)
                .position(x: frame.midX, y: frame.midY)
        }
    }
}
