// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// Note: Hashable conformance is possible because ColorProperties now provides a custom Hashable implementation based
/// on color hex strings.
/// Configuration for a group of menu bar applications.
public struct Group: VisualContainer {
    public typealias AppearanceMode = GroupsAppearanceMode
    /// The metadata configuration for Group entities.
    public static let metadata = VisualContainerMetadata(
        entityName: String(localized: LocalizedStringResource("Group")),
        entityNamePlural: String(localized: LocalizedStringResource("Groups")),
        tagPrefix: "groups",
        canAddEntities: true,
        canDeleteEntities: true,
        showForegroundSection: false,
        defaultGlobalColorProperties: ConfigurationDefaults.groupsGlobalColorProperties,
        defaultGlobalEffectProperties: ConfigurationDefaults.groupsGlobalEffectProperties,
        defaultGlobalGeometricProperties: ConfigurationDefaults.groupsGlobalGeometricProperties,
        canDeleteEntity: { entity in
            guard let group = entity as? Group else { return false }

            return group.id > 0 // Groups with id > 0 can be deleted
        },
        footerText: String(localized: LocalizedStringResource(
            """
            Delete a group and its configuration by swipe, or by clicking the
            group's delete button available in its configuration.
            """
        )),
        resetAlertTitle: String(localized: LocalizedStringResource("Reset Groups")),
        resetAlertMessage: String(localized: LocalizedStringResource(
            """
            Are you sure you want to reset all groups to their default configuration? \
            This action cannot be undone.
            """
        )),
        resetButtonTitle: String(localized: LocalizedStringResource("Reset Groups")),
        resetButtonDescription: String(localized: LocalizedStringResource(
            "Reset all groups to their default configuration."
        ))
    )

    /// The unique identifier for the group.
    public var id: Int

    /// The Group title name
    public var title: String {
        get { String(id) }
        set { id = Int(newValue) ?? id }
    }

    /// The start index of the group in the list of apps (inclusive).
    public var startIndex: Int

    /// The end index of the group in the list of apps (inclusive).
    public var endIndex: Int

    /// The color properties for the group container.
    public var colorProperties: ColorProperties

    /// The geometric properties for the group container.
    public var geometricProperties: GeometricProperties

    /// The effect properties for the group container.
    public var effectProperties: EffectProperties

    /// The range of indices that this group covers.
    public var range: ClosedRange<Int> {
        startIndex ... endIndex
    }

    /// Coding keys for TOML serialization
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case id
        case startIndex = "start-index"
        case endIndex = "end-index"
        case colorProperties = "visual-config"
        case geometricProperties = "geometric-config"
        case effectProperties = "effect-config"
    }

    /// Standard initializer for creating GroupConfiguration instances
    /// - Parameters:
    ///   - id: The unique identifier for the group
    ///   - startIndex: The start index of the group in the list of apps (inclusive)
    ///   - endIndex: The end index of the group in the list of apps (inclusive)
    ///   - colorProperties: The color properties for the group container
    ///   - geometricProperties: The geometric properties for the group container
    ///   - effectProperties: The effect properties for the group container
    public init(
        id: Int,
        startIndex: Int,
        endIndex: Int,
        colorProperties: ColorProperties,
        geometricProperties: GeometricProperties,
        effectProperties: EffectProperties
    ) {
        self.id = id
        self.startIndex = startIndex
        self.endIndex = endIndex
        self.colorProperties = colorProperties
        self.geometricProperties = geometricProperties
        self.effectProperties = effectProperties
    }

    /// Custom decoder for TOML compatibility
    /// - Parameter decoder: The decoder to read from
    /// - Throws: DecodingError if the data is invalid
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        startIndex = try container.decode(Int.self, forKey: .startIndex)
        endIndex = try container.decode(Int.self, forKey: .endIndex)
        colorProperties = try container.decodeIfPresent(
            ColorProperties.self, forKey: .colorProperties
        ) ?? ConfigurationDefaults.groupsGlobalColorProperties
        geometricProperties = try container.decodeIfPresent(
            GeometricProperties.self, forKey: .geometricProperties
        ) ?? ConfigurationDefaults.groupsGlobalGeometricProperties
        effectProperties = try container.decodeIfPresent(
            EffectProperties.self, forKey: .effectProperties
        ) ?? ConfigurationDefaults.groupsGlobalEffectProperties
    }

    /// Custom encoder for TOML compatibility
    /// - Parameter encoder: The encoder to write to
    /// - Throws: EncodingError if the data cannot be encoded
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(startIndex, forKey: .startIndex)
        try container.encode(endIndex, forKey: .endIndex)
        try container.encode(colorProperties, forKey: .colorProperties)
        try container.encode(geometricProperties, forKey: .geometricProperties)
        try container.encode(effectProperties, forKey: .effectProperties)
    }

    /// Retrieves end index for this group.
    /// - Parameter menuBarAppsCount: number of existing menubar apps
    /// - Returns: the group end index
    public func getEndIndex(menuBarAppsCount: Int) -> Int {
        endIndex == Group.allAppsIndicatorIndex ? menuBarAppsCount : endIndex
    }

    /// Sets end index for this group.
    /// - Parameter index: new end index
    /// - Parameter menuBarAppsCount: number of existing menubar apps
    /// - Returns: the group end index
    public mutating func setEndIndex(_ index: Int, menuBarAppsCount: Int) {
        endIndex = if index == Group.allAppsIndicatorIndex {
            menuBarAppsCount
        } else {
            index
        }
    }

    /// An indicator for [endIndex] to signify all apps should be included in this group.
    private static let allAppsIndicatorIndex: Int = -1

    /// A default group configuration
    public static let defaultInstance: Group = .init(
        id: 0,
        startIndex: 1,
        endIndex: allAppsIndicatorIndex,
        colorProperties: ConfigurationDefaults.groupsGlobalColorProperties,
        geometricProperties: ConfigurationDefaults.groupsGlobalGeometricProperties,
        effectProperties: ConfigurationDefaults.groupsGlobalEffectProperties
    )

    /// A default single group configuration
    public static let singleGroup: [Domain.Group] = [defaultInstance]
}
