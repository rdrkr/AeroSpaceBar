// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Foundation

/// A parsed AeroSpace version, used to decide which integration features are available.
///
/// AeroSpace reports versions as `MAJOR.MINOR.PATCH` optionally followed by a
/// suffix, for example `0.21.3-Beta`. Only the numeric prefix is significant
/// for capability checks; the suffix is ignored.
public struct AeroSpaceVersion: Sendable, Equatable, Comparable {
    /// The first version that supports the `subscribe` event-streaming command
    /// and the versioned socket handshake.
    public static let eventSubscriptionMinimum = Self(major: 0, minor: 21, patch: 0)

    /// The major component.
    public let major: Int

    /// The minor component.
    public let minor: Int

    /// The patch component.
    public let patch: Int

    /// Initializes a version from its numeric components.
    /// - Parameters:
    ///   - major: The major component
    ///   - minor: The minor component
    ///   - patch: The patch component
    public init(major: Int, minor: Int, patch: Int) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }

    /// Parses a version from an AeroSpace version string.
    ///
    /// Accepts a leading `MAJOR.MINOR.PATCH` triple with an optional suffix
    /// (`"0.21.3-Beta"`), tolerates a missing patch (`"0.21"`), and ignores a
    /// leading `v` (`"v0.21.3"`). Returns `nil` when no numeric prefix can be
    /// read, so callers can fall back to the conservative behaviour.
    /// - Parameter string: The version string reported by AeroSpace
    public init?(string: String?) {
        guard let string else { return nil }

        var trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.first == "v" || trimmed.first == "V" {
            trimmed.removeFirst()
        }

        // Drop any pre-release/build suffix such as "-Beta" before splitting.
        let numeric = trimmed.prefix { $0.isNumber || $0 == "." }
        let components = numeric.split(separator: ".", omittingEmptySubsequences: false).map(String.init)

        guard let major = components.first.flatMap(Int.init) else { return nil }

        self.major = major
        minor = components.count > 1 ? Int(components[1]) ?? 0 : 0
        patch = components.count > 2 ? Int(components[2]) ?? 0 : 0
    }

    /// Whether this version supports subscribing to AeroSpace events over the socket.
    public var supportsEventSubscription: Bool {
        self >= Self.eventSubscriptionMinimum
    }

    /// Orders versions by major, then minor, then patch.
    /// - Parameters:
    ///   - lhs: The left-hand version
    ///   - rhs: The right-hand version
    /// - Returns: `true` if `lhs` precedes `rhs`
    public static func < (lhs: Self, rhs: Self) -> Bool {
        (lhs.major, lhs.minor, lhs.patch) < (rhs.major, rhs.minor, rhs.patch)
    }
}
