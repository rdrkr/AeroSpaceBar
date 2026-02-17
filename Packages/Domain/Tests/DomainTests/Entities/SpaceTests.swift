// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Nimble
import SwiftUI
import XCTest

final class SpaceTests: XCTestCase {
    // MARK: - Initialization Tests

    func testInitWithDefaultValues() {
        // When creating a space with minimal parameters
        let space = Space(id: "1")

        // Then it should have correct default values
        expect(space.id) == "1"
        expect(space.isFocused) == false
        expect(space.windows.isEmpty) == true
        expect(space.colorProperties) == ConfigurationDefaults.spaceColorProperties
        expect(space.geometricProperties) == ConfigurationDefaults.spaceGeometricProperties
        expect(space.effectProperties) == ConfigurationDefaults.spaceEffectProperties
    }

    func testInitWithAllParameters() {
        // Given custom properties
        let windows = [WindowFixtures.safari, WindowFixtures.vscode]
        let colorProps = ColorProperties(
            backgroundTintColor: Color(hex: "#FF0000") ?? .red,
            borderTintColor: Color(hex: "#FF0000") ?? .red,
            foregroundColor: Color(hex: "#FFFFFF") ?? .white
        )
        let geomProps = GeometricProperties(cornerRadius: 10.0, borderWidth: 2.0)
        let effectProps = EffectProperties(
            backgroundOpacity: 0.9,
            backgroundBlurRadius: 5.0,
            borderOpacity: 0.9
        )

        // When creating a space with all parameters
        let space = Space(
            id: "test",
            isFocused: true,
            windows: windows,
            colorProperties: colorProps,
            geometricProperties: geomProps,
            effectProperties: effectProps
        )

        // Then all properties should be set correctly
        expect(space.id) == "test"
        expect(space.isFocused) == true
        expect(space.windows.count) == 2
        expect(space.windows[0].id) == WindowFixtures.safari.id
        expect(space.windows[1].id) == WindowFixtures.vscode.id
        expect(space.colorProperties) == colorProps
        expect(space.geometricProperties) == geomProps
        expect(space.effectProperties) == effectProps
    }

    func testTitleMatchesId() {
        // Given a space with an ID
        var space = Space(id: "original")

        // Then title should match ID
        expect(space.title) == "original"

        // When changing the title
        space.title = "updated"

        // Then both ID and title should be updated
        expect(space.id) == "updated"
        expect(space.title) == "updated"
    }

    // MARK: - Coding Tests

    func testEncoding() throws {
        // Given a space with custom properties
        let space = Space(
            id: "encode-test",
            isFocused: true,
            windows: [WindowFixtures.safari],
            colorProperties: ColorProperties(
                backgroundTintColor: Color(hex: "#123456") ?? .blue,
                borderTintColor: Color(hex: "#123456") ?? .blue,
                foregroundColor: .white
            ),
            geometricProperties: GeometricProperties(cornerRadius: 15.0, borderWidth: 1.0),
            effectProperties: EffectProperties(
                backgroundOpacity: 0.8,
                backgroundBlurRadius: 2.0,
                borderOpacity: 0.8
            )
        )

        // When encoding the space
        let encoder = JSONEncoder()
        let data = try encoder.encode(space)

        // Then it should be encodable without errors
        expect(data.isEmpty) == false

        // And should contain the expected keys
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        expect(json).toNot(beNil())
        expect(json?["workspace"] as? String) == "encode-test"
        expect(json?["visual-config"] as Any?).toNot(beNil())
        expect(json?["geometric-config"] as Any?).toNot(beNil())
        expect(json?["effect-config"] as Any?).toNot(beNil())
    }

    func testDecoding() throws {
        // Given JSON data with space information
        let json = """
        {
            "workspace": "decode-test",
            "visual-config": {
                "background-tint-color": {"red": 0.67, "green": 0.8, "blue": 0.93, "alpha": 1.0},
                "border-tint-color": {"red": 0.67, "green": 0.8, "blue": 0.93, "alpha": 1.0},
                "foreground-color": {"red": 0.996, "green": 0.862, "blue": 0.733, "alpha": 1.0}
            },
            "geometric-config": {
                "corner-radius": 20.0,
                "border-width": 2.0
            },
            "effect-config": {
                "background-opacity": 0.7,
                "background-blur-radius": 3.0,
                "border-opacity": 0.7
            }
        }
        """

        // When decoding the JSON
        let data = Data(json.utf8)
        let decoder = JSONDecoder()
        let space = try decoder.decode(Space.self, from: data)

        // Then it should decode correctly
        expect(space.id) == "decode-test"
        expect(space.isFocused) == false // Default value
        expect(space.windows.isEmpty) == true // Default value
        expect(space.geometricProperties.cornerRadius) == 20.0
        expect(space.geometricProperties.borderWidth) == 2.0
        expect(space.effectProperties.backgroundOpacity) == 0.7
        expect(space.effectProperties.backgroundBlurRadius) == 3.0
        expect(space.effectProperties.borderOpacity) == 0.7
    }

