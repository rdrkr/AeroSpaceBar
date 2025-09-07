// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// Configuration for a group of menu bar applications.
public struct GroupConfiguration: Codable, Equatable, @unchecked Sendable {
    /// The unique identifier for the group.
    var id: Int

    /// The start index of the group in the list of apps (inclusive).
    var startIndex: Int

    /// The end index of the group in the list of apps (inclusive).
    var endIndex: Int

    /// The background color of the group.
    var backgroundTintColor: Color

    /// The opacity of the background color.
    var backgroundOpacity: Double

    /// The blur radius applied to the background.
    var backgroundBlurRadius: Double

    /// The border color of the group.
    var borderColor: Color

    /// The opacity of the border color.
    var borderOpacity: Double

    /// The width of the border.
    var borderWidth: Double

    /// The corner radius of the group.
    var cornerRadius: Double

    /// The range of indices that this group covers.
    var range: ClosedRange<Int> {
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
    }

    /// Standard initializer for creating GroupConfiguration instances
    public init(
        id: Int,
        startIndex: Int,
        endIndex: Int,
        backgroundTintColor: Color,
        backgroundOpacity: Double,
        backgroundBlurRadius: Double,
        borderColor: Color,
        borderOpacity: Double,
        borderWidth: Double,
        cornerRadius: Double
    ) {
        self.id = id
        self.startIndex = startIndex
        self.endIndex = endIndex
        self.backgroundTintColor = backgroundTintColor
        self.backgroundOpacity = backgroundOpacity
        self.backgroundBlurRadius = backgroundBlurRadius
        self.borderColor = borderColor
        self.borderOpacity = borderOpacity
        self.borderWidth = borderWidth
        self.cornerRadius = cornerRadius
    }

    /// Custom decoder for TOML compatibility
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        startIndex = try container.decode(Int.self, forKey: .startIndex)
        endIndex = try container.decode(Int.self, forKey: .endIndex)
        backgroundOpacity = try container.decode(Double.self, forKey: .backgroundOpacity)
        backgroundBlurRadius = try container.decode(Double.self, forKey: .backgroundBlurRadius)
        borderOpacity = try container.decode(Double.self, forKey: .borderOpacity)
        borderWidth = try container.decode(Double.self, forKey: .borderWidth)
        cornerRadius = try container.decode(Double.self, forKey: .cornerRadius)

        // Decode colors from hex strings
        let backgroundColorHex = try container.decode(String.self, forKey: .backgroundTintColor)
        backgroundTintColor = Color(hex: backgroundColorHex) ?? .white

        let borderColorHex = try container.decode(String.self, forKey: .borderColor)
        borderColor = Color(hex: borderColorHex) ?? .white
    }

    /// Custom encoder for TOML compatibility
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(startIndex, forKey: .startIndex)
        try container.encode(endIndex, forKey: .endIndex)
        try container.encode(backgroundOpacity, forKey: .backgroundOpacity)
        try container.encode(backgroundBlurRadius, forKey: .backgroundBlurRadius)
        try container.encode(borderOpacity, forKey: .borderOpacity)
        try container.encode(borderWidth, forKey: .borderWidth)
        try container.encode(cornerRadius, forKey: .cornerRadius)

        // Encode colors as hex strings
        try container.encode(backgroundTintColor.toHex(), forKey: .backgroundTintColor)
        try container.encode(borderColor.toHex(), forKey: .borderColor)
    }

    /// Retrieves end index for this group.
    /// - Parameter menuBarAppsCount: number of existing menubar apps
    /// - Returns: the group end index
    public func getEndIndex(menuBarAppsCount: Int) -> Int {
        endIndex == GroupConfiguration.allAppsIndicatorIndex ? menuBarAppsCount : endIndex
    }

    /// Sets end index for this group.
    /// - Parameter index: new end index
    /// - Parameter menuBarAppsCount: number of existing menubar apps
    /// - Returns: the group end index
    public mutating func setEndIndex(_ index: Int, menuBarAppsCount: Int) {
        endIndex = if index == GroupConfiguration.allAppsIndicatorIndex {
            menuBarAppsCount
        } else {
            index
        }
    }

    /// An indicator for [endIndex] to signify all apps should be included in this group.
    private static let allAppsIndicatorIndex: Int = -1

    /// A default group configuration
    @MainActor public static let defaultInstance: GroupConfiguration = .init(
        id: 0,
        startIndex: 1,
        endIndex: allAppsIndicatorIndex,
        backgroundTintColor: ConfigurationDefaults.spaceBackgroundTintColor,
        backgroundOpacity: min(ConfigurationDefaults.spaceBackgroundOpacity, 0.2),
        backgroundBlurRadius: ConfigurationDefaults.spaceBackgroundBlurRadius,
        borderColor: ConfigurationDefaults.spaceBorderTintColor,
        borderOpacity: ConfigurationDefaults.spaceBorderOpacity,
        borderWidth: ConfigurationDefaults.spaceBorderWidth,
        cornerRadius: ConfigurationDefaults.spaceCornerRadius
    )

    /// A default single group configuration
    @MainActor public static let singleGroup: [GroupConfiguration] = [defaultInstance]
}

// MARK: - Color Extensions for TOML Support

extension Color {
    /// Initialize a Color from a hex string
    /// - Parameter hex: Hex string (with or without #)
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
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
