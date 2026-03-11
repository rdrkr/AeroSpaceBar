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

    /// The groups content view that renders all group backgrounds using a single Canvas.
    ///
    /// Uses `GroupsCanvasView` to draw all group backgrounds in one programmatic draw pass,
    /// bypassing SwiftUI's layout engine which incorrectly divides ForEach children vertically.
    private var groupsContent: some View {
        GroupsCanvasView(
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
    }

    /// The body of the groups view.
    ///
    /// This view creates a container for grouped menu bar applications,
    /// positioned on the top right below the menu bar with similar styling to SpacesView.
    var body: some View {
        ZStack {
            // Display grouped apps with their group styling, only when enabled
            if shouldShowView {
                groupsContent
                    .offset(y: !viewModel.menuBarApps.isEmpty ? 0 : -viewModel.menuBarHeight)
                    .transition(.opacity)
            }

            // Apple Button background - rendered independently of groups
            if shouldShowAppleButton {
                AppleButtonBackgroundView(
                    frame: viewModel.appleButtonFrame,
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
