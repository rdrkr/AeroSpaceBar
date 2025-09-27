// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// A consolidated structure containing all visual configuration properties for container UI elements.
///
/// This struct encapsulates common visual properties used across groups, spaces, and other container components
/// to eliminate code duplication and provide a consistent visual configuration system.
public struct VisualProperties: Codable, Equatable, Hashable, Sendable {
    // MARK: - Background Properties

    /// The background tint color.
    public var backgroundTintColor: Color

    /// The background opacity (0.0 to 1.0).
    public var backgroundOpacity: Double

    /// The background blur radius.
    public var backgroundBlurRadius: Double

    // MARK: - Border Properties

    /// The border tint color.
    public var borderTintColor: Color

    /// The border opacity (0.0 to 1.0).
    public var borderOpacity: Double

    /// The border width.
    public var borderWidth: Double

    // MARK: - Shape Properties

    /// The corner radius for rounded corners.
    public var cornerRadius: Double

    // MARK: - Foreground Properties

    /// The foreground color for text and icons.
    public var foregroundColor: Color

    // MARK: - Initializers

    /// Creates a new visual container configuration.
    /// - Parameters:
    ///   - backgroundTintColor: The background tint color
    ///   - backgroundOpacity: The background opacity (0.0 to 1.0)
    ///   - backgroundBlurRadius: The background blur radius
    ///   - borderTintColor: The border tint color
    ///   - borderOpacity: The border opacity (0.0 to 1.0)
    ///   - borderWidth: The border width
    ///   - cornerRadius: The corner radius for rounded corners
    ///   - foregroundColor: The foreground color for text and icons
    public init(
        backgroundTintColor: Color,
        backgroundOpacity: Double,
        backgroundBlurRadius: Double,
        borderTintColor: Color,
        borderOpacity: Double,
        borderWidth: Double,
        cornerRadius: Double,
        foregroundColor: Color
    ) {
        self.backgroundTintColor = backgroundTintColor
        self.backgroundOpacity = backgroundOpacity
        self.backgroundBlurRadius = backgroundBlurRadius
        self.borderTintColor = borderTintColor
        self.borderOpacity = borderOpacity
        self.borderWidth = borderWidth
        self.cornerRadius = cornerRadius
        self.foregroundColor = foregroundColor
    }

    // MARK: - Codable Implementation

    /// Coding keys for JSON serialization.
    private enum CodingKeys: String, CodingKey {
        case backgroundTintColor = "background-tint-color"
        case backgroundOpacity = "background-opacity"
        case backgroundBlurRadius = "background-blur-radius"
        case borderTintColor = "border-tint-color"
        case borderOpacity = "border-opacity"
        case borderWidth = "border-width"
        case cornerRadius = "corner-radius"
        case foregroundColor = "foreground-color"
    }

    /// Creates a visual container configuration from a decoder.
    /// - Parameter decoder: The decoder to read from
    /// - Throws: DecodingError if the data is invalid
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        backgroundOpacity = try container.decode(Double.self, forKey: .backgroundOpacity)
        backgroundBlurRadius = try container.decode(Double.self, forKey: .backgroundBlurRadius)
        borderOpacity = try container.decode(Double.self, forKey: .borderOpacity)
        borderWidth = try container.decode(Double.self, forKey: .borderWidth)
        cornerRadius = try container.decode(Double.self, forKey: .cornerRadius)

        // Decode colors from ColorComponents
        let backgroundComponents = try container.decode(ColorComponents.self, forKey: .backgroundTintColor)
        backgroundTintColor = Color(
            .sRGB,
            red: backgroundComponents.red,
            green: backgroundComponents.green,
            blue: backgroundComponents.blue,
            opacity: backgroundComponents.alpha
        )

        let borderComponents = try container.decode(ColorComponents.self, forKey: .borderTintColor)
        borderTintColor = Color(
            .sRGB,
            red: borderComponents.red,
            green: borderComponents.green,
            blue: borderComponents.blue,
            opacity: borderComponents.alpha
        )

        let foregroundComponents = try container.decode(ColorComponents.self, forKey: .foregroundColor)
        foregroundColor = Color(
            .sRGB,
            red: foregroundComponents.red,
            green: foregroundComponents.green,
            blue: foregroundComponents.blue,
            opacity: foregroundComponents.alpha
        )
    }

    /// Encodes the visual container configuration to an encoder.
    /// - Parameter encoder: The encoder to write to
    /// - Throws: EncodingError if the data cannot be encoded
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(backgroundOpacity, forKey: .backgroundOpacity)
        try container.encode(backgroundBlurRadius, forKey: .backgroundBlurRadius)
        try container.encode(borderOpacity, forKey: .borderOpacity)
        try container.encode(borderWidth, forKey: .borderWidth)
        try container.encode(cornerRadius, forKey: .cornerRadius)

        // Encode colors as ColorComponents
        let backgroundResolved = backgroundTintColor.resolve(in: EnvironmentValues())
        let backgroundComponents = ColorComponents(
            red: Double(backgroundResolved.red),
            green: Double(backgroundResolved.green),
            blue: Double(backgroundResolved.blue),
            alpha: Double(backgroundResolved.opacity)
        )
        try container.encode(backgroundComponents, forKey: .backgroundTintColor)

        let borderResolved = borderTintColor.resolve(in: EnvironmentValues())
        let borderComponents = ColorComponents(
            red: Double(borderResolved.red),
            green: Double(borderResolved.green),
            blue: Double(borderResolved.blue),
            alpha: Double(borderResolved.opacity)
        )
        try container.encode(borderComponents, forKey: .borderTintColor)

        let foregroundResolved = foregroundColor.resolve(in: EnvironmentValues())
        let foregroundComponents = ColorComponents(
            red: Double(foregroundResolved.red),
            green: Double(foregroundResolved.green),
            blue: Double(foregroundResolved.blue),
            alpha: Double(foregroundResolved.opacity)
        )
        try container.encode(foregroundComponents, forKey: .foregroundColor)
    }

    // MARK: - Hashable Implementation

    public static func == (lhs: VisualProperties, rhs: VisualProperties) -> Bool {
        lhs.backgroundTintColor.toHex() == rhs.backgroundTintColor.toHex() &&
            lhs.backgroundOpacity == rhs.backgroundOpacity &&
            lhs.backgroundBlurRadius == rhs.backgroundBlurRadius &&
            lhs.borderTintColor.toHex() == rhs.borderTintColor.toHex() &&
            lhs.borderOpacity == rhs.borderOpacity &&
            lhs.borderWidth == rhs.borderWidth &&
            lhs.cornerRadius == rhs.cornerRadius &&
            lhs.foregroundColor.toHex() == rhs.foregroundColor.toHex()
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(backgroundTintColor.toHex())
        hasher.combine(backgroundOpacity)
        hasher.combine(backgroundBlurRadius)
        hasher.combine(borderTintColor.toHex())
        hasher.combine(borderOpacity)
        hasher.combine(borderWidth)
        hasher.combine(cornerRadius)
        hasher.combine(foregroundColor.toHex())
    }
}

/// Helper struct for Color serialization.
private struct ColorComponents: Codable {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double
}

// MARK: - Color Extensions for Hex Support

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

        return unsafe String(format: "#%02X%02X%02X", red, green, blue)
    }
}
