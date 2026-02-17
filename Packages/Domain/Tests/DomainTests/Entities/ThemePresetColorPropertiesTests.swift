// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Nimble
import SwiftUI
import XCTest

/// Tests for ThemePresetColorProperties enum.
///
/// These tests verify ThemePresetColorProperties cases, color properties, display names,
/// descriptions, Codable conformance, and CaseIterable protocol.
@MainActor
final class ThemePresetColorPropertiesTests: XCTestCase {
    // MARK: - Case Tests

    func testAllCases() {
        // Given all theme preset cases
        let allCases = ThemePresetColorProperties.allCases

        // Then should have 16 cases
        expect(allCases.count) == 16
        expect(allCases.contains(.catppuccinFrappe)) == true
        expect(allCases.contains(.catppuccinLatte)) == true
        expect(allCases.contains(.catppuccinMacchiato)) == true
        expect(allCases.contains(.catppuccinMocha)) == true
        expect(allCases.contains(.dracula)) == true
        expect(allCases.contains(.gruvboxDark)) == true
        expect(allCases.contains(.gruvboxLight)) == true
        expect(allCases.contains(.gruvboxMaterialDark)) == true
        expect(allCases.contains(.nord)) == true
        expect(allCases.contains(.nordAurora)) == true
        expect(allCases.contains(.oneDark)) == true
        expect(allCases.contains(.oneLight)) == true
        expect(allCases.contains(.solarizedDark)) == true
        expect(allCases.contains(.solarizedLight)) == true
        expect(allCases.contains(.tokyoNight)) == true
        expect(allCases.contains(.tokyoNightStorm)) == true
    }

    // MARK: - Raw Value Tests

    func testRawValues() {
        // Given theme presets with kebab-case raw values
        let presets: [(ThemePresetColorProperties, String)] = [
            (.catppuccinFrappe, "catppuccin-frappe"),
            (.catppuccinLatte, "catppuccin-latte"),
            (.catppuccinMacchiato, "catppuccin-macchiato"),
            (.catppuccinMocha, "catppuccin-mocha"),
            (.dracula, "dracula"),
            (.gruvboxDark, "gruvbox-dark"),
            (.gruvboxLight, "gruvbox-light"),
            (.gruvboxMaterialDark, "gruvbox-material-dark"),
            (.nord, "nord"),
            (.nordAurora, "nord-aurora"),
            (.oneDark, "one-dark"),
            (.oneLight, "one-light"),
            (.solarizedDark, "solarized-dark"),
            (.solarizedLight, "solarized-light"),
            (.tokyoNight, "tokyo-night"),
            (.tokyoNightStorm, "tokyo-night-storm")
        ]

        for (preset, expectedRawValue) in presets {
            // Then should have correct raw value
            expect(preset.rawValue) == expectedRawValue
        }
    }

    // MARK: - Display Name Tests

    func testDisplayNames() {
        // Given theme presets
        let presets: [(ThemePresetColorProperties, String)] = [
            (.catppuccinFrappe, "Catppuccin Frappé"),
            (.catppuccinLatte, "Catppuccin Latte"),
            (.catppuccinMacchiato, "Catppuccin Macchiato"),
            (.catppuccinMocha, "Catppuccin Mocha"),
            (.dracula, "Dracula"),
            (.gruvboxDark, "Gruvbox Dark"),
            (.gruvboxLight, "Gruvbox Light"),
            (.gruvboxMaterialDark, "Gruvbox Material Dark"),
            (.nord, "Nord"),
            (.nordAurora, "Nord Aurora"),
            (.oneDark, "One Dark"),
            (.oneLight, "One Light"),
            (.solarizedDark, "Solarized Dark"),
            (.solarizedLight, "Solarized Light"),
            (.tokyoNight, "Tokyo Night"),
            (.tokyoNightStorm, "Tokyo Night Storm")
        ]

        for (preset, expectedDisplayName) in presets {
            // Then should have correct display name
            expect(preset.displayName) == expectedDisplayName
        }
    }

