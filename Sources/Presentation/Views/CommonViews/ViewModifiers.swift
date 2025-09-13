// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

// MARK: - Shadow Modifiers

/// Standard shadow modifier for spaces and windows
struct StandardShadow: ViewModifier {
    func body(content: Content) -> some View {
        content.shadow(color: .themeShadow, radius: 2)
    }
}

/// Icon shadow modifier for window icons
struct IconShadow: ViewModifier {
    func body(content: Content) -> some View {
        content.shadow(color: .themeIconShadow, radius: 2)
    }
}

/// Text shadow modifier for foreground text
struct TextShadow: ViewModifier {
    func body(content: Content) -> some View {
        content.shadow(color: .themeForegroundShadow, radius: 2)
    }
}

// MARK: - Animation Modifiers

/// Smooth animation modifier with configurable duration
struct SmoothAnimation: ViewModifier {
    let duration: Double

    init(duration: Double = 0.3) {
        self.duration = duration
    }

    func body(content: Content) -> some View {
        content.animation(.smooth(duration: duration), value: true)
    }
}

/// Blur replace transition modifier
struct BlurReplaceTransition: ViewModifier {
    func body(content: Content) -> some View {
        content.transition(.blurReplace)
    }
}

// MARK: - Corner Radius Modifiers

/// Space corner radius modifier
struct SpaceCornerRadius: ViewModifier {
    let cornerRadius: Double

    init(cornerRadius: Double = .themeSpaceCornerRadius) {
        self.cornerRadius = cornerRadius
    }

    func body(content: Content) -> some View {
        content.clipShape(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        )
    }
}

/// Window corner radius modifier
struct WindowCornerRadius: ViewModifier {
    let cornerRadius: Double

    init(cornerRadius: Double = .themeWindowCornerRadius) {
        self.cornerRadius = cornerRadius
    }

    func body(content: Content) -> some View {
        content.clipShape(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        )
    }
}

// MARK: - Hover Modifiers

/// Hover state modifier for interactive elements
struct HoverState: ViewModifier {
    @Binding var isHovered: Bool

    func body(content: Content) -> some View {
        content
            .onHover { value in
                isHovered = value
            }
            .animation(.themeSmooth, value: isHovered)
    }
}

// MARK: - Focus State Modifiers

/// Focus state modifier for spaces
struct SpaceFocusState: ViewModifier {
    struct Configuration {
        let backgroundOpacity: Double
        let backgroundBlurRadius: Double
        let backgroundTintColor: Color
        let foregroundColor: Color
        let borderTintColor: Color
        let borderOpacity: Double
        let borderCornerRadius: Double
        let borderWidth: Double
    }

    let isFocused: Bool
    let configuration: Configuration

    func body(content: Content) -> some View {
        content
            .background(
                configuration.backgroundTintColor
                    .opacity(
                        isFocused ? (
                            configuration.backgroundOpacity == 0 ? 0 :
                                min(configuration.backgroundOpacity + 0.2, 1)
                        ) : configuration.backgroundOpacity
                    )
                    .blur(radius: configuration.backgroundBlurRadius)
            )
            .overlay(
                RoundedRectangle(cornerRadius: configuration.borderCornerRadius, style: .continuous)
                    .stroke(
                        configuration.borderTintColor
                            .opacity(configuration.borderOpacity),
                        lineWidth: configuration.borderWidth
                    )
            )
    }
}

/// Window focus state modifier
struct WindowFocusState: ViewModifier {
    let isFocused: Bool
    let spaceIsFocused: Bool

    func body(content: Content) -> some View {
        content.opacity(spaceIsFocused && !isFocused ? 0.5 : 1)
    }
}

// MARK: - Interaction Modifiers

/// Conditional interaction modifier for click and hover interactions
struct ConditionalInteraction: ViewModifier {
    let isEnabled: Bool
    @Binding var isHovered: Bool
    let onTap: () -> Void

    func body(content: Content) -> some View {
        content
            .modifier(ConditionalTapGesture(isEnabled: isEnabled, onTap: onTap))
            .modifier(ConditionalHoverState(isEnabled: isEnabled, isHovered: $isHovered))
    }
}

/// Conditional tap gesture modifier
private struct ConditionalTapGesture: ViewModifier {
    let isEnabled: Bool
    let onTap: () -> Void

    func body(content: Content) -> some View {
        if isEnabled {
            content.onTapGesture(perform: onTap)
        } else {
            content
        }
    }
}

/// Conditional hover state modifier
private struct ConditionalHoverState: ViewModifier {
    let isEnabled: Bool
    @Binding var isHovered: Bool

    func body(content: Content) -> some View {
        if isEnabled {
            content.modifier(HoverState(isHovered: $isHovered))
        } else {
            content
        }
    }
}

// MARK: - Text Styling Modifiers

/// Small secondary text modifier for descriptions and help text.
///
/// Applies consistent styling for secondary information text throughout the app.
struct SecondaryText: ViewModifier {
    /// The body of the secondary text modifier.
    /// - Returns: Content styled with small secondary text appearance.
    func body(content: Content) -> some View {
        content
            .font(.themeCaption)
            .foregroundColor(.themeSecondary)
    }
}

