// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// A type-erased wrapper for NavigationPage that allows storing different page types together.
public struct AnyNavigationPage: NavigationPage {
    /// The unique identifier for this navigation page.
    public let id: Int

    /// The localized display name for this navigation page.
    public let name: String

    /// The description/subtitle text for this navigation page.
    public let description: String

    /// The SF Symbol name to display in the sidebar.
    public let symbolName: String

    /// The page icon view to display for this page.
    @MainActor
    public var icon: AnyView {
        AnyView(defaultIcon)
    }

    /// The parent page of this navigation page, if any.
    public let parentPage: (any NavigationPage)?

    /// A closure that returns the view for this navigation page.
    /// Stored as a closure to avoid Sendable issues with AnyView.
    private let _viewForPage: @Sendable @MainActor () -> PageView

    /// A view builder that returns the view for this navigation page.
    /// - Returns: The view associated with this navigation page
    @MainActor
    public var viewForPage: PageView {
        _viewForPage()
    }

    /// A view builder that returns the sidebar item view for this navigation page.
    @MainActor
    public var viewForSidebar: AnyView {
        AnyView(defaultViewForSidebar(AnyView(icon)))
    }

    /// Initializes an AnyNavigationPage with a concrete NavigationPage.
    /// - Parameter page: The concrete navigation page to wrap
    @MainActor
    public init(_ page: some NavigationPage) {
        id = page.id
        name = page.name
        symbolName = page.symbolName
        description = page.description
        parentPage = page.parentPage
        _viewForPage = { page.viewForPage }
    }

    /// Hashes the essential components of this navigation page.
    /// Uses the unique identifier as the hash basis for proper SwiftUI selection.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    /// Returns a Boolean value indicating whether two navigation pages are equal.
    /// Two navigation pages are equal if they have the same identifier.
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
