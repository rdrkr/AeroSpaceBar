// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Data Transfer Object for Window data from AeroSpace CLI.
///
/// This struct represents the raw JSON structure returned by the AeroSpace CLI
/// for window information. It's used to decode the CLI response before
/// mapping to domain entities.
struct WindowData: Codable {
    /// The unique identifier of the window.
    let windowId: Int

    /// The title of the window.
    let windowTitle: String

    /// The bundle identifier of the application.
    let appName: String?

    /// The workspace/space that the window belongs to.
    let workspace: String?

    /// Coding keys for JSON serialization.
    enum CodingKeys: String, CodingKey {
        case windowId = "window-id"
        case windowTitle = "window-title"
        case appName = "app-name"
        case workspace
    }

    /// Maps this DTO to a domain Window entity.
    /// - Returns: A domain Window entity
    func toDomain() -> Window {
        Window(
            id: windowId,
            title: windowTitle,
            appName: appName,
            workspace: workspace
        )
    }
}
