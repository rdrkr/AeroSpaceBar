// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// A consolidated structure containing all visual configuration properties for container UI elements.
///
/// This struct encapsulates common visual properties used across groups, spaces, and other container components
/// to eliminate code duplication and provide a consistent visual configuration system.
public struct VisualContainer: Equatable, Codable, Hashable {
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

    // MARK: - Hashable Implementation

    public static func == (lhs: VisualContainer, rhs: VisualContainer) -> Bool {
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

// MARK: - Helper Structures

/// Background visual properties.
public struct BackgroundProperties {
    /// The background tint color.
    public let tintColor: Color
    /// The background opacity (0.0 to 1.0).
    public let opacity: Double
    /// The background blur radius.
    public let blurRadius: Double

    /// Creates background properties.
    /// - Parameters:
    ///   - tintColor: The background tint color
    ///   - opacity: The background opacity (0.0 to 1.0)
    ///   - blurRadius: The background blur radius
    public init(tintColor: Color, opacity: Double, blurRadius: Double) {
        self.tintColor = tintColor
        self.opacity = opacity
        self.blurRadius = blurRadius
    }
}

/// Border visual properties.
public struct BorderProperties {
    /// The border tint color.
    public let tintColor: Color
    /// The border opacity (0.0 to 1.0).
    public let opacity: Double
    /// The border width.
    public let width: Double

    /// Creates border properties.
    /// - Parameters:
    ///   - tintColor: The border tint color
    ///   - opacity: The border opacity (0.0 to 1.0)
    ///   - width: The border width
    public init(tintColor: Color, opacity: Double, width: Double) {
        self.tintColor = tintColor
        self.opacity = opacity
        self.width = width
    }
}

// MARK: - Convenience Extensions

public extension VisualContainer {
    /// Creates a default visual container configuration with common values.
    /// - Returns: A visual container configuration with sensible default values
    static func `default`() -> VisualContainer {
        VisualContainer(
            backgroundTintColor: .clear,
            backgroundOpacity: 0.0,
            backgroundBlurRadius: 0.0,
            borderTintColor: .white,
            borderOpacity: 0.3,
            borderWidth: 1.0,
            cornerRadius: 8.0,
            foregroundColor: .primary
        )
    }

    /// Creates a visual container configuration optimized for group elements.
    /// - Parameters:
    ///   - background: Background properties (tint color, opacity, blur radius)
    ///   - border: Border properties (tint color, opacity, width)
    ///   - cornerRadius: The corner radius
    /// - Returns: A visual container configuration configured for groups
    static func group(
        background: BackgroundProperties,
        border: BorderProperties,
        cornerRadius: Double
    ) -> VisualContainer {
        VisualContainer(
            backgroundTintColor: background.tintColor,
            backgroundOpacity: background.opacity,
            backgroundBlurRadius: background.blurRadius,
            borderTintColor: border.tintColor,
            borderOpacity: border.opacity,
            borderWidth: border.width,
            cornerRadius: cornerRadius,
            foregroundColor: .primary
        )
    }

    /// Creates a visual container configuration optimized for space elements.
    /// - Parameters:
    ///   - background: Background properties (tint color, opacity, blur radius)
    ///   - border: Border properties (tint color, opacity, width)
    ///   - cornerRadius: The corner radius
    ///   - foregroundColor: The foreground color for text and icons
    /// - Returns: A visual container configuration configured for spaces
    static func space(
        background: BackgroundProperties,
        border: BorderProperties,
        cornerRadius: Double,
        foregroundColor: Color
    ) -> VisualContainer {
        VisualContainer(
            backgroundTintColor: background.tintColor,
            backgroundOpacity: background.opacity,
            backgroundBlurRadius: background.blurRadius,
            borderTintColor: border.tintColor,
            borderOpacity: border.opacity,
            borderWidth: border.width,
            cornerRadius: cornerRadius,
            foregroundColor: foregroundColor
        )
    }
}

// MARK: - Codable Implementation

public extension VisualContainer {
    /// Coding keys for JSON serialization.
    private enum CodingKeys: String, CodingKey {
        case backgroundTintColor = "background_tint_color"
        case backgroundOpacity = "background_opacity"
        case backgroundBlurRadius = "background_blur_radius"
        case borderTintColor = "border_tint_color"
        case borderOpacity = "border_opacity"
        case borderWidth = "border_width"
        case cornerRadius = "corner_radius"
        case foregroundColor = "foreground_color"
    }

    /// Creates a visual container configuration from a decoder.
    /// - Parameter decoder: The decoder to read from
    /// - Throws: DecodingError if the data is invalid
    init(from decoder: Decoder) throws {
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
    func encode(to encoder: Encoder) throws {
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
}

/// Helper struct for Color serialization.
private struct ColorComponents: Codable {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double
}
