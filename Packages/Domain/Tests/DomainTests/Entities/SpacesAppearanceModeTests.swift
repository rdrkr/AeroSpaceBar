// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

@testable import Domain
import Nimble
import XCTest

/// Tests for SpacesAppearanceMode enum.
///
/// These tests verify spaces appearance mode behavior including:
/// - Enum cases and raw values
/// - Display names and descriptions
/// - Global config visibility logic
/// - AppearanceMode protocol conformance
final class SpacesAppearanceModeTests: XCTestCase {
    // MARK: - Enum Cases Tests

    func testAllCases() {
        // Given SpacesAppearanceMode
        // When accessing all cases
        let allCases = SpacesAppearanceMode.allCases

        // Then should have exactly 2 cases
        expect(allCases.count) == 2
        expect(allCases.contains(.perSpace)) == true
        expect(allCases.contains(.allSpaces)) == true
    }

    func testRawValues() {
        // Given appearance modes
        // Then each should have correct raw value
        expect(SpacesAppearanceMode.perSpace.rawValue) == "per-space"
        expect(SpacesAppearanceMode.allSpaces.rawValue) == "all-spaces"
    }

    func testInitFromRawValue() {
        // Given raw values
        // When initializing from raw values
        // Then should create correct modes
        expect(SpacesAppearanceMode(rawValue: "per-space")) == .perSpace
        expect(SpacesAppearanceMode(rawValue: "all-spaces")) == .allSpaces
        expect(SpacesAppearanceMode(rawValue: "invalid")).to(beNil())
    }

    // MARK: - Display Name Tests

    func testDisplayNames() {
        // Given appearance modes
        // Then each should have appropriate display name
        expect(String(localized: SpacesAppearanceMode.perSpace.displayName)) == "Per Space"
        expect(String(localized: SpacesAppearanceMode.allSpaces.displayName)) == "All Spaces"
    }

    // MARK: - Description Tests

    func testDescriptions() {
        // Given appearance modes
        // Then each should have appropriate description
        let perSpaceDesc = String(localized: SpacesAppearanceMode.perSpace.description)
        let allSpacesDesc = String(localized: SpacesAppearanceMode.allSpaces.description)

        expect(perSpaceDesc.contains("each space")) == true
        expect(allSpacesDesc.contains("same appearance")) == true
    }

    // MARK: - Global Config Visibility Tests

    func testShouldShowGlobalConfigForPerSpace() {
        // Given perSpace mode
        let mode = SpacesAppearanceMode.perSpace

        // When checking shouldShowGlobalConfig
        // Then should be false (each space has individual config)
        expect(mode.shouldShowGlobalConfig) == false
    }

    func testShouldShowGlobalConfigForAllSpaces() {
        // Given allSpaces mode
        let mode = SpacesAppearanceMode.allSpaces

        // When checking shouldShowGlobalConfig
        // Then should be true (all spaces share config)
        expect(mode.shouldShowGlobalConfig) == true
    }

    // MARK: - Protocol Conformance Tests

    func testConformsToAppearanceMode() {
        /// Given SpacesAppearanceMode
        /// Then should conform to AppearanceMode protocol
        func assertIsAppearanceMode(_ value: some AppearanceMode) {
            expect(value.displayName).toNot(beNil())
            expect(value.description).toNot(beNil())
        }

        assertIsAppearanceMode(SpacesAppearanceMode.perSpace)
        assertIsAppearanceMode(SpacesAppearanceMode.allSpaces)
    }

    func testConformsToCaseIterable() {
        // Given SpacesAppearanceMode
        // Then should conform to CaseIterable
        let _: any CaseIterable.Type = SpacesAppearanceMode.self
    }

    func testConformsToRawRepresentable() {
        // Given SpacesAppearanceMode
        // Then should conform to RawRepresentable with String
        let _: any RawRepresentable.Type = SpacesAppearanceMode.self
    }

    // MARK: - Equatable Tests

    func testEquality() {
        // Given appearance modes
        // Then equality should work correctly
        expect(SpacesAppearanceMode.perSpace) == .perSpace
        expect(SpacesAppearanceMode.allSpaces) == .allSpaces

        expect(SpacesAppearanceMode.perSpace) != .allSpaces
    }

    // MARK: - Logic Tests

    func testGlobalConfigLogicConsistency() {
        // Given all appearance modes
        let allCases = SpacesAppearanceMode.allCases

        // Then only allSpaces should show global config
        let modesShowingGlobalConfig = allCases.filter(\.shouldShowGlobalConfig)
        expect(modesShowingGlobalConfig.count) == 1
        expect(modesShowingGlobalConfig.first) == .allSpaces
    }

    // MARK: - Comparison with GroupsAppearanceMode

    func testDifferentFromGroupsAppearanceMode() {
        // Given SpacesAppearanceMode
        // Then should have 2 cases (vs 3 for GroupsAppearanceMode)
        expect(SpacesAppearanceMode.allCases.count) == 2

        // And should not have matchSpaces equivalent
        let rawValues = SpacesAppearanceMode.allCases.map(\.rawValue)
        expect(rawValues.contains("match-spaces")) == false
    }
}
