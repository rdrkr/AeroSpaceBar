// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Nimble
import XCTest

/// Tests for VisualContainerMetadata struct.
///
/// These tests verify metadata configuration for visual container entities,
/// including localization strings, UI configuration, and entity management settings.
@MainActor
final class VisualContainerMetadataTests: XCTestCase {
    // MARK: - Initialization Tests

    func testBasicInitialization() {
        // Given metadata parameters
        let metadata = VisualContainerMetadata(
            entityName: "Space",
            entityNamePlural: "Spaces",
            tagPrefix: "space",
            canAddEntities: true,
            canDeleteEntities: true,
            showForegroundSection: true,
            defaultGlobalColorProperties: ConfigurationDefaults.spaceColorProperties,
            defaultGlobalEffectProperties: EffectProperties(),
            defaultGlobalGeometricProperties: GeometricProperties(),
            canDeleteEntity: { _ in true },
            footerText: "Test footer",
            resetAlertTitle: "Reset",
            resetAlertMessage: "Are you sure?",
            resetButtonTitle: "Reset",
            resetButtonDescription: "Reset to defaults"
        )

        // Then all properties should be set
        expect(metadata.entityName) == "Space"
        expect(metadata.entityNamePlural) == "Spaces"
        expect(metadata.tagPrefix) == "space"
        expect(metadata.canAddEntities) == true
        expect(metadata.canDeleteEntities) == true
        expect(metadata.showForegroundSection) == true
        expect(metadata.footerText) == "Test footer"
        expect(metadata.resetAlertTitle) == "Reset"
        expect(metadata.resetAlertMessage) == "Are you sure?"
        expect(metadata.resetButtonTitle) == "Reset"
        expect(metadata.resetButtonDescription) == "Reset to defaults"
    }

    func testInitializationWithDefaultThemeProperties() {
        // Given metadata with default theme properties
        let metadata = VisualContainerMetadata(
            entityName: "Group",
            entityNamePlural: "Groups",
            tagPrefix: "group",
            canAddEntities: false,
            canDeleteEntities: false,
            showForegroundSection: false,
            defaultGlobalColorProperties: ConfigurationDefaults.spaceColorProperties,
            defaultGlobalEffectProperties: EffectProperties(),
            defaultGlobalGeometricProperties: GeometricProperties(),
            // defaultThemeGeometricProperties uses ConfigurationDefaults
            // defaultThemeEffectProperties uses ConfigurationDefaults
            canDeleteEntity: { _ in false },
            footerText: "",
            resetAlertTitle: "",
            resetAlertMessage: "",
            resetButtonTitle: "",
            resetButtonDescription: ""
        )

        // Then should use configuration defaults for theme properties
        expect(metadata.defaultThemeGeometricProperties) == ConfigurationDefaults.themePresetGeometricProperties
        expect(metadata.defaultThemeEffectProperties) == ConfigurationDefaults.themePresetEffectProperties
    }

    // MARK: - Entity Name Tests

    func testEntityNameSingularAndPlural() {
        // Given metadata with different singular/plural names
        let spaceMeta = VisualContainerMetadata(
            entityName: "Space",
            entityNamePlural: "Spaces",
            tagPrefix: "space",
            canAddEntities: true,
            canDeleteEntities: true,
            showForegroundSection: true,
            defaultGlobalColorProperties: ConfigurationDefaults.spaceColorProperties,
            defaultGlobalEffectProperties: EffectProperties(),
            defaultGlobalGeometricProperties: GeometricProperties(),
            canDeleteEntity: { _ in true },
            footerText: "",
            resetAlertTitle: "",
            resetAlertMessage: "",
            resetButtonTitle: "",
            resetButtonDescription: ""
        )

        // Then should maintain distinct names
        expect(spaceMeta.entityName) == "Space"
        expect(spaceMeta.entityNamePlural) == "Spaces"
        expect(spaceMeta.entityName) != spaceMeta.entityNamePlural
    }

    // MARK: - UI Configuration Tests

    func testTagPrefixForUITesting() {
        // Given metadata with tag prefix
        let metadata = VisualContainerMetadata(
            entityName: "Test",
            entityNamePlural: "Tests",
            tagPrefix: "test-entity",
            canAddEntities: true,
            canDeleteEntities: true,
            showForegroundSection: true,
            defaultGlobalColorProperties: ConfigurationDefaults.spaceColorProperties,
            defaultGlobalEffectProperties: EffectProperties(),
            defaultGlobalGeometricProperties: GeometricProperties(),
            canDeleteEntity: { _ in true },
            footerText: "",
            resetAlertTitle: "",
            resetAlertMessage: "",
            resetButtonTitle: "",
            resetButtonDescription: ""
        )

        // Then tag prefix should be set
        expect(metadata.tagPrefix) == "test-entity"
    }

