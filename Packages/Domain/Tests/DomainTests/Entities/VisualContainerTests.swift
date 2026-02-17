// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

@testable import Domain
import Nimble
import SwiftUI
import XCTest

/// Tests for VisualContainer protocol.
///
/// These tests verify:
/// - Protocol requirements
/// - Associated type constraints
/// - Mock implementation conformance
/// - Property requirements
final class VisualContainerTests: XCTestCase {
    // MARK: - Protocol Conformance Tests

    func testConformsToIdentifiable() {
        // Given
        let container = MockVisualContainer(
            id: "test-id",
            title: "Test",
            colorProperties: ColorProperties(
                backgroundTintColor: .blue,
                borderTintColor: .white,
                foregroundColor: .primary
            ),
            geometricProperties: GeometricProperties(cornerRadius: 10, borderWidth: 2),
            effectProperties: EffectProperties(backgroundOpacity: 0.8, backgroundBlurRadius: 10, borderOpacity: 1.0)
        )

        // When/Then - Should have id property
        expect(container.id) == "test-id"
    }

    func testConformsToCodable() {
        // Given/When/Then - Should compile with Codable conformance
        let _: any VisualContainer = MockVisualContainer(
            id: "test",
            title: "Test",
            colorProperties: ColorProperties(
                backgroundTintColor: .blue,
                borderTintColor: .white,
                foregroundColor: .primary
            ),
            geometricProperties: GeometricProperties(cornerRadius: 10, borderWidth: 2),
            effectProperties: EffectProperties(backgroundOpacity: 0.8, backgroundBlurRadius: 10, borderOpacity: 1.0)
        )
    }

    func testConformsToEquatable() {
        // Given
        let container1 = MockVisualContainer(
            id: "test",
            title: "Test",
            colorProperties: ColorProperties(
                backgroundTintColor: .blue,
                borderTintColor: .white,
                foregroundColor: .primary
            ),
            geometricProperties: GeometricProperties(cornerRadius: 10, borderWidth: 2),
            effectProperties: EffectProperties(backgroundOpacity: 0.8, backgroundBlurRadius: 10, borderOpacity: 1.0)
        )
        let container2 = MockVisualContainer(
            id: "test",
            title: "Different",
            colorProperties: ColorProperties(
                backgroundTintColor: .red,
                borderTintColor: .black,
                foregroundColor: .secondary
            ),
            geometricProperties: GeometricProperties(cornerRadius: 5, borderWidth: 1),
            effectProperties: EffectProperties(backgroundOpacity: 0.5, backgroundBlurRadius: 5, borderOpacity: 0.8)
        )

        // When/Then
        expect(container1 == container2) == true
    }

    func testConformsToHashable() {
        // Given
        let container1 = MockVisualContainer(
            id: "test",
            title: "Test",
            colorProperties: ColorProperties(
                backgroundTintColor: .blue,
                borderTintColor: .white,
                foregroundColor: .primary
            ),
            geometricProperties: GeometricProperties(cornerRadius: 10, borderWidth: 2),
            effectProperties: EffectProperties(backgroundOpacity: 0.8, backgroundBlurRadius: 10, borderOpacity: 1.0)
        )
        let container2 = MockVisualContainer(
            id: "test",
            title: "Different",
            colorProperties: ColorProperties(
                backgroundTintColor: .red,
                borderTintColor: .black,
                foregroundColor: .secondary
            ),
            geometricProperties: GeometricProperties(cornerRadius: 5, borderWidth: 1),
            effectProperties: EffectProperties(backgroundOpacity: 0.5, backgroundBlurRadius: 5, borderOpacity: 0.8)
        )

        // When
        var hasher1 = Hasher()
        var hasher2 = Hasher()
        container1.hash(into: &hasher1)
        container2.hash(into: &hasher2)

        // Then
        expect(hasher1.finalize() == hasher2.finalize()) == true
    }

    func testConformsToSendable() {
        // Given/When/Then - Should compile with Sendable conformance
        Task { @MainActor in
            let container = MockVisualContainer(
                id: "test",
                title: "Test",
                colorProperties: ColorProperties(
                    backgroundTintColor: .blue,
                    borderTintColor: .white,
                    foregroundColor: .primary
                ),
                geometricProperties: GeometricProperties(cornerRadius: 10, borderWidth: 2),
                effectProperties: EffectProperties(backgroundOpacity: 0.8, backgroundBlurRadius: 10, borderOpacity: 1.0)
            )
            expect(container.id) == "test"
        }
    }

    // MARK: - Associated Type Tests

    func testAppearanceModeAssociatedType() {
        // Given/When/Then - Should have AppearanceMode associated type
        let mode: MockVisualContainer.AppearanceMode = .allEntities
        expect(mode.displayName) == "All Entities"
    }

    // MARK: - Property Tests

    func testMetadataProperty() {
        // Given/When
        let metadata = MockVisualContainer.metadata

        // Then
        expect(metadata.entityName) == "Mock"
        expect(metadata.entityNamePlural) == "Mocks"
        expect(metadata.tagPrefix) == "mock"
        expect(metadata.showForegroundSection) == true
        expect(metadata.canAddEntities) == true
        expect(metadata.canDeleteEntities) == true
    }

