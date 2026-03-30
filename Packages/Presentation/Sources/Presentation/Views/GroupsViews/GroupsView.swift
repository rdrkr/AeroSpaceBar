// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import AppKit
import Domain
import SwiftUI

/// The main groups view that displays grouped menu bar applications.
///
/// This view provides the interface for displaying grouped menu bar applications
/// on the top right of the screen, below the menu bar. It renders a container
/// for system menu bar apps with the same background, border, and styling
/// properties as SpacesView. This view follows clean architecture principles
/// by only interacting with ViewModels.
struct GroupsView: View {
    /// The groups ViewModel for managing groups data and interactions.
    @EnvironmentObject private var viewModel: GroupsViewModel

    // MARK: - Computed Properties

    /// Whether the groups view should be shown.
    private var shouldShowView: Bool {
        viewModel.isGroupsFeatureEnabled && viewModel.showGroups && !viewModel.menuBarApps.isEmpty
    }

    /// Whether the Apple Button background should be shown.
    private var shouldShowAppleButton: Bool {
        viewModel.showAppleButtonAsSpace && viewModel.appleButtonFrame != .zero
    }

    /// The color properties used for the Apple Button based on the current spaces appearance mode.
    private var appleButtonColorProperties: ColorProperties {
        switch viewModel.spacesAppearanceMode {
        case .perSpace: viewModel.appleButtonColorProperties
        case .allSpaces: viewModel.globalSpacesColorProperties
        }
    }

    /// The geometric properties used for the Apple Button based on the current spaces appearance mode.
    private var appleButtonGeometricProperties: GeometricProperties {
        switch viewModel.spacesAppearanceMode {
        case .perSpace: viewModel.appleButtonGeometricProperties
        case .allSpaces: viewModel.globalSpacesGeometricProperties
        }
    }

    /// The effect properties used for the Apple Button based on the current spaces appearance mode.
    private var appleButtonEffectProperties: EffectProperties {
        switch viewModel.spacesAppearanceMode {
        case .perSpace: viewModel.appleButtonEffectProperties
        case .allSpaces: viewModel.globalSpacesEffectProperties
        }
    }

    /// The groups content view that renders all group backgrounds.
    ///
    /// In glass mode, renders SwiftUI glass effect views per group.
    /// Otherwise, uses `GroupsCanvasView` for a single Canvas draw pass.
    @ViewBuilder
    private var groupsContent: some View {
        if viewModel.themeMode == .glass, #available(macOS 26.0, *) {
            glassGroupsContent
        } else {
            GroupsCanvasView(
                groups: viewModel.groups,
                menuBarApps: viewModel.menuBarApps,
                appearanceMode: viewModel.groupsAppearanceMode,
                showForegroundOverlay: viewModel.showForegroundOverlay,
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
        }
    }

    /// Glass effect backgrounds for all groups, rendered as individual SwiftUI views.
    @available(macOS 26.0, *)
    private var glassGroupsContent: some View {
        ZStack {
            ForEach(viewModel.groups, id: \.id) { group in
                let frame = glassGroupFrame(for: group)
                if frame.width > 0, frame.height > 0 {
                    Text("")
                        .frame(width: frame.width, height: frame.height)
                        .glassEffect(.clear.interactive(true))
                        .position(x: frame.midX, y: frame.midY)
                }
            }
        }
    }

    /// Computes the frame rectangle for a group for glass mode rendering.
    /// - Parameter group: The group to compute the frame for.
    /// - Returns: The computed frame rectangle, or `.zero` if the group has no visible apps.
    private func glassGroupFrame(for group: Domain.Group) -> CGRect {
        let actualEndIndex = group.getEndIndex(menuBarAppsCount: viewModel.menuBarApps.count)
        guard
            group.startIndex > 0,
            actualEndIndex >= group.startIndex,
            actualEndIndex <= viewModel.menuBarApps.count
        else {
            return .zero
        }

        let range = group.startIndex ... actualEndIndex
        let apps = Array(viewModel.menuBarApps.dropFirst(range.lowerBound - 1).prefix(range.count))
        guard !apps.isEmpty else { return .zero }

        let minX = apps.map(\.frame.minX).min() ?? 0
        let maxX = apps.map(\.frame.maxX).max() ?? 0
        let minY = apps.map(\.frame.minY).min() ?? 0
        let maxY = apps.map(\.frame.maxY).max() ?? 0

        let fullWidth = maxX - minX
        let fullHeight = maxY - minY
        let reduceWidth = fullWidth - ConfigurationDefaults.widgetSpacing
        let reducedHeight = ConfigurationDefaults.windowIconSize
            + (ConfigurationDefaults.menuBarVerticalPadding * 2)
        let horizontalMargin = (fullWidth - reduceWidth) / 2
        let verticalMargin = (fullHeight - reducedHeight) / 2

        return CGRect(
            x: minX + horizontalMargin,
            y: minY + verticalMargin,
            width: reduceWidth,
            height: reducedHeight
        )
    }

    /// The body of the groups view.
    ///
    /// This view creates a container for grouped menu bar applications,
    /// positioned on the top right below the menu bar with similar styling to SpacesView.
    var body: some View {
        ZStack {
            // Groups content always stays in the view hierarchy to survive sleep/wake
            // cycles. Opacity is applied directly to hide it when disabled.
            groupsContent
                .offset(y: !viewModel.menuBarApps.isEmpty ? 0 : -viewModel.menuBarHeight)
                .opacity(shouldShowView ? 1.0 : 0.0)

            // Apple Button background - rendered independently of groups
            if shouldShowAppleButton {
                AppleButtonBackgroundView(
                    frame: viewModel.appleButtonFrame,
                    showForegroundOverlay: viewModel.showForegroundOverlay,
                    colorProperties: appleButtonColorProperties,
                    geometricProperties: appleButtonGeometricProperties,
                    effectProperties: appleButtonEffectProperties,
                    themeMode: viewModel.themeMode,
                    themePresetColorProperties: viewModel.themePresetColorProperties,
                    themePresetGeometricProperties: viewModel.themePresetGeometricProperties,
                    themePresetEffectProperties: viewModel.themePresetEffectProperties
                )
            }
        }
        .animation(.themeEaseInOutFast, value: viewModel.groups)
        .animation(.themeEaseInOutFast, value: viewModel.menuBarApps)
        .ignoresSafeArea()
        .opacity(shouldShowView || shouldShowAppleButton ? 1.0 : 0.0)
        .animation(.themeEaseInOutFast, value: shouldShowView)
        .animation(.themeEaseInOutFast, value: shouldShowAppleButton)
        .animation(.themeEaseInOutFast, value: viewModel.groupsAppearanceMode)
        .animation(.themeEaseInOutFast, value: viewModel.themeMode)
        .tag("groups-container")
    }
}

#Preview {
    GroupsView()
        .environmentObject(DependencyContainer.shared.getGroupsViewModel())
}
