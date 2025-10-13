// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation
import IOKit

/// Utility for obtaining hardware-based device identifiers.
///
/// This utility provides access to macOS hardware identifiers that persist
/// across app reinstalls and OS updates, making them suitable for device
/// identification in licensing systems.
public enum HardwareIdentifier {
    /// Retrieves the hardware UUID from the macOS IOKit registry.
    ///
    /// The hardware UUID (IOPlatformUUID) is a unique identifier assigned to
    /// the Mac's hardware. It persists across:
    /// - App reinstalls
    /// - OS reinstalls
    /// - User account changes
    ///
    /// This makes it ideal for device identification in licensing systems,
    /// as users cannot easily circumvent it by deleting app data.
    ///
    /// - Returns: The hardware UUID string, or an empty string if unavailable
    ///
    /// ## Example
    /// ```swift
    /// let uuid = HardwareIdentifier.getHardwareUUID()
    /// print(uuid) // "12345678-ABCD-EFGH-IJKL-1234567890AB"
    /// ```
    ///
    /// ## Technical Details
    /// This method queries the IOKit registry for the IOPlatformExpertDevice
    /// and retrieves its IOPlatformUUID property. No special entitlements are
    /// required to access this information.
    ///
    /// - Warning: This method uses unsafe IOKit C APIs. The unsafe operations
    ///   are explicitly marked for Swift 6 strict memory safety compliance.
    public static func getHardwareUUID() -> String {
        // Get the IOPlatformExpertDevice service from IOKit registry
        // IOKit uses unsafe C pointers that need explicit unsafe marking in Swift 6
        let platformExpert: io_service_t = unsafe IOServiceGetMatchingService(
            kIOMainPortDefault,
            IOServiceMatching("IOPlatformExpertDevice")
        )

        // Ensure we got a valid service reference
        guard platformExpert != 0 else {
            return ""
        }

        // Release the service reference when we're done
        defer { IOObjectRelease(platformExpert) }

        // Query the IOPlatformUUID property
        guard
            let uuidProperty = IORegistryEntryCreateCFProperty(
                platformExpert,
                "IOPlatformUUID" as CFString,
                kCFAllocatorDefault,
                0
            )
        else {
            return ""
        }

        // Cast the property to a String
        // takeRetainedValue() transfers ownership from Core Foundation to Swift
        // Marked unsafe for Swift 6 strict memory safety compliance
        guard let uuid = unsafe uuidProperty.takeRetainedValue() as? String else {
            return ""
        }

        return uuid
    }
}
