// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// A structure containing visual effect properties for container UI elements.
///
/// This struct encapsulates visual effect properties such as opacity and blur radius
/// used across groups, spaces, and other container components to provide a consistent
/// visual effects configuration system.
public struct EffectProperties: Codable, Equatable, Hashable, Sendable, DefaultInitializable {
    // MARK: - Background Effect Properties

    /// The background opacity (0.0 to 1.0).
    public var backgroundOpacity: Double

    /// The background blur radius.
    public var backgroundBlurRadius: Double

    // MARK: - Border Effect Properties

    /// The border opacity (0.0 to 1.0).
    public var borderOpacity: Double

    // MARK: - Initializers

    /// Creates a new effect properties configuration.
    /// - Parameters:
    ///   - backgroundOpacity: The background opacity (0.0 to 1.0)
    ///   - backgroundBlurRadius: The background blur radius
    ///   - borderOpacity: The border opacity (0.0 to 1.0)
    public init(
        backgroundOpacity: Double,
        backgroundBlurRadius: Double,
        borderOpacity: Double
    ) {
        self.backgroundOpacity = backgroundOpacity
        self.backgroundBlurRadius = backgroundBlurRadius
        self.borderOpacity = borderOpacity
    }

    public init() {
        backgroundOpacity = ConfigurationDefaults.spaceEffectProperties.backgroundOpacity
        backgroundBlurRadius = ConfigurationDefaults.spaceEffectProperties.backgroundBlurRadius
        borderOpacity = ConfigurationDefaults.spaceEffectProperties.borderOpacity
    }

    // MARK: - Codable Implementation

    /// Coding keys for JSON serialization.
    private enum CodingKeys: String, CodingKey {
        case backgroundOpacity = "background-opacity"
        case backgroundBlurRadius = "background-blur-radius"
        case borderOpacity = "border-opacity"
    }
}
