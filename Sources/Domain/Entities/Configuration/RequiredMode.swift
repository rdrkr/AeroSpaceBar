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
    public typealias VisualPropertiesArrayType = [VisualProperties]
    public typealias GroupArrayType = [Domain.Group]
    public typealias VisualPropertiesType = VisualProperties
}
