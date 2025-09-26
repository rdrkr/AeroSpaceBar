// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// A navigation page that represents a specific group detail view.
///
/// This allows individual group configurations to be part of the main navigation system,
/// enabling the navigation buttons to work across both main settings pages and group details.
struct GroupNavigationPage: NavigationPage {
    /// A prefix to the name of this type of navigation page.
    static let namePrefix: String = "Group "

    /// The index of the group in the list of groups.
    let index: Int

    /// The unique identifier for this navigation page which is the group index.
    var id: Int { index }

    /// The localized display name for this navigation page.
    var name: String {
        String(
            localized: LocalizedStringResource(
                "\(GroupNavigationPage.namePrefix)\(id + 1)",
                comment: "Title for group detail page"
            )
        )
    }

    /// The SF Symbol name to display in the sidebar.
    var symbolName: String {
        "rectangle.3.group"
    }

    /// The page icon view to display for this page.
    @MainActor
    var icon: AnyView {
        AnyView(defaultIcon)
    }

    /// The description/subtitle text for this navigation page.
    var description: String {
        String(
            localized: LocalizedStringResource(
                "Configure the appearance and behavior of this group.",
                comment: "Description for group detail page"
            )
        )
    }

    /// A view builder that returns the sidebar item view for this navigation page.
    @MainActor
    @ViewBuilder
    var viewForSidebar: AnyView {
        AnyView(defaultViewForSidebar(icon))
    }

    /// The parent page of the navigation option.
    var parentPage: (any NavigationPage)? { RootNavigationPage.groups }

    /// A view builder that returns the view for this navigation page.
    @MainActor
    @ViewBuilder
    var viewForPage: PageView {
        PageView(GroupPageView(id: id))
    }

    /// Hashes the essential components of this navigation page.
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    /// Returns a Boolean value indicating whether two group detail navigation pages are equal.
    static func == (lhs: GroupNavigationPage, rhs: GroupNavigationPage) -> Bool {
        lhs.id == rhs.id
    }
}
