// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// The application delegate that manages the menu bar panel and application lifecycle.
///
/// This delegate is responsible for:
/// - Setting up and managing the menu bar panel
/// - Handling screen parameter changes
/// - Managing menu items (Settings, Quit)
/// - Coordinating with the main app ViewModel
/// - Managing the application's lifecycle events
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    /// The menu bar panel that displays the main interface.
    private var menuBarPanel: NSPanel?

    /// The About window instance to prevent multiple windows.
    private var aboutWindow: NSPanel?

    /// The spaces ViewModel for managing spaces data and interactions.
    private var spacesViewModel: SpacesViewModel?

    /// The dependency container for accessing services.
    private let dependencyContainer = DependencyContainer.shared

    /// Called when the application has finished launching.
    ///
    /// This method initializes the main app ViewModel, sets up the menu bar panel,
    /// and registers for screen parameter change notifications.
    /// - Parameter notification: The launch notification
    func applicationDidFinishLaunching(_: Notification) {
        Logger.info("Application launching", category: Logger.app, metadata: [
            "version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown",
            "build": Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown"
        ])

        // Initialize the spaces ViewModel and setup panels
        Task { @MainActor in
            Logger.beginInterval("App Initialization", id: Logger.SignpostID.spacesFetch)

            spacesViewModel = dependencyContainer.getSpacesViewModel()
            Logger.info("SpacesViewModel initialized", category: Logger.app)

            setupPanels()
            Logger.endInterval("App Initialization", id: Logger.SignpostID.spacesFetch)

            Logger.info("Application launch completed", category: Logger.app)
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenParametersDidChange(_:)),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showAboutWindowNotification(_:)),
            name: .showAboutWindow,
            object: nil
        )

        Logger.info("Screen parameter change observer registered", category: Logger.app)
    }

    /// Handles screen parameter changes by updating the menu bar panel.
    ///
    /// This method is called when the screen configuration changes (e.g., display connected/disconnected,
    /// resolution changes, etc.) and ensures the menu bar panel is properly positioned and sized.
    /// - Parameter notification: The screen parameters change notification
    @objc private func screenParametersDidChange(_: Notification) {
        Logger.info("Screen parameters changed", category: Logger.app, metadata: [
            "screenCount": NSScreen.screens.count,
            "mainScreenFrame": NSScreen.main?.frame.debugDescription ?? "unknown"
        ])

        Task { @MainActor in
            setupPanels()
        }
    }

    /// Configures and displays the menu bar panel.
    ///
    /// This method creates or updates the menu bar panel with the correct dimensions
    /// and content. The panel spans half the screen width and the full screen height.
    @MainActor
    private func setupPanels() {
        guard let screenFrame = NSScreen.main?.frame else { return }

        let menuBarFrame = NSRect(
            x: screenFrame.origin.x,
            y: screenFrame.origin.y,
            width: screenFrame.width,
            height: screenFrame.height
        )

        guard let spacesViewModel else {
            Logger.warning("SpacesViewModel not initialized yet", category: Logger.app)
            return
        }

        let spacesView = SpacesView()
            .environmentObject(spacesViewModel)

        setupPanel(
            &menuBarPanel,
            frame: menuBarFrame,
            level: Int(CGWindowLevelForKey(.statusWindow)),
            hostingRootView: AnyView(spacesView)
        )
    }

    /// Sets up an NSPanel with the provided parameters.
    ///
    /// This method creates or updates an NSPanel with the specified frame, window level,
    /// and SwiftUI content. The panel is configured to be non-activating and join all spaces.
    /// - Parameters:
    ///   - panel: A reference to the panel to set up or update
    ///   - frame: The frame for the panel
    ///   - level: The window level for the panel
    ///   - hostingRootView: The SwiftUI view to host in the panel
    private func setupPanel(_ panel: inout NSPanel?, frame: CGRect, level: Int, hostingRootView: AnyView) {
        if let existingPanel = panel {
            existingPanel.setFrame(frame, display: true)
            return
        }

        let newPanel = NSPanel(
            contentRect: frame,
            styleMask: [.nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        newPanel.level = NSWindow.Level(rawValue: level)
        newPanel.backgroundColor = .clear
        newPanel.hasShadow = false
        newPanel.collectionBehavior = [.canJoinAllSpaces]
        newPanel.contentView = NSHostingView(rootView: hostingRootView)
        newPanel.orderFront(nil)
        panel = newPanel
    }

    /// Handles the show about window notification.
    @objc private func showAboutWindowNotification(_: Notification) {
        showAboutWindow()
    }

    /// Shows the About window.
    @objc private func showAboutWindow() {
        // If the About window already exists, just focus it
        if let existingWindow = aboutWindow, existingWindow.isVisible {
            existingWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 450, height: 450),
            styleMask: [.titled, .closable, .nonactivatingPanel],
            backing: .buffered,
            defer: true
        )

        panel.title = "About AeroSpaceBar"
        panel.center()

        // Make panel always on top
        panel.level = .floating
        panel.hidesOnDeactivate = false

        // This is crucial for floating panels over full-screen apps
        panel.collectionBehavior.insert(.fullScreenAuxiliary)

        // Set up panel delegate to clean up reference when closed
        panel.delegate = self

        let aboutView = AboutView()
        panel.contentView = NSHostingView(rootView: aboutView)

        // Store reference to prevent multiple windows
        aboutWindow = panel

        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    // MARK: - NSWindowDelegate

    /// Called when the About window is closed to clean up the reference.
    func windowWillClose(_ notification: Notification) {
        guard let panel = notification.object as? NSPanel else { return }

        // Clean up if this is our About window
        if panel === aboutWindow {
            // Clear the delegate to prevent any further callbacks
            panel.delegate = nil
            // Clear our reference
            aboutWindow = nil
        }
    }
}
