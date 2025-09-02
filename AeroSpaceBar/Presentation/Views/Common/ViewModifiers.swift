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
    let isFocused: Bool

    func body(content: Content) -> some View {
        content.background(
            isFocused ? Color.active : Color.noActive
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
    func spaceFocusState(_ isFocused: Bool) -> some View {
        modifier(SpaceFocusState(isFocused: isFocused))
    }

    /// Apply window focus state modifier
    func windowFocusState(_ isFocused: Bool, spaceIsFocused: Bool) -> some View {
        modifier(WindowFocusState(isFocused: isFocused, spaceIsFocused: spaceIsFocused))
    }
}
