// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Protocol for mapping types between optional and required variants in configuration.
///
/// This protocol enables the generic optionality system by defining associated types
/// that can be either optional or required depending on the implementation.
/// Used with phantom types (OptionalMode/RequiredMode) to provide compile-time
/// type safety for configuration parsing vs saving operations.
///
/// The protocol works by allowing the same configuration structure to represent
/// both optional fields (for TOML parsing where fields may be missing) and
/// required fields (for runtime usage where all values must be present).
/// This eliminates the need for separate data structures for parsing and usage.
public protocol OptionalTypeMapping: Codable {
    /// Associated type for boolean values (Bool for required, Bool? for optional).
    associatedtype BoolType

    /// Associated type for string values (String for required, String? for optional).
    associatedtype StringType

    /// Associated type for visual properties arrays ([VisualProperties] for required, [VisualProperties]? for
    /// optional).
    associatedtype VisualPropertiesArrayType

    /// Associated type for group arrays ([Group] for required, [Group]? for optional).
    associatedtype GroupArrayType

    /// Associated type for visual properties (VisualProperties for required, VisualProperties? for optional).
    associatedtype VisualPropertiesType

    /// Associated type for general settings (GeneralSettings<RequiredMode> for required, GeneralSettings<RequiredMode>?
    /// for optional).
    associatedtype GeneralSettingsType

    /// Associated type for spaces settings (SpacesSettings<RequiredMode> for required, SpacesSettings<RequiredMode>?
    /// for optional).
    associatedtype SpacesSettingsType

    /// Associated type for groups settings (GroupsSettings<RequiredMode> for required, GroupsSettings<RequiredMode>?
    /// for optional).
    associatedtype GroupsSettingsType

    /// Associated type for advanced settings (AdvancedSettings<RequiredMode> for required,
    /// AdvancedSettings<RequiredMode>? for optional).
    associatedtype AdvancedSettingsType

    /// Associated type for configuration data (ConfigurationData<RequiredMode> for required,
    /// ConfigurationData<RequiredMode>? for optional).
    associatedtype ConfigurationDataType
}

/// Protocol for types that support optional/required dual representation.
///
/// This protocol allows configuration structures to exist in both optional
/// and required forms, enabling seamless merging of TOML configuration data
/// with default values. Types implementing this protocol must provide both
/// variants and a merge operation.
///
/// The protocol is designed to work with the `OptionalTypeMapping` system,
/// where the same logical structure can represent optional fields during
/// parsing and required fields during runtime usage.
public protocol OptionalType: Codable {
    /// The optional variant of this type, used during TOML parsing.
    ///
    /// This variant has optional fields that may be nil if not present
    /// in the configuration file.
    associatedtype OptionalVariant: OptionalType

    /// The required variant of this type, used during runtime operations.
    ///
    /// This variant has non-optional fields that are guaranteed to have
    /// values, either from configuration or from defaults.
    associatedtype RequiredVariant: OptionalType

    /// Decodes optional settings and merges with required defaults.
    ///
    /// This method provides the core functionality for merging optional
    /// configuration data with required default values. For each property,
    /// if the decoded value is nil, the corresponding default value is used.
    ///
    /// - Parameters:
    ///   - decodedValue: The optional variant decoded from TOML configuration
    ///   - defaultValue: The required default variant to use for nil values
    /// - Returns: A new required variant with merged values
    /// - Throws: Can throw decoding errors if the merge operation fails
    static func decode(
        from decodedValue: OptionalVariant,
        defaultValue: RequiredVariant
    ) throws -> RequiredVariant
}