    func testTitleProperty() {
        // Given
        var container = MockVisualContainer(
            id: "test",
            title: "Original",
            colorProperties: ColorProperties(
                backgroundTintColor: .blue,
                borderTintColor: .white,
                foregroundColor: .primary
            ),
            geometricProperties: GeometricProperties(cornerRadius: 10, borderWidth: 2),
            effectProperties: EffectProperties(backgroundOpacity: 0.8, backgroundBlurRadius: 10, borderOpacity: 1.0)
        )

        // When
        container.title = "Updated"

        // Then
        expect(container.title) == "Updated"
    }

    func testColorPropertiesProperty() {
        // Given
        var container = MockVisualContainer(
            id: "test",
            title: "Test",
            colorProperties: ColorProperties(
                backgroundTintColor: .blue,
                borderTintColor: .white,
                foregroundColor: .primary
            ),
            geometricProperties: GeometricProperties(cornerRadius: 10, borderWidth: 2),
            effectProperties: EffectProperties(backgroundOpacity: 0.8, backgroundBlurRadius: 10, borderOpacity: 1.0)
        )

        // When
        container.colorProperties = ColorProperties(
            backgroundTintColor: .red,
            borderTintColor: .black,
            foregroundColor: .secondary
        )

        // Then
        expect(container.colorProperties.backgroundTintColor) == .red
    }

    func testGeometricPropertiesProperty() {
        // Given
        var container = MockVisualContainer(
            id: "test",
            title: "Test",
            colorProperties: ColorProperties(
                backgroundTintColor: .blue,
                borderTintColor: .white,
                foregroundColor: .primary
            ),
            geometricProperties: GeometricProperties(cornerRadius: 10, borderWidth: 2),
            effectProperties: EffectProperties(backgroundOpacity: 0.8, backgroundBlurRadius: 10, borderOpacity: 1.0)
        )

        // When
        container.geometricProperties = GeometricProperties(cornerRadius: 5, borderWidth: 1)

        // Then
        expect(container.geometricProperties.cornerRadius) == 5
    }

    func testEffectPropertiesProperty() {
        // Given
        var container = MockVisualContainer(
            id: "test",
            title: "Test",
            colorProperties: ColorProperties(
                backgroundTintColor: .blue,
                borderTintColor: .white,
                foregroundColor: .primary
            ),
            geometricProperties: GeometricProperties(cornerRadius: 10, borderWidth: 2),
            effectProperties: EffectProperties(backgroundOpacity: 0.8, backgroundBlurRadius: 10, borderOpacity: 1.0)
        )

        // When
        container.effectProperties = EffectProperties(
            backgroundOpacity: 0.5,
            backgroundBlurRadius: 5,
            borderOpacity: 0.8
        )

        // Then
        expect(container.effectProperties.backgroundOpacity) == 0.5
    }

    // MARK: - Protocol Extension Tests

    func testVisualContainerProtocolUsage() {
        // Given
        let container: any VisualContainer = MockVisualContainer(
            id: "test",
            title: "Test",
            colorProperties: ColorProperties(
                backgroundTintColor: .blue,
                borderTintColor: .white,
                foregroundColor: .primary
            ),
            geometricProperties: GeometricProperties(cornerRadius: 10, borderWidth: 2),
            effectProperties: EffectProperties(backgroundOpacity: 0.8, backgroundBlurRadius: 10, borderOpacity: 1.0)
        )

        // When/Then - Should access all protocol requirements
        expect(container.title) == "Test"
        expect(container.colorProperties.backgroundTintColor) == .blue
        expect(container.geometricProperties.cornerRadius) == 10
        expect(container.effectProperties.backgroundOpacity) == 0.8
    }
}

// MARK: - Mock Implementation

private struct MockVisualContainer: VisualContainer {
    typealias AppearanceMode = MockVisualContainerAppearanceMode

    static var metadata: VisualContainerMetadata {
        VisualContainerMetadata(
            entityName: "Mock",
            entityNamePlural: "Mocks",
            tagPrefix: "mock",
            canAddEntities: true,
            canDeleteEntities: true,
            showForegroundSection: true,
            defaultGlobalColorProperties: ConfigurationDefaults.spaceColorProperties,
            defaultGlobalEffectProperties: ConfigurationDefaults.spaceEffectProperties,
            defaultGlobalGeometricProperties: GeometricProperties(cornerRadius: 10, borderWidth: 2),
            defaultThemeGeometricProperties: ConfigurationDefaults.themePresetGeometricProperties,
            defaultThemeEffectProperties: ConfigurationDefaults.themePresetEffectProperties,
            canDeleteEntity: { _ in false },
            footerText: "Footer",
            resetAlertTitle: "Reset?",
            resetAlertMessage: "Are you sure?",
            resetButtonTitle: "Reset All",
            resetButtonDescription: "Reset description"
        )
    }

    let id: String
    var title: String
    var colorProperties: ColorProperties
    var geometricProperties: GeometricProperties
    var effectProperties: EffectProperties

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Mock Appearance Mode

private enum MockVisualContainerAppearanceMode: String, Domain.AppearanceMode {
    case allEntities
    case perEntity

    var displayName: LocalizedStringResource {
        switch self {
        case .allEntities: "All Entities"
        case .perEntity: "Per Entity"
        }
    }

    var description: LocalizedStringResource {
        switch self {
        case .allEntities: "Apply to all"
        case .perEntity: "Apply individually"
        }
    }

    var shouldShowGlobalConfig: Bool {
        switch self {
        case .allEntities: true
        case .perEntity: false
        }
    }
}