/// Small success text modifier for positive status messages.
///
/// Applies styling for success or positive status indicators with optional text selection.
struct SuccessText: ViewModifier {
    /// Whether the text should be selectable by the user.
    let isSelectable: Bool

    /// Initializes a success text modifier.
    /// - Parameter isSelectable: Whether to enable text selection. Defaults to false.
    init(isSelectable: Bool = false) {
        self.isSelectable = isSelectable
    }

    /// The body of the success text modifier.
    /// - Returns: Content styled with success text appearance and optional selection.
    func body(content: Content) -> some View {
        if isSelectable {
            content
                .font(.themeCaption)
                .foregroundColor(.themeSuccess)
                .textSelection(.enabled)
        } else {
            content
                .font(.themeCaption)
                .foregroundColor(.themeSuccess)
        }
    }
}

/// Small error text modifier for error messages.
///
/// Applies styling for error or negative status indicators with optional text selection.
struct ErrorText: ViewModifier {
    /// Whether the text should be selectable by the user.
    let isSelectable: Bool

    /// Initializes an error text modifier.
    /// - Parameter isSelectable: Whether to enable text selection. Defaults to false.
    init(isSelectable: Bool = false) {
        self.isSelectable = isSelectable
    }

    /// The body of the error text modifier.
    /// - Returns: Content styled with error text appearance and optional selection.
    func body(content: Content) -> some View {
        if isSelectable {
            content
                .font(.themeCaption)
                .foregroundColor(.themeError)
                .textSelection(.enabled)
        } else {
            content
                .font(.themeCaption)
                .foregroundColor(.themeError)
        }
    }
}

// MARK: - Additional Modifiers

/// Button style modifier for settings buttons
struct SettingsButton: ViewModifier {
    let isEnabled: Bool

    init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }

    func body(content: Content) -> some View {
        content
            .buttonStyle(.plain)
            .foregroundColor(isEnabled ? .themePrimary : .themeSecondary)
            .disabled(!isEnabled)
    }
}

/// Accessible image modifier for proper accessibility
struct AccessibleImage: ViewModifier {
    let label: LocalizedStringResource
    let isDecorative: Bool

    init(label: LocalizedStringResource, isDecorative: Bool = false) {
        self.label = label
        self.isDecorative = isDecorative
    }

    func body(content: Content) -> some View {
        content
            .accessibilityLabel(isDecorative ? "" : String(localized: label))
            .accessibilityHidden(isDecorative)
    }
}

// MARK: - View Extensions

extension View {
    /// Apply standard shadow modifier
    func standardShadow() -> some View {
        modifier(StandardShadow())
    }

    /// Apply icon shadow modifier
    func iconShadow() -> some View {
        modifier(IconShadow())
    }

    /// Apply text shadow modifier
    func textShadow() -> some View {
        modifier(TextShadow())
    }

    /// Apply smooth animation modifier
    func smoothAnimation(duration: Double = 0.3) -> some View {
        modifier(SmoothAnimation(duration: duration))
    }

    /// Apply blur replace transition modifier
    func blurReplaceTransition() -> some View {
        modifier(BlurReplaceTransition())
    }

    /// Apply space corner radius modifier
    func spaceCornerRadius(_ cornerRadius: Double = .themeSpaceCornerRadius) -> some View {
        modifier(SpaceCornerRadius(cornerRadius: cornerRadius))
    }

    /// Apply window corner radius modifier
    func windowCornerRadius(_ cornerRadius: Double = .themeWindowCornerRadius) -> some View {
        modifier(WindowCornerRadius(cornerRadius: cornerRadius))
    }

    /// Apply space focus state modifier
    func spaceFocusState(
        _ isFocused: Bool,
        configuration: SpaceFocusState.Configuration
    ) -> some View {
        modifier(SpaceFocusState(isFocused: isFocused, configuration: configuration))
    }

    /// Apply window focus state modifier
    func windowFocusState(_ isFocused: Bool, spaceIsFocused: Bool) -> some View {
        modifier(WindowFocusState(isFocused: isFocused, spaceIsFocused: spaceIsFocused))
    }

    /// Apply settings button modifier
    func settingsButton(isEnabled: Bool = true) -> some View {
        modifier(SettingsButton(isEnabled: isEnabled))
    }

    /// Apply accessible image modifier
    func accessibleImage(_ label: LocalizedStringResource, isDecorative: Bool = false) -> some View {
        modifier(AccessibleImage(label: label, isDecorative: isDecorative))
    }

    /// Apply conditional interaction modifier
    func conditionalInteraction(
        isEnabled: Bool,
        isHovered: Binding<Bool>,
        onTap: @escaping () -> Void
    ) -> some View {
        modifier(ConditionalInteraction(isEnabled: isEnabled, isHovered: isHovered, onTap: onTap))
    }

    // MARK: - Text Styling Extensions

    /// Apply secondary text styling
    func secondaryText() -> some View {
        modifier(SecondaryText())
    }

    /// Apply success text styling
    func successText(isSelectable: Bool = false) -> some View {
        modifier(SuccessText(isSelectable: isSelectable))
    }

    /// Apply error text styling
    func errorText(isSelectable: Bool = false) -> some View {
        modifier(ErrorText(isSelectable: isSelectable))
    }
}
