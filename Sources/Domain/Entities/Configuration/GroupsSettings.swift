// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Groups-related configuration settings with generic optionality support.
///
/// This structure manages settings for application group display, group definitions,
/// and visual configuration. Groups allow organizing applications into logical
/// collections in the menu bar interface. Supports both optional and required
/// field variants through the `OptionalTypeMapping` protocol for flexible
/// TOML parsing and runtime usage.
public class GroupsSettings<Mode: OptionalTypeMapping>: OptionalType
    where
    Mode.BoolType: Codable,
    Mode.GroupArrayType: Codable,
    Mode.StringType: Codable,
    Mode.VisualPropertiesType: Codable
{
    /// Type alias for the optional variant used during TOML decoding.
    public typealias OptionalVariant = GroupsSettings<OptionalMode>

    /// Type alias for the required variant used during runtime operations.
    public typealias RequiredVariant = GroupsSettings<RequiredMode>

    /// Whether to show groups in the menu bar interface.
    ///
    /// When enabled, application groups are displayed in the menu bar,
    /// allowing users to organize and access applications by logical groupings.
    /// When disabled, individual applications are shown without grouping.
    public let showGroups: Mode.BoolType

    /// Array of group definitions for organizing applications.
    ///
    /// Each group contains a collection of applications that should be
    /// displayed together in the menu bar interface. Groups can have
    /// custom visual properties and behavior settings.
    public let groups: Mode.GroupArrayType

    /// The appearance mode for groups display (raw string value).
    ///
    /// Controls how groups are visually presented in the menu bar.
    /// Valid values correspond to `GroupsAppearanceMode` enum cases.
    public let groupsAppearanceMode: Mode.StringType

    /// Global visual properties applied to all groups.
    ///
    /// These properties serve as defaults for all groups unless
    /// overridden by individual group configurations. Includes
    /// settings like colors, fonts, spacing, and other visual attributes.
    public let globalGroupsVisualConfig: Mode.VisualPropertiesType

    /// Initializes a new GroupsSettings instance.
    ///
    /// - Parameters:
    ///   - showGroups: Whether to display groups in the menu bar interface
    ///   - groups: Array of group definitions for organizing applications
    ///   - groupsAppearanceMode: The appearance mode for groups display
    ///   - globalGroupsVisualConfig: Global visual properties for all groups
    public init(
        showGroups: Mode.BoolType,
        groups: Mode.GroupArrayType,
        groupsAppearanceMode: Mode.StringType,
        globalGroupsVisualConfig: Mode.VisualPropertiesType
    ) {
        self.showGroups = showGroups
        self.groups = groups
        self.groupsAppearanceMode = groupsAppearanceMode
        self.globalGroupsVisualConfig = globalGroupsVisualConfig
    }

    enum CodingKeys: String, CodingKey {
        case showGroups = "show-groups"
        case groups
        case groupsAppearanceMode = "appearance-mode"
        case globalGroupsVisualConfig = "global-visual-config"
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
    /// - Returns: A new `GroupsSettings<RequiredMode>` instance with merged values
    /// - Throws: Can throw decoding errors if the merge operation fails
    public static func decode(
        from decodedValue: GroupsSettings<OptionalMode>,
        defaultValue: GroupsSettings<RequiredMode>
    ) throws -> GroupsSettings<RequiredMode> {
        GroupsSettings<RequiredMode>(
            showGroups: decodedValue.showGroups ?? defaultValue.showGroups,
            groups: decodedValue.groups ?? defaultValue.groups,
            groupsAppearanceMode: decodedValue.groupsAppearanceMode ?? defaultValue.groupsAppearanceMode,
            globalGroupsVisualConfig: decodedValue.globalGroupsVisualConfig ?? defaultValue.globalGroupsVisualConfig
        )
    }
}

/// Extension providing type alias for OptionalMode.
public extension OptionalMode {
    /// Type alias for optional groups settings used in OptionalTypeMapping.
    typealias GroupsSettingsType = GroupsSettings<RequiredMode>?
}

/// Extension providing type alias for RequiredMode.
public extension RequiredMode {
    /// Type alias for required groups settings used in OptionalTypeMapping.
    typealias GroupsSettingsType = GroupsSettings<RequiredMode>
}
