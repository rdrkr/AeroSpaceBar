// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Phantom type for required configuration mode.
///
/// This type represents configuration data where all fields are required,
/// typically used when saving TOML files where all values must be present.
/// Works with the OptionalTypeMapping protocol to provide type safety.
public struct RequiredMode: OptionalTypeMapping {
    public typealias BoolType = Bool
    public typealias StringType = String
    public typealias ThemeModeType = ThemeMode
    public typealias ThemePresetColorPropertiesType = ThemePresetColorProperties
    public typealias ColorPropertiesArrayType = [ColorProperties]
    public typealias GeometricPropertiesArrayType = [GeometricProperties]
    public typealias EffectPropertiesArrayType = [EffectProperties]
    public typealias GroupArrayType = [Domain.Group]
    public typealias ColorPropertiesType = ColorProperties
    public typealias GeometricPropertiesType = GeometricProperties
    public typealias EffectPropertiesType = EffectProperties
    public typealias QuickHideTriggerKeyType = QuickHideTriggerKey
}
