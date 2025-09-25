// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Domain
import SwiftUI

/// A protocol that defines the requirements for any navigation page in the settings interface.
///
/// This protocol allows for both static enum-based navigation (like main settings pages)
/// and dynamic navigation (like group pages) to work together in a unified system.
protocol NavigationPage: Equatable, Hashable, Identifiable, Sendable {
    /// The associated type for the view returned by this navigation page.
    typealias PageView = AnyView

    /// The unique identifier for this navigation page.
    var id: Int { get }

    /// The localized display name for this navigation page.
    var name: String { get }

    /// The SF Symbol name to display for this page.
    var symbolName: String { get }

    /// The parent page of this navigation page, if any.
    var parentPage: (any NavigationPage)? { get }

    /// A view builder that returns the view for this navigation page.
    /// - Returns: The view associated with this navigation page
    @MainActor
    @ViewBuilder
    var viewForPage: PageView { get }
}

/// Default protocol implementations.
extension NavigationPage {
    // swiftformat:disable all
    @MainActor
    internal var defaultIcon: some View {
        // swiftformat:enable all
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

    /// The page icon view to display for this page.
    @MainActor
    var icon: AnyView {
        AnyView(defaultIcon)
    }

    /// A default internal view builder that returns the sidebar item view for this navigation page.
    @MainActor
    @ViewBuilder
    // in order to retain internal, disable swiftformat.
    // swiftformat:disable all
    internal func defaultViewForSidebar(_ icon: AnyView) -> some View {
        // swiftformat:enable all
        HStack(spacing: 5) {
            icon
            Text(name).font(.callout)
        }
    }

    /// A view builder that returns the sidebar item view for this navigation page.
    @MainActor
    @ViewBuilder
    var viewForSidebar: some View {
        defaultViewForSidebar(AnyView(icon))
    }
}

/// A type-erased wrapper for NavigationPage that allows storing different page types together.
struct AnyNavigationPage: NavigationPage {
    /// The unique identifier for this navigation page.
    let id: Int

    /// The localized display name for this navigation page.
    let name: String

    /// The SF Symbol name to display in the sidebar.
    let symbolName: String

    /// The parent page of this navigation page, if any.
    let parentPage: (any NavigationPage)?

    /// A closure that returns the view for this navigation page.
    /// Stored as a closure to avoid Sendable issues with AnyView.
    private let _viewForPage: @Sendable @MainActor () -> PageView

    /// A view builder that returns the view for this navigation page.
    /// - Returns: The view associated with this navigation page
    @MainActor
    @ViewBuilder
    var viewForPage: PageView {
        _viewForPage()
    }

    /// Initializes an AnyNavigationPage with a concrete NavigationPage.
    /// - Parameter page: The concrete navigation page to wrap
    @MainActor
    init(_ page: some NavigationPage) {
        id = page.id
        name = page.name
        symbolName = page.symbolName
        parentPage = page.parentPage
        _viewForPage = { page.viewForPage }
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
