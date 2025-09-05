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
    let cornerRadius: CGFloat

    init(cornerRadius: CGFloat = .themeSpaceCornerRadius) {
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
    let cornerRadius: CGFloat

    init(cornerRadius: CGFloat = .themeWindowCornerRadius) {
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
        let backgroundBlurRadius: CGFloat
        let backgroundTintColor: Color
        let foregroundColor: Color
        let borderTintColor: Color
        let borderOpacity: Double
        let borderCornerRadius: CGFloat
        let borderWidth: CGFloat
    }

    let isFocused: Bool
    let configuration: Configuration

    func body(content: Content) -> some View {
        content
            .background(
                configuration.backgroundTintColor
                    .opacity(isFocused ? configuration
                        .backgroundOpacity : (configuration.backgroundOpacity == 0 ? 0 : 0.2)
                    )
                    .blur(radius: configuration.backgroundBlurRadius)
            )
            .overlay(
                RoundedRectangle(cornerRadius: configuration.borderCornerRadius, style: .continuous)
                    .stroke(
                        configuration.borderTintColor
                            .opacity(isFocused ? configuration
                                .borderOpacity :
                                (configuration.borderOpacity == 0 ? 0 : configuration.borderOpacity * 0.3)
                            ),
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

/// Value display text modifier for numeric values next to sliders.
///
/// Applies consistent styling for numeric value display with fixed width and alignment.
/// Commonly used to show slider values, percentages, and measurements.
struct ValueDisplayText: ViewModifier {
    /// The fixed width for the value display area.
    let width: CGFloat
    /// The alignment of text within the fixed width area.
    let alignment: Alignment

    /// Initializes a value display text modifier.
    /// - Parameters:
    ///   - width: The fixed width for the display area. Defaults to theme value.
    ///   - alignment: The text alignment within the area. Defaults to .trailing.
    init(width: CGFloat = .themeValueDisplayWidth, alignment: Alignment = .trailing) {
        self.width = width
        self.alignment = alignment
    }

    /// The body of the value display text modifier.
    /// - Returns: Content styled as a fixed-width value display.
    func body(content: Content) -> some View {
        content
            .secondaryText()
            .frame(width: width, alignment: alignment)
    }
}

/// Fixed size text modifier for multiline help text.
///
/// Applies styling for secondary text that needs to maintain its natural size
/// without being compressed by container constraints. Ideal for help text and descriptions.
struct FixedSizeText: ViewModifier {
    /// Whether to fix the horizontal size.
    let horizontal: Bool
    /// Whether to fix the vertical size.
    let vertical: Bool

    /// Initializes a fixed size text modifier.
    /// - Parameters:
    ///   - horizontal: Whether to maintain natural horizontal size. Defaults to false.
    ///   - vertical: Whether to maintain natural vertical size. Defaults to true.
    init(horizontal: Bool = false, vertical: Bool = true) {
        self.horizontal = horizontal
        self.vertical = vertical
    }

    /// The body of the fixed size text modifier.
    /// - Returns: Content styled with secondary text and fixed sizing.
    func body(content: Content) -> some View {
        content
            .secondaryText()
            .fixedSize(horizontal: horizontal, vertical: vertical)
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

/// Form styling modifier for consistent form appearance
struct FormStyling: ViewModifier {
    func body(content: Content) -> some View {
        content
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
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

/// Loading state modifier
struct LoadingState: ViewModifier {
    let isLoading: Bool

    func body(content: Content) -> some View {
        content
            .disabled(isLoading)
            .opacity(isLoading ? 0.6 : 1.0)
            .overlay {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.8)
                }
            }
    }
}

/// Card-like styling modifier
struct CardStyle: ViewModifier {
    let backgroundColor: Color
    let cornerRadius: CGFloat

    init(backgroundColor: Color = .themeCardBackground, cornerRadius: CGFloat = .themeCardCornerRadius) {
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
    }

    func body(content: Content) -> some View {
        content
            .padding()
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
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

    /// Apply smooth theme animation
    func themeSmoothAnimation() -> some View {
        animation(.themeSmooth, value: true)
    }

    /// Apply blur replace transition modifier
    func blurReplaceTransition() -> some View {
        modifier(BlurReplaceTransition())
    }

    /// Apply space corner radius modifier
    func spaceCornerRadius(_ cornerRadius: CGFloat = .themeSpaceCornerRadius) -> some View {
        modifier(SpaceCornerRadius(cornerRadius: cornerRadius))
    }

    /// Apply window corner radius modifier
    func windowCornerRadius(_ cornerRadius: CGFloat = .themeWindowCornerRadius) -> some View {
        modifier(WindowCornerRadius(cornerRadius: cornerRadius))
    }

    /// Apply hover state modifier
    func hoverState(_ isHovered: Binding<Bool>) -> some View {
        modifier(HoverState(isHovered: isHovered))
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

    /// Apply form styling modifier
    func formStyling() -> some View {
        modifier(FormStyling())
    }

    /// Apply accessible image modifier
    func accessibleImage(_ label: LocalizedStringResource, isDecorative: Bool = false) -> some View {
        modifier(AccessibleImage(label: label, isDecorative: isDecorative))
    }

    /// Apply loading state modifier
    func loadingState(_ isLoading: Bool) -> some View {
        modifier(LoadingState(isLoading: isLoading))
    }

    /// Apply card style modifier
    func cardStyle(
        backgroundColor: Color = .themeCardBackground,
        cornerRadius: CGFloat = .themeCardCornerRadius
    ) -> some View {
        modifier(CardStyle(backgroundColor: backgroundColor, cornerRadius: cornerRadius))
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

    /// Apply value display text styling
    func valueDisplayText(width: CGFloat = .themeValueDisplayWidth, alignment: Alignment = .trailing) -> some View {
        modifier(ValueDisplayText(width: width, alignment: alignment))
    }

    /// Apply fixed size secondary text styling
    func fixedSizeText(horizontal: Bool = false, vertical: Bool = true) -> some View {
        modifier(FixedSizeText(horizontal: horizontal, vertical: vertical))
    }
}
