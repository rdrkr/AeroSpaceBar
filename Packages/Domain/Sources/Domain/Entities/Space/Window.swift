// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import AppKit
import Foundation

/// Represents a window in the system.
///
/// This struct contains information about a window including its identifier,
/// title, associated application, focus state, workspace assignment, and color properties.
public struct Window: VisualContainer {
    public typealias AppearanceMode = WindowsAppearanceMode
    /// The metadata configuration for Window entities.
    public static let metadata = VisualContainerMetadata(
        entityName: String(localized: LocalizedStringResource("Window")),
        entityNamePlural: String(localized: LocalizedStringResource("Windows")),
        tagPrefix: "windows",
        canAddEntities: false,
        canDeleteEntities: false,
        showForegroundSection: true,
        defaultGlobalColorProperties: ConfigurationDefaults.spaceColorProperties,
        defaultGlobalEffectProperties: ConfigurationDefaults.spaceEffectProperties,
        defaultGlobalGeometricProperties: ConfigurationDefaults.spaceGeometricProperties,
        canDeleteEntity: { _ in false }, // Windows cannot be deleted manually
        footerText: String(localized: LocalizedStringResource(
            "Windows are managed by the system and cannot be deleted manually."
        )),
        resetAlertTitle: String(localized: LocalizedStringResource("Reset Windows")),
        resetAlertMessage: String(localized: LocalizedStringResource(
            """
            Are you sure you want to reset all window configurations to their defaults? \
            This action cannot be undone.
            """
        )),
        resetButtonTitle: String(localized: LocalizedStringResource("Reset Windows")),
        resetButtonDescription: String(localized: LocalizedStringResource(
            "Reset all window configurations to their defaults."
        ))
    )

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

    /// The color properties for the window container.
    public var colorProperties: ColorProperties

    /// The geometric properties for the window container.
    public var geometricProperties: GeometricProperties

    /// The effect properties for the window container.
    public var effectProperties: EffectProperties

    /// Coding keys for JSON serialization.
    public enum CodingKeys: String, CodingKey {
        case id = "window-id"
        case title = "window-title"
        case appName = "app-name"
        case workspace
        case colorProperties = "visual-config"
        case geometricProperties = "geometric-config"
        case effectProperties = "effect-config"
    }

    /// Creates a window with the specified parameters.
    /// - Parameters:
    ///   - id: The unique identifier for the window
    ///   - title: The title of the window
    ///   - appName: The name of the application that owns the window
    ///   - isFocused: Whether the window is currently focused
    ///   - workspace: The workspace/space that the window belongs to
    ///   - appIcon: The application icon for the window
    ///   - colorProperties: The color properties for the window container
    ///   - geometricProperties: The geometric properties for the window container
    ///   - effectProperties: The effect properties for the window container
    public init(
        id: Int,
        title: String,
        appName: String?,
        isFocused: Bool = false,
        workspace: String?,
        appIcon: NSImage? = nil,
        colorProperties: ColorProperties = ConfigurationDefaults.spaceColorProperties,
        geometricProperties: GeometricProperties = ConfigurationDefaults.spaceGeometricProperties,
        effectProperties: EffectProperties = ConfigurationDefaults.spaceEffectProperties
    ) {
        self.id = id
        self.title = title
        self.appName = appName
        self.isFocused = isFocused
        self.workspace = workspace
        self.appIcon = appIcon
        self.colorProperties = colorProperties
        self.geometricProperties = geometricProperties
        self.effectProperties = effectProperties
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
        try container.encode(colorProperties, forKey: .colorProperties)
        try container.encode(geometricProperties, forKey: .geometricProperties)
        try container.encode(effectProperties, forKey: .effectProperties)
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
            lhs.colorProperties == rhs.colorProperties &&
            lhs.geometricProperties == rhs.geometricProperties &&
            lhs.effectProperties == rhs.effectProperties
    }
}
