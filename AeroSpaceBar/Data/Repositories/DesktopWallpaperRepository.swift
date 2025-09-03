// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import AppKit
import Combine
import CoreGraphics
import Foundation

/// Repository for capturing and managing desktop wallpaper dynamically.
@MainActor
final class DesktopWallpaperRepository: DesktopWallpaperGateway {
    /// Publisher that emits wallpaper image updates.
    private let wallpaperSubject = CurrentValueSubject<NSImage?, Never>(nil)

    /// Publisher that emits menu bar height updates.
    private let menuBarHeightSubject = CurrentValueSubject<CGFloat, Never>(ConfigurationDefaults.menuBarHeight)

    /// The last captured wallpaper image data for comparison.
    private var lastWallpaperData: Data?

    /// The observer for the screens did sleep notification.
    private var screenSleepNotificationObserver: NSObjectProtocol?

    /// The observer for the screens did wake up notification.
    private var screenWakeNotificationObserver: NSObjectProtocol?

    /// The task for capturing the wallpaper.
    private var captureTask: Task<Void, Never>?

    /// Initializes the desktop wallpaper gateway.
    init() {
        setupObservers()
        startPeriodicUpdates()
    }

    /// Publisher that emits wallpaper image updates.
    var wallpaperPublisher: AnyPublisher<NSImage?, Never> {
        wallpaperSubject.eraseToAnyPublisher()
    }

    /// Publisher that emits menu bar height updates.
    var menuBarHeightPublisher: AnyPublisher<CGFloat, Never> {
        menuBarHeightSubject.eraseToAnyPublisher()
    }

    /// Starts periodic wallpaper updates.
    private func startPeriodicUpdates() {
        stopPeriodicUpdates()

        captureTask = Task.detached(priority: .utility) { [weak self] in
            repeat {
                await self?.performWallpaperCapture()
                try? await Task.sleep(for: .seconds(4))
            } while !Task.isCancelled
        }
    }

    /// Sets up observers for the desktop wallpaper repository.
    private func setupObservers() {
        let notificationCenter = NSWorkspace.shared.notificationCenter

        screenSleepNotificationObserver = notificationCenter.addObserver(
            forName: NSWorkspace.screensDidSleepNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.stopPeriodicUpdates()
            }
        }

        screenWakeNotificationObserver = notificationCenter.addObserver(
            forName: NSWorkspace.screensDidWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.startPeriodicUpdates()
            }
        }
    }

    /// Stops the periodic wallpaper updates.
    private func stopPeriodicUpdates() {
        captureTask?.cancel()
        captureTask = nil
    }

    /// Performs wallpaper capture and updates the publisher.
    private func performWallpaperCapture() async {
        // Find the wallpaper window for the main display
        guard let wallpaperWindow = findWallpaperWindow() else {
            Logger.info("No wallpaper window found", category: Logger.config)
            return
        }

        // Find the menu bar window to determine the area to capture
        guard let menuBarWindow = findMenuBarWindow() else {
            Logger.info("No menu bar window found", category: Logger.config)
            return
        }

        // Update the menu bar height if it has changed
        if menuBarWindow.frame.height != menuBarHeightSubject.value {
            menuBarHeightSubject.send(menuBarWindow.frame.height)
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

    /// Finds the wallpaper window for the main display.
    /// - Returns: The wallpaper window info, or nil if not found
    private func findWallpaperWindow() -> WindowInfo? {
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

    /// Finds the menu bar window for the main display.
    /// - Returns: The menu bar window info, or nil if not found
    private func findMenuBarWindow() -> WindowInfo? {
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
    var owningApplication: NSRunningApplication? {
        NSRunningApplication(processIdentifier: ownerPID)
    }

    /// A Boolean value that indicates whether the window is on screen.
    var isOnScreen: Bool

    /// A Boolean value that indicates whether the window belongs to the window server.
    var isWindowServerWindow: Bool {
        ownerName == "Window Server"
    }

    /// Creates a window with the given window identifier.
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
    static func getOnScreenWindows(excludeDesktopWindows: Bool = false) -> [WindowInfo] {
        let options: CGWindowListOption = excludeDesktopWindows ? [.optionOnScreenOnly, .excludeDesktopElements] :
            .optionOnScreenOnly
        guard let list = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[CFString: CFTypeRef]] else {
            return []
        }

        return list.compactMap { WindowInfo(dictionary: $0) }
    }

    /// Creates a window with the given dictionary.
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

// A protocol used to suppress deprecation warnings for the `CGWindowList` screen capture APIs.
//
// ScreenCaptureKit doesn't support capturing composite images of offscreen menu bar items, but
// this should be replaced once it does.
private protocol WindowListImage {
    init?(windowListFromArrayScreenBounds: CGRect, windowArray: CFArray, imageOption: CGWindowImageOption)
}

private extension WindowListImage {
    static func windowListImage(
        from screenBounds: CGRect,
        windowArray: CFArray,
        imageOption: CGWindowImageOption
    ) -> Self? {
        Self(windowListFromArrayScreenBounds: screenBounds, windowArray: windowArray, imageOption: imageOption)
    }
}

extension CGImage: WindowListImage { }

// Extend NSImage to add PNG data conversion
private extension NSImage {
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
