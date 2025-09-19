// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import AppKit
import Foundation

/// Represents a window in the system.
///
/// This struct contains information about a window including its identifier,
/// title, associated application, focus state, workspace assignment, and visual configuration.
public struct Window: VisualConfigurable {
    /// The unique identifier for the window.
    public let id: Int

    /// The Window title name
    public var title: String

    /// The name of the application that owns the window.
    public let appName: String?

    /// Whether the window is currently focused.
    public var isFocused: Bool

    /// The workspace/space that the window belongs to.
    public let workspace: String?

    /// The application icon for the window.
    ///
    /// This property stores the cached application icon.
    /// It should be set by the presentation layer using dependency injection.
    public var appIcon: NSImage?

    /// The visual configuration for the window container.
    public var visualConfig: VisualContainer

    /// Coding keys for JSON serialization.
    public enum CodingKeys: String, CodingKey {
        case id = "window-id"
        case title = "window-title"
        case appName = "app-name"
        case workspace
        case visualConfig = "visual-config"
    }

    /// Creates a window with the specified parameters.
    /// - Parameters:
    ///   - id: The unique identifier for the window
    ///   - title: The title of the window
    ///   - appName: The name of the application that owns the window
    ///   - isFocused: Whether the window is currently focused
    ///   - workspace: The workspace/space that the window belongs to
    ///   - appIcon: The application icon for the window
    ///   - visualConfig: The visual configuration for the window container
    public init(
        id: Int,
        title: String,
        appName: String?,
        isFocused: Bool = false,
        workspace: String?,
        appIcon: NSImage? = nil,
        visualConfig: VisualContainer
    ) {
        self.id = id
        self.title = title
        self.appName = appName
        self.isFocused = isFocused
        self.workspace = workspace
        self.appIcon = appIcon
        self.visualConfig = visualConfig
    }

    /// Creates a window from a decoder.
    /// - Parameter decoder: The decoder to read from
    /// - Throws: DecodingError if the data is invalid
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        appName = try container.decode(String.self, forKey: .appName)
        workspace = try container.decode(String.self, forKey: .workspace)
        visualConfig = try container.decodeIfPresent(
            VisualContainer.self, forKey: .visualConfig
        ) ?? ConfigurationDefaults.defaultSpaceVisualConfig
        isFocused = false
        appIcon = nil // appIcon is not encoded/decoded as NSImage doesn't conform to Codable
    }

    /// Encodes the window to an encoder.
    /// - Parameter encoder: The encoder to write to
    /// - Throws: EncodingError if the data cannot be encoded
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(appName, forKey: .appName)
        try container.encode(workspace, forKey: .workspace)
        try container.encode(visualConfig, forKey: .visualConfig)
    }

    /// Compares two windows for equality.
    /// - Parameters:
    ///   - lhs: The left-hand side window
    ///   - rhs: The right-hand side window
    /// - Returns: True if the windows are equal (ignoring appIcon)
    public static func == (lhs: Window, rhs: Window) -> Bool {
        lhs.id == rhs.id &&
            lhs.title == rhs.title &&
            lhs.appName == rhs.appName &&
            lhs.isFocused == rhs.isFocused &&
            lhs.workspace == rhs.workspace &&
            lhs.visualConfig == rhs.visualConfig
    }
}
