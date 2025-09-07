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
    @State private var isWindowConfigured = false

    // MARK: - Body

    var body: some View {
        Group {
            if isWindowConfigured {
                NavigationSplitView {
                    List(selection: Binding(
                        get: { viewModel.sidebarSelectedPage },
                        set: { newPage in
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
                    )) {
                        ForEach(viewModel.sidebarPages, id: \.id) { page in
                            NavigationLink(value: page) {
                                HStack {
                                    let symbolImage = Image(systemName: page.symbolName)
                                        .resizable()
                                        .frame(width: 18, height: 18)
                                        .padding(4)
                                        .background(.white.opacity(0.1), in: .rect)

                                    if #available(macOS 26.0, *) {
                                        symbolImage
                                            .glassEffect(.clear, in: .rect)
                                            .cornerRadius(8)
                                    } else {
                                        symbolImage
                                            .cornerRadius(8)
                                    }

                                    Text(page.name)
                                }
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
                    viewModel.selectedPage
                        .viewForPage
                        .tag("settings-detail-content")
                }
                .toolbar {
                    ToolbarItemGroup(placement: .navigation) {
                        Button(action: viewModel.navigateBackward) {
                            Image(systemName: "chevron.backward")
                        }
                        .disabled(!viewModel.canNavigateBackward)
                        .tag("settings-back-button")

                        Button(action: viewModel.navigateForward) {
                            Image(systemName: "chevron.forward")
                        }
                        .disabled(!viewModel.canNavigateForward)
                        .tag("settings-forward-button")
                    }
                }
                .environmentObject(viewModel)
                .tag("settings-navigation-split")
            }
        }
        .frame(width: 680, height: 560)
        .task {
            await configureWindow()
        }
        .onDisappear {
            viewModel.resetNavigationOnWindowClose()
        }
        .tag("settings-view")
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
            window.level = .floating
            window.hidesOnDeactivate = false

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
}
