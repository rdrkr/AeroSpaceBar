// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// The main settings view that provides a comprehensive interface for configuring AeroSpaceBar.
///
/// This view uses a NavigationStack with a NavigationSplitView layout following Apple's modern design patterns:
/// - The sidebar displays section names for navigation
/// - The main content area shows the settings for the selected section
/// - Settings are automatically saved when changed
/// - Navigation buttons in the toolbar are fully functional
struct SettingsView: View {
    @EnvironmentObject private var viewModel: SettingsViewModel

    @FocusState private var sidebarFocused: Bool

    @State private var selectedPage: SettingsNavigationOptions = .general
    @State private var isWindowConfigured = false
    @State private var navigationHistory: [SettingsNavigationOptions] = [.general]
    @State private var forwardHistory: [SettingsNavigationOptions] = []

    // MARK: - Computed Properties

    /// Computed property for backward navigation availability
    private var canNavigateBackward: Bool {
        navigationHistory.count >= 2
    }

    /// Computed property for forward navigation availability
    private var canNavigateForward: Bool {
        !forwardHistory.isEmpty
    }

    // MARK: - Body

    var body: some View {
        Group {
            if isWindowConfigured {
                NavigationSplitView {
                    List(selection: $selectedPage) {
                        ForEach(SettingsNavigationOptions.allCases) { page in
                            NavigationLink(value: page) {
                                Label(page.name, systemImage: page.symbolName)
                            }
                            .tag("settings-nav-\(page.id)")
                        }
                    }
                    .toolbar(removing: .sidebarToggle)
                    .frame(minWidth: 180)
                    .focused($sidebarFocused)
                    .tag("settings-sidebar")
                }
                detail: {
                    selectedPage.viewForPage()
                        .tag("settings-detail-content")
                }
                .toolbar {
                    ToolbarItemGroup(placement: .navigation) {
                        Button(action: navigateBackward) {
                            Image(systemName: "chevron.backward")
                        }
                        .disabled(!canNavigateBackward)
                        .tag("settings-back-button")

                        Button(action: navigateForward) {
                            Image(systemName: "chevron.forward")
                        }
                        .disabled(!canNavigateForward)
                        .tag("settings-forward-button")
                    }
                }
                .environmentObject(viewModel)
                .onChange(of: selectedPage) { _, newPage in
                    handlePageSelection(newPage)
                }
                .tag("settings-navigation-split")
            }
        }
        .frame(width: 680, height: 560)
        .task {
            await configureWindow()
        }
        .tag("settings-view")
    }

    // MARK: - Private Methods

    /// Handles page selection changes and updates navigation history
    private func handlePageSelection(_ newPage: SettingsNavigationOptions) {
        // Add to navigation history when sidebar selection changes
        if navigationHistory.last != newPage {
            navigationHistory.append(newPage)
            // Clear forward history when navigating to a new page
            forwardHistory.removeAll()
        }
    }

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
            window.level = .floating
            window.hidesOnDeactivate = false

            window.makeKeyAndOrderFront(nil)
        }

        isWindowConfigured = true

        // Set focus to the sidebar
        sidebarFocused = true
    }

    // MARK: - Navigation Methods

    /// Determines if backward navigation is available.
    ///
    /// Returns true if there are at least 2 pages in the navigation history,
    /// indicating that the user can navigate back to a previous page.
    private func navigateBackward() {
        guard canNavigateBackward else { return }

        // Remove current page from history
        let currentPage = navigationHistory.removeLast()

        // Add current page to forward history
        forwardHistory.append(currentPage)

        // Navigate to the previous page
        selectedPage = navigationHistory.last ?? .general
    }

    /// Determines if forward navigation is available.
    ///
    /// Returns true if there are pages in the forward history,
    /// indicating that the user can navigate forward to a previously visited page.
    private func navigateForward() {
        guard canNavigateForward else { return }

        // Get the next page from forward history
        let nextPage = forwardHistory.removeLast()

        // Add current page to navigation history
        navigationHistory.append(selectedPage)

        // Navigate to the next page
        selectedPage = nextPage
    }
}

#Preview {
    SettingsView()
        .environmentObject(DependencyContainer.shared.getSettingsViewModel())
}
