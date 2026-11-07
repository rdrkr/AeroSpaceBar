// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import AppKit
import Combine
import CoreGraphics
import Domain
import Foundation
internal import ScreenCaptureKit

/// Repository for capturing and managing desktop wallpaper dynamically and tracking system menu bar state.
@MainActor
public final class SystemMenuBarRepository: SystemMenuBarGateway {
    /// An explicit target for a spaces panel; nil follows the primary display for groups.
    private let displayID: CGDirectDisplayID?

    /// Resolves the primary display dynamically when the system display arrangement changes.
    private var targetDisplayID: CGDirectDisplayID {
        displayID ?? CGMainDisplayID()
    }

    /// Publisher that emits wallpaper image updates.
    private let wallpaperSubject = CurrentValueSubject<NSImage?, Never>(nil)

    /// Publisher that emits menu bar height updates.
    private let menuBarHeightSubject = CurrentValueSubject<Double, Never>(ConfigurationDefaults.menuBarHeight)

    /// Publisher that emits menu bar visibility updates.
    private let menuBarVisibilitySubject = CurrentValueSubject<Bool, Never>(true)

    /// Publisher that emits menu bar applications updates.
    private let menuBarAppsSubject = CurrentValueSubject<[MenuBarApp], Never>([])

    /// Publisher that emits screen capture permission status updates.
    private let screenCapturePermissionGrantedSubject = CurrentValueSubject<Bool, Never>(false)

    /// Publisher that emits Apple Button (Apple menu icon) frame updates.
    private let appleButtonFrameSubject = CurrentValueSubject<CGRect, Never>(.zero)

    /// The last captured wallpaper image data for comparison.
    private var lastWallpaperData: Data?

    /// The last known menu bar frame for comparison.
    private var lastMenuBarFrame: CGRect?

    /// The observer for the screens did sleep notification.
    private var screenSleepNotificationObserver: NSObjectProtocol?

    /// The observer for the screens did wake up notification.
    private var screenWakeNotificationObserver: NSObjectProtocol?

    /// The task for recognizing windows (menu bar detection).
    private var windowRecognitionTask: Task<Void, Never>?

    /// The task for capturing wallpaper images.
    private var wallpaperCaptureTask: Task<Void, Never>?

    /// Use case for accessing show groups setting.
    private let getShowGroupsUseCase: GetShowGroupsUseCase

    /// Use case for checking if user has been asked for screen capture permissions.
    private let getHasAskedForScreenCapturePermissionsUseCase: GetHasAskedForScreenCapturePermissionsUseCase

    /// Use case for setting whether user has been asked for screen capture permissions.
    private let setHasAskedForScreenCapturePermissionsUseCase: SetHasAskedForScreenCapturePermissionsUseCase

    /// Current show groups setting value.
    private var showGroupsEnabled: Bool = false

    /// Cancellable for the show groups publisher subscription.
    private var showGroupsCancellable: AnyCancellable?

    /// Cancellable for the has asked for permissions publisher subscription.
    private var hasAskedForPermissionsCancellable: AnyCancellable?

    /// Use case for checking if user has been asked for Accessibility permissions.
    private let getHasAskedForAccessibilityPermissionsUseCase: GetHasAskedForAccessibilityPermissionsUseCase

    /// Use case for setting whether user has been asked for Accessibility permissions.
    private let setHasAskedForAccessibilityPermissionsUseCase: SetHasAskedForAccessibilityPermissionsUseCase

    /// Cancellable for the has asked for Accessibility permissions publisher subscription.
    private var hasAskedForAccessibilityPermissionsCancellable: AnyCancellable?

    /// Reader for menu bar status items exposed through the Accessibility API (macOS 27+).
    private let accessibilityReader = MenuBarItemsAccessibilityReader()

    /// The in-flight Accessibility status item scan, used to avoid overlapping scans.
    private var accessibilityScanTask: Task<Void, Never>?

