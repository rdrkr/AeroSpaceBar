// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import AppKit
import Combine
import CoreGraphics
import Foundation

/// Repository for capturing and managing desktop wallpaper dynamically and tracking system menu bar state.
@MainActor
final class SystemMenuBarRepository: SystemMenuBarGateway {
    /// Publisher that emits wallpaper image updates.
    private let wallpaperSubject = CurrentValueSubject<NSImage?, Never>(nil)

    /// Publisher that emits menu bar height updates.
    private let menuBarHeightSubject = CurrentValueSubject<CGFloat, Never>(ConfigurationDefaults.menuBarHeight)

    /// Publisher that emits menu bar visibility updates.
    private let menuBarVisibilitySubject = CurrentValueSubject<Bool, Never>(true)

    /// The last captured wallpaper image data for comparison.
    private var lastWallpaperData: Data?

    /// The observer for the screens did sleep notification.
    private var screenSleepNotificationObserver: NSObjectProtocol?

    /// The observer for the screens did wake up notification.
    private var screenWakeNotificationObserver: NSObjectProtocol?

    /// The task for recognizing windows (menu bar detection).
    private var windowRecognitionTask: Task<Void, Never>?

    /// The task for capturing wallpaper images.
    private var wallpaperCaptureTask: Task<Void, Never>?

    /// Initializes the system menu bar repository.
    init() {
        setupScreenStateObservers()
        startPeriodicTasks()
    }

    /// Publisher that emits wallpaper image updates.
    /// - Returns: A publisher that emits optional NSImage instances when wallpaper changes.
    var wallpaperPublisher: AnyPublisher<NSImage?, Never> {
        wallpaperSubject.eraseToAnyPublisher()
    }

    /// Publisher that emits menu bar height updates.
    /// - Returns: A publisher that emits CGFloat values representing menu bar height changes.
    var menuBarHeightPublisher: AnyPublisher<CGFloat, Never> {
        menuBarHeightSubject.eraseToAnyPublisher()
    }

    /// Publisher that emits menu bar visibility changes.
    /// - Returns: A publisher that emits Boolean values indicating menu bar visibility state.
    var menuBarVisibilityPublisher: AnyPublisher<Bool, Never> {
        menuBarVisibilitySubject.eraseToAnyPublisher()
    }

    /// Starts periodic tasks for window recognition and wallpaper capture.
    private func startPeriodicTasks() {
        stopPeriodicTasks()
        startWindowRecognition()
        startWallpaperCapture()
    }

    /// Starts the periodic window recognition task (menu bar detection and height tracking).
    private func startWindowRecognition() {
        windowRecognitionTask = Task.detached(priority: .utility) { [weak self] in
            repeat {
                await self?.recognizeWindows()
                try? await Task.sleep(for: .seconds(0.4))
            } while !Task.isCancelled
        }
    }

    /// Starts the periodic wallpaper capture task.
    private func startWallpaperCapture() {
        wallpaperCaptureTask = Task.detached(priority: .background) { [weak self] in
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
            Task { @MainActor in
                self?.stopPeriodicTasks()
            }
        }

        screenWakeNotificationObserver = notificationCenter.addObserver(
            forName: NSWorkspace.screensDidWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.startPeriodicTasks()
            }
        }
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
    private func recognizeWindows() async {
        // Find the menu bar window
        let menuBarWindow = findSystemMenuBarWindow()
        let isMenuBarVisible = menuBarWindow != nil

        // Update menu bar visibility if it has changed
        if isMenuBarVisible != menuBarVisibilitySubject.value {
            Logger.debug("Menu bar visibility changed to: \(isMenuBarVisible)", category: Logger.userInterface)
            menuBarVisibilitySubject.send(isMenuBarVisible)
        }

        // Update the menu bar height if it has changed and is visible
        if let menuBarFrame = menuBarWindow?.frame, menuBarFrame.height != menuBarHeightSubject.value {
            menuBarHeightSubject.send(menuBarFrame.height)
        }
    }

    /// Captures wallpaper image and updates the publisher.
    ///
    /// This resource-intensive method runs less frequently to capture and update
    /// the wallpaper image when the menu bar is visible.
    private func captureWallpaperImage() async {
        // Find the wallpaper window for the main display
        guard let wallpaperWindow = findDesktopWallpaperWindow() else {
            Logger.info("No wallpaper window found", category: Logger.config)
            return
        }

        // Find the menu bar window to get its frame for clipping
        guard let menuBarWindow = findSystemMenuBarWindow() else {
            Logger.warning("Menu bar is hidden, skipping wallpaper capture", category: Logger.userInterface)
            return
        }

        // Capture the wallpaper window clipped to menu bar area
        let capturedImage = ScreenCapture.captureWindow(
            wallpaperWindow.windowID,
            screenBounds: menuBarWindow.frame,
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
            }
        } else {
            Logger.warning("Failed to capture wallpaper image", category: Logger.config)
        }
    }

    /// Finds the desktop wallpaper window for the main display.
    /// - Returns: The wallpaper window info, or nil if not found
    private func findDesktopWallpaperWindow() -> WindowInfo? {
        let windows = WindowInfo.getOnScreenWindows()
        return windows.first { window in
            // Wallpaper window criteria:
            // - Belongs to the Dock process
            // - Has a title that starts with "Wallpaper"
            // - Is within the main display bounds
            window.owningApplication?.bundleIdentifier == "com.apple.dock" &&
                window.title?.hasPrefix("Wallpaper") == true &&
                CGDisplayBounds(CGMainDisplayID()).contains(window.frame)
        }
    }

    /// Finds the system menu bar window for the main display.
    /// - Returns: The menu bar window info, or nil if not found
    private func findSystemMenuBarWindow() -> WindowInfo? {
        let windows = WindowInfo.getOnScreenWindows(excludeDesktopWindows: true)
        return windows.first { window in
            // Menu bar window criteria:
            // - Belongs to the WindowServer process
            // - Is on screen
            // - Has the menu bar layer level
            // - Has title "Menubar"
            // - Is within the main display bounds
            window.isWindowServerWindow &&
                window.isOnScreen &&
                window.layer == kCGMainMenuWindowLevel &&
                window.title == "Menubar" &&
                CGDisplayBounds(CGMainDisplayID()).contains(window.frame)
        }
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

    /// Creates a window with the given window identifier.
    /// - Parameter windowID: The Core Graphics window identifier.
    init?(windowID: CGWindowID) {
        var pointer = UnsafeRawPointer(bitPattern: Int(windowID))
        guard
            CFArrayCreate(kCFAllocatorDefault, &pointer, 1, nil) != nil,
            let list = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[CFString: CFTypeRef]],
            let dictionary = list.first(where: { ($0[kCGWindowNumber] as? CGWindowID) == windowID })
        else {
            return nil
        }

        guard
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
    static func getOnScreenWindows(excludeDesktopWindows: Bool = false) -> [WindowInfo] {
        let options: CGWindowListOption = excludeDesktopWindows ? [.optionOnScreenOnly, .excludeDesktopElements] :
            .optionOnScreenOnly
        guard let list = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[CFString: CFTypeRef]] else {
            return []
        }

        return list.compactMap { WindowInfo(dictionary: $0) }
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
        pointer[0] = UnsafeRawPointer(bitPattern: UInt(windowID))

        // Create the window array for the protocol call
        guard let windowArray = CFArrayCreate(kCFAllocatorDefault, pointer, 1, nil) else {
            return nil
        }

        pointer.deallocate()

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
