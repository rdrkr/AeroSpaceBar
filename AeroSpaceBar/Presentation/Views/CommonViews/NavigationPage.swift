// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// A protocol that defines the requirements for any navigation page in the settings interface.
///
/// This protocol allows for both static enum-based navigation (like main settings pages)
/// and dynamic navigation (like group pages) to work together in a unified system.
protocol NavigationPage: Equatable, Hashable, Identifiable {
    /// The associated type for the view returned by this navigation page.
    typealias PageView = AnyView

    /// The unique identifier for this navigation page.
    var id: Int { get }

    /// The localized display name for this navigation page.
    var name: LocalizedStringResource { get }

    /// The SF Symbol name to display in the sidebar.
    var symbolName: String { get }

    /// The parent page of this navigation page, if any.
    var parentPage: (any NavigationPage)? { get }

    /// A view builder that returns the view for this navigation page.
    /// - Returns: The view associated with this navigation page
    @MainActor
    @ViewBuilder
    var viewForPage: PageView { get }
}

/// A type-erased wrapper for NavigationPage that allows storing different page types together.
struct AnyNavigationPage: NavigationPage {
    /// The unique identifier for this navigation page.
    let id: Int

    /// The localized display name for this navigation page.
    let name: LocalizedStringResource

    /// The SF Symbol name to display in the sidebar.
    let symbolName: String

    /// The parent page of this navigation page, if any.
    let parentPage: (any NavigationPage)?

    /// A view builder that returns the view for this navigation page.
    /// - Returns: The view associated with this navigation page
    @MainActor @ViewBuilder let viewForPage: PageView

    /// Initializes an AnyNavigationPage with a concrete NavigationPage.
    /// - Parameter page: The concrete navigation page to wrap
    @MainActor
    init(_ page: some NavigationPage) {
        id = page.id
        name = page.name
        symbolName = page.symbolName
        parentPage = page.parentPage
        viewForPage = page.viewForPage
    }

    /// Hashes the essential components of this navigation page.
    /// Uses the unique identifier as the hash basis for proper SwiftUI selection.
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    /// Returns a Boolean value indicating whether two navigation pages are equal.
    /// Two navigation pages are equal if they have the same identifier.
    static func == (lhs: AnyNavigationPage, rhs: AnyNavigationPage) -> Bool {
        lhs.id == rhs.id
    }
}