    /// Initializes the system menu bar repository.
    /// - Parameters:
    ///   - getShowGroupsUseCase: The use case for accessing show groups setting
    ///   - getHasAskedForScreenCapturePermissionsUseCase: The use case for checking permission request status
    ///   - setHasAskedForScreenCapturePermissionsUseCase: The use case for setting permission request status
    ///   - getHasAskedForAccessibilityPermissionsUseCase: The use case for checking Accessibility permission
    ///     request status
    ///   - setHasAskedForAccessibilityPermissionsUseCase: The use case for setting Accessibility permission
    ///     request status
    ///   - displayID: The display to observe, or nil to follow the primary display and observe groups.
    public init(
        getShowGroupsUseCase: GetShowGroupsUseCase,
        getHasAskedForScreenCapturePermissionsUseCase: GetHasAskedForScreenCapturePermissionsUseCase,
        setHasAskedForScreenCapturePermissionsUseCase: SetHasAskedForScreenCapturePermissionsUseCase,
        getHasAskedForAccessibilityPermissionsUseCase: GetHasAskedForAccessibilityPermissionsUseCase,
        setHasAskedForAccessibilityPermissionsUseCase: SetHasAskedForAccessibilityPermissionsUseCase,
        displayID: CGDirectDisplayID? = nil
    ) {
        self.displayID = displayID
        self.getShowGroupsUseCase = getShowGroupsUseCase
        self.getHasAskedForScreenCapturePermissionsUseCase = getHasAskedForScreenCapturePermissionsUseCase
        self.setHasAskedForScreenCapturePermissionsUseCase = setHasAskedForScreenCapturePermissionsUseCase
        self.getHasAskedForAccessibilityPermissionsUseCase = getHasAskedForAccessibilityPermissionsUseCase
        self.setHasAskedForAccessibilityPermissionsUseCase = setHasAskedForAccessibilityPermissionsUseCase

        setupShowGroupsSubscription()
        setupScreenStateObservers()
        startPeriodicTasks()
    }

    /// Sets up the show groups publisher subscription.
    private func setupShowGroupsSubscription() {
        showGroupsCancellable = getShowGroupsUseCase.execute()
            .sink { [weak self] value in
                self?.showGroupsEnabled = value
            }
    }

    /// Checks and requests screen capture permissions if needed on macOS 15+.
    private func checkAndRequestPermissionsIfNeeded() {
        guard #available(macOS 15.0, *) else {
            // On older macOS versions, we don't need explicit permissions for legacy API
            screenCapturePermissionGrantedSubject.send(true)
            return
        }

        // Check current permission status
        let hasPermission = CGPreflightScreenCaptureAccess()
        screenCapturePermissionGrantedSubject.send(hasPermission)

        // If we already have permission, no need to ask
        if hasPermission {
            return
        }

        // The shared primary repository owns permission prompting, not each spaces panel.
        guard displayID == nil else { return }

