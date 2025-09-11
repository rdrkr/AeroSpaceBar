// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// A view representing a single list section row for a group configuration.
struct GroupSettingsListRowView: View {
    let groupId: Int
    let onRegisterDynamicSubPage: (AnyNavigationPage) -> Void
    let onNavigateTo: (AnyNavigationPage) -> Void
    let onDelete: () -> Void

    var body: some View {
        Button(
            action: {
                // Register and navigate to the group page
                let groupPage = AnyNavigationPage(GroupNavigationPage(index: groupId))
                onRegisterDynamicSubPage(groupPage)
                onNavigateTo(groupPage)
            },
            label: {
                HStack {
                    Text(LocalizedStringResource("Group \(groupId + 1)"))
                    Spacer()

                    Image(systemName: "chevron.right").foregroundColor(.secondary)
                }
                .contentShape(.rect)
            }
        )
        .deleteDisabled(true)
        .buttonStyle(GroupSettingsListRowButtonStyle())
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label(LocalizedStringResource("Delete"), systemImage: "trash")
            }
        }
    }
}

/// Custom button style for group settings list row to provide visual feedback on press.
private struct GroupSettingsListRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .listRowBackground(configuration.isPressed ? Color.primary.opacity(0.1) : Color.clear)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
