// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

// MARK: - Shadow Modifiers

/// Standard shadow modifier for spaces and windows
struct StandardShadow: ViewModifier {
    func body(content: Content) -> some View {
        content.shadow(color: .shadow, radius: 2)
    }
}

/// Icon shadow modifier for window icons
struct IconShadow: ViewModifier {
    func body(content: Content) -> some View {
        content.shadow(color: .iconShadow, radius: 2)
    }
}

/// Text shadow modifier for foreground text
struct TextShadow: ViewModifier {
    func body(content: Content) -> some View {
        content.shadow(color: .foregroundShadow, radius: 2)
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

    init(cornerRadius: CGFloat = 8.0) {
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

    init(cornerRadius: CGFloat = 4.0) {
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
            .animation(.smooth, value: isHovered)
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
            .foregroundColor(isEnabled ? .blue : .secondary)
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

    init(backgroundColor: Color = Color(.controlBackgroundColor), cornerRadius: CGFloat = 12) {
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

    /// Apply blur replace transition modifier
    func blurReplaceTransition() -> some View {
        modifier(BlurReplaceTransition())
    }

    /// Apply space corner radius modifier
    func spaceCornerRadius(_ cornerRadius: CGFloat = 8.0) -> some View {
        modifier(SpaceCornerRadius(cornerRadius: cornerRadius))
    }

    /// Apply window corner radius modifier
    func windowCornerRadius(_ cornerRadius: CGFloat = 4.0) -> some View {
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
        backgroundColor: Color = Color(.controlBackgroundColor),
        cornerRadius: CGFloat = 12
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
}
