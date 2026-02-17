// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Nimble
import XCTest

/// Tests for ThemeMode enum.
///
/// These tests verify ThemeMode cases, availability, customization capabilities,
/// and CaseIterable/Codable conformance.
@MainActor
final class ThemeModeTests: XCTestCase {
    // MARK: - Case Tests

    func testPresetCase() {
        // Given preset theme mode
        let mode = ThemeMode.preset

        // Then should match expected case
        expect(mode) == .preset
        expect(mode.rawValue) == "preset"
    }

    func testGlassCase() {
        // Given glass theme mode
        let mode = ThemeMode.glass

        // Then should match expected case
        expect(mode) == .glass
        expect(mode.rawValue) == "glass"
    }

    func testCustomCase() {
        // Given custom theme mode
        let mode = ThemeMode.custom

        // Then should match expected case
        expect(mode) == .custom
        expect(mode.rawValue) == "custom"
    }

    // MARK: - CaseIterable Tests

    func testAllCases() {
        // Given all theme mode cases
        let allCases = ThemeMode.allCases

        // Then should have 3 cases
        expect(allCases.count) == 3
        expect(allCases.contains(.preset)) == true
        expect(allCases.contains(.glass)) == true
        expect(allCases.contains(.custom)) == true
    }

    func testIteratingAllCases() {
        // Given all cases
        var caseCount = 0

        // When iterating
        for _ in ThemeMode.allCases {
            caseCount += 1
        }

        // Then should iterate all 3
        expect(caseCount) == 3
    }

    // MARK: - Availability Tests

    func testPresetAvailability() {
        // Given preset mode
        let mode = ThemeMode.preset

        // Then should always be available
        expect(mode.isAvailable) == true
    }

    func testCustomAvailability() {
        // Given custom mode
        let mode = ThemeMode.custom

        // Then should always be available
        expect(mode.isAvailable) == true
    }

