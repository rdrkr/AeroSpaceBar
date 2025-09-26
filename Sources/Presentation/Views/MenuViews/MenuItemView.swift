// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Domain
import SwiftUI

/// A reusable view for menu items with consistent styling.
///
/// This component provides a standardized menu item appearance that matches native macOS
/// menu styling when used within a `.window` style MenuBarExtra. It includes proper hover
/// states, keyboard shortcut display, and consistent spacing and typography.
///
/// ## Features
/// - Native macOS menu item appearance with blue highlight on hover
/// - Automatic keyboard shortcut formatting and display
/// - Consistent icon and text layout with proper spacing
/// - Accessibility support through proper labeling
/// - Customizable action handling
///
/// ## Usage
/// ```swift
/// MenuItemView(
///     title: "Settings...",
///     systemImage: "gear",
///     keyboardShortcut: ","
/// ) {
///     openSettings()
/// }
/// ```
struct MenuItemView: View {
    /// The localized title text displayed in the menu item.
    let title: LocalizedStringResource

    /// The SF Symbol name used for the menu item icon.
    let systemImage: String

    /// The optional keyboard shortcut that triggers this menu item.
    let keyboardShortcut: KeyEquivalent?

    /// The action to perform when the menu item is selected.
    let action: () -> Void

    /// Tracks whether the menu item is currently being hovered for visual feedback.
    @State private var isHovered = false

    /// Creates a new menu item with the specified configuration.
    ///
    /// - Parameters:
    ///   - title: The localized title text to display
    ///   - systemImage: The SF Symbol name for the menu item icon
    ///   - keyboardShortcut: Optional keyboard shortcut (defaults to nil)
    ///   - action: The closure to execute when the menu item is selected
    init(
        title: LocalizedStringResource,
        systemImage: String,
        keyboardShortcut: KeyEquivalent? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.keyboardShortcut = keyboardShortcut
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemImage).font(.caption)
                Text(title)
                Spacer()

                if let shortcut = keyboardShortcut {
                    Text("⌘\(shortcut.character.uppercased())")
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 4)
            .background(
                Rectangle()
                    .fill(isHovered ? Color.accentColor : Color.clear)
                    .padding(.horizontal, -10)
                    .cornerRadius(6)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
        .modifier(ConditionalKeyboardShortcut(shortcut: keyboardShortcut))
        .tag("menu-item-\(systemImage)")
    }
}

/// A reusable divider for menu sections.
///
/// This component provides consistent visual separation between menu sections
/// with proper padding and styling that matches native macOS menu appearance.
///
/// ## Features
/// - Consistent horizontal and vertical padding
/// - Automatic tagging for UI testing and identification
/// - Native divider appearance that adapts to light/dark mode
///
/// ## Usage
/// ```swift
/// MenuDivider(identifier: "main-section")
/// ```
struct MenuDivider: View {
    /// A unique identifier used for tagging and testing purposes.
    let identifier: String

    var body: some View {
        Divider()
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .tag("menu-divider-\(identifier)")
    }
}

// MARK: - Supporting Modifiers

/// A modifier that conditionally applies a keyboard shortcut to a view.
///
/// This modifier provides a clean way to optionally apply keyboard shortcuts
/// to views without requiring conditional view construction. It applies the
/// shortcut only when a valid KeyEquivalent is provided.
///
/// ## Usage
/// ```swift
/// Button("Save") { save() }
///     .modifier(ConditionalKeyboardShortcut(shortcut: "s"))
/// ```
///
/// - Note: This modifier is used internally by MenuItemView to handle
///         optional keyboard shortcuts in a type-safe manner.
private struct ConditionalKeyboardShortcut: ViewModifier {
    /// The optional keyboard shortcut to apply. If nil, no shortcut is added.
    let shortcut: KeyEquivalent?

    /// Applies the keyboard shortcut modifier conditionally.
    ///
    /// - Parameter content: The content view to modify
    /// - Returns: The content view with an optional keyboard shortcut applied
    func body(content: Content) -> some View {
        if let shortcut {
            content.keyboardShortcut(shortcut)
        } else {
            content
        }
    }
}

#Preview {
    VStack {
        MenuItemView(
            title: "Settings",
            systemImage: "gear",
            keyboardShortcut: ","
        ) {
            Logger.debug("Settings tapped", category: Logger.userInterface)
        }

        MenuDivider(identifier: "1")

        MenuItemView(
            title: "About AeroSpaceBar",
            systemImage: "info.circle"
        ) {
            Logger.debug("About tapped", category: Logger.userInterface)
        }
    }
    .padding()
}
