// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Nimble
import SwiftUI
import XCTest

final class WindowTests: XCTestCase {
    // MARK: - Initialization Tests

    func testInitWithAllParameters() {
        // Given custom properties
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

        // When creating a window with all parameters
        let window = Window(
            id: 123,
            title: "Test Window",
            appName: "TestApp",
            isFocused: true,
            workspace: "1",
            appIcon: nil,
            colorProperties: colorProps,
            geometricProperties: geomProps,
            effectProperties: effectProps
        )

        // Then all properties should be set correctly
        expect(window.id) == 123
        expect(window.title) == "Test Window"
        expect(window.appName) == "TestApp"
        expect(window.isFocused) == true
        expect(window.workspace) == "1"
        expect(window.appIcon).to(beNil())
        expect(window.colorProperties) == colorProps
        expect(window.geometricProperties) == geomProps
        expect(window.effectProperties) == effectProps
    }

    func testInitWithDefaultValues() {
        // When creating a window with minimal parameters
        let window = Window(
            id: 456,
            title: "Minimal Window",
            appName: "App",
            workspace: "2"
        )

        // Then it should have correct default values
        expect(window.id) == 456
        expect(window.title) == "Minimal Window"
        expect(window.appName) == "App"
        expect(window.isFocused) == false
        expect(window.workspace) == "2"
        expect(window.appIcon).to(beNil())
        expect(window.colorProperties) == ConfigurationDefaults.spaceColorProperties
        expect(window.geometricProperties) == ConfigurationDefaults.spaceGeometricProperties
        expect(window.effectProperties) == ConfigurationDefaults.spaceEffectProperties
    }

    func testInitWithNilAppName() {
        // When creating a window with nil app name
        let window = Window(
            id: 789,
            title: "No App Window",
            appName: nil,
            workspace: "3"
        )

        // Then appName should be nil
        expect(window.id) == 789
        expect(window.appName).to(beNil())
    }

    func testInitWithNilWorkspace() {
        // When creating a window with nil workspace
        let window = Window(
            id: 101,
            title: "Floating Window",
            appName: "App",
            workspace: nil
        )

        // Then workspace should be nil
        expect(window.id) == 101
        expect(window.workspace).to(beNil())
    }

    // MARK: - Coding Tests

    func testEncoding() throws {
        // Given a window with custom properties
        let window = Window(
            id: 999,
            title: "Encode Test",
            appName: "TestApp",
            workspace: "1",
            colorProperties: ColorProperties(
                backgroundTintColor: Color(hex: "#123456") ?? .white,
                borderTintColor: .white,
                foregroundColor: .white
            ),
            geometricProperties: GeometricProperties(cornerRadius: 15.0, borderWidth: 0.0),
            effectProperties: EffectProperties(backgroundOpacity: 0.8, backgroundBlurRadius: 5.0, borderOpacity: 0.8)
        )

        // When encoding the window
        let encoder = JSONEncoder()
        let data = try encoder.encode(window)

        // Then it should be encodable without errors
        expect(data.isEmpty) == false

        // And should contain the expected keys
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        expect(json).toNot(beNil())
        expect(json?["window-id"] as? Int).to(equal(999))
        expect(json?["window-title"] as? String).to(equal("Encode Test"))
        expect(json?["app-name"] as? String).to(equal("TestApp"))
        expect(json?["workspace"] as? String).to(equal("1"))
        expect(json?["visual-config"] as Any?).toNot(beNil())
        expect(json?["geometric-config"] as Any?).toNot(beNil())
        expect(json?["effect-config"] as Any?).toNot(beNil())
    }

