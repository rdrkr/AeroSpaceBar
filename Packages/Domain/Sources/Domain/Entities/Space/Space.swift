// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation
import SwiftUI

/// Represents a space/workspace in the system.
///
/// This struct contains information about a workspace including its identifier,
/// focus state, associated windows, and color properties.
public struct Space: VisualContainer {
    public typealias AppearanceMode = SpacesAppearanceMode

    /// The unique identifier used for the Apple Button virtual space.
    public static let appleButtonId = "\u{F8FF}"

    /// The metadata configuration for Space entities.
    public static let metadata = VisualContainerMetadata(
        entityName: String(localized: LocalizedStringResource("Space")),
        entityNamePlural: String(localized: LocalizedStringResource("Spaces")),
        tagPrefix: "spaces",
        canAddEntities: false,
        canDeleteEntities: false,
        showForegroundSection: true,
        defaultGlobalColorProperties: ConfigurationDefaults.spaceColorProperties,
        defaultGlobalEffectProperties: ConfigurationDefaults.spaceEffectProperties,
        defaultGlobalGeometricProperties: ConfigurationDefaults.spaceGeometricProperties,
        canDeleteEntity: { _ in false }, // Spaces cannot be deleted
        footerText: String(localized: LocalizedStringResource(
            "Spaces cannot be deleted or added manually - they are managed by AeroSpace."
        )),
        resetAlertTitle: String(localized: LocalizedStringResource("Reset Spaces")),
        resetAlertMessage: String(localized: LocalizedStringResource(
            """
            Are you sure you want to reset all spaces to their default configuration? \
            This action cannot be undone.
            """
        )),
        resetButtonTitle: String(localized: LocalizedStringResource("Reset Spaces")),
        resetButtonDescription: String(localized: LocalizedStringResource(
            "Reset all spaces to their default configuration."
        ))
    )

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

    /// The color properties for the space container.
    public var colorProperties: ColorProperties

    /// The geometric properties for the space container.
    public var geometricProperties: GeometricProperties

    /// The effect properties for the space container.
    public var effectProperties: EffectProperties

    /// Coding keys for JSON serialization.
    public enum CodingKeys: String, CodingKey {
        case id = "workspace"
        case colorProperties = "visual-config"
        case geometricProperties = "geometric-config"
        case effectProperties = "effect-config"
    }

    /// Creates a space with the specified parameters.
    /// - Parameters:
    ///   - id: The unique identifier for the space
    ///   - isFocused: Whether the space is currently focused
    ///   - windows: The windows that belong to this space
    ///   - colorProperties: The color properties for the space container
    ///   - geometricProperties: The geometric properties for the space container
    ///   - effectProperties: The effect properties for the space container
    public init(
        id: String,
        isFocused: Bool = false,
        windows: [Window] = [],
        colorProperties: ColorProperties = ConfigurationDefaults.spaceColorProperties,
        geometricProperties: GeometricProperties = ConfigurationDefaults.spaceGeometricProperties,
        effectProperties: EffectProperties = ConfigurationDefaults.spaceEffectProperties
    ) {
        self.id = id
        self.isFocused = isFocused
        self.windows = windows
        self.colorProperties = colorProperties
        self.geometricProperties = geometricProperties
        self.effectProperties = effectProperties
    }

    /// Creates a space from a decoder.
    /// - Parameter decoder: The decoder to read from
    /// - Throws: DecodingError if the data is invalid
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        colorProperties = try container.decodeIfPresent(
            ColorProperties.self, forKey: .colorProperties
        ) ?? ConfigurationDefaults.spaceColorProperties
        geometricProperties = try container.decodeIfPresent(
            GeometricProperties.self, forKey: .geometricProperties
        ) ?? ConfigurationDefaults.spaceGeometricProperties
        effectProperties = try container.decodeIfPresent(
            EffectProperties.self, forKey: .effectProperties
        ) ?? ConfigurationDefaults.spaceEffectProperties
        isFocused = false
        windows = []
    }

    /// Custom encoder for TOML compatibility
    /// - Parameter encoder: The encoder to write to
    /// - Throws: EncodingError if the data cannot be encoded
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(colorProperties, forKey: .colorProperties)
        try container.encode(geometricProperties, forKey: .geometricProperties)
        try container.encode(effectProperties, forKey: .effectProperties)
    }
}