    func testShowForegroundSectionFlag() {
        // Given metadata with foreground section enabled
        let metadataWithForeground = VisualContainerMetadata(
            entityName: "Test",
            entityNamePlural: "Tests",
            tagPrefix: "test",
            canAddEntities: true,
            canDeleteEntities: true,
            showForegroundSection: true,
            defaultGlobalColorProperties: ConfigurationDefaults.spaceColorProperties,
            defaultGlobalEffectProperties: EffectProperties(),
            defaultGlobalGeometricProperties: GeometricProperties(),
            canDeleteEntity: { _ in true },
            footerText: "",
            resetAlertTitle: "",
            resetAlertMessage: "",
            resetButtonTitle: "",
            resetButtonDescription: ""
        )

        // And metadata with foreground section disabled
        let metadataWithoutForeground = VisualContainerMetadata(
            entityName: "Test",
            entityNamePlural: "Tests",
            tagPrefix: "test",
            canAddEntities: true,
            canDeleteEntities: true,
            showForegroundSection: false,
            defaultGlobalColorProperties: ConfigurationDefaults.spaceColorProperties,
            defaultGlobalEffectProperties: EffectProperties(),
            defaultGlobalGeometricProperties: GeometricProperties(),
            canDeleteEntity: { _ in true },
            footerText: "",
            resetAlertTitle: "",
            resetAlertMessage: "",
            resetButtonTitle: "",
            resetButtonDescription: ""
        )

        // Then flags should be correctly set
        expect(metadataWithForeground.showForegroundSection) == true
        expect(metadataWithoutForeground.showForegroundSection) == false
    }

    // MARK: - Entity Management Tests

    func testCanAddEntitiesFlag() {
        // Given metadata with add enabled
        let canAdd = VisualContainerMetadata(
            entityName: "Test",
            entityNamePlural: "Tests",
            tagPrefix: "test",
            canAddEntities: true,
            canDeleteEntities: false,
            showForegroundSection: true,
            defaultGlobalColorProperties: ConfigurationDefaults.spaceColorProperties,
            defaultGlobalEffectProperties: EffectProperties(),
            defaultGlobalGeometricProperties: GeometricProperties(),
            canDeleteEntity: { _ in true },
            footerText: "",
            resetAlertTitle: "",
            resetAlertMessage: "",
            resetButtonTitle: "",
            resetButtonDescription: ""
        )

        // And metadata with add disabled
        let cannotAdd = VisualContainerMetadata(
            entityName: "Test",
            entityNamePlural: "Tests",
            tagPrefix: "test",
            canAddEntities: false,
            canDeleteEntities: true,
            showForegroundSection: true,
            defaultGlobalColorProperties: ConfigurationDefaults.spaceColorProperties,
            defaultGlobalEffectProperties: EffectProperties(),
            defaultGlobalGeometricProperties: GeometricProperties(),
            canDeleteEntity: { _ in true },
            footerText: "",
            resetAlertTitle: "",
            resetAlertMessage: "",
            resetButtonTitle: "",
            resetButtonDescription: ""
        )

        // Then flags should be correctly set
        expect(canAdd.canAddEntities) == true
        expect(cannotAdd.canAddEntities) == false
    }

    func testCanDeleteEntitiesFlag() {
        // Given metadata with delete enabled
        let canDelete = VisualContainerMetadata(
            entityName: "Test",
            entityNamePlural: "Tests",
            tagPrefix: "test",
            canAddEntities: false,
            canDeleteEntities: true,
            showForegroundSection: true,
            defaultGlobalColorProperties: ConfigurationDefaults.spaceColorProperties,
            defaultGlobalEffectProperties: EffectProperties(),
            defaultGlobalGeometricProperties: GeometricProperties(),
            canDeleteEntity: { _ in true },
            footerText: "",
            resetAlertTitle: "",
            resetAlertMessage: "",
            resetButtonTitle: "",
            resetButtonDescription: ""
        )

        // And metadata with delete disabled
        let cannotDelete = VisualContainerMetadata(
            entityName: "Test",
            entityNamePlural: "Tests",
            tagPrefix: "test",
            canAddEntities: true,
            canDeleteEntities: false,
            showForegroundSection: true,
            defaultGlobalColorProperties: ConfigurationDefaults.spaceColorProperties,
            defaultGlobalEffectProperties: EffectProperties(),
            defaultGlobalGeometricProperties: GeometricProperties(),
            canDeleteEntity: { _ in false },
            footerText: "",
            resetAlertTitle: "",
            resetAlertMessage: "",
            resetButtonTitle: "",
            resetButtonDescription: ""
        )

        // Then flags should be correctly set
        expect(canDelete.canDeleteEntities) == true
        expect(cannotDelete.canDeleteEntities) == false
    }

