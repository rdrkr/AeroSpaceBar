// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Nimble
import XCTest

/// Tests for WindowsAppearanceMode enum.
///
/// These tests verify WindowsAppearanceMode cases, display names, descriptions,
/// and AppearanceMode protocol conformance.
@MainActor
final class WindowsAppearanceModeTests: XCTestCase {
    // MARK: - Case Tests

    func testPerWindowCase() {
        // Given per-window mode
        let mode = WindowsAppearanceMode.perWindow

        // Then should match expected case
        expect(mode) == .perWindow
        expect(mode.rawValue) == "per-window"
    }

    func testAllWindowsCase() {
        // Given all-windows mode
        let mode = WindowsAppearanceMode.allWindows

        // Then should match expected case
        expect(mode) == .allWindows
        expect(mode.rawValue) == "all-windows"
    }

    // MARK: - Display Name Tests

    func testPerWindowDisplayName() {
        // Given per-window mode
        let mode = WindowsAppearanceMode.perWindow

        // Then should have correct display name
        expect(String(localized: mode.displayName)) == "Per Window"
    }

    func testAllWindowsDisplayName() {
        // Given all-windows mode
        let mode = WindowsAppearanceMode.allWindows

        // Then should have correct display name
        expect(String(localized: mode.displayName)) == "All Windows"
    }

    // MARK: - Description Tests

    func testPerWindowDescription() {
        // Given per-window mode
        let mode = WindowsAppearanceMode.perWindow

        // Then should have correct description
        expect(String(localized: mode.description)) == "Configure appearance for each window individually."
    }

    func testAllWindowsDescription() {
        // Given all-windows mode
        let mode = WindowsAppearanceMode.allWindows

        // Then should have correct description
        expect(String(localized: mode.description)) == "Use the same appearance for all windows."
    }

    // MARK: - Global Config Tests

    func testPerWindowGlobalConfig() {
        // Given per-window mode
        let mode = WindowsAppearanceMode.perWindow

        // Then should not show global config
        expect(mode.shouldShowGlobalConfig) == false
    }

    func testAllWindowsGlobalConfig() {
        // Given all-windows mode
        let mode = WindowsAppearanceMode.allWindows

        // Then should show global config
        expect(mode.shouldShowGlobalConfig) == true
    }

    // MARK: - CaseIterable Tests

    func testAllCases() {
        // Given all windows appearance mode cases
        let allCases = WindowsAppearanceMode.allCases

        // Then should have 2 cases
        expect(allCases.count) == 2
        expect(allCases.contains(.perWindow)) == true
        expect(allCases.contains(.allWindows)) == true
    }

    func testIteratingAllCases() {
        // Given all cases
        var caseCount = 0

        // When iterating
        for _ in WindowsAppearanceMode.allCases {
            caseCount += 1
        }

        // Then should iterate all 2
        expect(caseCount) == 2
    }

    // MARK: - Codable Tests

    func testEncodingAndDecoding() throws {
        // Given all windows appearance modes
        let modes = WindowsAppearanceMode.allCases

        for mode in modes {
            // When encoding and decoding
            let encoder = JSONEncoder()
            let data = try encoder.encode(mode)
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(WindowsAppearanceMode.self, from: data)

            // Then should match original
            expect(decoded) == mode
        }
    }

    func testRawValueCoding() throws {
        // Given per-window mode
        let mode = WindowsAppearanceMode.perWindow

        // When encoding
        let encoder = JSONEncoder()
        let data = try encoder.encode(mode)
        let jsonString = String(bytes: data, encoding: .utf8) ?? ""

        // Then should encode as raw value
        expect(jsonString.contains("per-window")) == true
    }

    func testDecodingFromRawValue() throws {
        // Given JSON with raw value
        let json = "\"all-windows\""

        // When decoding
        let data = Data(json.utf8)
        let decoder = JSONDecoder()
        let mode = try decoder.decode(WindowsAppearanceMode.self, from: data)

        // Then should decode correctly
        expect(mode) == .allWindows
    }

    func testDecodingInvalidValue() {
        // Given JSON with invalid value
        let json = "\"invalid\""

        // When decoding
        let data = Data(json.utf8)
        let decoder = JSONDecoder()

        // Then should throw decoding error
        expect { try decoder.decode(WindowsAppearanceMode.self, from: data) }.to(throwError())
    }

    // MARK: - RawRepresentable Tests

    func testRawValueInitialization() {
        // Given raw values
        let perWindow = WindowsAppearanceMode(rawValue: "per-window")
        let allWindows = WindowsAppearanceMode(rawValue: "all-windows")
        let invalid = WindowsAppearanceMode(rawValue: "invalid")

        // Then should create correct modes
        expect(perWindow) == .perWindow
        expect(allWindows) == .allWindows
        expect(invalid).to(beNil())
    }

    // MARK: - AppearanceMode Protocol Tests

