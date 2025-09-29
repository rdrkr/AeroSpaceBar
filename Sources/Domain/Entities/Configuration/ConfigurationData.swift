// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Generic data structure for TOML configuration file operations.
///
/// This structure serves as the root container for all application configuration settings,
/// supporting both parsing (with optional fields) and saving (with required fields)
/// through the OptionalTypeMapping protocol. The Mode parameter determines whether
/// fields are optional (for TOML parsing) or required (for runtime usage).
///
/// The structure organizes configuration into logical sections:
/// - General: Basic application settings and paths
/// - Spaces: AeroSpace workspace display and visual configuration
/// - Groups: Application grouping and organization settings
/// - Advanced: Performance, debugging, and interaction options
public class ConfigurationData<Mode: OptionalTypeMapping>: OptionalType
    where
    Mode.GeneralSettingsType: Codable,
    Mode.SpacesSettingsType: Codable,
    Mode.GroupsSettingsType: Codable,
    Mode.AdvancedSettingsType: Codable
{
    /// Type alias for the optional variant used during TOML decoding.
    public typealias OptionalVariant = ConfigurationData<OptionalMode>

    /// Type alias for the required variant used during runtime operations.
    public typealias RequiredVariant = ConfigurationData<RequiredMode>

    /// General application settings including window display options and executable paths.
    public let general: Mode.GeneralSettingsType

    /// Spaces-related configuration for AeroSpace workspace display and visual properties.
    public let spaces: Mode.SpacesSettingsType

    /// Groups configuration for organizing applications into logical collections.
    public let groups: Mode.GroupsSettingsType

    /// Advanced settings including performance optimizations and debugging options.
    public let advanced: Mode.AdvancedSettingsType

    /// Initializes a new ConfigurationData instance.
    ///
    /// - Parameters:
    ///   - general: General application settings
    ///   - spaces: Spaces-related configuration settings
    ///   - groups: Groups configuration settings
    ///   - advanced: Advanced application settings
    public init(
        general: Mode.GeneralSettingsType,
        spaces: Mode.SpacesSettingsType,
        groups: Mode.GroupsSettingsType,
        advanced: Mode.AdvancedSettingsType
    ) {
        self.general = general
        self.spaces = spaces
        self.groups = groups
        self.advanced = advanced
    }

    enum CodingKeys: String, CodingKey {
        case general
        case spaces
        case groups
        case advanced
    }

    /// Decodes optional settings and merges with required defaults.
    ///
    /// This method implements the `OptionalType` protocol requirement, providing
    /// a way to merge optional TOML configuration data with required default values.
    /// Each configuration section is merged independently, with nil sections falling
    /// back to their corresponding default values.
    ///
    /// - Parameters:
    ///   - decodedValue: The optional configuration data decoded from TOML
    ///   - defaultValue: The required default configuration data
    /// - Returns: A new `ConfigurationData<RequiredMode>` instance with merged values
    /// - Throws: Can throw decoding errors if the merge operation fails
    public static func decode(
        from decodedValue: ConfigurationData<OptionalMode>,
        defaultValue: ConfigurationData<RequiredMode>
    ) throws -> ConfigurationData<RequiredMode> {
        ConfigurationData<RequiredMode>(
            general: decodedValue.general ?? defaultValue.general,
            spaces: decodedValue.spaces ?? defaultValue.spaces,
            groups: decodedValue.groups ?? defaultValue.groups,
            advanced: decodedValue.advanced ?? defaultValue.advanced
        )
    }
}

/// Extension providing type alias for OptionalMode.
public extension OptionalMode {
    /// Type alias for optional configuration data used in OptionalTypeMapping.
    typealias ConfigurationDataType = ConfigurationData<RequiredMode>?
}

/// Extension providing type alias for RequiredMode.
public extension RequiredMode {
    /// Type alias for required configuration data used in OptionalTypeMapping.
    typealias ConfigurationDataType = ConfigurationData<RequiredMode>
}
