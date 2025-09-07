// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import AppKit
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

    /// Computed property for menu bar apps to avoid repeated access
    private var menuBarApps: [MenuBarApp] {
        viewModel.menuBarApps
    }

    /// Computed property for group configuration to avoid repeated access
    private var groupsConfiguration: [GroupConfiguration] {
        viewModel.groupsConfiguration
    }

    /// Whether the view should be shown
    private var shouldShowView: Bool {
        viewModel.isGroupsFeatureEnabled && viewModel.showGroups && !menuBarApps.isEmpty
    }

    /// Animation duration for UI transitions
    private var animationDuration: Double {
        viewModel.animationDuration
    }

    /// Widget spacing for UI layout
    private var widgetSpacing: CGFloat {
        viewModel.widgetSpacing
    }

    /// The body of the groups view.
    ///
    /// This view creates a container for grouped menu bar applications,
    /// positioned on the top right below the menu bar with similar styling to SpacesView.
    var body: some View {
        GeometryReader { _ in
            // Display grouped apps with their group styling
            ForEach(groupsConfiguration, id: \.id) { group in
                GroupView(
                    group: group,
                    menuBarApps: menuBarApps,
                    animationDuration: animationDuration,
                    widgetSpacing: widgetSpacing
                )
            }
        }
        .ignoresSafeArea()
        .opacity(shouldShowView ? 1.0 : 0.0)
        .animation(.smooth(duration: animationDuration), value: shouldShowView)
        .tag("groups-container")
    }
}

#Preview {
    GroupsView()
        .environmentObject(DependencyContainer.shared.getGroupsViewModel())
}