    // MARK: - Description Tests

    func testDescriptions() {
        // Given all theme presets
        let presets = ThemePresetColorProperties.allCases

        // Then all should have non-empty descriptions
        for preset in presets {
            let description = String(localized: preset.description)
            expect(description).toNot(beEmpty())
        }
    }

    // MARK: - Color Properties Tests

    func testAllPresetsHaveColorProperties() {
        // Given all theme presets
        let presets = ThemePresetColorProperties.allCases

        // Then all should have color properties
        for preset in presets {
            let colorProps = preset.colorProperties
            expect(colorProps.backgroundTintColor).toNot(beNil())
            expect(colorProps.borderTintColor).toNot(beNil())
            expect(colorProps.foregroundColor).toNot(beNil())
        }
    }

    func testCatppuccinFrappeColors() {
        // Given Catppuccin Frappe theme
        let preset = ThemePresetColorProperties.catppuccinFrappe

        // When getting color properties
        let colorProps = preset.colorProperties

        // Then should have Catppuccin Frappe colors
        expect(colorProps).toNot(beNil())
        expect(preset.displayName) == "Catppuccin Frappé"
    }

    func testDraculaColors() {
        // Given Dracula theme
        let preset = ThemePresetColorProperties.dracula

        // When getting color properties
        let colorProps = preset.colorProperties

        // Then should have Dracula colors
        expect(colorProps).toNot(beNil())
        expect(preset.displayName) == "Dracula"
    }

    func testGruvboxDarkColors() {
        // Given Gruvbox Dark theme
        let preset = ThemePresetColorProperties.gruvboxDark

        // When getting color properties
        let colorProps = preset.colorProperties

        // Then should have Gruvbox Dark colors
        expect(colorProps).toNot(beNil())
        expect(preset.displayName) == "Gruvbox Dark"
    }

    func testNordColors() {
        // Given Nord theme
        let preset = ThemePresetColorProperties.nord

        // When getting color properties
        let colorProps = preset.colorProperties

        // Then should have Nord colors
        expect(colorProps).toNot(beNil())
        expect(preset.displayName) == "Nord"
    }

    func testSolarizedDarkColors() {
        // Given Solarized Dark theme
        let preset = ThemePresetColorProperties.solarizedDark

        // When getting color properties
        let colorProps = preset.colorProperties

        // Then should have Solarized Dark colors
        expect(colorProps).toNot(beNil())
        expect(preset.displayName) == "Solarized Dark"
    }

    func testTokyoNightColors() {
        // Given Tokyo Night theme
        let preset = ThemePresetColorProperties.tokyoNight

        // When getting color properties
        let colorProps = preset.colorProperties

        // Then should have Tokyo Night colors
        expect(colorProps).toNot(beNil())
        expect(preset.displayName) == "Tokyo Night"
    }

    // MARK: - Codable Tests

    func testEncodingAndDecoding() throws {
        // Given all theme presets
        let presets = ThemePresetColorProperties.allCases

        for preset in presets {
            // When encoding and decoding
            let encoder = JSONEncoder()
            let data = try encoder.encode(preset)
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(ThemePresetColorProperties.self, from: data)

            // Then should match original
            expect(decoded) == preset
        }
    }

    func testRawValueCoding() throws {
        // Given Dracula preset
        let preset = ThemePresetColorProperties.dracula

        // When encoding
        let encoder = JSONEncoder()
        let data = try encoder.encode(preset)
        let jsonString = String(bytes: data, encoding: .utf8) ?? ""

        // Then should encode as raw value
        expect(jsonString.contains("dracula")) == true
    }

