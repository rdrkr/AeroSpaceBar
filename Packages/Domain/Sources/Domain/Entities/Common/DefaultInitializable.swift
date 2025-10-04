// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

/// A simple protocol for default initializable types.
public protocol DefaultInitializable: Sendable {
    init()
}

/// The types which conform to have a default initializer.
extension Array: DefaultInitializable { }
extension Bool: DefaultInitializable { }
extension Dictionary: DefaultInitializable { }
extension Double: DefaultInitializable { }
extension Float: DefaultInitializable { }
extension Int: DefaultInitializable { }
extension String: DefaultInitializable { }