        // Check if we've already asked the user
        hasAskedForPermissionsCancellable = getHasAskedForScreenCapturePermissionsUseCase.execute()
            .sink { [weak self] hasAsked in
                guard let self, !hasAsked else { return }

                // Request permissions for the first time
                Task { @MainActor [weak self] in
                    await self?.requestScreenCapturePermissions()
                }
            }
    }

    /// Requests screen capture permissions from the user.
    public func requestScreenCapturePermissions() async {
        guard #available(macOS 15.0, *) else {
            // Not needed on older macOS versions
            return
        }

        // Mark that we've asked for permissions
        await setHasAskedForScreenCapturePermissionsUseCase.execute(value: true)

        // Request permissions by calling SCShareableContent
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            CGRequestScreenCaptureAccess()
            SCShareableContent.getWithCompletionHandler { _, _ in
                // After the permission dialog, check the new permission status
                Task { @MainActor in
                    let hasPermission = CGPreflightScreenCaptureAccess()
                    self.screenCapturePermissionGrantedSubject.send(hasPermission)

                    if hasPermission {
                        Logger.info("Screen capture permissions granted", category: Logger.config)
                    } else {
                        Logger.warning("Screen capture permissions denied", category: Logger.config)
                    }

                    continuation.resume()
                }
            }
        }
    }

    /// Publisher that emits wallpaper image updates.
    /// - Returns: A publisher that emits optional NSImage instances when wallpaper changes.
    public var wallpaperPublisher: AnyPublisher<NSImage?, Never> {
        wallpaperSubject.eraseToAnyPublisher()
    }

    /// Publisher that emits menu bar height updates.
    /// - Returns: A publisher that emits Double values representing menu bar height changes.
    public var menuBarHeightPublisher: AnyPublisher<Double, Never> {
        menuBarHeightSubject.eraseToAnyPublisher()
    }

    /// Publisher that emits menu bar visibility changes.
    /// - Returns: A publisher that emits Boolean values indicating menu bar visibility state.
    public var menuBarVisibilityPublisher: AnyPublisher<Bool, Never> {
        menuBarVisibilitySubject.eraseToAnyPublisher()
    }

    /// Publisher that emits menu bar applications updates.
    /// - Returns: A publisher that emits arrays of MenuBarApp instances.
    public var menuBarAppsPublisher: AnyPublisher<[MenuBarApp], Never> {
        menuBarAppsSubject.eraseToAnyPublisher()
    }

    /// Publisher that emits screen capture permission status updates.
    /// - Returns: A publisher that emits Boolean values indicating permission status.
    public var screenCapturePermissionGrantedPublisher: AnyPublisher<Bool, Never> {
        screenCapturePermissionGrantedSubject.eraseToAnyPublisher()
    }

    /// Publisher that emits Apple Button (Apple menu icon) frame updates.
    /// - Returns: A publisher that emits CGRect instances representing the Apple Button frame.
    public var appleButtonFramePublisher: AnyPublisher<CGRect, Never> {
        appleButtonFrameSubject.eraseToAnyPublisher()
    }

    /// Starts periodic tasks for window recognition and wallpaper capture.
    private func startPeriodicTasks() {
        stopPeriodicTasks()
        startRecognitionTask()
        startWallpaperCaptureTask()
    }

    /// Starts the periodic recognition task.
    private func startRecognitionTask() {
        windowRecognitionTask = Task.detached(priority: .utility) { [weak self] in
            repeat {
                await self?.recognizeAction()
                try? await Task.sleep(for: .seconds(0.4))
            } while !Task.isCancelled
        }
    }

    /// The action performed periodically to recognize windows and menu bar apps.
    private func recognizeAction() {
        let screenWindows = WindowInfo.getOnScreenWindows(excludeDesktopWindows: true)

        recognizeSystemMenuBar(windows: screenWindows)
        recognizeAppleButtonWindow(windows: screenWindows)

        // Only recognize menu bar apps if show groups is enabled
        if displayID == nil, showGroupsEnabled {
            recognizeSystemMenuBarApps(windows: screenWindows)
        }
    }

    /// Starts the periodic wallpaper capture task.
    private func startWallpaperCaptureTask() {
        wallpaperCaptureTask = Task.detached(priority: .background) { [weak self] in
            await self?.recognizeAction()

            repeat {
                await self?.captureWallpaperImage()
                try? await Task.sleep(for: .seconds(5.0))
            } while !Task.isCancelled
        }
    }

    /// Sets up observers for screen sleep and wake notifications.
    private func setupScreenStateObservers() {
        let notificationCenter = NSWorkspace.shared.notificationCenter

        screenSleepNotificationObserver = notificationCenter.addObserver(
            forName: NSWorkspace.screensDidSleepNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.stopPeriodicTasks()
            }
        }

        screenWakeNotificationObserver = notificationCenter.addObserver(
            forName: NSWorkspace.screensDidWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.startPeriodicTasks()
            }
        }
    }

    /// Stops display-scoped work when a panel is removed or its display disconnects.
    public func stop() {
        stopPeriodicTasks()
        accessibilityScanTask?.cancel()
        accessibilityScanTask = nil
        showGroupsCancellable?.cancel()
        hasAskedForPermissionsCancellable?.cancel()
        hasAskedForAccessibilityPermissionsCancellable?.cancel()
        let center = NSWorkspace.shared.notificationCenter
        if let screenSleepNotificationObserver {
            center.removeObserver(screenSleepNotificationObserver)
        }
        if let screenWakeNotificationObserver {
            center.removeObserver(screenWakeNotificationObserver)
        }
        screenSleepNotificationObserver = nil
        screenWakeNotificationObserver = nil
    }

    /// Stops the periodic tasks for window recognition and wallpaper capture.
    private func stopPeriodicTasks() {
        windowRecognitionTask?.cancel()
        windowRecognitionTask = nil
        wallpaperCaptureTask?.cancel()
        wallpaperCaptureTask = nil
    }

    /// Recognizes windows and updates menu bar visibility and height.
    ///
    /// This lightweight method runs frequently to detect menu bar state changes without
    /// performing expensive wallpaper capture operations.
    /// - Parameter windows: The current list of on-screen windows.
    private func recognizeSystemMenuBar(windows: [WindowInfo]) {
        // Find the menu bar window
        let menuBarWindow = findSystemMenuBarWindow(windows: windows)
        let isMenuBarVisible = menuBarWindow != nil

        // Update menu bar visibility if it has changed
        if isMenuBarVisible != menuBarVisibilitySubject.value {
            Logger.debug("Menu bar visibility changed to: \(isMenuBarVisible)", category: Logger.userInterface)
            menuBarVisibilitySubject.send(isMenuBarVisible)
        }

        // Update the menu bar height if it has changed and is visible
        if let menuBarFrame = menuBarWindow?.frame {
            lastMenuBarFrame = menuBarFrame

            if menuBarFrame.height != menuBarHeightSubject.value {
                menuBarHeightSubject.send(menuBarFrame.height)
            }
        }
    }

    /// Updates the Apple Button (Apple menu icon) frame based on the menu bar dimensions.
    ///
    /// The Apple menu icon is always at the leftmost position of the macOS menu bar.
    /// Since macOS does not expose window information for the Apple menu icon via
    /// the CGWindowList APIs, the frame is calculated from the known menu bar height
    /// and a fixed width that matches the standard Apple menu icon area.
    /// - Parameter windows: The current list of on-screen windows (used for menu bar visibility check).
    private func recognizeAppleButtonWindow(windows _: [WindowInfo]) {
        let menuBarHeight = menuBarHeightSubject.value

        // Only provide a frame when the menu bar is visible
        guard menuBarHeight > 0, menuBarVisibilitySubject.value else {
            if appleButtonFrameSubject.value != .zero {
                appleButtonFrameSubject.send(.zero)
            }
            return
        }

        // The Apple menu icon area is approximately 54 points wide on standard macOS displays.
        let appleButtonWidth: CGFloat = 39.0
        let appleButtonFrame = CGRect(
            x: 8,
            y: 0,
            width: appleButtonWidth,
            height: menuBarHeight
        )

        if appleButtonFrame != appleButtonFrameSubject.value {
            appleButtonFrameSubject.send(appleButtonFrame)
        }
    }

    /// Captures wallpaper image and updates the publisher.
    ///
    /// This resource-intensive method runs less frequently to capture and update
    /// the wallpaper image when the menu bar is visible.
    private func captureWallpaperImage() async {
        // Capture only while this display's menu bar is visible.
        guard
            !Task.isCancelled,
            CGDisplayIsActive(targetDisplayID) != 0,
            menuBarVisibilitySubject.value,
            let menuBarFrame = lastMenuBarFrame
        else {
            Logger.warning("Menu bar is hidden, skipping wallpaper capture", category: Logger.userInterface)
            return
        }

        checkAndRequestPermissionsIfNeeded()

        // Use ScreenCaptureKit on macOS 15+ for better performance and future compatibility
        if #available(macOS 15.0, *), screenCapturePermissionGrantedSubject.value {
            await captureWallpaperUsingScreenCaptureKit(menuBarFrame: menuBarFrame)
        } else {
            captureWallpaperUsingLegacyAPI(menuBarFrame: menuBarFrame)
        }
    }

    /// Captures wallpaper using the modern ScreenCaptureKit API (macOS 15+).
    /// This captures the menu bar region including wallpaper and visual effects,
    /// but excludes the menu bar UI and AeroSpaceBar app windows.
    /// - Parameter menuBarFrame: The menu bar frame to use for clipping the capture area.
    @available(macOS 15.0, *)
    private func captureWallpaperUsingScreenCaptureKit(menuBarFrame: CGRect) async {
        let captureDisplayID = targetDisplayID
        let displayBounds = CGDisplayBounds(captureDisplayID)
        let processID = ProcessInfo.processInfo.processIdentifier

        // ScreenCaptureKit uses coordinates local to the selected display, not global CG coordinates.
        let sourceRect = menuBarFrame.offsetBy(dx: -displayBounds.minX, dy: -displayBounds.minY)

        // Capture the image in a nonisolated context
        let result = await Task<NSImage?, Never>.detached {
            do {
                // Get shareable content to access displays and windows
                let content = try await SCShareableContent.current

                // Match the panel's display, not whichever display is currently primary.
                guard
                    let captureDisplay = content.displays.first(where: { display in
                        display.displayID == captureDisplayID
                    })
                else {
                    Logger.warning("Target display not found in shareable content", category: Logger.config)
                    return nil as NSImage?
                }

                // Find windows to exclude from capture
                let windowsToExclude = content.windows.filter { window in
                    // Exclude Window Server's Menubar window
                    let isMenuBarWindow = window.title == "Menubar"

                    // Exclude AeroSpaceBar app windows
                    let isAeroSpaceBarWindow = window.owningApplication?.processID == processID

                    return isAeroSpaceBarWindow || isMenuBarWindow
                }

                // Configure the capture to capture the menu bar region
                let configuration = SCStreamConfiguration()
                configuration.width = Int(menuBarFrame.width)
                configuration.height = Int(menuBarFrame.height)
                configuration.sourceRect = sourceRect
                configuration.showsCursor = false
                configuration.capturesAudio = false

                // Create a content filter that captures the display region excluding specified windows
                // This will include wallpaper and visual effects, but not the menu bar UI itself
                let contentFilter = SCContentFilter(display: captureDisplay, excludingWindows: windowsToExclude)

                // Capture the display region
                let cgImage = try await SCScreenshotManager.captureImage(
                    contentFilter: contentFilter,
                    configuration: configuration
                )

                // Save PNG to Downloads folder - Useful for debugging
                // if let image = nsImage.pngData {
                //     await MainActor.run {
                //         self.savePNGToDownloads(image)
                //     }
                // }

                // Convert to NSImage
                return NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
            } catch {
                Logger.warning(
                    "Failed to capture wallpaper using ScreenCaptureKit: \(error.localizedDescription)",
                    category: Logger.config
                )
                return nil
            }
        }
        .value

        // Discard captures completed after teardown, disconnect, or a display arrangement change.
        guard
            !Task.isCancelled,
            captureDisplayID == targetDisplayID,
            CGDisplayIsActive(captureDisplayID) != 0,
            CGDisplayBounds(captureDisplayID) == displayBounds,
            lastMenuBarFrame == menuBarFrame
        else { return }

        // Update state on the main actor
        await MainActor.run {
            if let nsImage = result {
                // Check if this is different from the last captured image
                if let pngData = nsImage.pngData, pngData != self.lastWallpaperData {
                    self.lastWallpaperData = pngData
                    self.wallpaperSubject.send(nsImage)
                    Logger.debug("Wallpaper captured and updated (ScreenCaptureKit)", category: Logger.config)

                    // Save PNG to Downloads folder - Useful for debugging
                    // self.savePNGToDownloads(pngData)
                }
            } else {
                // Fall back to legacy API on error
                self.captureWallpaperUsingLegacyAPI(menuBarFrame: menuBarFrame)
            }
        }
    }

    /// Captures wallpaper using the legacy CGWindowList API (macOS 14 and below).
    /// This captures the menu bar region including wallpaper and visual effects,
    /// but excludes the menu bar UI and AeroSpaceBar app windows.
    /// - Parameter menuBarFrame: The menu bar frame to use for clipping the capture area.
    private func captureWallpaperUsingLegacyAPI(menuBarFrame: CGRect) {
        // Find the wallpaper window for this repository's display.
        guard let wallpaperWindow = findDesktopWallpaperWindow() else {
            Logger.info("No wallpaper window found", category: Logger.config)
            return
        }

        // Capture the wallpaper window clipped to menu bar area
        let capturedImage = ScreenCapture.captureWindow(
            wallpaperWindow.windowID,
            screenBounds: menuBarFrame,
            option: [.nominalResolution]
        )

        // Convert CGImage to NSImage
        if let cgImage = capturedImage {
            let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))

            // Check if this is different from the last captured image
            if let pngData = nsImage.pngData, pngData != lastWallpaperData {
                lastWallpaperData = pngData
                wallpaperSubject.send(nsImage)
                Logger.info("Wallpaper captured and updated", category: Logger.config)

                // Save PNG to Downloads folder - Useful for debugging
                // savePNGToDownloads(pngData)
            }
        } else {
            Logger.warning("Failed to capture wallpaper image", category: Logger.config)
        }
    }

    /// Saves PNG data to the Downloads folder with a timestamped filename.
    /// - Parameter pngData: The PNG image data to save.
    private func savePNGToDownloads(_ pngData: Data) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = dateFormatter.string(from: Date())
        let filename = "wallpaper_\(timestamp).png"

        guard let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
            Logger.warning("Could not find Downloads folder", category: Logger.config)
            return
        }

        let fileURL = downloadsURL.appendingPathComponent(filename)

        do {
            try pngData.write(to: fileURL)
            Logger.info("Saved wallpaper to: \(fileURL.path)", category: Logger.config)
        } catch {
            Logger.warning("Failed to save wallpaper: \(error.localizedDescription)", category: Logger.config)
        }
    }

    /// Recognizes menu bar applications and updates the publisher.
    ///
    /// This method scans for menu bar items and extracts application information
    /// from processes that have menu bar icons.
    /// - Parameter windows: The current list of on-screen windows.
    private func recognizeSystemMenuBarApps(windows: [WindowInfo]) {
        let foundApps: [MenuBarApp] = findMenuBarApplications(windows: windows)

        // macOS 27+ no longer backs status items with individual windows, so fall back to Accessibility.
        guard !foundApps.isEmpty else {
            recognizeSystemMenuBarAppsUsingAccessibility(windows: windows)
            return
        }

        publishMenuBarApps(foundApps)
    }

    /// Recognizes menu bar applications through the Accessibility API.
    ///
    /// Used when the window list exposes no status item windows (macOS 27+). Requests Accessibility
    /// permissions once if the app is not trusted yet. The scan runs off the main actor and never overlaps
    /// with a previous scan that is still in flight.
    /// - Parameter windows: The current list of on-screen windows.
    private func recognizeSystemMenuBarAppsUsingAccessibility(windows: [WindowInfo]) {
        guard MenuBarItemsAccessibilityReader.isTrusted else {
            checkAndRequestAccessibilityPermissionsIfNeeded()
            return
        }

        guard accessibilityScanTask == nil else { return }

        let reader = accessibilityReader
        let displayBounds = CGDisplayBounds(CGMainDisplayID())
        let targetMenuBar = CGRect(
            origin: displayBounds.origin,
            size: CGSize(width: displayBounds.width, height: menuBarHeightSubject.value)
        )
        let menuBars = findMenuBarFrames(windows: windows) + [targetMenuBar]

        accessibilityScanTask = Task { [weak self] in
            let result = await reader.readItems(menuBars: menuBars, targetMenuBar: targetMenuBar)
            self?.publishMenuBarApps(from: result)
            self?.accessibilityScanTask = nil
        }
    }

    /// Publishes status items read from the active menu bar.
    ///
    /// A narrower active menu bar can hide items that the primary one shows. Shrinking the list would
    /// permanently cap saved group ranges, so only the primary menu bar may reduce the item count.
    /// - Parameter result: The status items read through the Accessibility API.
    private func publishMenuBarApps(from result: MenuBarItemsAccessibilityReader.ReadResult) {
        guard result.isFromTargetMenuBar || result.items.count >= menuBarAppsSubject.value.count else { return }

        publishMenuBarApps(result.items)
    }

    /// Publishes the recognized menu bar applications if they differ from the current value.
    /// - Parameter foundApps: The recognized menu bar applications, sorted from right to left.
    private func publishMenuBarApps(_ foundApps: [MenuBarApp]) {
        guard foundApps != menuBarAppsSubject.value else { return }

        Logger.debug("Menu bar apps updated: \(foundApps.count) apps found", category: Logger.userInterface)
        menuBarAppsSubject.send(foundApps)
    }

    /// Requests Accessibility permissions if the user has never been asked before.
    ///
    /// Subscribes only once; the persisted flag guarantees the system prompt is shown a single time.
    private func checkAndRequestAccessibilityPermissionsIfNeeded() {
        guard hasAskedForAccessibilityPermissionsCancellable == nil else { return }

        hasAskedForAccessibilityPermissionsCancellable = getHasAskedForAccessibilityPermissionsUseCase.execute()
            .sink { [weak self] hasAsked in
                guard let self, !hasAsked else { return }

                Task { @MainActor [weak self] in
                    await self?.requestAccessibilityPermissions()
                }
            }
    }

    /// Marks Accessibility permissions as requested and shows the system prompt.
    private func requestAccessibilityPermissions() async {
        await setHasAskedForAccessibilityPermissionsUseCase.execute(value: true)
        MenuBarItemsAccessibilityReader.requestTrust()
        Logger.info("Requested Accessibility permissions for menu bar status items", category: Logger.config)
    }

    /// Finds the desktop wallpaper window for the target display.
    /// - Returns: The wallpaper window info, or nil if not found
    private func findDesktopWallpaperWindow() -> WindowInfo? {
        let windows = WindowInfo.getOnScreenWindows()
        return windows.first { window in
            // Wallpaper window criteria:
            // - Belongs to the Dock process
            // - Has a title that starts with "Wallpaper"
            // - Is within the target display bounds
            window.owningApplication?.bundleIdentifier == "com.apple.dock" &&
                window.title?.hasPrefix("Wallpaper") == true &&
                CGDisplayBounds(targetDisplayID).contains(window.frame)
        }
    }

    /// Finds the frames of the system menu bars on every display.
    /// - Parameter windows: The current list of on-screen windows.
    /// - Returns: The frame of each visible menu bar in global coordinates.
    private func findMenuBarFrames(windows: [WindowInfo]) -> [CGRect] {
        windows
            .filter { window in
                window.isWindowServerWindow &&
                    window.isOnScreen &&
                    window.layer == kCGMainMenuWindowLevel &&
                    window.title == "Menubar"
            }
            .map(\.frame)
    }

    /// Finds the system menu bar window for the target display.
    /// - Parameter windows: The current list of on-screen windows.
    /// - Returns: The menu bar window info, or nil if not found
    private func findSystemMenuBarWindow(windows: [WindowInfo]) -> WindowInfo? {
        windows.first { window in
            // Menu bar window criteria:
            // - Belongs to the WindowServer process
            // - Is on screen
            // - Has the menu bar layer level
            // - Has title "Menubar"
            // - Is within the target display bounds
            window.isWindowServerWindow &&
                window.isOnScreen &&
                window.layer == kCGMainMenuWindowLevel &&
                window.title == "Menubar" &&
                CGDisplayBounds(targetDisplayID).contains(window.frame)
        }
    }

    /// Finds menu bar applications by scanning for processes with menu bar items.
    /// - Parameter windows: The current list of on-screen windows.
    /// - Returns: An array of MenuBarApp instances representing menu bar applications from right to left.
    private func findMenuBarApplications(windows: [WindowInfo]) -> [MenuBarApp] {
        let menuBarHeight = menuBarHeightSubject.value

        return windows
            .filter { window in
                window.isControlCenterWindow &&
                    window.isOnScreen &&
                    window.layer >= kCGMainMenuWindowLevel &&
                    // ignore views which are non in menubar (e.g. notifications).
                    window.frame.origin.y == 0.0 &&
                    // ignore views which are non in menubar (e.g. widgets).
                    window.frame.size.height <= menuBarHeight &&
                    CGDisplayBounds(CGMainDisplayID()).contains(window.frame)
            }
            .map { window in
                MenuBarApp(
                    id: window.windowID.formatted(),
                    frame: window.frame
                )
            }
            .sorted { $0.frame.origin.x > $1.frame.origin.x } // Sort apps from right to left
            .insertClockApp()
    }
}