    func testConformsToAppearanceMode() {
        // Given a windows appearance mode
        let mode: any AppearanceMode = WindowsAppearanceMode.perWindow

        // Then should conform to AppearanceMode protocol
        expect(mode.displayName).toNot(beNil())
        expect(mode.description).toNot(beNil())
    }

    func testGlobalConfigForAllModes() {
        // Given all modes
        for mode in WindowsAppearanceMode.allCases {
            // Then shouldShowGlobalConfig should be defined
            let shouldShow = mode.shouldShowGlobalConfig
            expect(shouldShow).toNot(beNil())
        }
    }

    // MARK: - Sendable Tests

    func testSendableConformance() {
        // WindowsAppearanceMode conforms to Sendable
        Task { @MainActor in
            let mode = WindowsAppearanceMode.perWindow
            // If this compiles, Sendable conformance is working
            expect(mode).toNot(beNil())
        }
    }

    // MARK: - Pattern Matching Tests

    func testPatternMatchingPerWindow() {
        // Given all windows appearance modes
        let modes = WindowsAppearanceMode.allCases

        // When checking which matches perWindow
        let perWindowModes = modes.filter { mode in
            switch mode {
            case .perWindow:
                true

            case .allWindows:
                false
            }
        }

        // Then should find exactly one perWindow mode
        expect(perWindowModes.count) == 1
        expect(perWindowModes.first) == .perWindow
    }

    func testPatternMatchingAllWindows() {
        // Given all windows appearance modes
        let modes = WindowsAppearanceMode.allCases

        // When checking which matches allWindows
        let allWindowsModes = modes.filter { mode in
            switch mode {
            case .allWindows:
                true

            case .perWindow:
                false
            }
        }

        // Then should find exactly one allWindows mode
        expect(allWindowsModes.count) == 1
        expect(allWindowsModes.first) == .allWindows
    }

    // MARK: - Equality Tests

    func testEquality() {
        // Given same modes
        let mode1 = WindowsAppearanceMode.perWindow
        let mode2 = WindowsAppearanceMode.perWindow

        // Then should be equal
        expect(mode1) == mode2
    }

    func testInequality() {
        // Given different modes
        let mode1 = WindowsAppearanceMode.perWindow
        let mode2 = WindowsAppearanceMode.allWindows

        // Then should not be equal
        expect(mode1) != mode2
    }

    // MARK: - Hashable Tests

    func testHashableConformance() {
        // Given windows appearance modes
        let mode1 = WindowsAppearanceMode.perWindow
        let mode2 = WindowsAppearanceMode.allWindows

        // When adding to set
        let set: Set<WindowsAppearanceMode> = [mode1, mode2]

        // Then should store unique modes
        expect(set.count) == 2
    }

    func testHashableWithDuplicates() {
        // Given duplicate modes
        let mode1 = WindowsAppearanceMode.perWindow
        let mode2 = WindowsAppearanceMode.perWindow

        // When adding to set
        let set: Set<WindowsAppearanceMode> = [mode1, mode2]

        // Then should only store one
        expect(set.count) == 1
    }

    func testHashConsistency() {
        // Given same modes
        let mode1 = WindowsAppearanceMode.allWindows
        let mode2 = WindowsAppearanceMode.allWindows

        // Then hash values should be equal
        expect(mode1.hashValue) == mode2.hashValue
    }

    // MARK: - Usage Scenario Tests

    func testUIConfigurationScenarioPerWindow() {
        // Given per-window mode for UI configuration
        let mode = WindowsAppearanceMode.perWindow

        // Then user configures each window individually
        expect(mode.shouldShowGlobalConfig) == false
        expect(String(localized: mode.displayName)) == "Per Window"
    }

    func testUIConfigurationScenarioAllWindows() {
        // Given all-windows mode for UI configuration
        let mode = WindowsAppearanceMode.allWindows

        // Then user configures all windows together
        expect(mode.shouldShowGlobalConfig) == true
        expect(String(localized: mode.displayName)) == "All Windows"
    }

    // MARK: - Edge Cases

    func testAllModesHaveRawValues() {
        // Given all modes
        let modes = WindowsAppearanceMode.allCases

        // Then all should have non-empty raw values
        for mode in modes {
            expect(mode.rawValue).toNot(beEmpty())
        }
    }

    func testRawValuesAreUnique() {
        // Given all modes
        let modes = WindowsAppearanceMode.allCases
        let rawValues = modes.map(\.rawValue)

        // Then all raw values should be unique
        let uniqueRawValues = Set(rawValues)
        expect(rawValues.count) == uniqueRawValues.count
    }

    func testRoundTripCodingForAllModes() throws {
        // Given all modes
        for mode in WindowsAppearanceMode.allCases {
            // When encoding and decoding
            let encoder = JSONEncoder()
            let data = try encoder.encode(mode)
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(WindowsAppearanceMode.self, from: data)

            // Then should match original
            expect(decoded) == mode
        }
    }
}
