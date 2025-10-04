// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// A generic view representing a single list section row item with navigation and deletion capabilities.
///
/// This view provides a clickable row that displays item information with navigation and optional deletion actions.
/// It handles different layout scenarios based on item position and implements custom press feedback.
public struct LazyVStackListRowItem<Item: Identifiable, Page>: View {
    /// The item entity to display in this row.
    let item: Item

    /// All items in the list, used for position-based layout logic.
    let allItems: [Item]

    /// ViewBuilder that creates the content to display for this item.
    let content: (Item) -> any View

    /// Function that creates a navigation page for the given item.
    let createPage: (Item) -> Page

    /// Callback to register a dynamic sub-page for navigation.
    let onRegisterDynamicSubPage: (Page) -> Void

    /// Callback to navigate to the item's configuration page.
    let onNavigateTo: (Page) -> Void

    /// Optional callback to delete the item and its configuration.
    let onDelete: ((Page) -> Void)?

    /// Optional function to determine if delete action should be available for this item.
    /// If nil, delete action is never available.
    let shouldShowDeleteAction: ((Item) -> Bool)?

    /// The navigation page associated with this item, created on appearance.
    @State private var itemPage: Page?

    /// Whether the row is currently being pressed, used for visual feedback.
    @State private var isPressed = false

    /// The index of this item in the list (computed from item ID)
    private var itemIndex: Int {
        allItems.firstIndex(where: { $0.id == item.id }) ?? 0
    }

    /// The total number of items in the list
    private var numberOfItems: Int {
        allItems.count
    }

    /// Whether this is the first item in the list
    private var isFirstItem: Bool {
        allItems.first?.id == item.id
    }

    /// Whether this is the last item in the list
    private var isLastItem: Bool {
        allItems.last?.id == item.id
    }

    /// Creates a LazyVStackListRowItem
    ///
    /// - Parameters:
    ///   - item: The item to display in this row
    ///   - allItems: All items in the list for position-based layout logic
    ///   - content: ViewBuilder that creates the display content for the item
    ///   - createPage: Function that creates a navigation page for the item
    ///   - onRegisterDynamicSubPage: Callback to register navigation pages
    ///   - onNavigateTo: Callback for navigation events
    ///   - onDelete: Optional callback for delete events
    ///   - shouldShowDeleteAction: Optional function to control delete action visibility
    public init(
        item: Item,
        allItems: [Item],
        @ViewBuilder content: @escaping (Item) -> any View,
        createPage: @escaping (Item) -> Page,
        onRegisterDynamicSubPage: @escaping (Page) -> Void,
        onNavigateTo: @escaping (Page) -> Void,
        onDelete: ((Page) -> Void)? = nil,
        shouldShowDeleteAction: ((Item) -> Bool)? = nil
    ) {
        self.item = item
        self.allItems = allItems
        self.content = content
        self.createPage = createPage
        self.onRegisterDynamicSubPage = onRegisterDynamicSubPage
        self.onNavigateTo = onNavigateTo
        self.onDelete = onDelete
        self.shouldShowDeleteAction = shouldShowDeleteAction
    }

    /// The body of the LazyVStackListRowItem view
    ///
    /// Creates the main row structure with navigation, press feedback, and optional swipe actions.
    public var body: some View {
        let itemBackground = Color.primary
            .opacity(isPressed ? 0.1 : 0.0)
            .animation(.themeSmoothFastest, value: isPressed)

        VStack(spacing: 0) {
            if !isFirstItem {
                Spacer(minLength: 6)
                Divider()
            }

            // This is a hack to make swipe actions functional when the row is in a LazyVStack.
            if isFirstItem {
                ZStack {
                    itemBackground
                        .padding(.top, -7)
                        .padding(.bottom, numberOfItems > 1 ? 5 : -2)

                    createItemButton()
                        .padding(.horizontal, 10)
                        .padding(.top, 1)
                        .padding(.bottom, numberOfItems > 1 ? 14 : 6)
                }
            } else if isLastItem {
                ZStack {
                    itemBackground
                        .padding(.bottom, -6)

                    List { createItemButton() }
                        .padding(.top, 4)
                        .padding(.bottom, 3.5)
                }
            } else {
                ZStack {
                    itemBackground
                        .padding(.bottom, 5)

                    List { createItemButton() }
                        .padding(.top, 4)
                        .padding(.bottom, 9.5)
                }
            }
        }
        .padding(.horizontal, -20)
        .padding(.top, -3)
        .padding(.bottom, -8)
        .onAppear {
            itemPage = createPage(item)
        }
        .id("\(item.id)")
    }

    /// Creates the item button with navigation and press gesture handling
    ///
    /// - Returns: A configured button for this list item
    private func createItemButton() -> some View {
        Button(
            action: {
                // Register and navigate to the item page
                if let page = itemPage {
                    onRegisterDynamicSubPage(page)
                    onNavigateTo(page)
                }
            },
            label: {
                HStack {
                    AnyView(content(item))
                    Spacer()

                    Image(systemName: "chevron.right").foregroundColor(.secondary)
                }
                .contentShape(.rect)
            }
        )
        .buttonStyle(NoEffectButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
        .frame(height: 24)
        .deleteDisabled(true)
        .swipeActions(edge: .trailing) {
            if
                let shouldShow = shouldShowDeleteAction, shouldShow(item),
                let deleteAction = onDelete
            {
                Button(role: .destructive) {
                    if let page = itemPage {
                        deleteAction(page)
                    }
                } label: {
                    VStack {
                        Label(LocalizedStringResource("Delete"), systemImage: "trash")
                        Text(LocalizedStringResource("Delete")).secondaryText()
                    }
                }
            }
        }
    }
}

/// A button style that applies no visual effects when pressed.
private struct NoEffectButtonStyle: ButtonStyle {
    /// Creates the button body without any press effects.
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}
