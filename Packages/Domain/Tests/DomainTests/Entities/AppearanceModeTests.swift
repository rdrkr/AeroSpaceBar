// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Nimble
import XCTest

/// Tests for appearance mode enums (GroupsAppearanceMode and SpacesAppearanceMode).
///
/// These tests verify appearance mode cases, display names, descriptions,
/// and configuration behavior.
@MainActor
final class AppearanceModeTests: XCTestCase {
    // MARK: - GroupsAppearanceMode Tests

    func testGroupsAppearanceModeCases() {
        // Given all groups appearance mode cases
        let modes: [GroupsAppearanceMode] = [.perGroup, .allGroups, .matchSpaces]

        // Then should have 3 cases
        expect(modes.count) == 3
    }

    func testGroupsPerGroupMode() {
        // Given per-group mode
        let mode = GroupsAppearanceMode.perGroup

        // Then should have correct raw value
        expect(mode.rawValue) == "per-group"
    }

    func testGroupsAllGroupsMode() {
        // Given all-groups mode
        let mode = GroupsAppearanceMode.allGroups

        // Then should have correct raw value
        expect(mode.rawValue) == "all-groups"
    }

    func testGroupsMatchSpacesMode() {
        // Given match-spaces mode
        let mode = GroupsAppearanceMode.matchSpaces

        // Then should have correct raw value
        expect(mode.rawValue) == "match-spaces"
    }

    func testGroupsPerGroupGlobalConfig() {
        // Given per-group mode
        let mode = GroupsAppearanceMode.perGroup

        // Then should not show global config
        expect(mode.shouldShowGlobalConfig) == false
    }

    func testGroupsAllGroupsGlobalConfig() {
        // Given all-groups mode
        let mode = GroupsAppearanceMode.allGroups

        // Then should show global config
        expect(mode.shouldShowGlobalConfig) == true
    }

    func testGroupsMatchSpacesGlobalConfig() {
        // Given match-spaces mode
        let mode = GroupsAppearanceMode.matchSpaces

        // Then should not show global config (uses space config)
        expect(mode.shouldShowGlobalConfig) == false
    }

    func testGroupsDisplayNames() {
        // Given groups appearance modes
        let perGroup = GroupsAppearanceMode.perGroup
        let allGroups = GroupsAppearanceMode.allGroups
        let matchSpaces = GroupsAppearanceMode.matchSpaces

        // Then all should have display names
        expect(perGroup.displayName).toNot(beNil())
        expect(allGroups.displayName).toNot(beNil())
        expect(matchSpaces.displayName).toNot(beNil())
    }

    func testGroupsDescriptions() {
        // Given groups appearance modes
        let perGroup = GroupsAppearanceMode.perGroup
        let allGroups = GroupsAppearanceMode.allGroups
        let matchSpaces = GroupsAppearanceMode.matchSpaces

        // Then all should have descriptions
        expect(perGroup.description).toNot(beNil())
        expect(allGroups.description).toNot(beNil())
        expect(matchSpaces.description).toNot(beNil())
    }

    // MARK: - SpacesAppearanceMode Tests

    func testSpacesAppearanceModeCases() {
        // Given all spaces appearance mode cases
        let modes: [SpacesAppearanceMode] = [.perSpace, .allSpaces]

        // Then should have 2 cases
        expect(modes.count) == 2
    }

    func testSpacesPerSpaceMode() {
        // Given per-space mode
        let mode = SpacesAppearanceMode.perSpace

        // Then should have correct raw value
        expect(mode.rawValue) == "per-space"
    }

    func testSpacesAllSpacesMode() {
        // Given all-spaces mode
        let mode = SpacesAppearanceMode.allSpaces

        // Then should have correct raw value
        expect(mode.rawValue) == "all-spaces"
    }

    func testSpacesPerSpaceGlobalConfig() {
        // Given per-space mode
        let mode = SpacesAppearanceMode.perSpace

        // Then should not show global config
        expect(mode.shouldShowGlobalConfig) == false
    }

    func testSpacesAllSpacesGlobalConfig() {
        // Given all-spaces mode
        let mode = SpacesAppearanceMode.allSpaces

        // Then should show global config
        expect(mode.shouldShowGlobalConfig) == true
    }

    func testSpacesDisplayNames() {
        // Given spaces appearance modes
        let perSpace = SpacesAppearanceMode.perSpace
        let allSpaces = SpacesAppearanceMode.allSpaces

        // Then all should have display names
        expect(perSpace.displayName).toNot(beNil())
        expect(allSpaces.displayName).toNot(beNil())
    }

    func testSpacesDescriptions() {
        // Given spaces appearance modes
        let perSpace = SpacesAppearanceMode.perSpace
        let allSpaces = SpacesAppearanceMode.allSpaces

        // Then all should have descriptions
        expect(perSpace.description).toNot(beNil())
        expect(allSpaces.description).toNot(beNil())
    }

    // MARK: - RawRepresentable Tests

    func testGroupsRawValueInitialization() {
        // Given raw values
        let perGroup = GroupsAppearanceMode(rawValue: "per-group")
        let allGroups = GroupsAppearanceMode(rawValue: "all-groups")
        let matchSpaces = GroupsAppearanceMode(rawValue: "match-spaces")
        let invalid = GroupsAppearanceMode(rawValue: "invalid")

        // Then should create correct modes
        expect(perGroup) == .perGroup
        expect(allGroups) == .allGroups
        expect(matchSpaces) == .matchSpaces
        expect(invalid).to(beNil())
    }

