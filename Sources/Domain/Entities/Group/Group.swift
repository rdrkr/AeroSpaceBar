// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// Note: Hashable conformance is possible because VisualProperties now provides a custom Hashable implementation based
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
        defaultGlobalVisualConfig: ConfigurationDefaults.defaultGroupsGlobalVisualConfig,
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
    public var title: String

    /// The start index of the group in the list of apps (inclusive).
    public var startIndex: Int

    /// The end index of the group in the list of apps (inclusive).
    public var endIndex: Int

    /// The visual configuration for the group container.
    public var visualConfig: VisualProperties

    /// The range of indices that this group covers.
    public var range: ClosedRange<Int> {
        startIndex ... endIndex
    }

    /// Coding keys for TOML serialization
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case id
        case title
        case startIndex = "start-index"
        case endIndex = "end-index"
        case visualConfig = "visual-config"
    }

    /// Standard initializer for creating GroupConfiguration instances
    /// - Parameters:
    ///   - id: The unique identifier for the group
    ///   - title: The title of the group
    ///   - startIndex: The start index of the group in the list of apps (inclusive)
    ///   - endIndex: The end index of the group in the list of apps (inclusive)
    ///   - visualConfig: The visual configuration for the group container
    public init(
        id: Int,
        title: String,
        startIndex: Int,
        endIndex: Int,
        visualConfig: VisualProperties
    ) {
        self.id = id
        self.title = title
        self.startIndex = startIndex
        self.endIndex = endIndex
        self.visualConfig = visualConfig
    }

    /// Custom decoder for TOML compatibility
    /// - Parameter decoder: The decoder to read from
    /// - Throws: DecodingError if the data is invalid
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        startIndex = try container.decode(Int.self, forKey: .startIndex)
        endIndex = try container.decode(Int.self, forKey: .endIndex)
        visualConfig = try container.decodeIfPresent(
            VisualProperties.self, forKey: .visualConfig
        ) ?? ConfigurationDefaults.defaultGroupsGlobalVisualConfig
    }

    /// Custom encoder for TOML compatibility
    /// - Parameter encoder: The encoder to write to
    /// - Throws: EncodingError if the data cannot be encoded
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(startIndex, forKey: .startIndex)
        try container.encode(endIndex, forKey: .endIndex)
        try container.encode(visualConfig, forKey: .visualConfig)
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
        title: "0",
        startIndex: 1,
        endIndex: allAppsIndicatorIndex,
        visualConfig: ConfigurationDefaults.defaultGroupsGlobalVisualConfig
    )

    /// A default single group configuration
    public static let singleGroup: [Domain.Group] = [defaultInstance]
}
