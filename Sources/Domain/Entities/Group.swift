// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// Note: Hashable conformance is possible because VisualContainer now provides a custom Hashable implementation based
/// on color hex strings.
/// Configuration for a group of menu bar applications.
public struct Group: Identifiable, Codable, Equatable, Hashable, @unchecked Sendable {
    /// The unique identifier for the group.
    public var id: Int

    /// The start index of the group in the list of apps (inclusive).
    public var startIndex: Int

    /// The end index of the group in the list of apps (inclusive).
    public var endIndex: Int

    /// The visual configuration for the group container.
    public var visualConfig: VisualContainer

    /// The range of indices that this group covers.
    public var range: ClosedRange<Int> {
        startIndex ... endIndex
    }

    /// Coding keys for TOML serialization
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case id
        case startIndex = "start_index"
        case endIndex = "end_index"
        case backgroundTintColor = "background_tint_color"
        case backgroundOpacity = "background_opacity"
        case backgroundBlurRadius = "background_blur_radius"
        case borderColor = "border_color"
        case borderOpacity = "border_opacity"
        case borderWidth = "border_width"
        case cornerRadius = "corner_radius"
        case foregroundColor = "foreground_color"
    }

    /// Standard initializer for creating GroupConfiguration instances
    /// - Parameters:
    ///   - id: The unique identifier for the group
    ///   - startIndex: The start index of the group in the list of apps (inclusive)
    ///   - endIndex: The end index of the group in the list of apps (inclusive)
    ///   - visualConfig: The visual configuration for the group container
    public init(
        id: ID,
        startIndex: Int,
        endIndex: Int,
        visualConfig: VisualContainer
    ) {
        self.id = id
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
        startIndex = try container.decode(Int.self, forKey: .startIndex)
        endIndex = try container.decode(Int.self, forKey: .endIndex)

        // Decode individual visual properties and create VisualContainerConfiguration
        let backgroundOpacity = try container.decode(Double.self, forKey: .backgroundOpacity)
        let backgroundBlurRadius = try container.decode(Double.self, forKey: .backgroundBlurRadius)
        let borderOpacity = try container.decode(Double.self, forKey: .borderOpacity)
        let borderWidth = try container.decode(Double.self, forKey: .borderWidth)
        let cornerRadius = try container.decode(Double.self, forKey: .cornerRadius)

        // Decode colors from hex strings
        let backgroundColorHex = try container.decode(String.self, forKey: .backgroundTintColor)
        let backgroundTintColor = Color(hex: backgroundColorHex) ?? .white

        let borderColorHex = try container.decode(String.self, forKey: .borderColor)
        let borderTintColor = Color(hex: borderColorHex) ?? .white

        // Try to decode foreground color, use default if not present (for backward compatibility)
        let foregroundColorHex = try container.decodeIfPresent(String.self, forKey: .foregroundColor)
        let foregroundColor = foregroundColorHex.flatMap { Color(hex: $0) } ?? .primary

        // Create VisualContainerConfiguration from decoded properties
        visualConfig = VisualContainer(
            backgroundTintColor: backgroundTintColor,
            backgroundOpacity: backgroundOpacity,
            backgroundBlurRadius: backgroundBlurRadius,
            borderTintColor: borderTintColor,
            borderOpacity: borderOpacity,
            borderWidth: borderWidth,
            cornerRadius: cornerRadius,
            foregroundColor: foregroundColor
        )
    }

    /// Custom encoder for TOML compatibility
    /// - Parameter encoder: The encoder to write to
    /// - Throws: EncodingError if the data cannot be encoded
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(startIndex, forKey: .startIndex)
        try container.encode(endIndex, forKey: .endIndex)

        // Encode visual configuration properties individually for TOML compatibility
        try container.encode(visualConfig.backgroundOpacity, forKey: .backgroundOpacity)
        try container.encode(visualConfig.backgroundBlurRadius, forKey: .backgroundBlurRadius)
        try container.encode(visualConfig.borderOpacity, forKey: .borderOpacity)
        try container.encode(visualConfig.borderWidth, forKey: .borderWidth)
        try container.encode(visualConfig.cornerRadius, forKey: .cornerRadius)

        // Encode colors as hex strings
        try container.encode(visualConfig.backgroundTintColor.toHex(), forKey: .backgroundTintColor)
        try container.encode(visualConfig.borderTintColor.toHex(), forKey: .borderColor)
        try container.encode(visualConfig.foregroundColor.toHex(), forKey: .foregroundColor)
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
    @MainActor public static let defaultInstance: Group = .init(
        id: 0,
        startIndex: 1,
        endIndex: allAppsIndicatorIndex,
        visualConfig: VisualContainer(
            backgroundTintColor: ConfigurationDefaults.spaceBackgroundTintColor,
            backgroundOpacity: min(ConfigurationDefaults.spaceBackgroundOpacity, 0.2),
            backgroundBlurRadius: ConfigurationDefaults.spaceBackgroundBlurRadius,
            borderTintColor: ConfigurationDefaults.spaceBorderTintColor,
            borderOpacity: ConfigurationDefaults.spaceBorderOpacity,
            borderWidth: ConfigurationDefaults.spaceBorderWidth,
            cornerRadius: ConfigurationDefaults.spaceCornerRadius,
            foregroundColor: .primary
        )
    )

    /// A default single group configuration
    @MainActor public static let singleGroup: [Domain.Group] = [defaultInstance]
}

// MARK: - Color Extensions for TOML Support

extension Color {
    /// Initialize a Color from a hex string
    /// - Parameter hex: Hex string (with or without #)
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        guard let int = UInt64(hex, radix: 16) else { return nil }

        let alpha, red, green, blue: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (alpha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)

        case 6: // RGB (24-bit)
            (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)

        case 8: // ARGB (32-bit)
            (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)

        default:
            return nil
        }

        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }

    /// Convert Color to hex string
    func toHex() -> String {
        let uiColor = NSColor(self)
        let cgColor = uiColor.cgColor
        guard let components = cgColor.components, components.count >= 3 else { return "#FFFFFF" }

        let red = Int(components[0] * 255)
        let green = Int(components[1] * 255)
        let blue = Int(components[2] * 255)

        return String(format: "#%02X%02X%02X", red, green, blue)
    }
}