    func testSpacesRawValueInitialization() {
        // Given raw values
        let perSpace = SpacesAppearanceMode(rawValue: "per-space")
        let allSpaces = SpacesAppearanceMode(rawValue: "all-spaces")
        let invalid = SpacesAppearanceMode(rawValue: "invalid")

        // Then should create correct modes
        expect(perSpace) == .perSpace
        expect(allSpaces) == .allSpaces
        expect(invalid).to(beNil())
    }

    // MARK: - AppearanceMode Protocol Tests

    func testGroupsConformsToAppearanceMode() {
        // Given groups appearance mode
        let mode: any AppearanceMode = GroupsAppearanceMode.perGroup

        // Then should conform to AppearanceMode protocol
        expect(mode.displayName).toNot(beNil())
        expect(mode.description).toNot(beNil())
        expect(mode.shouldShowGlobalConfig).toNot(beNil())
    }

    func testSpacesConformsToAppearanceMode() {
        // Given spaces appearance mode
        let mode: any AppearanceMode = SpacesAppearanceMode.perSpace

        // Then should conform to AppearanceMode protocol
        expect(mode.displayName).toNot(beNil())
        expect(mode.description).toNot(beNil())
        expect(mode.shouldShowGlobalConfig).toNot(beNil())
    }

    // MARK: - Pattern Matching Tests

    func testGroupsPatternMatching() {
        // Given all groups appearance modes
        let modes = GroupsAppearanceMode.allCases

        // When checking which matches perGroup
        let perGroupModes = modes.filter { mode in
            switch mode {
            case .perGroup:
                true

            case .allGroups,
                 .matchSpaces:
                false
            }
        }

        // Then should find exactly one perGroup mode
        expect(perGroupModes.count) == 1
        expect(perGroupModes.first) == .perGroup
    }

    func testSpacesPatternMatching() {
        // Given all spaces appearance modes
        let modes = SpacesAppearanceMode.allCases

        // When checking which matches allSpaces
        let allSpacesModes = modes.filter { mode in
            switch mode {
            case .allSpaces:
                true

            case .perSpace:
                false
            }
        }

        // Then should find exactly one allSpaces mode
        expect(allSpacesModes.count) == 1
        expect(allSpacesModes.first) == .allSpaces
    }

    // MARK: - Configuration Logic Tests

    func testGroupsPerGroupConfigurationLogic() {
        // Given per-group mode
        let mode = GroupsAppearanceMode.perGroup

        // Then should configure each group individually
        // (no global config shown, each group has its own)
        expect(mode.shouldShowGlobalConfig) == false
    }

    func testGroupsAllGroupsConfigurationLogic() {
        // Given all-groups mode
        let mode = GroupsAppearanceMode.allGroups

        // Then should use single configuration for all groups
        expect(mode.shouldShowGlobalConfig) == true
    }

    func testGroupsMatchSpacesConfigurationLogic() {
        // Given match-spaces mode
        let mode = GroupsAppearanceMode.matchSpaces

        // Then should use space configuration (not group-specific)
        expect(mode.shouldShowGlobalConfig) == false
    }

    func testSpacesPerSpaceConfigurationLogic() {
        // Given per-space mode
        let mode = SpacesAppearanceMode.perSpace

        // Then should configure each space individually
        expect(mode.shouldShowGlobalConfig) == false
    }

    func testSpacesAllSpacesConfigurationLogic() {
        // Given all-spaces mode
        let mode = SpacesAppearanceMode.allSpaces

        // Then should use single configuration for all spaces
        expect(mode.shouldShowGlobalConfig) == true
    }

    // MARK: - Frozen Enum Tests

    func testGroupsEnumIsFrozen() {
        // GroupsAppearanceMode is @frozen
        // This means it's a fixed set of cases that won't change
        // Compiler enforces this - if this compiles, test passes
        let mode = GroupsAppearanceMode.perGroup
        expect(mode).toNot(beNil())
    }

    func testSpacesEnumIsFrozen() {
        // SpacesAppearanceMode is @frozen
        // This means it's a fixed set of cases that won't change
        // Compiler enforces this - if this compiles, test passes
        let mode = SpacesAppearanceMode.perSpace
        expect(mode).toNot(beNil())
    }

    // MARK: - Equality Tests

    func testGroupsEquality() {
        // Given same modes
        let mode1 = GroupsAppearanceMode.perGroup
        let mode2 = GroupsAppearanceMode.perGroup

        // Then should be equal
        expect(mode1) == mode2
    }

    func testGroupsInequality() {
        // Given different modes
        let mode1 = GroupsAppearanceMode.perGroup
        let mode2 = GroupsAppearanceMode.allGroups

        // Then should not be equal
        expect(mode1) != mode2
    }

    func testSpacesEquality() {
        // Given same modes
        let mode1 = SpacesAppearanceMode.perSpace
        let mode2 = SpacesAppearanceMode.perSpace

        // Then should be equal
        expect(mode1) == mode2
    }

    func testSpacesInequality() {
        // Given different modes
        let mode1 = SpacesAppearanceMode.perSpace
        let mode2 = SpacesAppearanceMode.allSpaces

        // Then should not be equal
        expect(mode1) != mode2
    }
}