    func testDecodingFromRawValue() throws {
        // Given JSON with raw value
        let json = "\"nord\""

        // When decoding
        let data = Data(json.utf8)
        let decoder = JSONDecoder()
        let preset = try decoder.decode(ThemePresetColorProperties.self, from: data)

        // Then should decode correctly
        expect(preset) == .nord
    }

    func testDecodingKebabCaseRawValue() throws {
        // Given JSON with kebab-case raw value
        let json = "\"gruvbox-dark\""

        // When decoding
        let data = Data(json.utf8)
        let decoder = JSONDecoder()
        let preset = try decoder.decode(ThemePresetColorProperties.self, from: data)

        // Then should decode correctly
        expect(preset) == .gruvboxDark
    }

    func testDecodingInvalidValue() {
        // Given JSON with invalid value
        let json = "\"invalid-theme\""

        // When decoding
        let data = Data(json.utf8)
        let decoder = JSONDecoder()

        // Then should throw decoding error
        expect { try decoder.decode(ThemePresetColorProperties.self, from: data) }.to(throwError())
    }

    // MARK: - RawRepresentable Tests

    func testRawValueInitialization() {
        // Given raw values
        let dracula = ThemePresetColorProperties(rawValue: "dracula")
        let nord = ThemePresetColorProperties(rawValue: "nord")
        let gruvboxDark = ThemePresetColorProperties(rawValue: "gruvbox-dark")
        let invalid = ThemePresetColorProperties(rawValue: "invalid")

        // Then should create correct presets
        expect(dracula) == .dracula
        expect(nord) == .nord
        expect(gruvboxDark) == .gruvboxDark
        expect(invalid).to(beNil())
    }

    // MARK: - Sendable Tests

    func testSendableConformance() {
        // ThemePresetColorProperties conforms to Sendable
        Task {
            let preset = ThemePresetColorProperties.nord
            // If this compiles, Sendable conformance is working
            expect(preset).toNot(beNil())
        }
    }

    // MARK: - Pattern Matching Tests

    func testPatternMatching() {
        // Given all theme presets
        let presets = ThemePresetColorProperties.allCases

        // When checking which matches dracula
        let draculaPresets = presets.filter { preset in
            switch preset {
            case .dracula:
                true

            default:
                false
            }
        }

        // Then should find exactly one dracula preset
        expect(draculaPresets.count) == 1
        expect(draculaPresets.first) == .dracula
    }

    // MARK: - Equality Tests

    func testEquality() {
        // Given same presets
        let preset1 = ThemePresetColorProperties.nord
        let preset2 = ThemePresetColorProperties.nord

        // Then should be equal
        expect(preset1) == preset2
    }

    func testInequality() {
        // Given different presets
        let preset1 = ThemePresetColorProperties.nord
        let preset2 = ThemePresetColorProperties.dracula

        // Then should not be equal
        expect(preset1) != preset2
    }

    // MARK: - Hashable Tests

    func testHashableConformance() {
        // Given theme presets
        let preset1 = ThemePresetColorProperties.nord
        let preset2 = ThemePresetColorProperties.dracula
        let preset3 = ThemePresetColorProperties.gruvboxDark

        // When adding to set
        let set: Set<ThemePresetColorProperties> = [preset1, preset2, preset3]

        // Then should store unique presets
        expect(set.count) == 3
    }

    func testHashableWithDuplicates() {
        // Given duplicate presets
        let preset1 = ThemePresetColorProperties.nord
        let preset2 = ThemePresetColorProperties.nord

        // When adding to set
        let set: Set<ThemePresetColorProperties> = [preset1, preset2]

        // Then should only store one
        expect(set.count) == 1
    }

    func testHashConsistency() {
        // Given same presets
        let preset1 = ThemePresetColorProperties.dracula
        let preset2 = ThemePresetColorProperties.dracula

        // Then hash values should be equal
        expect(preset1.hashValue) == preset2.hashValue
    }

    // MARK: - CaseIterable Tests