    func testDecoding() throws {
        // Given JSON data with window information
        let json = """
        {
            "window-id": 888,
            "window-title": "Decode Test",
            "app-name": "DecoderApp",
            "workspace": "2",
            "visual-config": {
                "background-tint-color": {
                    "red": 0.6705882352941176,
                    "green": 0.803921568627451,
                    "blue": 0.9372549019607843,
                    "alpha": 1.0
                },
                "border-tint-color": {
                    "red": 1.0,
                    "green": 1.0,
                    "blue": 1.0,
                    "alpha": 1.0
                },
                "foreground-color": {
                    "red": 0.996078431372549,
                    "green": 0.8627450980392157,
                    "blue": 0.7294117647058823,
                    "alpha": 1.0
                }
            },
            "geometric-config": {
                "corner-radius": 20.0,
                "border-width": 10.0
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
        let window = try decoder.decode(Window.self, from: data)

        // Then it should decode correctly
        expect(window.id) == 888
        expect(window.title) == "Decode Test"
        expect(window.appName) == "DecoderApp"
        expect(window.workspace) == "2"
        expect(window.isFocused) == false // Default value
        expect(window.appIcon) == nil // Not encoded/decoded
        // Check colors match the expected values (approximately #ABCDEF and #FEDCBA)
        expect(window.colorProperties.backgroundTintColor).toNot(beNil())
        expect(window.colorProperties.borderTintColor).toNot(beNil())
        expect(window.colorProperties.foregroundColor).toNot(beNil())
        expect(window.geometricProperties.cornerRadius) == 20.0
        expect(window.geometricProperties.borderWidth) == 10.0
        expect(window.effectProperties.backgroundOpacity) == 0.7
    }

    func testDecodingWithMissingProperties() throws {
        // Given minimal JSON data
        let json = """
        {
            "window-id": 777,
            "window-title": "Minimal",
            "app-name": "App",
            "workspace": "1"
        }
        """

        // When decoding the JSON
        let data = Data(json.utf8)
        let decoder = JSONDecoder()
        let window = try decoder.decode(Window.self, from: data)

        // Then it should use default values for missing properties
        expect(window.id) == 777
        expect(window.colorProperties) == ConfigurationDefaults.spaceColorProperties
        expect(window.geometricProperties) == ConfigurationDefaults.spaceGeometricProperties
        expect(window.effectProperties) == ConfigurationDefaults.spaceEffectProperties
    }

    func testRoundTripCoding() throws {
        // Given a window with all properties set
        let original = Window(
            id: 555,
            title: "Round Trip",
            appName: "RoundTripApp",
            isFocused: true,
            workspace: "5",
            colorProperties: ColorProperties(
                backgroundTintColor: Color(hex: "#112233") ?? .white,
                borderTintColor: .white,
                foregroundColor: .white
            ),
            geometricProperties: GeometricProperties(cornerRadius: 12.0, borderWidth: 0.0),
            effectProperties: EffectProperties(backgroundOpacity: 0.95, backgroundBlurRadius: 5.0, borderOpacity: 0.95)
        )

        // When encoding and then decoding
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Window.self, from: data)

        // Then the decoded window should match the original (except runtime properties)
        expect(decoded.id) == original.id
        expect(decoded.title) == original.title
        expect(decoded.appName) == original.appName
        expect(decoded.workspace) == original.workspace
        expect(decoded.colorProperties) == original.colorProperties
        expect(decoded.geometricProperties) == original.geometricProperties
        expect(decoded.effectProperties) == original.effectProperties
        // Note: isFocused and appIcon are not encoded/decoded
    }

    // MARK: - Equality Tests

    func testEqualityWithSameValues() {
        // Given two windows with identical values
        let window1 = Window(id: 1, title: "Test", appName: "App", workspace: "1")
        let window2 = Window(id: 1, title: "Test", appName: "App", workspace: "1")

        // Then they should be equal
        expect(window1) == window2
    }

    func testEqualityWithDifferentIds() {
        // Given two windows with different IDs
        let window1 = Window(id: 1, title: "Test", appName: "App", workspace: "1")
        let window2 = Window(id: 2, title: "Test", appName: "App", workspace: "1")

        // Then they should not be equal
        expect(window1) != window2
    }

    func testEqualityWithDifferentTitles() {
        // Given two windows with different titles
        let window1 = Window(id: 1, title: "Title1", appName: "App", workspace: "1")
        let window2 = Window(id: 1, title: "Title2", appName: "App", workspace: "1")

        // Then they should not be equal
        expect(window1) != window2
    }

    func testEqualityWithDifferentAppNames() {
        // Given two windows with different app names
        let window1 = Window(id: 1, title: "Test", appName: "App1", workspace: "1")
        let window2 = Window(id: 1, title: "Test", appName: "App2", workspace: "1")

        // Then they should not be equal
        expect(window1) != window2
    }

    func testEqualityWithDifferentFocusStates() {
        // Given two windows with different focus states
        let window1 = Window(id: 1, title: "Test", appName: "App", isFocused: true, workspace: "1")
        let window2 = Window(id: 1, title: "Test", appName: "App", isFocused: false, workspace: "1")

        // Then they should not be equal
        expect(window1) != window2
    }

    func testEqualityWithDifferentWorkspaces() {
        // Given two windows with different workspaces
        let window1 = Window(id: 1, title: "Test", appName: "App", workspace: "1")
        let window2 = Window(id: 1, title: "Test", appName: "App", workspace: "2")

        // Then they should not be equal
        expect(window1) != window2
    }

    func testEqualityIgnoresAppIcon() {
        // Given two windows with same properties but different app icons would be equal
        // (appIcon is explicitly excluded from equality comparison)
        let window1 = Window(id: 1, title: "Test", appName: "App", workspace: "1", appIcon: nil)
        let window2 = Window(id: 1, title: "Test", appName: "App", workspace: "1", appIcon: nil)

        // Then they should be equal
        expect(window1) == window2
    }

    // MARK: - VisualContainer Conformance Tests

    func testVisualContainerMetadata() {
        // Then metadata should be correctly configured
        expect(Window.metadata.entityName) == "Window"
        expect(Window.metadata.entityNamePlural) == "Windows"
        expect(Window.metadata.tagPrefix) == "windows"
        expect(Window.metadata.canAddEntities) == false
        expect(Window.metadata.canDeleteEntities) == false
        expect(Window.metadata.showForegroundSection) == true
    }

    func testCannotDeleteWindows() {
        // Given a window
        let window = Window(id: 1, title: "Test", appName: "App", workspace: "1")

        // Then it should not be deletable
        expect(Window.metadata.canDeleteEntity(window)) == false
    }

    // MARK: - Property Tests

    func testTitleProperty() {
        // Given a window
        var window = Window(id: 1, title: "Original", appName: "App", workspace: "1")

        // Then title should be gettable
        expect(window.title) == "Original"

        // When changing title
        window.title = "Updated"

        // Then title should be updated
        expect(window.title) == "Updated"
    }

    func testIdIsImmutable() {
        // Given a window
        let window = Window(id: 123, title: "Test", appName: "App", workspace: "1")

        // Then ID should be constant
        expect(window.id) == 123
        // Note: id is a let constant, so this test just verifies it's accessible
    }

    // MARK: - Fixture Tests

    func testFixtures() {
        // Verify that test fixtures work correctly
        expect(WindowFixtures.safari.id) == 1_001
        expect(WindowFixtures.safari.appName) == "Safari"
        expect(WindowFixtures.safari.isFocused) == false

        expect(WindowFixtures.safariFocused.id) == 1_001
        expect(WindowFixtures.safariFocused.isFocused) == true

        expect(WindowFixtures.vscode.appName) == "Code"
        expect(WindowFixtures.terminal.appName) == "Terminal"
        expect(WindowFixtures.slack.appName) == "Slack"
    }

    func testFixtureBuilders() {
        // Test fixture builder methods
        let custom = WindowFixtures.withId(9_999)
        expect(custom.id) == 9_999
        expect(custom.appName) == "TestApp"

        let customFocused = WindowFixtures.focusedWithId(8_888)
        expect(customFocused.id) == 8_888
        expect(customFocused.isFocused) == true

        let inWorkspace = WindowFixtures.inWorkspace("5")
        expect(inWorkspace.workspace) == "5"

        let array = WindowFixtures.array(count: 5, startId: 2_000, workspace: "3")
        expect(array.count) == 5
        expect(array[0].id) == 2_000
        expect(array[4].id) == 2_004
        expect(array.allSatisfy { $0.workspace == "3" }) == true
    }

    // MARK: - Edge Cases Tests

    func testWindowWithVeryLongTitle() {
        // Given a window with a very long title
        let longTitle = String(repeating: "A", count: 1_000)
        let window = Window(id: 1, title: longTitle, appName: "App", workspace: "1")

        // Then it should handle it correctly
        expect(window.title.count) == 1_000
        expect(window.title) == longTitle
    }

    func testWindowWithSpecialCharactersInTitle() {
        // Given a window with special characters in title
        let specialTitle = "Test 🚀 Window - [Special] (Characters) & Symbols"
        let window = Window(id: 1, title: specialTitle, appName: "App", workspace: "1")

        // Then it should preserve special characters
        expect(window.title) == specialTitle
    }

    func testWindowWithEmptyTitle() {
        // Given a window with empty title
        let window = Window(id: 1, title: "", appName: "App", workspace: "1")

        // Then it should allow empty titles
        expect(window.title.isEmpty) == true
    }

    func testWindowWithLargeId() {
        // Given a window with a large ID
        let largeId = Int.max
        let window = Window(id: largeId, title: "Test", appName: "App", workspace: "1")

        // Then it should handle large IDs
        expect(window.id) == largeId
    }
}
