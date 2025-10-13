// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import AppKit
import Domain
import Foundation
import UniformTypeIdentifiers

/// A thread-safe gateway for storing application icons.
///
/// This class provides a centralized cache for application icons to improve performance
/// by avoiding repeated icon loading operations. It uses NSCache for automatic memory management
/// and implements the IconCache for dependency injection support.
/// This is the data layer implementation of the IconCache.
@MainActor
public final class IconCache {
    /// The underlying cache for storing application icons.
    ///
    /// This cache uses the application name as the key and stores NSImage objects.
    /// It has configurable limits for memory management.
    private let cache: NSCache<NSString, NSImage> = .init()

    /// Initializer that configures cache limits.
    public init() {
        // Configure cache limits
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1_024 * 1_024 // 50MB
    }

    /// Retrieves the icon for a given application name.
    ///
    /// This method first checks the cache for an existing icon. If not found,
    /// it attempts to load the icon from the running application and caches it.
    /// - Parameter appName: The name of the application
    /// - Returns: The application icon if available, nil otherwise
    public func icon(for appName: String) -> NSImage? {
        // Check cache first
        if let cachedIcon = cache.object(forKey: appName as NSString) {
            Logger.debug(
                "Icon found in cache",
                category: Logger.data,
                metadata: ["appName": appName, "source": "cache"]
            )
            return cachedIcon
        }

        Logger.info("Loading icon for application", category: Logger.data, metadata: ["appName": appName])

        // Try to get icon from running applications
        let runningApps: [NSRunningApplication] = NSWorkspace.shared.runningApplications
        if let app = runningApps.first(where: { $0.localizedName?.lowercased() == appName.lowercased() }) {
            let icon: NSImage = app.icon ?? NSWorkspace.shared.icon(for: .application)
            cache.setObject(icon, forKey: appName as NSString)
            Logger.info("Icon loaded from running application", category: Logger.data, metadata: [
                "appName": appName,
                "source": "running_app",
                "hasCustomIcon": app.icon != nil
            ])
            return icon
        }

        // Try to get icon from applications folder
        if let appPath = findAppPath(for: appName) {
            let icon = NSWorkspace.shared.icon(forFile: appPath)
            cache.setObject(icon, forKey: appName as NSString)
            Logger.info("Icon loaded from applications folder", category: Logger.data, metadata: [
                "appName": appName,
                "source": "applications_folder",
                "appPath": appPath
            ])
            return icon
        }

        // Return default icon if app not found
        let defaultIcon = NSWorkspace.shared.icon(for: .application)
        cache.setObject(defaultIcon, forKey: appName as NSString)
        Logger.warning("Using default icon for application", category: Logger.data, metadata: [
            "appName": appName,
            "source": "default"
        ])
        return defaultIcon
    }

    /// Finds the path to an application in the Applications folder.
    /// - Parameter appName: The name of the application to find
    /// - Returns: The path to the application if found, nil otherwise
    private func findAppPath(for appName: String) -> String? {
        let applicationsPaths = [
            "/Applications",
            "/System/Applications",
            NSHomeDirectory() + "/Applications"
        ]

        for path in applicationsPaths {
            let appPath = "\(path)/\(appName).app"
            if FileManager.default.fileExists(atPath: appPath) {
                return appPath
            }
        }

        return nil
    }
}
