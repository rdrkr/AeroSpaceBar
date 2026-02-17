// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

@testable import Domain
import Nimble
import XCTest

/// Tests for GroupsAppearanceMode enum.
///
/// These tests verify groups appearance mode behavior including:
/// - Enum cases and raw values
/// - Display names and descriptions
/// - Global config visibility logic
/// - AppearanceMode protocol conformance
final class GroupsAppearanceModeTests: XCTestCase {
    // MARK: - Enum Cases Tests

    func testAllCases() {
        // Given GroupsAppearanceMode
        // When accessing all cases
        let allCases = GroupsAppearanceMode.allCases

        // Then should have exactly 3 cases
        expect(allCases.count) == 3
        expect(allCases.contains(.perGroup)) == true
        expect(allCases.contains(.allGroups)) == true
        expect(allCases.contains(.matchSpaces)) == true
    }

    func testRawValues() {
        // Given appearance modes
        // Then each should have correct raw value
        expect(GroupsAppearanceMode.perGroup.rawValue) == "per-group"
        expect(GroupsAppearanceMode.allGroups.rawValue) == "all-groups"
        expect(GroupsAppearanceMode.matchSpaces.rawValue) == "match-spaces"
    }

    func testInitFromRawValue() {
        // Given raw values
        // When initializing from raw values
        // Then should create correct modes
        expect(GroupsAppearanceMode(rawValue: "per-group")) == .perGroup
        expect(GroupsAppearanceMode(rawValue: "all-groups")) == .allGroups
        expect(GroupsAppearanceMode(rawValue: "match-spaces")) == .matchSpaces
        expect(GroupsAppearanceMode(rawValue: "invalid")).to(beNil())
    }

    // MARK: - Display Name Tests

    func testDisplayNames() {
        // Given appearance modes
        // Then each should have appropriate display name
        expect(String(localized: GroupsAppearanceMode.perGroup.displayName)) == "Per Group"
        expect(String(localized: GroupsAppearanceMode.allGroups.displayName)) == "All Groups"
        expect(String(localized: GroupsAppearanceMode.matchSpaces.displayName)) == "Match Spaces"
    }

    // MARK: - Description Tests

    func testDescriptions() {
        // Given appearance modes
        // Then each should have appropriate description
        let perGroupDesc = String(localized: GroupsAppearanceMode.perGroup.description)
        let allGroupsDesc = String(localized: GroupsAppearanceMode.allGroups.description)
        let matchSpacesDesc = String(localized: GroupsAppearanceMode.matchSpaces.description)

        expect(perGroupDesc.contains("each group")) == true
        expect(allGroupsDesc.contains("same appearance")) == true
        expect(matchSpacesDesc.contains("same appearance as spaces")) == true
    }

    // MARK: - Global Config Visibility Tests

    func testShouldShowGlobalConfigForPerGroup() {
        // Given perGroup mode
        let mode = GroupsAppearanceMode.perGroup

        // When checking shouldShowGlobalConfig
        // Then should be false (each group has individual config)
        expect(mode.shouldShowGlobalConfig) == false
    }

    func testShouldShowGlobalConfigForAllGroups() {
        // Given allGroups mode
        let mode = GroupsAppearanceMode.allGroups

        // When checking shouldShowGlobalConfig
        // Then should be true (all groups share config)
        expect(mode.shouldShowGlobalConfig) == true
    }

    func testShouldShowGlobalConfigForMatchSpaces() {
        // Given matchSpaces mode
        let mode = GroupsAppearanceMode.matchSpaces

        // When checking shouldShowGlobalConfig
        // Then should be false (uses spaces config)
        expect(mode.shouldShowGlobalConfig) == false
    }

    // MARK: - Protocol Conformance Tests

    func testConformsToAppearanceMode() {
        /// Given GroupsAppearanceMode
        /// Then should conform to AppearanceMode protocol
        func assertIsAppearanceMode(_ value: some AppearanceMode) {
            expect(value.displayName).toNot(beNil())
            expect(value.description).toNot(beNil())
        }

        assertIsAppearanceMode(GroupsAppearanceMode.perGroup)
        assertIsAppearanceMode(GroupsAppearanceMode.allGroups)
        assertIsAppearanceMode(GroupsAppearanceMode.matchSpaces)
    }

    func testConformsToCaseIterable() {
        // Given GroupsAppearanceMode
        // Then should conform to CaseIterable
    }

    func testConformsToRawRepresentable() {
        // Given GroupsAppearanceMode
        // Then should conform to RawRepresentable with String
    }

    // MARK: - Equatable Tests

    func testEquality() {
        // Given appearance modes
        // Then equality should work correctly
        expect(GroupsAppearanceMode.perGroup) == .perGroup
        expect(GroupsAppearanceMode.allGroups) == .allGroups
        expect(GroupsAppearanceMode.matchSpaces) == .matchSpaces

        expect(GroupsAppearanceMode.perGroup) != .allGroups
        expect(GroupsAppearanceMode.perGroup) != .matchSpaces
        expect(GroupsAppearanceMode.allGroups) != .matchSpaces
    }

    // MARK: - Logic Tests

    func testGlobalConfigLogicConsistency() {
        // Given all appearance modes
        let allCases = GroupsAppearanceMode.allCases

        // Then only allGroups should show global config
        let modesShowingGlobalConfig = allCases.filter(\.shouldShowGlobalConfig)
        expect(modesShowingGlobalConfig.count) == 1
        expect(modesShowingGlobalConfig.first) == .allGroups
    }
}
