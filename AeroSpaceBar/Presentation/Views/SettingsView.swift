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

    // MARK: - Body

    var body: some View {
        Group {
            if isWindowConfigured {
                NavigationSplitView {
                    List(selection: $selectedPage) {
                        ForEach(SettingsNavigationOptions.mainPages) { page in
                            NavigationLink(value: page) {
                                Label(page.name, systemImage: page.symbolName)
                            }
                        }
                    }
                    .toolbar(removing: .sidebarToggle)
                    .frame(minWidth: 180)
                    .focused($sidebarFocused)
                }
                detail: {
                    selectedPage.viewForPage()
                }
                .toolbar {
                    ToolbarItemGroup(placement: .navigation) {
                        Button(action: navigateBackward) {
                            Image(systemName: "chevron.backward")
                        }
                        .disabled(!canNavigateBackward)

                        Button(action: navigateForward) {
                            Image(systemName: "chevron.forward")
                        }
                        .disabled(!canNavigateForward)
                    }
                }
                .environmentObject(viewModel)
                .onChange(of: selectedPage) { _, newPage in
                    // Add to navigation history when sidebar selection changes
                    if navigationHistory.last != newPage {
                        navigationHistory.append(newPage)
                        // Clear forward history when navigating to a new page
                        forwardHistory.removeAll()
                    }
                }
            }
        }
        .frame(width: 620, height: 560)
        .task {
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
    }

    // MARK: - Navigation Methods

    /// Determines if backward navigation is available.
    ///
    /// Returns true if there are at least 2 pages in the navigation history,
    /// allowing the user to go back to a previous page.
    private var canNavigateBackward: Bool {
        navigationHistory.count > 1
    }

    /// Determines if forward navigation is available.
    ///
    /// Returns true if there are pages in the forward history that the user
    /// can navigate to after going backward.
    private var canNavigateForward: Bool {
        !forwardHistory.isEmpty
    }

    /// Navigates to the previous page in the navigation history.
    ///
    /// Removes the current page from history and updates the selected page
    /// to the previous page in the history stack. Also adds the current page
    /// to the forward history for potential forward navigation.
    private func navigateBackward() {
        guard
            canNavigateBackward,
            let currentPage = navigationHistory.last else { return }

        // Remove current page from history
        navigationHistory.removeLast()

        // Add current page to forward history
        forwardHistory.append(currentPage)

        // Navigate to previous page
        if let previousPage = navigationHistory.last {
            selectedPage = previousPage
        }
    }

    /// Navigates to the next page in the forward history.
    ///
    /// Takes the most recent page from forward history and adds it back to
    /// the main navigation history, updating the selected page accordingly.
    private func navigateForward() {
        guard canNavigateForward else { return }

        // Get the most recent page from forward history
        let nextPage = forwardHistory.removeLast()

        // Add it back to the main navigation history
        navigationHistory.append(nextPage)

        // Update the selected page
        selectedPage = nextPage
    }
}

#Preview {
    SettingsView()
        .environmentObject(DependencyContainer.shared.getSettingsViewModel())
}
