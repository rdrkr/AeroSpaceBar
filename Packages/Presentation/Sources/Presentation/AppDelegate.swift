// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
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
public final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    /// The panels of each display showing spaces or groups, keyed by persistent display UUID.
    private var displayPanels: [String: DisplayPanels] = [:]

    /// The current spaces display selection.
    private var spacesDisplayConfiguration = DisplayConfiguration()

    /// The current groups display selection.
    private var groupsDisplayConfiguration = DisplayConfiguration()

    /// The live spaces and groups display selection subscriptions.
    private var displayConfigurationCancellables = Set<AnyCancellable>()

    /// The panels of one connected display and the resources scoped to that display.
    private final class DisplayPanels {
        /// The panel hosting the spaces bar, present only while the display shows spaces.
        var spacesPanel: NSPanel?

        /// The panel drawing group and Apple Button backgrounds below the system menu bar.
        var groupsPanel: NSPanel?

        /// The panel drawing foreground colors above the system menu bar icons.
        var groupsForegroundOverlayPanel: NSPanel?

        /// The display's current Core Graphics identifier.
        let displayID: CGDirectDisplayID

        /// Whether the display was the primary display when these panels were created.
        let isPrimary: Bool

        /// The menu bar state shared by this display's panels.
        let viewModel: DisplayMenuBarViewModel

        /// Stops the resources scoped to this display.
        let stop: @MainActor () -> Void

        /// Creates the panel container for a display.
        /// - Parameters:
        ///   - displayID: The display's current Core Graphics identifier.
        ///   - isPrimary: Whether the display is the primary display.
        ///   - viewModel: The menu bar state shared by this display's panels.
        ///   - stop: Stops the resources scoped to this display.
        init(
            displayID: CGDirectDisplayID,
            isPrimary: Bool,
            viewModel: DisplayMenuBarViewModel,
            stop: @escaping @MainActor () -> Void
        ) {
            self.displayID = displayID
            self.isPrimary = isPrimary
            self.viewModel = viewModel
            self.stop = stop
        }
    }

    /// The About window instance to prevent multiple windows.
    private var aboutWindow: NSPanel?

    /// The dependency container for accessing services.
    private let dependencyContainer = DependencyContainer.shared

    /// Called when the application has finished launching.
    ///
    /// This method initializes the main app ViewModel, sets up the menu bar panel,
    /// and registers for screen parameter change notifications.
    /// - Parameter notification: The launch notification
    public func applicationDidFinishLaunching(_: Notification) {
        Logger.info("Application launching", category: Logger.app, metadata: [
            "version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown",
            "build": Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown"
        ])

        dependencyContainer.makeGetSpacesDisplayConfigurationUseCase()
            .execute()
            .sink { [weak self] configuration in
                guard let self else { return }

                spacesDisplayConfiguration = configuration
                reconcileDisplayPanels()
            }
            .store(in: &displayConfigurationCancellables)

        dependencyContainer.makeGetGroupsDisplayConfigurationUseCase()
            .execute()
            .sink { [weak self] configuration in
                guard let self else { return }

                groupsDisplayConfiguration = configuration
                reconcileDisplayPanels()
            }
            .store(in: &displayConfigurationCancellables)

        // Initialize the ViewModels and setup panels
        Task { @MainActor in
            Logger.beginInterval("App Initialization", id: Logger.SignpostID.spacesFetch)

            initializeAllPanels()

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
    @objc
    private func screenParametersDidChange(_: Notification) {
        Logger.info("Screen parameters changed", category: Logger.app, metadata: [
            "screenCount": NSScreen.screens.count,
            "mainScreenFrame": NSScreen.main?.frame.debugDescription ?? "unknown"
        ])

        initializeAllPanels()
    }

    /// Initializes all panels (Release builds or fallback)
    @MainActor
    private func initializeAllPanels() {
        reconcileDisplayPanels()
        Logger.info("Display panels initialized", category: Logger.app)
    }

    /// Adds, updates, and removes display-local panels after selection or screen changes.
    private func reconcileDisplayPanels() {
        let connectedDisplays = ConnectedDisplay.current
        let displays = connectedDisplays.filter { display in
            showsSpaces(on: display) || showsGroups(on: display)
        }
        let connectedIDs = Set(displays.map(\.id))
        let primaryWidth = connectedDisplays.first(where: \.isPrimary)?.screen.frame.width

        for id in Array(displayPanels.keys) where !connectedIDs.contains(id) {
            removeDisplayPanels(id: id)
        }

        for display in displays {
            // Primary panels share the groups repository, which follows primary-display changes.
            if
                let existing = displayPanels[display.id],
                existing.displayID != display.displayID || existing.isPrimary != display.isPrimary
            {
                removeDisplayPanels(id: display.id)
            }
            if displayPanels[display.id] == nil {
                let resources = dependencyContainer.makeDisplayMenuBarViewModel(displayID: display.displayID)
                displayPanels[display.id] = DisplayPanels(
                    displayID: display.displayID,
                    isPrimary: display.isPrimary,
                    viewModel: resources.viewModel,
                    stop: resources.stop
                )
            }
            guard let entry = displayPanels[display.id] else { continue }

            configurePanels(entry, for: display, primaryWidth: primaryWidth)
        }
    }

    /// Returns whether a display shows the spaces bar and the Apple Button background.
    /// - Parameter display: The display to evaluate.
    /// - Returns: `true` if the spaces display selection includes the display.
    private func showsSpaces(on display: ConnectedDisplay) -> Bool {
        spacesDisplayConfiguration.includesDisplay(id: display.id, isPrimary: display.isPrimary)
    }

    /// Returns whether a display shows groups.
    /// - Parameter display: The display to evaluate.
    /// - Returns: `true` if the groups display selection includes the display.
    private func showsGroups(on display: ConnectedDisplay) -> Bool {
        groupsDisplayConfiguration.includesDisplay(id: display.id, isPrimary: display.isPrimary)
    }

    /// Applies the current selection to one display's panels.
    /// - Parameters:
    ///   - entry: The panels of the display.
    ///   - display: The connected display.
    ///   - primaryWidth: The width of the primary display, if connected.
    private func configurePanels(_ entry: DisplayPanels, for display: ConnectedDisplay, primaryWidth: CGFloat?) {
        let showsSpaces = showsSpaces(on: display)
        entry.viewModel.showsAppleButton = showsSpaces
        entry.viewModel.showsGroups = showsGroups(on: display)
        entry.viewModel.statusItemsGeometry = display.isPrimary ? nil : primaryWidth.map { width in
            DisplayMenuBarViewModel.StatusItemsGeometry(
                primaryWidth: width,
                displayWidth: display.screen.frame.width,
                minX: display.statusItemsMinX
            )
        }

        if showsSpaces {
            setupSpacesPanel(entry, screenFrame: display.screen.frame)
        } else {
            entry.spacesPanel?.close()
            entry.spacesPanel = nil
        }
        setupGroupsPanel(entry, screenFrame: display.screen.frame)
        setupGroupsForegroundOverlayPanel(entry, screenFrame: display.screen.frame)
    }

    /// Stops capture and closes a display's panels when it is deselected or disconnected.
    /// - Parameter id: The persistent display UUID.
    private func removeDisplayPanels(id: String) {
        guard let entry = displayPanels.removeValue(forKey: id) else { return }

        entry.stop()
        entry.spacesPanel?.close()
        entry.groupsPanel?.close()
        entry.groupsForegroundOverlayPanel?.close()
    }

    /// Releases display-scoped tasks when the application terminates.
    public func applicationWillTerminate(_: Notification) {
        displayConfigurationCancellables.removeAll()
        for id in Array(displayPanels.keys) {
            removeDisplayPanels(id: id)
        }
    }

    /// Positions the spaces panel in the left half of its display.
    /// - Parameters:
    ///   - entry: The panels of the display.
    ///   - screenFrame: The frame of the display.
    private func setupSpacesPanel(_ entry: DisplayPanels, screenFrame: CGRect) {
        let spacesFrame = NSRect(
            x: screenFrame.origin.x,
            y: screenFrame.origin.y,
            width: screenFrame.width / 2,
            height: screenFrame.height
        )

        let spacesView = SpacesView(displayViewModel: entry.viewModel)
            .environmentObject(dependencyContainer.getSpacesViewModel())

        setupPanel(
            &entry.spacesPanel,
            frame: spacesFrame,
            level: Int(CGWindowLevelForKey(.statusWindow)),
            hostingRootView: AnyView(spacesView)
        )
    }

    /// Configures and displays a display's groups panel.
    ///
    /// System menu bar item positions are relative to the full screen size, so the panel covers the
    /// full display. It also hosts the Apple Button background.
    /// - Parameters:
    ///   - entry: The panels of the display.
    ///   - screenFrame: The frame of the display.
    private func setupGroupsPanel(_ entry: DisplayPanels, screenFrame: CGRect) {
        let groupsView = GroupsView(displayViewModel: entry.viewModel)
            .environmentObject(dependencyContainer.getGroupsViewModel())

        setupPanel(
            &entry.groupsPanel,
            frame: screenFrame,
            level: Int(CGWindowLevelForKey(.utilityWindow)),
            hostingRootView: AnyView(groupsView),
            ignoresMouseEvents: true
        )
    }

    /// Configures and displays a display's groups foreground overlay panel.
    ///
    /// This panel draws semi-transparent foreground color rectangles above the system menu bar icons.
    /// It sits at `statusWindow` level (above system menu bar icons) and ignores mouse events
    /// so clicks pass through to the actual menu bar icons underneath.
    /// - Parameters:
    ///   - entry: The panels of the display.
    ///   - screenFrame: The frame of the display.
    private func setupGroupsForegroundOverlayPanel(_ entry: DisplayPanels, screenFrame: CGRect) {
        let overlayView = GroupsForegroundOverlayHostView(displayViewModel: entry.viewModel)
            .environmentObject(dependencyContainer.getGroupsViewModel())

        setupPanel(
            &entry.groupsForegroundOverlayPanel,
            frame: screenFrame,
            level: Int(CGWindowLevelForKey(.statusWindow)),
            hostingRootView: AnyView(overlayView),
            ignoresMouseEvents: true
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
    ///   - ignoresMouseEvents: Whether the panel should ignore mouse events (default: false)
    private func setupPanel(
        _ panel: inout NSPanel?,
        frame: CGRect,
        level: Int,
        hostingRootView: AnyView,
        ignoresMouseEvents: Bool = false
    ) {
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
        newPanel.isReleasedWhenClosed = false
        newPanel.level = NSWindow.Level(rawValue: level)
        newPanel.backgroundColor = .clear
        newPanel.hasShadow = false
        if ignoresMouseEvents {
            newPanel.ignoresMouseEvents = true
        }
        newPanel.collectionBehavior = [.canJoinAllSpaces]
        newPanel.contentView = NSHostingView(rootView: hostingRootView)
        newPanel.orderFront(nil)
        panel = newPanel
    }

    /// Handles the show about window notification.
    @objc
    private func showAboutWindowNotification(_: Notification) {
        showAboutWindow()
    }

    /// Shows the About window.
    @objc
    private func showAboutWindow() {
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
    public func windowWillClose(_ notification: Notification) {
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
