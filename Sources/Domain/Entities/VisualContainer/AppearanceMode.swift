// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Protocol for appearance mode configurations used in visual settings containers.
///
/// This protocol defines the common interface for appearance modes that control
/// how visual container entities (Groups, Spaces, etc.) are configured and displayed.
/// It provides standardized access to display names, descriptions, and configuration behavior.
public protocol AppearanceMode: CaseIterable, Equatable, RawRepresentable, Hashable, Codable, Sendable
    where
    AllCases: RandomAccessCollection,
    RawValue == String
{
    /// The localized display name for this appearance mode.
    ///
    /// This is the human-readable name shown in the UI picker controls.
    var displayName: LocalizedStringResource { get }

    /// The localized description explaining what this appearance mode does.
    ///
    /// This provides additional context to users about the behavior and
    /// effects of selecting this particular appearance mode.
    var description: LocalizedStringResource { get }

    /// Determines whether the global visual configuration should be shown for this mode.
    ///
    /// When `true`, the settings interface will display global configuration options
    /// that apply to all entities when this appearance mode is selected.
    /// When `false`, only individual entity configurations are available.
    var shouldShowGlobalConfig: Bool { get }
}
