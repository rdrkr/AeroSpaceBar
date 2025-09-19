// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation
import SwiftUI

/// Represents a space/workspace in the system.
///
/// This struct contains information about a workspace including its identifier,
/// focus state, associated windows, and visual configuration.
public struct Space: VisualConfigurable {
    /// The unique identifier for the space.
    public var id: String

    /// The Space title name
    public var title: String {
        get { id }
        set { id = newValue }
    }

    /// Whether the space is currently focused.
    public var isFocused: Bool

    /// The windows that belong to this space.
    public var windows: [Window]

    /// The visual configuration for the space container.
    public var visualConfig: VisualContainer

    /// Coding keys for JSON serialization.
    public enum CodingKeys: String, CodingKey {
        case id = "workspace"
        case visualConfig = "visual-config"
    }

    /// Creates a space with the specified parameters.
    /// - Parameters:
    ///   - id: The unique identifier for the space
    ///   - isFocused: Whether the space is currently focused
    ///   - windows: The windows that belong to this space
    ///   - visualConfig: The visual configuration for the space container
    public init(
        id: String,
        isFocused: Bool = false,
        windows: [Window] = [],
        visualConfig: VisualContainer = ConfigurationDefaults.defaultSpaceVisualConfig
    ) {
        self.id = id
        self.isFocused = isFocused
        self.windows = windows
        self.visualConfig = visualConfig
    }

    /// Creates a space from a decoder.
    /// - Parameter decoder: The decoder to read from
    /// - Throws: DecodingError if the data is invalid
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        visualConfig = try container.decodeIfPresent(
            VisualContainer.self, forKey: .visualConfig
        ) ?? ConfigurationDefaults.defaultSpaceVisualConfig
        isFocused = false
        windows = []
    }

    /// Custom encoder for TOML compatibility
    /// - Parameter encoder: The encoder to write to
    /// - Throws: EncodingError if the data cannot be encoded
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(visualConfig, forKey: .visualConfig)
    }
}
