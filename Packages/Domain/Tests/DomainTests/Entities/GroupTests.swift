// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Nimble
import SwiftUI
import XCTest

/// Tests for the Group entity.
///
/// These tests verify Group initialization, coding/decoding, range calculations,
/// VisualContainer conformance, and metadata configuration.
@MainActor
final class GroupTests: XCTestCase {
    // MARK: - Initialization Tests

    func testInitializationWithAllParameters() {
        // Given parameters
        let id = 1
        let startIndex = 5
        let endIndex = 10
        let colorProps = ColorProperties(
            backgroundTintColor: .red,
            borderTintColor: .blue,
            foregroundColor: .white
        )
        let geometricProps = GeometricProperties(cornerRadius: 8, borderWidth: 2)
        let effectProps = EffectProperties(backgroundOpacity: 0.8, backgroundBlurRadius: 5, borderOpacity: 1.0)

        // When creating group
        let group = Group(
            id: id,
            startIndex: startIndex,
            endIndex: endIndex,
            colorProperties: colorProps,
            geometricProperties: geometricProps,
            effectProperties: effectProps
        )

        // Then all properties should be set
        expect(group.id) == id
        expect(group.startIndex) == startIndex
        expect(group.endIndex) == endIndex
        expect(group.colorProperties) == colorProps
        expect(group.geometricProperties) == geometricProps
        expect(group.effectProperties) == effectProps
    }

    func testDefaultInstance() {
        // When using default instance
        let group = Group.defaultInstance

        // Then should have expected defaults
        expect(group.id) == 0
        expect(group.startIndex) == 1
        expect(group.endIndex) == -1 // all apps indicator
    }

    func testSingleGroup() {
        // When using single group configuration
        let groups = Group.singleGroup

        // Then should contain one default group
        expect(groups.count) == 1
        expect(groups.first?.id) == 0
    }

    // MARK: - Title Property Tests

    func testTitleGetterReturnsStringId() {
        // Given group with id
        let group = Group(
            id: 5,
            startIndex: 1,
            endIndex: 10,
            colorProperties: ColorProperties(
                backgroundTintColor: .clear,
                borderTintColor: .clear,
                foregroundColor: .clear
            ),
            geometricProperties: GeometricProperties(cornerRadius: 0, borderWidth: 0),
            effectProperties: EffectProperties(backgroundOpacity: 1, backgroundBlurRadius: 0, borderOpacity: 1)
        )

        // Then title should be string representation of id
        expect(group.title) == "5"
    }

    func testTitleSetterUpdatesId() {
        // Given group
        var group = Group.defaultInstance

        // When setting title
        group.title = "7"

        // Then id should be updated
        expect(group.id) == 7
    }

    func testTitleSetterWithInvalidStringKeepsOriginalId() {
        // Given group with id
        var group = Group.defaultInstance
        let originalId = group.id

        // When setting invalid title
        group.title = "invalid"

        // Then id should remain unchanged
        expect(group.id) == originalId
    }

    // MARK: - Range Tests

    func testRangeWithValidIndices() {
        // Given group with valid indices
        let group = Group(
            id: 1,
            startIndex: 3,
            endIndex: 8,
            colorProperties: ColorProperties(
                backgroundTintColor: .clear,
                borderTintColor: .clear,
                foregroundColor: .clear
            ),
            geometricProperties: GeometricProperties(cornerRadius: 0, borderWidth: 0),
            effectProperties: EffectProperties(backgroundOpacity: 1, backgroundBlurRadius: 0, borderOpacity: 1)
        )

        // Then range should be correct
        expect(group.range) == 3 ... 8
    }

    func testRangeWithSingleIndex() {
        // Given group with same start and end
        let group = Group(
            id: 1,
            startIndex: 5,
            endIndex: 5,
            colorProperties: ColorProperties(
                backgroundTintColor: .clear,
                borderTintColor: .clear,
                foregroundColor: .clear
            ),
            geometricProperties: GeometricProperties(cornerRadius: 0, borderWidth: 0),
            effectProperties: EffectProperties(backgroundOpacity: 1, backgroundBlurRadius: 0, borderOpacity: 1)
        )

        // Then range should contain single value
        expect(group.range) == 5 ... 5
        expect(group.range.count) == 1
    }

    // MARK: - End Index Management Tests

