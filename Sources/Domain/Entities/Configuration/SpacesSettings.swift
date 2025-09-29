// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Spaces-related configuration settings with generic optionality support.
///
/// This structure manages settings for AeroSpace workspace display, visual configuration,
/// and appearance modes. Spaces represent virtual workspaces in the AeroSpace window
/// manager, and these settings control how they appear in the menu bar interface.
/// Supports both optional and required field variants through the `OptionalTypeMapping`
/// protocol for flexible TOML parsing and runtime usage.
public class SpacesSettings<Mode: OptionalTypeMapping>: OptionalType
    where
    Mode.BoolType: Codable,
    Mode.VisualPropertiesArrayType: Codable,
    Mode.StringType: Codable,
    Mode.VisualPropertiesType: Codable
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
    public let spacesVisualConfig: Mode.VisualPropertiesArrayType

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
    public let globalSpacesVisualConfig: Mode.VisualPropertiesType

    /// Initializes a new SpacesSettings instance.
    ///
    /// - Parameters:
    ///   - showEmptySpaces: Whether to display empty spaces in the menu bar
    ///   - spacesVisualConfig: Array of visual properties for individual spaces
    ///   - spacesAppearanceMode: The appearance mode for spaces display
    ///   - globalSpacesVisualConfig: Global visual properties for all spaces
    public init(
        showEmptySpaces: Mode.BoolType,
        spacesVisualConfig: Mode.VisualPropertiesArrayType,
        spacesAppearanceMode: Mode.StringType,
        globalSpacesVisualConfig: Mode.VisualPropertiesType
    ) {
        self.showEmptySpaces = showEmptySpaces
        self.spacesVisualConfig = spacesVisualConfig
        self.spacesAppearanceMode = spacesAppearanceMode
        self.globalSpacesVisualConfig = globalSpacesVisualConfig
    }

    enum CodingKeys: String, CodingKey {
        case showEmptySpaces = "show-empty-spaces"
        case spacesVisualConfig = "visual-config"
        case spacesAppearanceMode = "appearance-mode"
        case globalSpacesVisualConfig = "global-visual-config"
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
            spacesVisualConfig: decodedValue.spacesVisualConfig ?? defaultValue.spacesVisualConfig,
            spacesAppearanceMode: decodedValue.spacesAppearanceMode ?? defaultValue.spacesAppearanceMode,
            globalSpacesVisualConfig: decodedValue.globalSpacesVisualConfig ?? defaultValue.globalSpacesVisualConfig
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
