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
    where
    Mode.BoolType: Codable,
    Mode.StringType: Codable,
    Mode.ThemeModeType: Codable,
    Mode.ThemePresetColorPropertiesType: Codable,
    Mode.GeometricPropertiesType: Codable,
    Mode.EffectPropertiesType: Codable,
    Mode.QuickHideTriggerKeyType: Codable
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

    /// The theme mode for visual customization.
    ///
    /// This property determines how visual themes are applied to spaces and groups.
    /// Options include preset, glass (macOS 26+ only), and custom configurations.
    public let themeMode: Mode.ThemeModeType

    /// The selected theme preset when theme mode is set to preset.
    ///
    /// This property stores the user's selected theme preset from the available
    /// predefined color schemes. Only used when themeMode is set to .preset.
    public let themePresetColorProperties: Mode.ThemePresetColorPropertiesType

    /// The geometric properties for theme preset elements.
    ///
    /// This property stores the geometric properties (corner radius, border width, etc.)
    /// used by preset theme elements. Only used when themeMode is set to .preset.
    public let themePresetGeometricProperties: Mode.GeometricPropertiesType

    /// The effect properties for theme preset elements.
    ///
    /// This property stores the effect properties (opacity, blur radius, etc.)
    /// used by preset theme elements. Only used when themeMode is set to .preset.
    public let themePresetEffectProperties: Mode.EffectPropertiesType

    /// Whether the Quick Hide feature is enabled.
    ///
    /// When enabled, holding the configured modifier key while hovering
    /// over the menu bar will temporarily hide the spaces display.
    public let quickHideEnabled: Mode.BoolType

    /// The modifier key that triggers the Quick Hide feature.
    ///
    /// Determines which modifier key must be held while hovering over the
    /// menu bar to temporarily hide the spaces display.
    public let quickHideTriggerKey: Mode.QuickHideTriggerKeyType

    /// Initializes a new GeneralSettings instance.
    ///
    /// - Parameters:
    ///   - showWindowTitles: Whether to display window titles in the menu bar
    ///   - aeroSpacePath: The file system path to the AeroSpace executable
    ///   - themeMode: The theme mode for visual customization
    ///   - themePresetColorProperties: The selected theme preset
    ///   - themePresetGeometricProperties: The geometric properties for theme preset elements
    ///   - themePresetEffectProperties: The effect properties for theme preset elements
    ///   - quickHideEnabled: Whether the Quick Hide feature is enabled
    ///   - quickHideTriggerKey: The modifier key that triggers the Quick Hide feature
    public init(
        showWindowTitles: Mode.BoolType,
        aeroSpacePath: Mode.StringType,
        themeMode: Mode.ThemeModeType,
        themePresetColorProperties: Mode.ThemePresetColorPropertiesType,
        themePresetGeometricProperties: Mode.GeometricPropertiesType,
        themePresetEffectProperties: Mode.EffectPropertiesType,
        quickHideEnabled: Mode.BoolType,
        quickHideTriggerKey: Mode.QuickHideTriggerKeyType
    ) {
        self.showWindowTitles = showWindowTitles
        self.aeroSpacePath = aeroSpacePath
        self.themeMode = themeMode
        self.themePresetColorProperties = themePresetColorProperties
        self.themePresetGeometricProperties = themePresetGeometricProperties
        self.themePresetEffectProperties = themePresetEffectProperties
        self.quickHideEnabled = quickHideEnabled
        self.quickHideTriggerKey = quickHideTriggerKey
    }

    enum CodingKeys: String, CodingKey {
        case showWindowTitles = "show-window-titles"
        case aeroSpacePath = "aerospace-path"
        case themeMode = "theme-mode"
        case themePresetColorProperties = "theme-preset"
        case themePresetGeometricProperties = "theme-preset-geometric"
        case themePresetEffectProperties = "theme-preset-effect"
        case quickHideEnabled = "quick-hide-enabled"
        case quickHideTriggerKey = "quick-hide-trigger-key"
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
            aeroSpacePath: decodedValue.aeroSpacePath ?? defaultValue.aeroSpacePath,
            themeMode: decodedValue.themeMode ?? defaultValue.themeMode,
            themePresetColorProperties: decodedValue.themePresetColorProperties ?? defaultValue
                .themePresetColorProperties,
            themePresetGeometricProperties: decodedValue.themePresetGeometricProperties ?? defaultValue
                .themePresetGeometricProperties,
            themePresetEffectProperties: decodedValue.themePresetEffectProperties ?? defaultValue
                .themePresetEffectProperties,
            quickHideEnabled: decodedValue.quickHideEnabled ?? defaultValue.quickHideEnabled,
            quickHideTriggerKey: decodedValue.quickHideTriggerKey ?? defaultValue.quickHideTriggerKey
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