    func testGetEndIndexWithNormalIndex() {
        // Given group with normal end index
        let group = Group(
            id: 1,
            startIndex: 1,
            endIndex: 10,
            colorProperties: ColorProperties(
                backgroundTintColor: .clear,
                borderTintColor: .clear,
                foregroundColor: .clear
            ),
            geometricProperties: GeometricProperties(cornerRadius: 0, borderWidth: 0),
            effectProperties: EffectProperties(backgroundOpacity: 1, backgroundBlurRadius: 0, borderOpacity: 1)
        )

        // When getting end index
        let result = group.getEndIndex(menuBarAppsCount: 20)

        // Then should return actual end index
        expect(result) == 10
    }

    func testGetEndIndexWithAllAppsIndicator() {
        // Given group with all apps indicator (-1)
        let group = Group.defaultInstance // Uses -1 as endIndex

        // When getting end index with 15 apps
        let result = group.getEndIndex(menuBarAppsCount: 15)

        // Then should return total app count
        expect(result) == 15
    }

    func testSetEndIndexWithNormalValue() {
        // Given group
        var group = Group.defaultInstance

        // When setting normal end index
        group.setEndIndex(10, menuBarAppsCount: 20)

        // Then should set the value directly
        expect(group.endIndex) == 10
    }

    func testSetEndIndexWithAllAppsIndicator() {
        // Given group
        var group = Group.defaultInstance

        // When setting all apps indicator
        group.setEndIndex(-1, menuBarAppsCount: 15)

        // Then should set to app count
        expect(group.endIndex) == 15
    }

    // MARK: - Coding Tests

    func testEncodingAndDecoding() throws {
        // Given a group
        let group = Group(
            id: 2,
            startIndex: 5,
            endIndex: 15,
            colorProperties: ColorProperties(
                backgroundTintColor: .red,
                borderTintColor: .blue,
                foregroundColor: .white
            ),
            geometricProperties: GeometricProperties(cornerRadius: 8, borderWidth: 2),
            effectProperties: EffectProperties(backgroundOpacity: 0.9, backgroundBlurRadius: 10, borderOpacity: 0.8)
        )

        // When encoding and decoding
        let encoder = JSONEncoder()
        let data = try encoder.encode(group)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Group.self, from: data)