/// Information for a window.
private struct WindowInfo {
    /// The window identifier associated with the window.
    let windowID: CGWindowID

    /// The frame of the window.
    let frame: CGRect

    /// The title of the window.
    let title: String?

    /// The layer number of the window.
    let layer: Int

    /// The process identifier of the application that owns the window.
    let ownerPID: pid_t

    /// The name of the application that owns the window.
    let ownerName: String?

    /// The application that owns the window.
    /// - Returns: The NSRunningApplication instance for the window owner, or nil if not found.
    var owningApplication: NSRunningApplication? {
        NSRunningApplication(processIdentifier: ownerPID)
    }

    /// A Boolean value that indicates whether the window is on screen.
    var isOnScreen: Bool

    /// A Boolean value that indicates whether the window belongs to the window server.
    /// - Returns: True if the window belongs to the Window Server process, false otherwise.
    var isWindowServerWindow: Bool {
        ownerName == "Window Server"
    }

    /// A Boolean value that indicates whether the window belongs to the Control Center.
    /// Up to macOS 26 the Control Center owns all system menu bar app icons (e.g., WiFi, battery, etc.).
    /// On macOS 27+ status items have no windows and are read through Accessibility instead.
    /// - Returns: True if the window belongs to the Control Center process, false otherwise.
    var isControlCenterWindow: Bool {
        ownerName == "Control Center"
    }

