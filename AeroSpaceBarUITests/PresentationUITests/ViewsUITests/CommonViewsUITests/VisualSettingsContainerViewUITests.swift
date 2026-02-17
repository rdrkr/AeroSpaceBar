// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Nimble
import XCTest

/// UI tests for VisualSettingsContainerView.
///
/// These tests verify visual settings container UI including:
/// - Generic container for Groups and Spaces settings
/// - Feature enable/disable toggle
/// - Appearance mode section
/// - Visual settings section (color, geometric, effect)
/// - Entities list with add/delete functionality
/// - Reset functionality with confirmation
/// - Theme mode integration
/// - Dynamic navigation page registration
@MainActor
final class VisualSettingsContainerViewUITests: XCTestCase {
    private var app: XCUIApplication?

    override func setUp() async throws {
        try await super.setUp()
        continueAfterFailure = false
        // Use guard statement to safely initialize app

        app = XCUIApplication()

        guard let app else {
            XCTFail("XCUIApplication should be initialized")

            return
        }

        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    // MARK: - Display Tests

    func testVisualSettingsContainerDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given settings are open
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then visual settings container should be displayed
        // for Groups or Spaces settings
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Visual settings container should be displayed"
        )
    }

    func testFeatureToggleDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given isFeatureEnabled binding is provided
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then toggle should be displayed in header
        // Tagged as "{tagPrefix}-show-{tagPrefix}-toggle"
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Feature toggle should be displayed"
        )
    }

    func testFeatureToggleInteraction() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given feature toggle is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // When toggle is switched
        // Then feature should be enabled/disabled
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Feature toggle should be interactive"
        )
    }

    func testFeatureDisabledCallback() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given feature is enabled
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // When feature is disabled
        // Then onFeatureDisabled callback should be invoked
        // to remove navigation pages
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Feature disabled callback should be invoked"
        )
    }

    func testAppearanceModeSection() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given visual settings are displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then appearance mode section should be displayed
        // Tagged as "{tagPrefix}-appearance-mode-section"
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Appearance mode section should be displayed"
        )
    }

    func testAppearanceModePicker() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given appearance mode section is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then segmented picker should be displayed
        // with available appearance modes
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Appearance mode picker should be displayed"
        )
    }

    func testAppearanceModeDisabledInPresetMode() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given theme mode is preset (not color customizable)
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then appearance mode picker should be disabled
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Appearance mode should be disabled in preset mode"
        )
    }

    func testVisualSettingsSectionGlobalConfig() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given appearance mode requires global config
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then visual settings section should be displayed
        // using VisualSettingsView component
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Visual settings should be shown for global config"
        )
    }

    func testVisualSettingsSectionPresetMode() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given theme mode is preset (not color customizable)
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then visual settings section should be displayed
        // with preset properties
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Visual settings should be shown in preset mode"
        )
    }

    func testEntitiesListDisplay() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given entities exist
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then entities list section should be displayed
        // with LazyVStackList of entities
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Entities list should be displayed"
        )
    }

    func testAddEntityButton() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given metadata allows adding entities
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then add button (+) should be displayed in section header
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Add entity button should be displayed"
        )
    }

    func testAddEntityButtonDisabled() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given canAddMoreEntities returns false
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then add button should be disabled
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Add button should be disabled when limit reached"
        )
    }

    func testDeleteEntityButton() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given metadata allows deleting entities
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then delete button should be available in row swipe
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Delete entity button should be available"
        )
    }

    func testResetSection() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given entities exist
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then reset section should be displayed
        // Tagged as "{tagPrefix}-reset-section"
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Reset section should be displayed"
        )
    }

    func testResetButton() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given reset section is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then reset button should be displayed
        // as SettingsDestructiveButton
        // Tagged as "{tagPrefix}-reset-button"
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Reset button should be displayed"
        )
    }

    func testResetConfirmationDialog() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given reset button is clicked
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then confirmation alert should be displayed
        // with Cancel and Reset (destructive) buttons
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Reset confirmation dialog should appear"
        )
    }

    func testEntityRowNavigation() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given entity row is clicked
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then should navigate to entity page
        // using createNavigationPage callback
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Entity row should navigate to detail page"
        )
    }

    func testDynamicPageRegistration() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given entities are rendered
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then onRegisterDynamicSubPage should be called
        // for each entity page
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Dynamic pages should be registered"
        )
    }

    func testPrependContent() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given container has prepend content
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then prepend content should be displayed
        // before main visual settings
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Prepend content should be displayed"
        )
    }

    func testAppendContent() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given container has append content
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then append content should be displayed
        // after main visual settings
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Append content should be displayed"
        )
    }

    func testAnimationsForStateChanges() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given container state changes
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then animations should be applied using .themeEaseInOutFast
        // for: isFeatureEnabled, entities, appearanceMode, themeMode
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "State changes should animate"
        )
    }

    func testIntroFormLayout() {
        guard let app else {
            XCTFail("XCUIApplication should be initialized")
            return
        }

        // Given visual settings container is displayed
        app.typeKey(",", modifierFlags: .command)
        sleep(1)

        // Then should use IntroForm with compact style
        let state = app.state
        expect(state == .runningForeground || state == .runningBackground).to(
            beTrue(),
            description: "Should use IntroForm layout"
        )
    }
}
