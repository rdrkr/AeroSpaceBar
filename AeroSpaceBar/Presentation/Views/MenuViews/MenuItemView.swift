// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// A reusable view for menu items with consistent styling
struct MenuItemView: View {
    let title: LocalizedStringResource
    let systemImage: String
    let keyboardShortcut: KeyEquivalent?
    let action: () -> Void

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
            Label(title, systemImage: systemImage)
        }
        .modifier(ConditionalKeyboardShortcut(shortcut: keyboardShortcut))
        .tag("menu-item-\(systemImage)")
    }
}

/// A reusable divider for menu sections
struct MenuDivider: View {
    let identifier: String

    var body: some View {
        Divider()
            .tag("menu-divider-\(identifier)")
    }
}

// MARK: - Supporting Modifiers

/// A modifier that conditionally applies a keyboard shortcut
private struct ConditionalKeyboardShortcut: ViewModifier {
    let shortcut: KeyEquivalent?

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
