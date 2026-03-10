// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Spaces-related configuration settings with generic optionality support.
///
/// This structure manages settings for AeroSpace workspace display, color properties,
/// and appearance modes. Spaces represent virtual workspaces in the AeroSpace window
/// manager, and these settings control how they appear in the menu bar interface.
/// Supports both optional and required field variants through the `OptionalTypeMapping`
/// protocol for flexible TOML parsing and runtime usage.
public class SpacesSettings<Mode: OptionalTypeMapping>: OptionalType
    where
    Mode.BoolType: Codable,
    Mode.ColorPropertiesArrayType: Codable,
    Mode.GeometricPropertiesArrayType: Codable,
    Mode.EffectPropertiesArrayType: Codable,
    Mode.StringType: Codable,
    Mode.ColorPropertiesType: Codable,
    Mode.GeometricPropertiesType: Codable,
    Mode.EffectPropertiesType: Codable
{
    /// Type alias for the optional variant used during TOML decoding.
    public typealias OptionalVariant = SpacesSettings<OptionalMode>

    /// Type alias for the required variant used during runtime operations.
    public typealias RequiredVariant = SpacesSettings<RequiredMode>

    /// Whether to show empty spaces in the menu bar interface.
    ///
    /// When enabled, spaces without any windows are still displayed in the menu bar,
    /// allowing users to see and interact with all available workspaces.
    /// When disabled, only spaces containing windows are shown.
    public let showEmptySpaces: Mode.BoolType

    /// Array of visual properties for individual spaces.
    ///
    /// Each space can have custom visual properties that override the global
    /// configuration. This array allows fine-grained control over how
    /// individual spaces appear in the menu bar interface.
    public let spacesColorProperties: Mode.ColorPropertiesArrayType

    /// Array of geometric properties for individual spaces.
    ///
    /// Each space can have custom geometric properties that override the global
    /// configuration. This array allows fine-grained control over geometry settings
    /// like corner radius and border width for individual spaces.
    public let spacesGeometricProperties: Mode.GeometricPropertiesArrayType

    /// Array of effect properties for individual spaces.
    ///
    /// Each space can have custom effect properties that override the global
    /// configuration. This array allows fine-grained control over effect settings
    /// like opacity and blur radius for individual spaces.
    public let spacesEffectProperties: Mode.EffectPropertiesArrayType

    /// The appearance mode for spaces display (raw string value).
    ///
    /// Controls how spaces are visually presented in the menu bar.
    /// Valid values correspond to `SpacesAppearanceMode` enum cases.
    public let spacesAppearanceMode: Mode.StringType

    /// Global visual properties applied to all spaces.
    ///
    /// These properties serve as defaults for all spaces unless
    /// overridden by individual space configurations. Includes
    /// settings like colors, fonts, spacing, and other visual attributes.
    public let globalSpacesColorProperties: Mode.ColorPropertiesType

    /// Global geometric properties applied to all spaces.
    ///
    /// These properties serve as defaults for all spaces unless
    /// overridden by individual space configurations. Includes
    /// settings like corner radius and border width.
    public let globalSpacesGeometricProperties: Mode.GeometricPropertiesType

    /// Global effect properties applied to all spaces.
    ///
    /// These properties serve as defaults for all spaces unless
    /// overridden by individual space configurations. Includes
    /// settings like opacity and blur radius.
    public let globalSpacesEffectProperties: Mode.EffectPropertiesType

    /// Whether to show the Apple Button as a space background.
    ///
    /// When enabled, a background is rendered behind the macOS Apple menu icon
    /// using the same visual system as spaces.
    public let showAppleButtonAsSpace: Mode.BoolType

    /// The color properties for the Apple Button space element.
    public let appleButtonColorProperties: Mode.ColorPropertiesType

    /// The geometric properties for the Apple Button space element.
    public let appleButtonGeometricProperties: Mode.GeometricPropertiesType

    /// The effect properties for the Apple Button space element.
    public let appleButtonEffectProperties: Mode.EffectPropertiesType

    /// Initializes a new SpacesSettings instance.
    ///
    /// - Parameters:
    ///   - showEmptySpaces: Whether to display empty spaces in the menu bar
    ///   - spacesColorProperties: Array of visual properties for individual spaces
    ///   - spacesGeometricProperties: Array of geometric properties for individual spaces
    ///   - spacesEffectProperties: Array of effect properties for individual spaces
    ///   - spacesAppearanceMode: The appearance mode for spaces display
    ///   - globalSpacesColorProperties: Global visual properties for all spaces
    ///   - globalSpacesGeometricProperties: Global geometric properties for all spaces
    ///   - globalSpacesEffectProperties: Global effect properties for all spaces
    ///   - showAppleButtonAsSpace: Whether to show the Apple Button as a space background
    ///   - appleButtonColorProperties: Color properties for the Apple Button
    ///   - appleButtonGeometricProperties: Geometric properties for the Apple Button
    ///   - appleButtonEffectProperties: Effect properties for the Apple Button
    public init(
        showEmptySpaces: Mode.BoolType,
        spacesColorProperties: Mode.ColorPropertiesArrayType,
        spacesGeometricProperties: Mode.GeometricPropertiesArrayType,
        spacesEffectProperties: Mode.EffectPropertiesArrayType,
        spacesAppearanceMode: Mode.StringType,
        globalSpacesColorProperties: Mode.ColorPropertiesType,
        globalSpacesGeometricProperties: Mode.GeometricPropertiesType,
        globalSpacesEffectProperties: Mode.EffectPropertiesType,
        showAppleButtonAsSpace: Mode.BoolType,
        appleButtonColorProperties: Mode.ColorPropertiesType,
        appleButtonGeometricProperties: Mode.GeometricPropertiesType,
        appleButtonEffectProperties: Mode.EffectPropertiesType
    ) {
        self.showEmptySpaces = showEmptySpaces
        self.spacesColorProperties = spacesColorProperties
        self.spacesGeometricProperties = spacesGeometricProperties
        self.spacesEffectProperties = spacesEffectProperties
        self.spacesAppearanceMode = spacesAppearanceMode
        self.globalSpacesColorProperties = globalSpacesColorProperties
        self.globalSpacesGeometricProperties = globalSpacesGeometricProperties
        self.globalSpacesEffectProperties = globalSpacesEffectProperties
        self.showAppleButtonAsSpace = showAppleButtonAsSpace
        self.appleButtonColorProperties = appleButtonColorProperties
        self.appleButtonGeometricProperties = appleButtonGeometricProperties
        self.appleButtonEffectProperties = appleButtonEffectProperties
    }

    enum CodingKeys: String, CodingKey {
        case showEmptySpaces = "show-empty-spaces"
        case spacesColorProperties = "visual-config"
        case spacesGeometricProperties = "geometric-config"
        case spacesEffectProperties = "effect-config"
        case spacesAppearanceMode = "appearance-mode"
        case globalSpacesColorProperties = "global-visual-config"
        case globalSpacesGeometricProperties = "global-geometric-config"
        case globalSpacesEffectProperties = "global-effect-config"
        case showAppleButtonAsSpace = "show-apple-button-as-space"
        case appleButtonColorProperties = "apple-button-visual-config"
        case appleButtonGeometricProperties = "apple-button-geometric-config"
        case appleButtonEffectProperties = "apple-button-effect-config"
    }

    /// Decodes optional settings and merges with required defaults.
    ///
    /// This method implements the `OptionalType` protocol requirement, providing
    /// a way to merge optional TOML configuration data with required default values.
    /// For each property, if the decoded value is nil, the corresponding default value is used.
    ///
    /// - Parameters:
    ///   - decodedValue: The optional settings decoded from TOML configuration
    ///   - defaultValue: The required default settings to use for nil values
    /// - Returns: A new `SpacesSettings<RequiredMode>` instance with merged values
    /// - Throws: Can throw decoding errors if the merge operation fails
    public static func decode(
        from decodedValue: SpacesSettings<OptionalMode>,
        defaultValue: SpacesSettings<RequiredMode>
    ) throws -> SpacesSettings<RequiredMode> {
        SpacesSettings<RequiredMode>(
            showEmptySpaces: decodedValue.showEmptySpaces ?? defaultValue.showEmptySpaces,
            spacesColorProperties: decodedValue.spacesColorProperties ?? defaultValue.spacesColorProperties,
            spacesGeometricProperties: decodedValue.spacesGeometricProperties ?? defaultValue
                .spacesGeometricProperties,
            spacesEffectProperties: decodedValue.spacesEffectProperties ?? defaultValue.spacesEffectProperties,
            spacesAppearanceMode: decodedValue.spacesAppearanceMode ?? defaultValue.spacesAppearanceMode,
            globalSpacesColorProperties: decodedValue.globalSpacesColorProperties ?? defaultValue
                .globalSpacesColorProperties,
            globalSpacesGeometricProperties: decodedValue.globalSpacesGeometricProperties ?? defaultValue
                .globalSpacesGeometricProperties,
            globalSpacesEffectProperties: decodedValue.globalSpacesEffectProperties ?? defaultValue
                .globalSpacesEffectProperties,
            showAppleButtonAsSpace: decodedValue.showAppleButtonAsSpace ?? defaultValue.showAppleButtonAsSpace,
            appleButtonColorProperties: decodedValue.appleButtonColorProperties ?? defaultValue
                .appleButtonColorProperties,
            appleButtonGeometricProperties: decodedValue.appleButtonGeometricProperties ?? defaultValue
                .appleButtonGeometricProperties,
            appleButtonEffectProperties: decodedValue.appleButtonEffectProperties ?? defaultValue
                .appleButtonEffectProperties
        )
    }
}

/// Extension providing type alias for OptionalMode.
public extension OptionalMode {
    /// Type alias for optional spaces settings used in OptionalTypeMapping.
    typealias SpacesSettingsType = SpacesSettings<RequiredMode>?
}

/// Extension providing type alias for RequiredMode.
public extension RequiredMode {
    /// Type alias for required spaces settings used in OptionalTypeMapping.
    typealias SpacesSettingsType = SpacesSettings<RequiredMode>
}