    func testDecodingWithMissingProperties() throws {
        // Given minimal JSON data
        let json = """
        {
            "workspace": "minimal"
        }
        """

        // When decoding the JSON
        let data = Data(json.utf8)
        let decoder = JSONDecoder()
        let space = try decoder.decode(Space.self, from: data)

        // Then it should use default values for missing properties
        expect(space.id) == "minimal"
        expect(space.colorProperties) == ConfigurationDefaults.spaceColorProperties
        expect(space.geometricProperties) == ConfigurationDefaults.spaceGeometricProperties
        expect(space.effectProperties) == ConfigurationDefaults.spaceEffectProperties
    }

    func testRoundTripCoding() throws {
        // Given a space with all properties set
        let original = Space(
            id: "roundtrip",
            isFocused: true,
            windows: [WindowFixtures.safari, WindowFixtures.vscode],
            colorProperties: ColorProperties(
                backgroundTintColor: Color(hex: "#112233") ?? .blue,
                borderTintColor: Color(hex: "#112233") ?? .blue,
                foregroundColor: .white
            ),
            geometricProperties: GeometricProperties(cornerRadius: 12.0, borderWidth: 1.5),
            effectProperties: EffectProperties(
                backgroundOpacity: 0.95,
                backgroundBlurRadius: 4.0,
                borderOpacity: 0.95
            )
        )

        // When encoding and then decoding
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Space.self, from: data)

        // Then the decoded space should match the original (except runtime properties)
        expect(decoded.id) == original.id
        expect(decoded.colorProperties) == original.colorProperties
        expect(decoded.geometricProperties) == original.geometricProperties
        expect(decoded.effectProperties) == original.effectProperties
        // Note: isFocused and windows are not encoded/decoded
    }

    // MARK: - Equality Tests

    func testEqualityWithSameValues() {
        // Given two spaces with identical values
        let space1 = Space(id: "1", isFocused: true, windows: [WindowFixtures.safari])
        let space2 = Space(id: "1", isFocused: true, windows: [WindowFixtures.safari])

        // Then they should be equal
        expect(space1) == space2
    }

    func testEqualityWithDifferentIds() {
        // Given two spaces with different IDs
        let space1 = Space(id: "1")
        let space2 = Space(id: "2")

        // Then they should not be equal
        expect(space1) != space2
    }

    func testEqualityWithDifferentFocusStates() {
        // Given two spaces with different focus states
        let space1 = Space(id: "1", isFocused: true)
        let space2 = Space(id: "1", isFocused: false)

        // Then they should not be equal
        expect(space1) != space2
    }

    func testEqualityWithDifferentWindows() {
        // Given two spaces with different windows
        let space1 = Space(id: "1", windows: [WindowFixtures.safari])
        let space2 = Space(id: "1", windows: [WindowFixtures.vscode])

        // Then they should not be equal
        expect(space1) != space2
    }

    // MARK: - VisualContainer Conformance Tests

    func testVisualContainerMetadata() {
        // Then metadata should be correctly configured
        expect(Space.metadata.entityName) == "Space"
        expect(Space.metadata.entityNamePlural) == "Spaces"
        expect(Space.metadata.tagPrefix) == "spaces"
        expect(Space.metadata.canAddEntities) == false
        expect(Space.metadata.canDeleteEntities) == false
        expect(Space.metadata.showForegroundSection) == true
    }

    func testCannotDeleteSpaces() {
        // Given a space
        let space = Space(id: "1")

        // Then it should not be deletable
        expect(Space.metadata.canDeleteEntity(space)) == false
    }

    // MARK: - Fixture Tests

    func testFixtures() {
        // Verify that test fixtures work correctly
        expect(SpaceFixtures.basic.id) == "1"
        expect(SpaceFixtures.basic.isFocused) == false
        expect(SpaceFixtures.basic.windows.isEmpty) == true

        expect(SpaceFixtures.focused.id) == "2"
        expect(SpaceFixtures.focused.isFocused) == true

        expect(SpaceFixtures.withWindows.id) == "3"
        expect(SpaceFixtures.withWindows.windows.count) == 3

        expect(SpaceFixtures.focusedWithWindows.isFocused) == true
        expect(SpaceFixtures.focusedWithWindows.windows.isEmpty) == false
    }

    func testFixtureBuilders() {
        // Test fixture builder methods
        let custom = SpaceFixtures.withId("custom")
        expect(custom.id) == "custom"
        expect(custom.isFocused) == false

        let customFocused = SpaceFixtures.focusedWithId("focused-custom")
        expect(customFocused.id) == "focused-custom"
        expect(customFocused.isFocused) == true

        let withWindows = SpaceFixtures.withWindows([WindowFixtures.safari])
        expect(withWindows.windows.count) == 1
        expect(withWindows.windows[0].id) == WindowFixtures.safari.id

        let array = SpaceFixtures.array(count: 5, focused: "3")
        expect(array.count) == 5
        expect(array[0].id) == "1"
        expect(array[4].id) == "5"
        expect(array[2].isFocused) == true // Index 2 has id "3"
        expect(array[0].isFocused) == false
    }
}
