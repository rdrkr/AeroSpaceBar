// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// A structure containing geometric properties for container UI elements.
///
/// This struct encapsulates geometric properties such as corner radius and border width
/// used across groups, spaces, and other container components to provide a consistent
/// geometric configuration system.
public struct GeometricProperties: Codable, Equatable, Hashable, Sendable, DefaultInitializable {
    // MARK: - Shape Properties

    /// The corner radius for rounded corners.
    public var cornerRadius: Double

    // MARK: - Border Properties

    /// The border width.
    public var borderWidth: Double

    // MARK: - Initializers

    /// Creates a new geometric properties configuration.
    /// - Parameters:
    ///   - cornerRadius: The corner radius for rounded corners
    ///   - borderWidth: The border width
    public init(
        cornerRadius: Double,
        borderWidth: Double
    ) {
        self.cornerRadius = cornerRadius
        self.borderWidth = borderWidth
    }

    public init() {
        cornerRadius = ConfigurationDefaults.spaceGeometricProperties.cornerRadius
        borderWidth = ConfigurationDefaults.spaceGeometricProperties.borderWidth
    }

    // MARK: - Codable Implementation

    /// Coding keys for JSON serialization.
    private enum CodingKeys: String, CodingKey {
        case cornerRadius = "corner-radius"
        case borderWidth = "border-width"
    }
}
