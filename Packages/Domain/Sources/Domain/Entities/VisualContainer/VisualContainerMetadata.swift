// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation

/// Metadata configuration for visual container entities.
///
/// This structure encapsulates all the localized strings and UI configuration
/// needed for displaying and managing visual container entities in the settings interface.
/// It provides a centralized way to define entity-specific metadata that drives
/// the generic visual settings container view behavior.
public struct VisualContainerMetadata: Sendable {
    // MARK: - Entity Names

    /// The singular localized name of the entity (e.g., "Group", "Space").
    public let entityName: String

    /// The plural localized name of the entities (e.g., "Groups", "Spaces").
    public let entityNamePlural: String

    // MARK: - UI Configuration

    /// The tag prefix for UI testing and identification.
    public let tagPrefix: String

    // MARK: - Entity Management Configuration

    /// Whether entities can be added by the user.
    public let canAddEntities: Bool

    /// Whether entities can be deleted by the user.
    public let canDeleteEntities: Bool

    /// Whether to show the foreground section in visual settings.
    public let showForegroundSection: Bool

    /// The default global color properties for this entity type.
    ///
    /// This configuration serves as the fallback values when entities are
    /// created or when global configurations are reset to defaults.
    public let defaultGlobalColorProperties: ColorProperties

    /// The default global effect properties for this entity type.
    ///
    /// This configuration serves as the fallback values when entities are
    /// created or when global configurations are reset to defaults.
    public let defaultGlobalEffectProperties: EffectProperties

    /// The default global geometric properties for this entity type.
    ///
    /// This configuration serves as the fallback values when entities are
    /// created or when global configurations are reset to defaults.
    public let defaultGlobalGeometricProperties: GeometricProperties

    /// The default theme effect properties for this entity type.
    ///
    /// This configuration serves as the fallback values when entities are
    /// created or when theme configurations are reset to defaults.
    public let defaultThemeEffectProperties: EffectProperties

    /// The default theme geometric properties for this entity type.
    ///
    /// This configuration serves as the fallback values when entities are
    /// created or when theme configurations are reset to defaults.
    public let defaultThemeGeometricProperties: GeometricProperties

    // MARK: - Entity Validation

    /// Function to determine if a specific entity can be deleted.
    ///
    /// This closure allows for entity-specific validation logic when determining
    /// whether an entity should allow deletion. For example, certain entities
    /// might be protected from deletion based on their state or properties.
    public let canDeleteEntity: @Sendable (any VisualContainer) -> Bool

    // MARK: - UI Text

    /// Footer text displayed in the entities list section.
    ///
    /// This text typically provides instructions on how to delete entities
    /// or other relevant usage information.
    public let footerText: String

    // MARK: - Reset Functionality

    /// The title for the reset confirmation alert dialog.
    public let resetAlertTitle: String

    /// The message displayed in the reset confirmation alert dialog.
    ///
    /// This should explain what will happen when the reset action is performed
    /// and that the action cannot be undone.
    public let resetAlertMessage: String

    /// The title for the reset button in the settings interface.
    public let resetButtonTitle: String

    /// The description text for the reset button explaining its functionality.
    public let resetButtonDescription: String

    // MARK: - Initializer

    /// Creates a new visual container metadata configuration.
    /// - Parameters:
    ///   - entityName: The singular localized name of the entity
    ///   - entityNamePlural: The plural localized name of the entities
    ///   - tagPrefix: The tag prefix for UI testing and identification
    ///   - canAddEntities: Whether entities can be added by the user
    ///   - canDeleteEntities: Whether entities can be deleted by the user
    ///   - showForegroundSection: Whether to show the foreground section in visual settings
    ///   - defaultGlobalColorProperties: The default global color properties for this entity type
    ///   - defaultGlobalGeometricProperties: The default global geometric properties for this entity type
    ///   - canDeleteEntity: Function to determine if a specific entity can be deleted
    ///   - footerText: Footer text for the entities list section
    ///   - resetAlertTitle: Title for the reset confirmation alert
    ///   - resetAlertMessage: Message for the reset confirmation alert
    ///   - resetButtonTitle: Title for the reset button
    ///   - resetButtonDescription: Description for the reset button
    public init(
        entityName: String,
        entityNamePlural: String,
        tagPrefix: String,
        canAddEntities: Bool,
        canDeleteEntities: Bool,
        showForegroundSection: Bool,
        defaultGlobalColorProperties: ColorProperties,
        defaultGlobalEffectProperties: EffectProperties,
        defaultGlobalGeometricProperties: GeometricProperties,
        defaultThemeGeometricProperties: GeometricProperties = ConfigurationDefaults.themePresetGeometricProperties,
        defaultThemeEffectProperties: EffectProperties = ConfigurationDefaults.themePresetEffectProperties,
        canDeleteEntity: @escaping @Sendable (any VisualContainer) -> Bool,
        footerText: String,
        resetAlertTitle: String,
        resetAlertMessage: String,
        resetButtonTitle: String,
        resetButtonDescription: String
    ) {
        self.entityName = entityName
        self.entityNamePlural = entityNamePlural
        self.tagPrefix = tagPrefix
        self.canAddEntities = canAddEntities
        self.canDeleteEntities = canDeleteEntities
        self.showForegroundSection = showForegroundSection
        self.defaultGlobalColorProperties = defaultGlobalColorProperties
        self.defaultGlobalEffectProperties = defaultGlobalEffectProperties
        self.defaultGlobalGeometricProperties = defaultGlobalGeometricProperties
        self.defaultThemeGeometricProperties = defaultThemeGeometricProperties
        self.defaultThemeEffectProperties = defaultThemeEffectProperties
        self.canDeleteEntity = canDeleteEntity
        self.footerText = footerText
        self.resetAlertTitle = resetAlertTitle
        self.resetAlertMessage = resetAlertMessage
        self.resetButtonTitle = resetButtonTitle
        self.resetButtonDescription = resetButtonDescription
    }
}
