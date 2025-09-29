// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// General application settings with generic optionality support.
///
/// This structure manages fundamental application configuration including
/// display preferences and external tool integration. It can represent either
/// optional or required settings based on the Mode parameter, supporting both
/// TOML parsing (with optional fields) and runtime usage (with required fields).
/// Uses the `OptionalTypeMapping` protocol for type-level optionality control.
public class GeneralSettings<Mode: OptionalTypeMapping>: OptionalType
    where Mode.BoolType: Codable, Mode.StringType: Codable
{
    /// Type alias for the optional variant used during TOML decoding.
    public typealias OptionalVariant = GeneralSettings<OptionalMode>

    /// Type alias for the required variant used during runtime operations.
    public typealias RequiredVariant = GeneralSettings<RequiredMode>

    /// Whether to show window titles in the menu bar interface.
    ///
    /// When enabled, window titles are displayed alongside or instead of
    /// application icons in the menu bar, providing more context about
    /// the active windows but potentially using more space.
    public let showWindowTitles: Mode.BoolType

    /// The file system path to the AeroSpace executable.
    ///
    /// This path is used to communicate with the AeroSpace window manager
    /// for retrieving workspace and window information. The path should
    /// point to a valid AeroSpace binary installation.
    public let aeroSpacePath: Mode.StringType

    /// Initializes a new GeneralSettings instance.
    ///
    /// - Parameters:
    ///   - showWindowTitles: Whether to display window titles in the menu bar
    ///   - aeroSpacePath: The file system path to the AeroSpace executable
    public init(showWindowTitles: Mode.BoolType, aeroSpacePath: Mode.StringType) {
        self.showWindowTitles = showWindowTitles
        self.aeroSpacePath = aeroSpacePath
    }

    enum CodingKeys: String, CodingKey {
        case showWindowTitles = "show-window-titles"
        case aeroSpacePath = "aerospace-path"
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
    /// - Returns: A new `GeneralSettings<RequiredMode>` instance with merged values
    /// - Throws: Can throw decoding errors if the merge operation fails
    public static func decode(
        from decodedValue: GeneralSettings<OptionalMode>,
        defaultValue: GeneralSettings<RequiredMode>
    ) throws -> GeneralSettings<RequiredMode> {
        GeneralSettings<RequiredMode>(
            showWindowTitles: decodedValue.showWindowTitles ?? defaultValue.showWindowTitles,
            aeroSpacePath: decodedValue.aeroSpacePath ?? defaultValue.aeroSpacePath
        )
    }
}

/// Extension providing type alias for OptionalMode.
public extension OptionalMode {
    /// Type alias for optional general settings used in OptionalTypeMapping.
    typealias GeneralSettingsType = GeneralSettings<RequiredMode>?
}

/// Extension providing type alias for RequiredMode.
public extension RequiredMode {
    /// Type alias for required general settings used in OptionalTypeMapping.
    typealias GeneralSettingsType = GeneralSettings<RequiredMode>
}
