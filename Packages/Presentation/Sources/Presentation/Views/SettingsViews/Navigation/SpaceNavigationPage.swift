// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Domain
import SwiftUI

/// A navigation page that represents a specific space detail view.
///
/// This allows individual space configurations to be part of the main navigation system,
/// enabling the navigation buttons to work across both main settings pages and space details.
struct SpaceNavigationPage: NavigationPage {
    /// A prefix to the name of this type of navigation page.
    static let namePrefix: String = "Space "

    /// The ID of the space.
    let spaceId: String

    /// The unique identifier for this navigation page which is the space ID hash.
    var id: Int { spaceId.hashValue }

    /// The localized display name for this navigation page.
    var name: String {
        String(
            localized: LocalizedStringResource(
                "\(Self.namePrefix)\(spaceId)",
                comment: "Title for space detail page"
            )
        )
    }

    /// The SF Symbol name to display in the sidebar.
    var symbolName: String {
        "square.3.layers.3d.top.filled"
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
                "Configure the appearance and behavior of this space.",
                comment: "Description for space detail page"
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
    var parentPage: (any NavigationPage)? { RootNavigationPage.spaces }

    /// A view builder that returns the view for this navigation page.
    @MainActor
    @ViewBuilder
    var viewForPage: PageView {
        PageView(SpacePageView(spaceId: spaceId))
    }

    /// Hashes the essential components of this navigation page.
    func hash(into hasher: inout Hasher) {
        hasher.combine(spaceId)
    }

    /// Returns a Boolean value indicating whether two space detail navigation pages are equal.
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.spaceId == rhs.spaceId
    }
}