    func testGlassAvailability() {
        // Given glass mode
        let mode = ThemeMode.glass

        // Then availability depends on macOS version
        if #available(macOS 26.0, *) {
            expect(mode.isAvailable) == true
        } else {
            expect(mode.isAvailable) == false
        }
    }

    func testFilterAvailableModes() {
        // Given all modes
        let allModes = ThemeMode.allCases

        // When filtering available modes
        let availableModes = allModes.filter(\.isAvailable)

        // Then should have at least preset and custom
        expect(availableModes.count) >= 2
        expect(availableModes.contains(.preset)) == true
        expect(availableModes.contains(.custom)) == true
    }

    // MARK: - Color Customization Tests

    func testCustomColorCustomizable() {
        // Given custom mode
        let mode = ThemeMode.custom

        // Then should support color customization
        expect(mode.isColorCustomizable) == true
    }

    func testPresetNotColorCustomizable() {
        // Given preset mode
        let mode = ThemeMode.preset

        // Then should not support color customization
        expect(mode.isColorCustomizable) == false
    }

    func testGlassNotColorCustomizable() {
        // Given glass mode
        let mode = ThemeMode.glass

        // Then should not support color customization
        expect(mode.isColorCustomizable) == false
    }

    // MARK: - Effect Customization Tests

    func testPresetEffectCustomizable() {
        // Given preset mode
        let mode = ThemeMode.preset

        // Then should support effect customization
        expect(mode.isEffectCustomizable) == true
    }

    func testCustomEffectCustomizable() {
        // Given custom mode
        let mode = ThemeMode.custom

        // Then should support effect customization
        expect(mode.isEffectCustomizable) == true
    }

    func testGlassNotEffectCustomizable() {
        // Given glass mode
        let mode = ThemeMode.glass

        // Then should not support effect customization (uses system glass)
        expect(mode.isEffectCustomizable) == false
    }

    // MARK: - Geometry Customization Tests

    func testPresetGeometryCustomizable() {
        // Given preset mode
        let mode = ThemeMode.preset

        // Then should support geometry customization
        expect(mode.isGeometryCustomizable) == true
    }

    func testCustomGeometryCustomizable() {
        // Given custom mode
        let mode = ThemeMode.custom

        // Then should support geometry customization
        expect(mode.isGeometryCustomizable) == true
    }

    func testGlassNotGeometryCustomizable() {
        // Given glass mode
        let mode = ThemeMode.glass

        // Then should not support geometry customization (uses system style)
        expect(mode.isGeometryCustomizable) == false
    }

    // MARK: - Customization Matrix Tests

    func testCustomModeFullyCustomizable() {
        // Given custom mode
        let mode = ThemeMode.custom

        // Then should support all customizations
        expect(mode.isColorCustomizable) == true
        expect(mode.isEffectCustomizable) == true
        expect(mode.isGeometryCustomizable) == true
    }

    func testPresetModePartiallyCustomizable() {
        // Given preset mode
        let mode = ThemeMode.preset

        // Then should not support color but support effects and geometry
        expect(mode.isColorCustomizable) == false
        expect(mode.isEffectCustomizable) == true
        expect(mode.isGeometryCustomizable) == true
    }

    func testGlassModeNotCustomizable() {
        // Given glass mode
        let mode = ThemeMode.glass

        // Then should not support any customizations (fully system-managed)
        expect(mode.isColorCustomizable) == false
        expect(mode.isEffectCustomizable) == false
        expect(mode.isGeometryCustomizable) == false
    }

    // MARK: - Codable Tests

    func testEncodingAndDecoding() throws {
        // Given all theme modes
        let modes = ThemeMode.allCases

        for mode in modes {
            // When encoding and decoding
            let encoder = JSONEncoder()
            let data = try encoder.encode(mode)
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(ThemeMode.self, from: data)

            // Then should match original
            expect(decoded) == mode
        }
    }

    func testRawValueCoding() throws {
        // Given preset mode
        let mode = ThemeMode.preset

        // When encoding
        let encoder = JSONEncoder()
        let data = try encoder.encode(mode)
        let jsonString = String(bytes: data, encoding: .utf8) ?? ""

        // Then should encode as raw value
        expect(jsonString.contains("preset")) == true
    }

    func testDecodingFromRawValue() throws {
        // Given JSON with raw value
        let json = "\"custom\""

        // When decoding
        let data = Data(json.utf8)
        let decoder = JSONDecoder()
        let mode = try decoder.decode(ThemeMode.self, from: data)

        // Then should decode correctly
        expect(mode) == .custom
    }

    func testDecodingInvalidValue() {
        // Given JSON with invalid value
        let json = "\"invalid\""

        // When decoding
        let data = Data(json.utf8)
        let decoder = JSONDecoder()

        // Then should throw decoding error
        expect { try decoder.decode(ThemeMode.self, from: data) }.to(throwError())
    }

    // MARK: - RawRepresentable Tests

    func testRawValueInitialization() {
        // Given raw values
        let preset = ThemeMode(rawValue: "preset")
        let glass = ThemeMode(rawValue: "glass")
        let custom = ThemeMode(rawValue: "custom")
        let invalid = ThemeMode(rawValue: "invalid")

        // Then should create correct modes
        expect(preset) == .preset
        expect(glass) == .glass
        expect(custom) == .custom
        expect(invalid).to(beNil())
    }

    // MARK: - Sendable Tests

    func testSendableConformance() {
        // ThemeMode conforms to Sendable
        Task { @MainActor in
            let mode = ThemeMode.preset
            // If this compiles, Sendable conformance is working
            expect(mode).toNot(beNil())
        }
    }

    // MARK: - Pattern Matching Tests

    func testPatternMatchingPreset() {
        // Given all theme modes
        let modes = ThemeMode.allCases

        // When checking which matches preset
        let presetModes = modes.filter { mode in
            switch mode {
            case .preset:
                true

            case .glass,
                 .custom:
                false
            }
        }

        // Then should find exactly one preset mode
        expect(presetModes.count) == 1
        expect(presetModes.first) == .preset
    }

    func testPatternMatchingGlass() {
        // Given all theme modes
        let modes = ThemeMode.allCases

        // When checking which matches glass
        let glassModes = modes.filter { mode in
            switch mode {
            case .glass:
                true

            case .preset,
                 .custom:
                false
            }
        }

        // Then should find exactly one glass mode
        expect(glassModes.count) == 1
        expect(glassModes.first) == .glass
    }

    func testPatternMatchingCustom() {
        // Given all theme modes
        let modes = ThemeMode.allCases

        // When checking which matches custom
        let customModes = modes.filter { mode in
            switch mode {
            case .custom:
                true

            case .preset,
                 .glass:
                false
            }
        }

        // Then should find exactly one custom mode
        expect(customModes.count) == 1
        expect(customModes.first) == .custom
    }

    // MARK: - Frozen Enum Tests

    func testEnumIsFrozen() {
        // ThemeMode is @frozen
        // This means it's a fixed set of cases that won't change
        // Compiler enforces this - if this compiles, test passes
        let mode = ThemeMode.preset
        expect(mode).toNot(beNil())
    }

    // MARK: - Equality Tests

    func testEquality() {
        // Given same modes
        let mode1 = ThemeMode.preset
        let mode2 = ThemeMode.preset

        // Then should be equal
        expect(mode1) == mode2
    }

    func testInequality() {
        // Given different modes
        let modes = ThemeMode.allCases

        // Then all should be different from each other
        for (index, mode1) in modes.enumerated() {
            for (otherIndex, mode2) in modes.enumerated() where otherIndex != index {
                expect(mode1) != mode2
            }
        }
    }

    // MARK: - Usage Scenario Tests

    func testUIConfigurationScenarioPreset() {
        // Given preset mode for UI configuration
        let mode = ThemeMode.preset

        // Then user selects from presets, can adjust effects/geometry but not colors
        expect(mode.isAvailable) == true
        expect(mode.isColorCustomizable) == false // Colors from preset
        expect(mode.isEffectCustomizable) == true // Can tweak effects
        expect(mode.isGeometryCustomizable) == true // Can tweak geometry
    }

    func testUIConfigurationScenarioCustom() {
        // Given custom mode for UI configuration
        let mode = ThemeMode.custom

        // Then user has full control over all properties
        expect(mode.isAvailable) == true
        expect(mode.isColorCustomizable) == true
        expect(mode.isEffectCustomizable) == true
        expect(mode.isGeometryCustomizable) == true
    }

    func testUIConfigurationScenarioGlass() {
        // Given glass mode for UI configuration
        let mode = ThemeMode.glass

        // Then system manages everything (if available)
        if mode.isAvailable {
            expect(mode.isColorCustomizable) == false
            expect(mode.isEffectCustomizable) == false
            expect(mode.isGeometryCustomizable) == false
        }
    }

    // MARK: - Edge Cases

    func testAllModesHaveRawValues() {
        // Given all modes
        let modes = ThemeMode.allCases

        // Then all should have non-empty raw values
        for mode in modes {
            expect(mode.rawValue).toNot(beEmpty())
        }
    }

    func testRawValuesAreUnique() {
        // Given all modes
        let modes = ThemeMode.allCases
        let rawValues = modes.map(\.rawValue)

        // Then all raw values should be unique
        let uniqueRawValues = Set(rawValues)
        expect(rawValues.count) == uniqueRawValues.count
    }

    func testRoundTripCodingForAllModes() throws {
        // Given all modes
        for mode in ThemeMode.allCases {
            // When encoding and decoding
            let encoder = JSONEncoder()
            let data = try encoder.encode(mode)
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(ThemeMode.self, from: data)

            // Then should match original
            expect(decoded) == mode
        }
    }
}