    /// Creates a window with the given window identifier.
    /// - Parameter windowID: The Core Graphics window identifier.
    init?(windowID: CGWindowID) {
        var pointer = unsafe UnsafeRawPointer(bitPattern: Int(windowID))
        guard
            unsafe CFArrayCreate(kCFAllocatorDefault, &pointer, 1, nil) != nil,
            let list = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[CFString: CFTypeRef]],
            let dictionary = list.first(where: { ($0[kCGWindowNumber] as? CGWindowID) == windowID }),
            let frameDict = dictionary[kCGWindowBounds] as? NSDictionary,
            let frame = CGRect(dictionaryRepresentation: frameDict),
            let layer = dictionary[kCGWindowLayer] as? Int,
            let ownerPID = dictionary[kCGWindowOwnerPID] as? pid_t
        else {
            return nil
        }

        self.windowID = windowID
        self.frame = frame
        title = dictionary[kCGWindowName] as? String
        self.layer = layer
        self.ownerPID = ownerPID
        ownerName = dictionary[kCGWindowOwnerName] as? String
        isOnScreen = dictionary[kCGWindowIsOnscreen] as? Bool ?? false
    }

    /// Returns the on screen windows.
    /// - Parameter excludeDesktopWindows: A Boolean value that indicates whether
    ///   to exclude desktop owned windows, such as the wallpaper and desktop icons.
    /// - Returns: An array of WindowInfo instances representing visible windows.
    static func getOnScreenWindows(excludeDesktopWindows: Bool = false) -> [Self] {
        let options: CGWindowListOption = excludeDesktopWindows ? [.optionOnScreenOnly, .excludeDesktopElements] :
            .optionOnScreenOnly
        guard let list = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[CFString: CFTypeRef]] else {
            return []
        }

        return list.compactMap { Self(dictionary: $0) }
    }

    /// Creates a window with the given dictionary.
    /// - Parameter dictionary: A dictionary containing window information from Core Graphics.
    private init?(dictionary: [CFString: CFTypeRef]) {
        guard
            let windowID = dictionary[kCGWindowNumber] as? CGWindowID,
            let boundsDict = dictionary[kCGWindowBounds] as? NSDictionary,
            let frame = CGRect(dictionaryRepresentation: boundsDict),
            let layer = dictionary[kCGWindowLayer] as? Int,
            let ownerPID = dictionary[kCGWindowOwnerPID] as? pid_t
        else {
            return nil
        }

        self.windowID = windowID
        self.frame = frame
        title = dictionary[kCGWindowName] as? String
        self.layer = layer
        self.ownerPID = ownerPID
        ownerName = dictionary[kCGWindowOwnerName] as? String
        isOnScreen = dictionary[kCGWindowIsOnscreen] as? Bool ?? false
    }
}