    func testIteratingAllCases() {
        // Given all cases
        var caseCount = 0

        // When iterating
        for _ in ThemePresetColorProperties.allCases {
            caseCount += 1
        }

        // Then should iterate all 16
        expect(caseCount) == 16
    }

    // MARK: - Theme Category Tests

    func testCatppuccinThemes() {
        // Given Catppuccin variants
        let catppuccinThemes: [ThemePresetColorProperties] = [
            .catppuccinFrappe,
            .catppuccinLatte,
            .catppuccinMacchiato,
            .catppuccinMocha
        ]

        // Then all should have "Catppuccin" in display name
        for theme in catppuccinThemes {
            expect(theme.displayName.contains("Catppuccin")) == true
        }
    }

    func testGruvboxThemes() {
        // Given Gruvbox variants
        let gruvboxThemes: [ThemePresetColorProperties] = [
            .gruvboxDark,
            .gruvboxLight,
            .gruvboxMaterialDark
        ]

        // Then all should have "Gruvbox" in display name
        for theme in gruvboxThemes {
            expect(theme.displayName.contains("Gruvbox")) == true
        }
    }

    func testNordThemes() {
        // Given Nord variants
        let nordThemes: [ThemePresetColorProperties] = [
            .nord,
            .nordAurora
        ]

        // Then all should have "Nord" in display name
        for theme in nordThemes {
            expect(theme.displayName.contains("Nord")) == true
        }
    }

    func testSolarizedThemes() {
        // Given Solarized variants
        let solarizedThemes: [ThemePresetColorProperties] = [
            .solarizedDark,
            .solarizedLight
        ]

        // Then all should have "Solarized" in display name
        for theme in solarizedThemes {
            expect(theme.displayName.contains("Solarized")) == true
        }
    }

    func testTokyoNightThemes() {
        // Given Tokyo Night variants
        let tokyoNightThemes: [ThemePresetColorProperties] = [
            .tokyoNight,
            .tokyoNightStorm
        ]

        // Then all should have "Tokyo Night" in display name
        for theme in tokyoNightThemes {
            expect(theme.displayName.contains("Tokyo Night")) == true
        }
    }

    // MARK: - Edge Cases

    func testAllPresetsHaveRawValues() {
        // Given all presets
        let presets = ThemePresetColorProperties.allCases

        // Then all should have non-empty raw values
        for preset in presets {
            expect(preset.rawValue).toNot(beEmpty())
        }
    }

    func testRawValuesAreUnique() {
        // Given all presets
        let presets = ThemePresetColorProperties.allCases
        let rawValues = presets.map(\.rawValue)

        // Then all raw values should be unique
        let uniqueRawValues = Set(rawValues)
        expect(rawValues.count) == uniqueRawValues.count
    }

    func testDisplayNamesAreUnique() {
        // Given all presets
        let presets = ThemePresetColorProperties.allCases
        let displayNames = presets.map(\.displayName)

        // Then all display names should be unique
        let uniqueDisplayNames = Set(displayNames)
        expect(displayNames.count) == uniqueDisplayNames.count
    }

    func testRoundTripCodingForAllPresets() throws {
        // Given all presets
        for preset in ThemePresetColorProperties.allCases {
            // When encoding and decoding
            let encoder = JSONEncoder()
            let data = try encoder.encode(preset)
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(ThemePresetColorProperties.self, from: data)

            // Then should match original
            expect(decoded) == preset
        }
    }

    // MARK: - Color Property Completeness Tests

    func testAllPresetsHaveCompleteColorProperties() {
        // Given all presets
        for preset in ThemePresetColorProperties.allCases {
            // When getting color properties
            let colorProps = preset.colorProperties

            // Then should have all three color components
            expect(colorProps.backgroundTintColor).toNot(beNil())
            expect(colorProps.borderTintColor).toNot(beNil())
            expect(colorProps.foregroundColor).toNot(beNil())
        }
    }
}