    // MARK: - Entity Validation Tests

    func testCanDeleteEntityClosure() {
        // Given metadata with validation closure
        let metadata = VisualContainerMetadata(
            entityName: "Test",
            entityNamePlural: "Tests",
            tagPrefix: "test",
            canAddEntities: true,
            canDeleteEntities: true,
            showForegroundSection: true,
            defaultGlobalColorProperties: ConfigurationDefaults.spaceColorProperties,
            defaultGlobalEffectProperties: EffectProperties(),
            defaultGlobalGeometricProperties: GeometricProperties(),
            canDeleteEntity: { entity in
                // Custom validation logic
                (entity as? Group)?.id != 0
            },
            footerText: "",
            resetAlertTitle: "",
            resetAlertMessage: "",
            resetButtonTitle: "",
            resetButtonDescription: ""
        )

        // When checking if entities can be deleted
        let deletableEntity = Group(
            id: 1,
            startIndex: 1,
            endIndex: 5,
            colorProperties: ConfigurationDefaults.groupsGlobalColorProperties,
            geometricProperties: GeometricProperties(),
            effectProperties: EffectProperties()
        )
        let protectedEntity = Group(
            id: 0,
            startIndex: 1,
            endIndex: 5,
            colorProperties: ConfigurationDefaults.groupsGlobalColorProperties,
            geometricProperties: GeometricProperties(),
            effectProperties: EffectProperties()
        )

        // Then closure should be called correctly
        expect(metadata.canDeleteEntity(deletableEntity)) == true
        expect(metadata.canDeleteEntity(protectedEntity)) == false
    }

    // MARK: - Default Properties Tests

    func testDefaultGlobalColorProperties() {
        // Given metadata with custom color properties
        let customColor = ColorProperties(
            backgroundTintColor: .red,
            borderTintColor: .blue,
            foregroundColor: .white
        )

        let metadata = VisualContainerMetadata(
            entityName: "Test",
            entityNamePlural: "Tests",
            tagPrefix: "test",
            canAddEntities: true,
            canDeleteEntities: true,
            showForegroundSection: true,
            defaultGlobalColorProperties: customColor,
            defaultGlobalEffectProperties: EffectProperties(),
            defaultGlobalGeometricProperties: GeometricProperties(),
            canDeleteEntity: { _ in true },
            footerText: "",
            resetAlertTitle: "",
            resetAlertMessage: "",
            resetButtonTitle: "",
            resetButtonDescription: ""
        )

        // Then should use custom color properties
        expect(metadata.defaultGlobalColorProperties) == customColor
        expect(metadata.defaultGlobalColorProperties.backgroundTintColor) == .red
        expect(metadata.defaultGlobalColorProperties.borderTintColor) == .blue
        expect(metadata.defaultGlobalColorProperties.foregroundColor) == .white
    }

    func testDefaultGlobalGeometricProperties() {
        // Given metadata with custom geometric properties
        let customGeometric = GeometricProperties(cornerRadius: 10, borderWidth: 2)

        let metadata = VisualContainerMetadata(
            entityName: "Test",
            entityNamePlural: "Tests",
            tagPrefix: "test",
            canAddEntities: true,
            canDeleteEntities: true,
            showForegroundSection: true,
            defaultGlobalColorProperties: ConfigurationDefaults.spaceColorProperties,
            defaultGlobalEffectProperties: EffectProperties(),
            defaultGlobalGeometricProperties: customGeometric,
            canDeleteEntity: { _ in true },
            footerText: "",
            resetAlertTitle: "",
            resetAlertMessage: "",
            resetButtonTitle: "",
            resetButtonDescription: ""
        )

        // Then should use custom geometric properties
        expect(metadata.defaultGlobalGeometricProperties) == customGeometric
        expect(metadata.defaultGlobalGeometricProperties.cornerRadius) == 10
        expect(metadata.defaultGlobalGeometricProperties.borderWidth) == 2
    }