/// A namespace for screen capture operations.
private enum ScreenCapture {
    /// Captures an image of a window.
    /// - Parameters:
    ///   - windowID: The identifier of the window to capture.
    ///   - screenBounds: The bounds to capture. Pass `nil` to capture the minimum rectangle that encloses the window.
    ///   - option: Options that specify the image to be captured.
    /// - Returns: A CGImage of the captured window, or nil if capture fails.
    static func captureWindow(
        _ windowID: CGWindowID,
        screenBounds: CGRect? = nil,
        option: CGWindowImageOption = []
    ) -> CGImage? {
        let pointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 1)
        unsafe pointer[0] = unsafe UnsafeRawPointer(bitPattern: UInt(windowID))

        // Create the window array for the protocol call
        guard let windowArray = unsafe CFArrayCreate(kCFAllocatorDefault, pointer, 1, nil) else {
            return nil
        }

        unsafe pointer.deallocate()

        return CGImage.windowListImage(from: screenBounds ?? .null, windowArray: windowArray, imageOption: option)
    }
}

// MARK: - Screen Capture Implementation

/// A protocol used to suppress deprecation warnings for the `CGWindowList` screen capture APIs.
///
/// ScreenCaptureKit doesn't support capturing composite images of offscreen menu bar items, but
/// this should be replaced once it does.
private protocol WindowListImage {
    /// Initializes a window list image from the specified parameters.
    /// - Parameters:
    ///   - windowListFromArrayScreenBounds: The screen bounds for the capture area.
    ///   - windowArray: An array of window identifiers to capture.
    ///   - imageOption: Options for image capture.
    init?(windowListFromArrayScreenBounds: CGRect, windowArray: CFArray, imageOption: CGWindowImageOption)
}

