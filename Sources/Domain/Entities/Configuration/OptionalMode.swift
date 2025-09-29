// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Phantom type for optional configuration mode.
///
/// This type represents configuration data where all fields are optional,
/// typically used when parsing TOML files where some fields might be missing.
/// Works with the OptionalTypeMapping protocol to provide type safety.
public struct OptionalMode: OptionalTypeMapping {
    public typealias BoolType = Bool?
    public typealias StringType = String?
    public typealias VisualPropertiesArrayType = [VisualProperties]?
    public typealias GroupArrayType = [Domain.Group]?
    public typealias VisualPropertiesType = VisualProperties?
}