    func testDefaultGlobalEffectProperties() {
        // Given metadata with custom effect properties
        let customEffect = EffectProperties(backgroundOpacity: 0.5, backgroundBlurRadius: 10, borderOpacity: 0.9)

        let metadata = VisualContainerMetadata(
            entityName: "Test",
            entityNamePlural: "Tests",
            tagPrefix: "test",
            canAddEntities: true,
            canDeleteEntities: true,
            showForegroundSection: true,
            defaultGlobalColorProperties: ConfigurationDefaults.spaceColorProperties,
            defaultGlobalEffectProperties: customEffect,
            defaultGlobalGeometricProperties: GeometricProperties(),
            canDeleteEntity: { _ in true },
            footerText: "",
            resetAlertTitle: "",
            resetAlertMessage: "",
            resetButtonTitle: "",
            resetButtonDescription: ""
        )

        // Then should use custom effect properties
        expect(metadata.defaultGlobalEffectProperties) == customEffect
        expect(metadata.defaultGlobalEffectProperties.backgroundOpacity) == 0.5
        expect(metadata.defaultGlobalEffectProperties.backgroundBlurRadius) == 10
        expect(metadata.defaultGlobalEffectProperties.borderOpacity) == 0.9
    }

    // MARK: - UI Text Tests

    func testFooterText() {
        // Given metadata with footer text
        let footerText = "Swipe to delete items"
        let metadata = VisualContainerMetadata(
            entityName: "Test",
            entityNamePlural: "Tests",
            tagPrefix: "test",
            canAddEntities: true,
            canDeleteEntities: true,
            showForegroundSection: true,
            defaultGlobalColorProperties: ConfigurationDefaults.spaceColorProperties,
            defaultGlobalEffectProperties: EffectProperties(),
            defaultGlobalGeometricProperties: GeometricProperties(),
            canDeleteEntity: { _ in true },
            footerText: footerText,
            resetAlertTitle: "",
            resetAlertMessage: "",
            resetButtonTitle: "",
            resetButtonDescription: ""
        )

        // Then should have correct footer text
        expect(metadata.footerText) == footerText
    }

    func testResetAlertConfiguration() {
        // Given metadata with reset alert configuration
        let title = "Reset Settings"
        let message = "This action cannot be undone"
        let metadata = VisualContainerMetadata(
            entityName: "Test",
            entityNamePlural: "Tests",
            tagPrefix: "test",
            canAddEntities: true,
            canDeleteEntities: true,
            showForegroundSection: true,
            defaultGlobalColorProperties: ConfigurationDefaults.spaceColorProperties,
            defaultGlobalEffectProperties: EffectProperties(),
            defaultGlobalGeometricProperties: GeometricProperties(),
            canDeleteEntity: { _ in true },
            footerText: "",
            resetAlertTitle: title,
            resetAlertMessage: message,
            resetButtonTitle: "Reset",
            resetButtonDescription: "Reset to defaults"
        )

        // Then should have correct alert configuration
        expect(metadata.resetAlertTitle) == title
        expect(metadata.resetAlertMessage) == message
    }

    func testResetButtonConfiguration() {
        // Given metadata with reset button configuration
        let title = "Reset All"
        let description = "Restore factory defaults"
        let metadata = VisualContainerMetadata(
            entityName: "Test",
            entityNamePlural: "Tests",
            tagPrefix: "test",
            canAddEntities: true,
            canDeleteEntities: true,
            showForegroundSection: true,
            defaultGlobalColorProperties: ConfigurationDefaults.spaceColorProperties,
            defaultGlobalEffectProperties: EffectProperties(),
            defaultGlobalGeometricProperties: GeometricProperties(),
            canDeleteEntity: { _ in true },
            footerText: "",
            resetAlertTitle: "",
            resetAlertMessage: "",
            resetButtonTitle: title,
            resetButtonDescription: description
        )

        // Then should have correct button configuration
        expect(metadata.resetButtonTitle) == title
        expect(metadata.resetButtonDescription) == description
    }

    // MARK: - Sendable Conformance Tests

    func testSendableConformance() {
        // Given metadata struct
        // Then should be Sendable
        func requiresSendable(_: some Sendable) { }
        let metadata = VisualContainerMetadata(
            entityName: "Test",
            entityNamePlural: "Tests",
            tagPrefix: "test",
            canAddEntities: true,
            canDeleteEntities: true,
            showForegroundSection: true,
            defaultGlobalColorProperties: ConfigurationDefaults.spaceColorProperties,
            defaultGlobalEffectProperties: EffectProperties(),
            defaultGlobalGeometricProperties: GeometricProperties(),
            canDeleteEntity: { _ in true },
            footerText: "",
            resetAlertTitle: "",
            resetAlertMessage: "",
            resetButtonTitle: "",
            resetButtonDescription: ""
        )

        requiresSendable(metadata)
    }
}
