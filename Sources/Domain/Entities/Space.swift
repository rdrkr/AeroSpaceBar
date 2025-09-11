// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Represents a space/workspace in the system.
///
/// This struct contains information about a workspace including its identifier,
/// focus state, and associated windows.
public struct Space: Identifiable, Equatable, Codable {
    /// The unique identifier for the space.
    public let id: String

    /// Whether the space is currently focused.
    public var isFocused: Bool

    /// The windows that belong to this space.
    public var windows: [Window]

    /// Coding keys for JSON serialization.
    public enum CodingKeys: String, CodingKey {
        case id = "workspace"
    }

    /// Creates a space from a decoder.
    /// - Parameter decoder: The decoder to read from
    /// - Throws: DecodingError if the data is invalid
    public init(from decoder: Decoder) throws {
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
    public init(id: String, isFocused: Bool = false, windows: [Window] = []) {
        self.id = id
        self.isFocused = isFocused
        self.windows = windows
    }
}
