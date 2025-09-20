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

    /// Whether the view should be shown
    private var shouldShowView: Bool {
        viewModel.isGroupsFeatureEnabled && viewModel.showGroups && !viewModel.menuBarApps.isEmpty
    }

    /// The body of the groups view.
    ///
    /// This view creates a container for grouped menu bar applications,
    /// positioned on the top right below the menu bar with similar styling to SpacesView.
    var body: some View {
        GeometryReader { _ in
            // Display grouped apps with their group styling
            ForEach(viewModel.groups, id: \.id) { group in
                GroupView(
                    group: group,
                    menuBarApps: viewModel.menuBarApps,
                    appearanceMode: viewModel.groupsAppearanceMode,
                    globalVisualConfiguration: viewModel.globalGroupsVisualConfig,
                    spaceVisualConfiguration: viewModel.globalSpacesVisualConfig
                )
            }
        }
        .animation(.themeEaseInOutFast, value: viewModel.groups.map(\.id))
        .ignoresSafeArea()
        .opacity(shouldShowView ? 1.0 : 0.0)
        .animation(.themeEaseInOutFast, value: shouldShowView)
        .tag("groups-container")
    }
}

#Preview {
    GroupsView()
        .environmentObject(DependencyContainer.shared.getGroupsViewModel())
}
