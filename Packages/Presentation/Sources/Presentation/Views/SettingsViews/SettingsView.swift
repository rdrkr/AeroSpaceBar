// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Domain
import SwiftUI

/// The main settings view that provides a comprehensive interface for configuring AeroSpaceBar.
///
/// This view uses a NavigationStack with a NavigationSplitView layout following Apple's modern design patterns:
/// - The sidebar displays section names for navigation
/// - The main content area shows the settings for the selected section
/// - Settings are automatically saved when changed
/// - Navigation buttons in the toolbar are fully functional
public struct SettingsView: View {
    /// The settings view model
    @EnvironmentObject private var viewModel: SettingsViewModel

    /// Whether the sidebar is in focus
    @FocusState private var sidebarFocused: Bool

    /// Whether the window is configured and ready to be displayed
    @State private var isWindowConfigured = false

    /// Whether the navigation button is currently hovered
    @State private var isNavigationButtonHovered = false

    // MARK: - Computed Properties

    /// Binding for the sidebar selection, converting between AnyNavigationPage and AnyNavigationPage?
    private var sidebarSelectionBinding: Binding<AnyNavigationPage?> {
        Binding(
            get: { viewModel.sidebarSelectedPage },
            set: { newPage in
                guard let newPage else { return }

                // Only navigate if the selected page is different and is a root page
                if
                    newPage.id != viewModel.sidebarSelectedPage.id,
                    viewModel.rootPages.contains(where: { AnyNavigationPage($0).id == newPage.id })
                {
                    Task {
                        viewModel.navigateTo(newPage)
                    }
                }
            }
        )
    }

    public init() { }

    // MARK: - Body

    public var body: some View {
        let settingsWindow = Group {
            if isWindowConfigured {
                NavigationSplitView {
                    LazyVStackList(selection: sidebarSelectionBinding) {
                        ForEach(viewModel.rootPages) { rootPage in
                            LazyVStackNavigationLink(value: AnyNavigationPage(rootPage)) {
                                rootPage.viewForSidebar
                            }
                            .tag("settings-nav-\(rootPage.id)")

                            // Add spacing after license item
                            if rootPage.id == RootNavigationPage.license.id {
                                Spacer()
                            }
                        }
                    }
                    .toolbar(removing: .sidebarToggle)
                    .navigationSplitViewColumnWidth(min: 216, ideal: 216, max: 216)
                    .focused($sidebarFocused)
                    .tag("settings-sidebar")
                }
                detail: {
                    viewModel.selectedPage
                        .viewForPage
                        .tag("settings-detail-content")
                }
                .toolbar {
                    ToolbarItemGroup(placement: .navigation) {
                        HStack(spacing: 2) {
                            Button(action: viewModel.navigateBackward) {
                                Image(systemName: "chevron.backward")
                            }
                            .onHover { hovering in
                                isNavigationButtonHovered = hovering
                            }
                            .disabled(!viewModel.canNavigateBackward)
                            .tag("settings-back-button")

                            Rectangle()
                                .fill(Color.secondary.opacity(isNavigationButtonHovered ? 0.0 : 0.4))
                                .frame(width: 1, height: 16)

                            Button(action: viewModel.navigateForward) {
                                Image(systemName: "chevron.forward")
                            }
                            .onHover { hovering in
                                isNavigationButtonHovered = hovering
                            }
                            .disabled(!viewModel.canNavigateForward)
                            .tag("settings-forward-button")
                        }
                    }
                }
                .environmentObject(viewModel)
                .tag("settings-navigation-split")
            }
        }
        .frame(
            minWidth: 720,
            idealWidth: 720,
            maxWidth: 720,
            minHeight: 540,
            idealHeight: 660
        )
        .task {
            await configureWindow()
        }
        .onDisappear {
            viewModel.resetNavigationOnWindowClose()
        }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToLicensePage)) { _ in
            Task {
                viewModel.navigateTo(AnyNavigationPage(RootNavigationPage.license))
            }
        }
        .animation(.themeEaseInOutFast, value: viewModel.rootPages)
        .tag("settings-view")

        if #available(macOS 15.0, *) {
            return settingsWindow.windowResizeBehavior(.enabled)
        } else {
            return settingsWindow
        }
    }

    // MARK: - Private Methods

    /// Configures the window for proper display and behavior
    private func configureWindow() async {
        // Activate the app to make sure the first key window is activated
        NSApp.activate(ignoringOtherApps: true)

        if isWindowConfigured { return }

        // Wait until the main window is available
        while NSApplication.shared.keyWindow == nil {
            try? await Task.sleep(for: .milliseconds(100))
        }

        // Set the window style and make it always on top
        if let window = NSApplication.shared.keyWindow {
            window.toolbarStyle = .unified

            // Make always on top
            // window.level = .floating
            // window.hidesOnDeactivate = false

            window.makeKeyAndOrderFront(nil)
        }

        isWindowConfigured = true

        // Set focus to the sidebar
        sidebarFocused = true
    }
}

#Preview {
    SettingsView()
        .environmentObject(DependencyContainer.shared.getSettingsViewModel())
        .environmentObject(DependencyContainer.shared.getGroupsViewModel())
        .environmentObject(DependencyContainer.shared.getLicenseViewModel())
}
