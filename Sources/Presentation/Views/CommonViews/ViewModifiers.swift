// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Domain
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
    let isFocused: Bool
    let visualConfig: VisualContainer
    let widgetSpacing: Double = ConfigurationDefaults.widgetSpacing

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    visualConfig.backgroundTintColor
                        .opacity(
                            isFocused ? (
                                visualConfig.backgroundOpacity == 0 ? 0 :
                                    min(visualConfig.backgroundOpacity + 0.2, 1)
                            ) : visualConfig.backgroundOpacity
                        )
                        .blur(radius: visualConfig.backgroundBlurRadius)
                        .cornerRadius(visualConfig.cornerRadius)
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height - (visualConfig.borderWidth * 2)
                        )
                        .offset(y: visualConfig.borderWidth)
                        .background(
                            RoundedRectangle(cornerRadius: visualConfig.cornerRadius, style: .continuous)
                                .stroke(
                                    visualConfig.borderTintColor
                                        .opacity(visualConfig.borderOpacity),
                                    lineWidth: visualConfig.borderWidth
                                )
                                .frame(
                                    width: geometry.size.width + visualConfig.borderWidth,
                                    height: geometry.size.height - visualConfig.borderWidth
                                )
                                .offset(y: visualConfig.borderWidth)
                        )
                }
            )
            .padding(.horizontal, widgetSpacing + visualConfig.borderWidth)
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
            .font(.subheadline)
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
                .font(.subheadline)
                .foregroundColor(.themeSuccess)
                .textSelection(.enabled)
        } else {
            content
                .font(.subheadline)
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
                .font(.subheadline)
                .foregroundColor(.themeError)
                .textSelection(.enabled)
        } else {
            content
                .font(.subheadline)
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

/// Settings form modifier for consistent styling
struct SettingsFormStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .formStyle(.grouped)
            .padding(.top, -20)
    }
}

// MARK: - Visual Container Configuration Modifiers

/// Visual container configuration modifier for applying consolidated visual styling
struct VisualContainerConfigurationModifier: ViewModifier {
    let configuration: VisualContainer
    let applyBackground: Bool
    let applyBorder: Bool
    let applyForeground: Bool

    func body(content: Content) -> some View {
        content
            .modifier(ConditionalBackground(configuration: configuration, applyBackground: applyBackground))
            .modifier(ConditionalBorder(configuration: configuration, applyBorder: applyBorder))
            .modifier(ConditionalForeground(configuration: configuration, applyForeground: applyForeground))
            .clipShape(RoundedRectangle(cornerRadius: configuration.cornerRadius))
    }
}

/// Conditional background modifier
private struct ConditionalBackground: ViewModifier {
    let configuration: VisualContainer
    let applyBackground: Bool

    func body(content: Content) -> some View {
        if applyBackground {
            content.background(
                configuration.backgroundTintColor
                    .opacity(configuration.backgroundOpacity)
                    .blur(radius: configuration.backgroundBlurRadius)
            )
        } else {
            content
        }
    }
}

/// Conditional border modifier
private struct ConditionalBorder: ViewModifier {
    let configuration: VisualContainer
    let applyBorder: Bool

    func body(content: Content) -> some View {
        if applyBorder {
            content.overlay(
                RoundedRectangle(cornerRadius: configuration.cornerRadius)
                    .stroke(
                        configuration.borderTintColor.opacity(configuration.borderOpacity),
                        lineWidth: configuration.borderWidth
                    )
            )
        } else {
            content
        }
    }
}

/// Conditional foreground modifier
private struct ConditionalForeground: ViewModifier {
    let configuration: VisualContainer
    let applyForeground: Bool

    func body(content: Content) -> some View {
        if applyForeground {
            content.foregroundStyle(configuration.foregroundColor)
        } else {
            content
        }
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

    /// Apply space focus state modifier
    func spaceFocusState(
        _ isFocused: Bool,
        visualConfig: VisualContainer
    ) -> some View {
        modifier(
            SpaceFocusState(
                isFocused: isFocused,
                visualConfig: visualConfig
            )
        )
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

    /// Apply settings form style modifier
    func settingsFormStyle() -> some View {
        modifier(SettingsFormStyle())
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

    /// Apply visual container configuration styling
    func visualContainerConfiguration(
        _ configuration: VisualContainer,
        applyBackground: Bool = true,
        applyBorder: Bool = true,
        applyForeground: Bool = true
    ) -> some View {
        modifier(
            VisualContainerConfigurationModifier(
                configuration: configuration,
                applyBackground: applyBackground,
                applyBorder: applyBorder,
                applyForeground: applyForeground
            )
        )
    }
}