private extension WindowListImage {
    /// Creates a window list image from the specified parameters.
    /// - Parameters:
    ///   - screenBounds: The screen bounds for the capture area.
    ///   - windowArray: An array of window identifiers to capture.
    ///   - imageOption: Options for image capture.
    /// - Returns: A window list image instance, or nil if creation fails.
    static func windowListImage(
        from screenBounds: CGRect,
        windowArray: CFArray,
        imageOption: CGWindowImageOption
    ) -> Self? {
        Self(windowListFromArrayScreenBounds: screenBounds, windowArray: windowArray, imageOption: imageOption)
    }
}

extension CGImage: WindowListImage { }

/// Extend NSImage to add PNG data conversion
private extension NSImage {
    /// Converts the image to PNG data.
    /// - Returns: PNG data representation of the image, or nil if conversion fails.
    var pngData: Data? {
        guard
            let tiffRepresentation,
            let bitmapImage = NSBitmapImageRep(data: tiffRepresentation)
        else {
            return nil
        }

        return bitmapImage.representation(using: .png, properties: [:])
    }
}

private extension [MenuBarApp] {
    /// Adds a synthetic clock app to the menu bar apps collection.
    ///
    /// This method creates a clock app that spans from the end of the rightmost
    /// menu bar app to the end of the screen width, using the same height as
    /// the existing menu bar apps.
    ///
    /// - Returns: A new array of menu bar apps including the synthetic clock app
    func insertClockApp() -> [MenuBarApp] {
        let clockAppID = "system.clock"
        var apps = self

        if contains(where: { $0.id == clockAppID }) {
            // Clock app already exists, return original array
            return apps
        }

        // Add synthetic clock app if we have menu bar apps
        if let rightmostApp = apps.first {
            let screenBounds = CGDisplayBounds(CGMainDisplayID())
            let clockStartX = rightmostApp.frame.origin.x + rightmostApp.frame.width - 1
            let clockWidth = screenBounds.width - clockStartX - 8

            // Only add clock if there's space for it
            let clockApp = MenuBarApp(
                id: clockAppID,
                frame: CGRect(
                    x: clockStartX,
                    y: rightmostApp.frame.origin.y,
                    width: clockWidth,
                    height: rightmostApp.frame.height
                )
            )

            apps.insert(clockApp, at: 0)
        }

        return apps
    }
}
