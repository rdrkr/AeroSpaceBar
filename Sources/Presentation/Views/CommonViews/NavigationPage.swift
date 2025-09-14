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

    /// The SF Symbol name to display for this page.
    var symbolName: String { get }

    // /// The page associated icon.
    // var icon: any View { get }

    /// The parent page of this navigation page, if any.
    var parentPage: (any NavigationPage)? { get }

    // /// A view builder that returns the sidebar item view for this navigation page.
    // /// - Returns: The sidebar item view associated with this navigation page
    // @MainActor
    // @ViewBuilder
    // var viewForSidebar: any View { get }

    /// A view builder that returns the view for this navigation page.
    /// - Returns: The view associated with this navigation page
    @MainActor
    @ViewBuilder
    var viewForPage: PageView { get }
}

/// Default protocol implementations.
extension NavigationPage {
    /// The page icon to display for this page.
    var icon: some View {
        Image(systemName: symbolName)
            .resizable()
            .frame(width: 16, height: 16)
            .padding(4)
            .background(.white.opacity(0.1), in: .rect)
            .cornerRadius(8)
    }

    /// A default internal view builder that returns the sidebar item view for this navigation page.
    @MainActor
    @ViewBuilder
    // in order to retain internal, disable swiftformat.
    // swiftformat:disable all
    internal var defaultViewForSidebar: some View {
        HStack {
            icon
            Text(name)
        }
    }
    // swiftformat:enable all

    /// A view builder that returns the sidebar item view for this navigation page.
    @MainActor
    @ViewBuilder
    var viewForSidebar: some View {
        defaultViewForSidebar
    }
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
