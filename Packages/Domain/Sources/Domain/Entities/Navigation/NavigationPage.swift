// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// A protocol that defines the requirements for any navigation page in the settings interface.
///
/// This protocol allows for both static enum-based navigation (like main settings pages)
/// and dynamic navigation (like group pages) to work together in a unified system.
public protocol NavigationPage: Equatable, Hashable, Identifiable, Sendable {
    /// The associated type for the view returned by this navigation page.
    typealias PageView = AnyView

    /// The unique identifier for this navigation page.
    var id: Int { get }

    /// The localized display name for this navigation page.
    var name: String { get }

    /// The description/subtitle text for this navigation page.
    var description: String { get }

    /// The SF Symbol name to display for this page.
    var symbolName: String { get }

    /// The page icon view to display for this page.
    @MainActor
    var icon: AnyView { get }

    /// The parent page of this navigation page, if any.
    var parentPage: (any NavigationPage)? { get }

    /// A view builder that returns the view for this navigation page.
    /// - Returns: The view associated with this navigation page
    @MainActor
    @ViewBuilder
    var viewForPage: PageView { get }

    /// A view builder that returns the sidebar item view for this navigation page.
    @MainActor
    @ViewBuilder
    var viewForSidebar: AnyView { get }
}

/// Default protocol implementations.
public extension NavigationPage {
    /// A default view builder that returns the default icon for this page.
    @MainActor
    var defaultIcon: some View {
        let image = Image(systemName: symbolName)
            .resizable()
            .frame(
                width: ConfigurationDefaults.settingsIconSmallSize,
                height: ConfigurationDefaults.settingsIconSmallSize
            )
            .padding(3)
            .background(
                LinearGradient(
                    gradient: Gradient(
                        colors: [
                            Color.gray.opacity(0.4),
                            Color(NSColor.controlBackgroundColor).opacity(0.8),
                            Color(NSColor.controlBackgroundColor).opacity(0.9),
                            Color(NSColor.controlBackgroundColor).opacity(1.0)
                        ]
                    ),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
            )
            .cornerRadius(5)

        if #available(macOS 26.0, *) {
            return image
                .glassEffect(.regular, in: .rect(cornerRadius: 5))
        } else {
            return image
        }
    }

    /// A default view builder that returns the sidebar item view for this navigation page.
    @MainActor
    @ViewBuilder
    func defaultViewForSidebar(_ icon: AnyView) -> some View {
        HStack(spacing: 5) {
            icon
            Text(name).font(.callout)
        }
    }
}
