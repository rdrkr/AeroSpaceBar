// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

// MARK: - Visual Configuration Protocols

/// Protocol for entities that have color properties capabilities.
///
/// This protocol defines the contract for entities that can be visually configured
/// through the settings interface. Conforming types must provide metadata for
/// UI presentation, a title, and visual properties that control their appearance.
///
/// The protocol extends several foundational protocols to ensure entities are
/// identifiable, persistable, comparable, and thread-safe.
public protocol VisualContainer: Identifiable, Codable, Equatable, Hashable, Sendable {
    /// The appearance mode type associated with this visual container.
    ///
    /// This defines the type of appearance mode enumeration that controls
    /// how color properties are applied to entities of this type.
    associatedtype AppearanceMode: Domain.AppearanceMode

    /// The metadata configuration for this visual container type.
    ///
    /// This property provides all the localized strings and configuration
    /// needed for the settings UI to properly display and manage entities
    /// of this type, including entity names, reset functionality text,
    /// and navigation context.
    static var metadata: VisualContainerMetadata { get }

    /// The title of the container.
    ///
    /// This is the user-facing name or identifier for this specific
    /// container instance (e.g., "Group 1", "Space A").
    var title: String { get set }

    /// The color properties for the container.
    ///
    /// This contains all the color properties that control how this
    /// container appears in the interface, including background, border,
    /// and foreground colors.
    var colorProperties: ColorProperties { get set }

    /// The geometric properties for the container.
    ///
    /// This contains all the geometric properties that control the
    /// shape and dimensions of this container, including corner radius
    /// and border width.
    var geometricProperties: GeometricProperties { get set }

    /// The effect properties for the container.
    ///
    /// This contains all the visual effect properties that control
    /// how this container's effects appear, including opacity and
    /// blur radius values.
    var effectProperties: EffectProperties { get set }
}
