// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import AppKit
import Foundation

/// Represents a window in the system.
///
/// This struct contains information about a window including its identifier,
/// title, associated application, focus state, and workspace assignment.
struct Window: Identifiable, Equatable, Codable {
    /// The unique identifier for the window.
    let id: Int

    /// The title of the window.
    let title: String

    /// The name of the application that owns the window.
    let appName: String?

    /// Whether the window is currently focused.
    var isFocused: Bool

    /// The workspace/space that the window belongs to.
    let workspace: String?

    /// The application icon for the window.
    ///
    /// This property stores the cached application icon.
    /// It should be set by the presentation layer using dependency injection.
    var appIcon: NSImage?

    /// Coding keys for JSON serialization.
    enum CodingKeys: String, CodingKey {
        case id = "window-id"
        case title = "window-title"
        case appName = "app-name"
        case workspace
    }

    /// Creates a window from a decoder.
    /// - Parameter decoder: The decoder to read from
    /// - Throws: DecodingError if the data is invalid
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        appName = try container.decodeIfPresent(String.self, forKey: .appName)
        workspace = try container.decodeIfPresent(String.self, forKey: .workspace)
        isFocused = false
    }

    /// Creates a window with the specified parameters.
    /// - Parameters:
    ///   - id: The unique identifier for the window
    ///   - title: The title of the window
    ///   - appName: The name of the application that owns the window
    ///   - isFocused: Whether the window is currently focused
    ///   - workspace: The workspace/space that the window belongs to
    ///   - appIcon: The application icon for the window
    init(
        id: Int,
        title: String,
        appName: String?,
        isFocused: Bool = false,
        workspace: String?,
        appIcon: NSImage? = nil
    ) {
        self.id = id
        self.title = title
        self.appName = appName
        self.isFocused = isFocused
        self.workspace = workspace
        self.appIcon = appIcon
    }
}

/// Represents a space/workspace in the system.
///
/// This struct contains information about a workspace including its identifier,
/// focus state, and associated windows.
struct Space: Identifiable, Equatable, Codable {
    /// The unique identifier for the space.
    let id: String

    /// Whether the space is currently focused.
    var isFocused: Bool

    /// The windows that belong to this space.
    var windows: [Window]

    /// Coding keys for JSON serialization.
    enum CodingKeys: String, CodingKey {
        case id = "workspace"
    }

    /// Creates a space from a decoder.
    /// - Parameter decoder: The decoder to read from
    /// - Throws: DecodingError if the data is invalid
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        isFocused = false
        windows = []
    }

    /// Creates a space with the specified parameters.
    /// - Parameters:
    ///   - id: The unique identifier for the space
    ///   - isFocused: Whether the space is currently focused
    ///   - windows: The windows that belong to this space
    init(id: String, isFocused: Bool = false, windows: [Window] = []) {
        self.id = id
        self.isFocused = isFocused
        self.windows = windows
    }
}