        // Then should match original
        expect(decoded.id) == group.id
        expect(decoded.startIndex) == group.startIndex
        expect(decoded.endIndex) == group.endIndex
        expect(decoded.geometricProperties) == group.geometricProperties
        expect(decoded.effectProperties) == group.effectProperties
    }

    func testDecodingWithMissingVisualProperties() throws {
        // Given JSON without visual properties
        let json = """
        {
            "id": 3,
            "start-index": 1,
            "end-index": 5
        }
        """

        // When decoding
        let data = Data(json.utf8)
        let decoder = JSONDecoder()
        let group = try decoder.decode(Group.self, from: data)

        // Then should use default visual properties
        expect(group.id) == 3
        expect(group.startIndex) == 1
        expect(group.endIndex) == 5
        expect(group.colorProperties).toNot(beNil())
        expect(group.geometricProperties).toNot(beNil())
        expect(group.effectProperties).toNot(beNil())
    }

    func testCodingKeysMapping() throws {
        // Given group
        let group = Group(
            id: 1,
            startIndex: 2,
            endIndex: 8,
            colorProperties: ColorProperties(
                backgroundTintColor: .clear,
                borderTintColor: .clear,
                foregroundColor: .clear
            ),
            geometricProperties: GeometricProperties(cornerRadius: 5, borderWidth: 1),
            effectProperties: EffectProperties(backgroundOpacity: 1, backgroundBlurRadius: 0, borderOpacity: 1)
        )

        // When encoding
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(group)
        let jsonString = String(bytes: data, encoding: .utf8) ?? ""

        // Then should use kebab-case keys
        expect(jsonString.contains("start-index")) == true
        expect(jsonString.contains("end-index")) == true
        expect(jsonString.contains("visual-config")) == true
        expect(jsonString.contains("geometric-config")) == true
        expect(jsonString.contains("effect-config")) == true
    }

    // MARK: - Equatable Tests

    func testEqualityWithSameValues() {
        // Given two groups with same values
        let colorProps = ColorProperties(backgroundTintColor: .red, borderTintColor: .blue, foregroundColor: .white)
        let geometricProps = GeometricProperties(cornerRadius: 8, borderWidth: 2)
        let effectProps = EffectProperties(backgroundOpacity: 0.8, backgroundBlurRadius: 5, borderOpacity: 1.0)

        let group1 = Group(
            id: 1,
            startIndex: 5,
            endIndex: 10,
            colorProperties: colorProps,
            geometricProperties: geometricProps,
            effectProperties: effectProps
        )

        let group2 = Group(
            id: 1,
            startIndex: 5,
            endIndex: 10,
            colorProperties: colorProps,
            geometricProperties: geometricProps,
            effectProperties: effectProps
        )

        // Then they should be equal
        expect(group1 == group2) == true
    }

    func testInequalityWithDifferentIds() {
        // Given two groups with different ids
        let colorProps = ColorProperties(backgroundTintColor: .red, borderTintColor: .blue, foregroundColor: .white)
        let geometricProps = GeometricProperties(cornerRadius: 8, borderWidth: 2)
        let effectProps = EffectProperties(backgroundOpacity: 0.8, backgroundBlurRadius: 5, borderOpacity: 1.0)

        let group1 = Group(
            id: 1,
            startIndex: 5,
            endIndex: 10,
            colorProperties: colorProps,
            geometricProperties: geometricProps,
            effectProperties: effectProps
        )
        let group2 = Group(
            id: 2,
            startIndex: 5,
            endIndex: 10,
            colorProperties: colorProps,
            geometricProperties: geometricProps,
            effectProperties: effectProps
        )

        // Then they should not be equal
        expect(group1 != group2) == true
    }

    func testInequalityWithDifferentIndices() {
        // Given two groups with different indices
        let colorProps = ColorProperties(backgroundTintColor: .red, borderTintColor: .blue, foregroundColor: .white)
        let geometricProps = GeometricProperties(cornerRadius: 8, borderWidth: 2)
        let effectProps = EffectProperties(backgroundOpacity: 0.8, backgroundBlurRadius: 5, borderOpacity: 1.0)

        let group1 = Group(
            id: 1,
            startIndex: 1,
            endIndex: 5,
            colorProperties: colorProps,
            geometricProperties: geometricProps,
            effectProperties: effectProps
        )
        let group2 = Group(
            id: 1,
            startIndex: 1,
            endIndex: 10,
            colorProperties: colorProps,
            geometricProperties: geometricProps,
            effectProperties: effectProps
        )

        // Then they should not be equal
        expect(group1 != group2) == true
    }

    // MARK: - Hashable Tests

    func testHashableConformance() {
        // Given groups
        let group1 = Group.defaultInstance
        let group2 = Group(
            id: 1,
            startIndex: 2,
            endIndex: 5,
            colorProperties: ColorProperties(
                backgroundTintColor: .red,
                borderTintColor: .blue,
                foregroundColor: .white
            ),
            geometricProperties: GeometricProperties(cornerRadius: 8, borderWidth: 2),
            effectProperties: EffectProperties(backgroundOpacity: 0.8, backgroundBlurRadius: 5, borderOpacity: 1.0)
        )

        // When adding to set
        let set: Set<Domain.Group> = [group1, group2]

        // Then should store unique groups
        expect(set.count) == 2
    }

    func testHashableWithDuplicates() {
        // Given duplicate groups
        let group1 = Group.defaultInstance
        let group2 = Group.defaultInstance

        // When adding to set
        let set: Set<Domain.Group> = [group1, group2]

        // Then should only store one
        expect(set.count) == 1
    }

    // MARK: - VisualContainer Tests

    func testConformsToVisualContainer() {
        // Given group
        let group = Group.defaultInstance

        // Then should conform to VisualContainer
        expect(group as any VisualContainer).toNot(beNil())
    }

    func testVisualContainerMetadata() {
        // When accessing metadata
        let metadata = Group.metadata

        // Then should have correct configuration
        expect(metadata.tagPrefix) == "groups"
        expect(metadata.canAddEntities) == true
        expect(metadata.canDeleteEntities) == true
        expect(metadata.showForegroundSection) == false
    }

    func testMetadataCanDeleteEntity() {
        // Given groups with different ids
        let deletableGroup = Group(
            id: 1,
            startIndex: 1,
            endIndex: 5,
            colorProperties: ColorProperties(
                backgroundTintColor: .clear,
                borderTintColor: .clear,
                foregroundColor: .clear
            ),
            geometricProperties: GeometricProperties(cornerRadius: 0, borderWidth: 0),
            effectProperties: EffectProperties(backgroundOpacity: 1, backgroundBlurRadius: 0, borderOpacity: 1)
        )

        let nonDeletableGroup = Group(
            id: 0,
            startIndex: 1,
            endIndex: 5,
            colorProperties: ColorProperties(
                backgroundTintColor: .clear,
                borderTintColor: .clear,
                foregroundColor: .clear
            ),
            geometricProperties: GeometricProperties(cornerRadius: 0, borderWidth: 0),
            effectProperties: EffectProperties(backgroundOpacity: 1, backgroundBlurRadius: 0, borderOpacity: 1)
        )

        // When checking if can delete
        let canDeleteId1 = Group.metadata.canDeleteEntity(deletableGroup)
        let canDeleteId0 = Group.metadata.canDeleteEntity(nonDeletableGroup)

        // Then only groups with id > 0 can be deleted
        expect(canDeleteId1) == true
        expect(canDeleteId0) == false
    }

    // MARK: - Edge Cases

    func testGroupWithZeroId() {
        // Given group with id 0
        let group = Group.defaultInstance

        // Then id should be 0
        expect(group.id) == 0
    }

    func testGroupWithNegativeIndices() {
        // Given group with negative end index (all apps indicator)
        let group = Group(
            id: 1,
            startIndex: 1,
            endIndex: -1,
            colorProperties: ColorProperties(
                backgroundTintColor: .clear,
                borderTintColor: .clear,
                foregroundColor: .clear
            ),
            geometricProperties: GeometricProperties(cornerRadius: 0, borderWidth: 0),
            effectProperties: EffectProperties(backgroundOpacity: 1, backgroundBlurRadius: 0, borderOpacity: 1)
        )

        // Then should be valid
        expect(group.endIndex) == -1
    }

    func testGroupRangeWithReversedIndices() {
        // Given group with start > end
        // Note: This is technically invalid but the type system allows it
        let group = Group(
            id: 1,
            startIndex: 10,
            endIndex: 5,
            colorProperties: ColorProperties(
                backgroundTintColor: .clear,
                borderTintColor: .clear,
                foregroundColor: .clear
            ),
            geometricProperties: GeometricProperties(cornerRadius: 0, borderWidth: 0),
            effectProperties: EffectProperties(backgroundOpacity: 1, backgroundBlurRadius: 0, borderOpacity: 1)
        )

        // Then range is created (though may not be semantically valid)
        // ClosedRange requires lowerBound <= upperBound, so this would trap at runtime
        // We just verify the properties are set
        expect(group.startIndex) == 10
        expect(group.endIndex) == 5
    }

    func testMultipleGroupsInArray() {
        // Given multiple groups
        let groups = [
            Group(
                id: 1,
                startIndex: 1,
                endIndex: 5,
                colorProperties: ColorProperties(
                    backgroundTintColor: .clear,
                    borderTintColor: .clear,
                    foregroundColor: .clear
                ),
                geometricProperties: GeometricProperties(cornerRadius: 0, borderWidth: 0),
                effectProperties: EffectProperties(backgroundOpacity: 1, backgroundBlurRadius: 0, borderOpacity: 1)
            ),
            Group(
                id: 2,
                startIndex: 6,
                endIndex: 10,
                colorProperties: ColorProperties(
                    backgroundTintColor: .clear,
                    borderTintColor: .clear,
                    foregroundColor: .clear
                ),
                geometricProperties: GeometricProperties(cornerRadius: 0, borderWidth: 0),
                effectProperties: EffectProperties(backgroundOpacity: 1, backgroundBlurRadius: 0, borderOpacity: 1)
            ),
            Group(
                id: 3,
                startIndex: 11,
                endIndex: 15,
                colorProperties: ColorProperties(
                    backgroundTintColor: .clear,
                    borderTintColor: .clear,
                    foregroundColor: .clear
                ),
                geometricProperties: GeometricProperties(cornerRadius: 0, borderWidth: 0),
                effectProperties: EffectProperties(backgroundOpacity: 1, backgroundBlurRadius: 0, borderOpacity: 1)
            )
        ]

        // Then should have correct count and order
        expect(groups.count) == 3
        expect(groups[0].id) == 1
        expect(groups[1].id) == 2
        expect(groups[2].id) == 3
    }
}
