// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import AppKit

/// A connected display with a persistent identity for saved display selections.
@MainActor
struct ConnectedDisplay: Identifiable {
    /// The display UUID, independent of the transient Core Graphics display ID.
    let id: String

    /// The current Core Graphics display ID.
    let displayID: CGDirectDisplayID

    /// The system-provided display name.
    let name: String

    /// The current screen geometry in AppKit coordinates.
    let screen: NSScreen

    /// Whether this display hosts the primary menu bar.
    let isPrimary: Bool

    /// Enumerates screens afresh so reconnects and arrangement changes are reflected.
    static var current: [Self] {
        NSScreen.screens.enumerated().compactMap { index, screen in
            guard
                let number = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber,
                let uuid = unsafe CGDisplayCreateUUIDFromDisplayID(number.uint32Value)?.takeRetainedValue()
            else { return nil }

            return Self(
                id: CFUUIDCreateString(nil, uuid) as String,
                displayID: number.uint32Value,
                name: screen.localizedName,
                screen: screen,
                isPrimary: index == 0
            )
        }
    }
}
