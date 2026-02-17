// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Domain
import Foundation
import Nimble
import XCTest

final class AppModelsTests: XCTestCase {
    // MARK: - Window Tests

    func testWindowInitialization() {
        // Given a window
        let window = Window(
            id: 123,
            title: "Test Window",
            appName: "TestApp",
            isFocused: true,
            workspace: "1"
        )

        // Then should have correct properties
        expect(window.id) == 123
        expect(window.title) == "Test Window"
        expect(window.appName) == "TestApp"
        expect(window.isFocused) == true
        expect(window.workspace) == "1"
        expect(window.appIcon).to(beNil())
        expect(window.colorProperties) == ConfigurationDefaults.spaceColorProperties
        expect(window.geometricProperties) == ConfigurationDefaults.spaceGeometricProperties
        expect(window.effectProperties) == ConfigurationDefaults.spaceEffectProperties
    }

    func testWindowCodingKeys() {
        // Then coding keys should match expected raw values
        expect(Window.CodingKeys.id.rawValue) == "window-id"
        expect(Window.CodingKeys.title.rawValue) == "window-title"
        expect(Window.CodingKeys.appName.rawValue) == "app-name"
        expect(Window.CodingKeys.workspace.rawValue) == "workspace"
        expect(Window.CodingKeys.colorProperties.rawValue) == "visual-config"
        expect(Window.CodingKeys.geometricProperties.rawValue) == "geometric-config"
        expect(Window.CodingKeys.effectProperties.rawValue) == "effect-config"
    }

    func testWindowDecoding() throws {
        // Given JSON data
        let json = """
        {
            "window-id": 456,
            "window-title": "Decoded Window",
            "app-name": "DecodedApp",
            "workspace": "2"
        }
        """

        guard let data = json.data(using: .utf8) else {
            fail("Failed to create data from JSON string")
            return
        }

        // When decoding
        let decoder = JSONDecoder()
        let window = try decoder.decode(Window.self, from: data)

        // Then should have correct values
        expect(window.id) == 456
        expect(window.title) == "Decoded Window"
        expect(window.appName) == "DecodedApp"
        expect(window.workspace) == "2"
        expect(window.isFocused) == false // Defaults to false
        expect(window.appIcon).to(beNil()) // Not encoded/decoded
        expect(window.colorProperties) == ConfigurationDefaults.spaceColorProperties
        expect(window.geometricProperties) == ConfigurationDefaults.spaceGeometricProperties
        expect(window.effectProperties) == ConfigurationDefaults.spaceEffectProperties
    }

    func testWindowEquatable() {
        // Given windows
        let window1 = Window(
            id: 123,
            title: "Test Window",
            appName: "TestApp",
            isFocused: true,
            workspace: "1"
        )

        let window2 = Window(
            id: 123,
            title: "Test Window",
            appName: "TestApp",
            isFocused: true,
            workspace: "1"
        )

        let window3 = Window(
            id: 456,
            title: "Different Window",
            appName: "TestApp",
            isFocused: false,
            workspace: "2"
        )

        // Then should compare correctly
        expect(window1) == window2
        expect(window1) != window3
    }

    // MARK: - Space Tests

    func testSpaceInitialization() {
        // Given a space
        let space = Space(
            id: "1",
            isFocused: true,
            windows: []
        )

        // Then should have correct properties
        expect(space.id) == "1"
        expect(space.title) == "1" // title is computed from id
        expect(space.isFocused) == true
        expect(space.windows.isEmpty) == true
        expect(space.colorProperties) == ConfigurationDefaults.spaceColorProperties
        expect(space.geometricProperties) == ConfigurationDefaults.spaceGeometricProperties
        expect(space.effectProperties) == ConfigurationDefaults.spaceEffectProperties
    }

    func testSpaceCodingKeys() {
        // Then coding keys should match expected raw values
        expect(Space.CodingKeys.id.rawValue) == "workspace"
        expect(Space.CodingKeys.colorProperties.rawValue) == "visual-config"
        expect(Space.CodingKeys.geometricProperties.rawValue) == "geometric-config"
        expect(Space.CodingKeys.effectProperties.rawValue) == "effect-config"
    }

    func testSpaceDecoding() throws {
        // Given JSON data
        let json = """
        {
            "workspace": "2"
        }
        """

        guard let data = json.data(using: .utf8) else {
            fail("Failed to create data from JSON string")
            return
        }

        // When decoding
        let decoder = JSONDecoder()
        let space = try decoder.decode(Space.self, from: data)

        // Then should have correct values
        expect(space.id) == "2"
        expect(space.title) == "2"
        expect(space.isFocused) == false // Defaults to false
        expect(space.windows.isEmpty) == true // Defaults to empty array
        expect(space.colorProperties) == ConfigurationDefaults.spaceColorProperties
        expect(space.geometricProperties) == ConfigurationDefaults.spaceGeometricProperties
        expect(space.effectProperties) == ConfigurationDefaults.spaceEffectProperties
    }

    func testSpaceEquatable() {
        // Given spaces
        let space1 = Space(id: "1", isFocused: true)
        let space2 = Space(id: "1", isFocused: true)
        let space3 = Space(id: "2", isFocused: false)

        // Then should compare IDs correctly
        // Space conforms to VisualContainer which requires Identifiable
        expect(space1.id) == space2.id
        expect(space1.id) != space3.id
    }
}
