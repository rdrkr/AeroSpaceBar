// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import AppKit
import Darwin

/// Detects whether a display is currently showing a native fullscreen Space.
///
/// macOS has no public API that reports the type of the Space shown on a display. On displays with a
/// camera housing, the system menu bar window stays on screen while an app is fullscreen, so the menu
/// bar window alone cannot tell AeroSpaceBar that the menu bar is hidden. This detector reads the window
/// server's managed display spaces, where a fullscreen Space has its own type.
///
/// The window server symbols are resolved at runtime. If a future macOS removes them, the detector
/// reports no fullscreen Space and menu bar detection falls back to the menu bar window alone.
enum FullScreenSpaceDetector {
    /// The C signature of `CGSMainConnectionID`, which returns this process's window server connection.
    private typealias MainConnectionIDFunction = @convention(c) () -> Int32

    /// The C signature of `CGSCopyManagedDisplaySpaces`, which copies the Spaces of every display.
    private typealias CopyManagedDisplaySpacesFunction = @convention(c) (Int32) -> Unmanaged<CFArray>?

    /// Keys and values used in the window server's managed display spaces dictionaries.
    enum Key {
        /// The key holding a display's identifier, a display UUID string or ``mainDisplayIdentifier``.
        static let displayIdentifier = "Display Identifier"

        /// The key holding the dictionary of the Space currently shown on a display.
        static let currentSpace = "Current Space"

        /// The key holding a Space's type.
        static let spaceType = "type"

        /// The display identifier used when displays do not have separate Spaces.
        ///
        /// In that case the window server reports a single entry that applies to every display.
        static let mainDisplayIdentifier = "Main"

        /// The Space type of a native fullscreen Space.
        static let fullScreenSpaceType = 4
    }

    /// The name of the window server function that returns this process's connection.
    private static let mainConnectionIDSymbol = "CGSMainConnectionID"

    /// The name of the window server function that copies the Spaces of every display.
    private static let copyManagedDisplaySpacesSymbol = "CGSCopyManagedDisplaySpaces"

    /// The `RTLD_DEFAULT` handle value, which makes `dlsym` search every image loaded in the process.
    private static let defaultHandleBitPattern = -2

    /// Whether the given display is currently showing a native fullscreen Space.
    ///
    /// The window server symbols are looked up on every call; `dlsym` is a cheap table lookup and this
    /// avoids keeping C function pointers in shared global state.
    /// - Parameter displayID: The display to check.
    /// - Returns: True if the display's current Space is fullscreen; false if it is not, or if it cannot be read.
    static func isShowingFullScreenSpace(on displayID: CGDirectDisplayID) -> Bool {
        guard
            let mainConnectionID: MainConnectionIDFunction = resolve(mainConnectionIDSymbol),
            let copyManagedDisplaySpaces: CopyManagedDisplaySpacesFunction =
            unsafe resolve(copyManagedDisplaySpacesSymbol),
            let uuid = unsafe CGDisplayCreateUUIDFromDisplayID(displayID)?.takeRetainedValue(),
            let uuidString = CFUUIDCreateString(nil, uuid) as String?,
            let managedDisplaySpaces = unsafe copyManagedDisplaySpaces(mainConnectionID())?.takeRetainedValue()
            as? [[String: Any]]
        else {
            return false
        }

        return isShowingFullScreenSpace(displayUUID: uuidString, in: managedDisplaySpaces)
    }

    /// Whether the display with the given UUID shows a fullscreen Space in the given managed display spaces.
    ///
    /// When displays do not have separate Spaces, the single ``Key/mainDisplayIdentifier`` entry applies to
    /// every display.
    /// - Parameters:
    ///   - displayUUID: The display's UUID string.
    ///   - managedDisplaySpaces: The window server's managed display spaces, one dictionary per display.
    /// - Returns: True if the matching display's current Space has the fullscreen type.
    static func isShowingFullScreenSpace(displayUUID: String, in managedDisplaySpaces: [[String: Any]]) -> Bool {
        let display = managedDisplaySpaces.first { entry in
            guard let identifier = entry[Key.displayIdentifier] as? String else { return false }

            return identifier.caseInsensitiveCompare(displayUUID) == .orderedSame
                || identifier == Key.mainDisplayIdentifier
        }
        let currentSpace = display?[Key.currentSpace] as? [String: Any]
        return currentSpace?[Key.spaceType] as? Int == Key.fullScreenSpaceType
    }

    /// Resolves a C function from the loaded images by symbol name.
    /// - Parameter symbol: The symbol name to resolve.
    /// - Returns: The function cast to the requested C function type, or nil if the symbol is not loaded.
    private static func resolve<Function>(_ symbol: String) -> Function? {
        let defaultHandle = unsafe UnsafeMutableRawPointer(bitPattern: defaultHandleBitPattern)
        guard let pointer = unsafe dlsym(defaultHandle, symbol) else { return nil }

        return unsafe unsafeBitCast(pointer, to: Function.self)
    }
}
