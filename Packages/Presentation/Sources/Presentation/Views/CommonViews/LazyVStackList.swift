// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// A LazyVStack implementation with List-like selection behavior and automatic scroll restoration
///
/// Provides optional single selection capability with visual feedback similar to SwiftUI's List,
/// but using LazyVStack for better performance and layout control. Includes automatic scroll position
/// restoration that persists across view lifecycle changes.
///
/// Example usage with selection:
/// ```swift
/// LazyVStackList(selection: $selectedItem) {
///     ForEach(items) { item in
///         LazyVStackNavigationLink(value: item) {
///             Text(item.title)
///         }
///     }
/// }
/// ```
///
/// Example usage without selection:
/// ```swift
/// LazyVStackList {
///     ForEach(items) { item in
///         Text(item.title)
///     }
/// }
/// ```
struct LazyVStackList<Content>: View where Content: View {
    /// The currently selected item identifier (optional for non-selection mode)
    @Binding private var selectionIdentifier: ObjectIdentifier?

    /// Content builder that creates the view content
    private let content: () -> Content

    /// Spacing between items
    private let spacing: CGFloat?

    /// Whether to show hover effects
    private let showHoverEffect: Bool

    /// Whether selection is enabled
    private var selectionEnabled: Bool {
        selection != nil
    }

    /// Whether to enable scrolling behavior
    private let useNativeScrollView: Bool

    /// Collected navigation items from child views
    @State private var collectedItems: [NavigationItem] = []

    /// Creates a LazyVStackList without selection capability
    /// - Parameters:
    ///   - spacing: Spacing between items (defaults to 0)
    ///   - showHoverEffect: Whether to show hover effects (defaults to true)
    ///   - useNativeScrollView: Whether to enable scrolling behavior (defaults to false)
    ///   - content: Content builder that creates the view content
    init(
        spacing: CGFloat? = 0,
        showHoverEffect: Bool = false,
        useNativeScrollView: Bool = false,
        @ViewBuilder content: @escaping () -> Content
    ) {
        _selectionIdentifier = .constant(nil)

        self.content = content
        self.spacing = spacing
        self.showHoverEffect = showHoverEffect
        self.useNativeScrollView = useNativeScrollView
    }
}

/// Wrapper for storing selection bindings in a type-erased way
///
/// This wrapper allows storing heterogeneous selection bindings in a single dictionary
/// by erasing the specific types while maintaining type safety at runtime.
private struct SelectionWrapper: Sendable {
    /// Closure that returns the current selection value
    let getValue: @Sendable () -> Any?

    /// Closure that updates the selection value
    let setValue: @Sendable (Any?) -> Void

    /// Optional closure that returns the selected item's identifier
    let getSelectedId: (@Sendable () -> Any?)?
}

extension SelectionWrapper {
    /// Creates a SelectionWrapper for basic selection handling without ID extraction
    /// - Parameters:
    ///   - getValue: Closure that returns the current selection value
    ///   - setValue: Closure that updates the selection value
    init(
        getValue: @escaping @Sendable () -> Any?,
        setValue: @escaping @Sendable (Any?) -> Void
    ) {
        self.getValue = getValue
        self.setValue = setValue
        getSelectedId = nil
    }

    /// Creates a SelectionWrapper with ID extraction capability for scrolling support
    /// - Parameters:
    ///   - getValue: Closure that returns the current selection value
    ///   - setValue: Closure that updates the selection value
    ///   - getSelectedId: Closure that returns the selected item's identifier
    init(
        getValue: @escaping @Sendable () -> Any?,
        setValue: @escaping @Sendable (Any?) -> Void,
        getSelectedId: @escaping @Sendable () -> Any?
    ) {
        self.getValue = getValue
        self.setValue = setValue
        self.getSelectedId = getSelectedId
    }
}

/// Private storage for selection bindings, keyed by type identifier
///
/// This global storage maintains selection state across LazyVStackList instances
/// by using ObjectIdentifier as keys to differentiate between different selection types.
@MainActor private var selectionStorage: [ObjectIdentifier: SelectionWrapper] = [:]

extension LazyVStackList {
    /// The currently selected item for this LazyVStackList instance
    ///
    /// Returns the currently selected item if selection is enabled, otherwise returns nil.
    /// The selection is retrieved from the global selection storage using the instance's type identifier.
    ///
    /// - Returns: The selected item, or nil if no selection is active or selection is disabled
    var selection: Any? {
        guard
            let identifier = selectionIdentifier,
            let wrapper = selectionStorage[identifier]
        else {
            return nil
        }

        return wrapper.getValue()
    }

    /// Creates a LazyVStackList with selection capability and automatic scroll restoration
    ///
    /// This initializer creates a LazyVStackList that supports item selection with visual feedback.
    /// The selection state is managed through a binding, and the list automatically handles
    /// selection changes and visual updates. Keyboard navigation is automatically enabled by
    /// collecting items from child LazyVStackNavigationLink components.
    ///
    /// - Parameters:
    ///   - selection: Binding to the currently selected item. When an item is selected,
    ///                this binding will be updated with the new selection.
    ///   - spacing: Spacing between items in points. Defaults to 0.
    ///   - showHoverEffect: Whether to show hover effects when items are hovered.
    ///                      Defaults to false for consistent behavior.
    ///   - useNativeScrollView: Whether to enable scrolling behavior when content exceeds bounds.
    ///                      Defaults to true for selection-enabled lists.
    ///   - content: ViewBuilder that creates the view content containing selectable items.
    init<SelectionValue>(
        selection: Binding<SelectionValue?>,
        spacing: CGFloat? = 0,
        showHoverEffect: Bool = false,
        useNativeScrollView: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) where SelectionValue: Identifiable & Hashable & Sendable, SelectionValue.ID: Sendable {
        let identifier = ObjectIdentifier(SelectionValue.self)

        // Store a wrapper that can update the binding
        selectionStorage[identifier] = SelectionWrapper(
            getValue: { selection.wrappedValue },
            setValue: { newValue in
                selection.wrappedValue = newValue as? SelectionValue
            },
            getSelectedId: { selection.wrappedValue?.id }
        )
        _selectionIdentifier = .constant(identifier)

        self.spacing = spacing
        self.showHoverEffect = showHoverEffect
        self.useNativeScrollView = useNativeScrollView
        self.content = content
    }

    /// The body of the LazyVStackList view
    ///
    /// This body creates the main view structure with conditional scrolling, selection handling,
    /// and automatic scroll restoration capabilities. It collects navigation items from child
    /// LazyVStackNavigationLink components and enables keyboard navigation.
    var body: some View {
        ConditionalScrollView(isEnabled: useNativeScrollView) {
            LazyVStack(spacing: spacing) {
                content()
            }
            .padding(.horizontal, 10)
            .environment(\.lazyVStackListContext, SelectionContext(
                selectedItem: selectionEnabled ? selection : nil,
                showHoverEffect: showHoverEffect,
                selectionEnabled: selectionEnabled,
                onSelectionChange: { newValue in
                    if
                        selectionEnabled,
                        let identifier = selectionIdentifier,
                        let wrapper = selectionStorage[identifier]
                    {
                        wrapper.setValue(newValue)
                    }
                }
            ))
        }
        .onPreferenceChange(NavigationItemsPreferenceKey.self) { items in
            collectedItems = items
        }
        .focusable()
        .focusEffectDisabled()
        .onMoveCommand { direction in
            handleKeyboardNavigation(direction: direction)
        }
    }

    /// Handles keyboard navigation for arrow keys
    /// - Parameter direction: The direction of movement
    private func handleKeyboardNavigation(direction: MoveCommandDirection) {
        guard
            selectionEnabled,
            !collectedItems.isEmpty,
            let identifier = selectionIdentifier,
            let wrapper = selectionStorage[identifier],
            let currentSelection = wrapper.getValue()
        else { return }

        // Get the current selection's ID
        guard let currentSelectionId = (currentSelection as? any Identifiable)?.id as? AnyHashable else { return }

        // Find the current index
        guard let currentIndex = collectedItems.firstIndex(where: { $0.id == currentSelectionId }) else { return }

        // Calculate the new index based on direction
        let newIndex: Int
        switch direction {
        case .up:
            guard currentIndex > 0 else { return }

            newIndex = currentIndex - 1

        case .down:
            guard currentIndex < collectedItems.count - 1 else { return }

            newIndex = currentIndex + 1

        default:
            return
        }

        // Update the selection
        wrapper.setValue(collectedItems[newIndex].value)
    }
}

// MARK: - Environment Support

/// Wrapper for navigation items that can be used in preference keys
///
/// This struct wraps navigation item data and implements Equatable by comparing IDs only,
/// since the value is type-erased and cannot be directly compared.
@MainActor
private struct NavigationItem: @MainActor Equatable {
    /// The unique identifier for this navigation item
    let id: AnyHashable

    /// The type-erased value of the navigation item
    let value: Any

    /// Compares two NavigationItems by their IDs only
    static func == (lhs: NavigationItem, rhs: NavigationItem) -> Bool {
        lhs.id == rhs.id
    }
}

/// Preference key for collecting navigation items from child views
///
/// This preference key allows LazyVStackNavigationLink components to report their values
/// up the view hierarchy, enabling automatic keyboard navigation without explicit item lists.
private struct NavigationItemsPreferenceKey: PreferenceKey {
    /// Array of navigation items
    static let defaultValue: [NavigationItem] = []

    /// Combines multiple navigation items from different child views
    /// - Parameters:
    ///   - value: The current accumulated value
    ///   - nextValue: Closure that returns the next value to combine
    static func reduce(value: inout [NavigationItem], nextValue: () -> [NavigationItem]) {
        value.append(contentsOf: nextValue())
    }
}

/// Context for sharing selection state management through the SwiftUI environment
///
/// This context is passed down to child views through the environment system,
/// allowing LazyVStackNavigationLink components to access selection state and callbacks.
@MainActor
private struct SelectionContext {
    /// The currently selected item, if any
    let selectedItem: Any?

    /// Whether to show hover effects on interactive elements
    let showHoverEffect: Bool

    /// Whether selection functionality is enabled for this list
    let selectionEnabled: Bool

    /// Callback invoked when selection changes, receives the newly selected item
    let onSelectionChange: @MainActor (Any) -> Void
}

/// Environment key for passing selection context through the SwiftUI environment
///
/// This key allows LazyVStackList to pass selection state and callbacks down to
/// LazyVStackNavigationLink and LazyVStackListRowItem components through the environment system.
private struct LazyVStackListContextKey: EnvironmentKey {
    /// Default value when no selection context is available
    static let defaultValue: SelectionContext? = nil
}

/// Extension to add selection context to SwiftUI's EnvironmentValues
private extension EnvironmentValues {
    /// The LazyVStackList selection context available in the current environment
    ///
    /// This property provides access to the selection state and callbacks
    /// for LazyVStackNavigationLink components.
    var lazyVStackListContext: SelectionContext? {
        get { self[LazyVStackListContextKey.self] }
        set { self[LazyVStackListContextKey.self] = newValue }
    }
}

/// A conditional scroll view that switches between ScrollView and VStack based on configuration
///
/// This view provides the ability to conditionally enable scrolling behavior.
/// When scrolling is enabled, it wraps content in a ScrollView. When disabled,
/// it uses a VStack with top alignment for non-scrollable layouts.
private struct ConditionalScrollView<Content: View>: View {
    /// Whether scrolling should be enabled
    private let isEnabled: Bool

    /// The content to be displayed
    private let content: () -> Content

    /// Creates a ConditionalScrollView
    /// - Parameters:
    ///   - isEnabled: Whether to enable scrolling behavior
    ///   - content: ViewBuilder that creates the content to display
    init(
        isEnabled: Bool,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.isEnabled = isEnabled
        self.content = content
    }

    /// The body of the conditional scroll view
    ///
    /// Conditionally wraps content in either a ScrollView (when scrolling is enabled)
    /// or a top-aligned VStack (when scrolling is disabled).
    var body: some View {
        if isEnabled {
            ScrollView {
                content()
            }
        } else {
            VStack(alignment: .leading, spacing: 0) {
                content()
            }
        }
    }
}

// MARK: - LazyVStackNavigationLink

/// Creates a NavigationLink with automatic selectable styling for LazyVStackList
///
/// This component provides a selectable list item that integrates with LazyVStackList's
/// selection system. It automatically handles visual feedback for selection and hover states,
/// matching the appearance of SwiftUI's List components.
///
/// - Parameters:
///   - value: The value associated with this link, used for selection identification
///   - label: ViewBuilder that creates the label content for the link
@MainActor
struct LazyVStackNavigationLink<Value: Identifiable & Hashable>: View {
    /// The value associated with this navigation link
    let value: Value

    /// ViewBuilder that creates the label content
    @ViewBuilder let label: () -> any View

    /// The window's control active state for focus-dependent styling
    @Environment(\.controlActiveState) private var controlActiveState

    /// Context for sharing selection state with the parent LazyVStackList
    @Environment(\.lazyVStackListContext) private var context

    /// Whether the link is currently being hovered
    @State private var isHovered = false

    /// Creates a LazyVStackNavigationLink
    /// - Parameters:
    ///   - value: The value associated with this link, must be Identifiable and Hashable
    ///   - label: ViewBuilder that creates the content to display in the link
    init(value: Value, @ViewBuilder label: @escaping () -> any View) {
        self.value = value
        self.label = label
    }

    /// The body of the LazyVStackNavigationLink
    ///
    /// Creates a selectable row with appropriate styling based on selection and hover state.
    /// The row automatically handles selection changes and visual feedback.
    var body: some View {
        let isSelected: Bool = {
            guard
                let context,
                context.selectionEnabled,
                let selectedItem = context.selectedItem else { return false }

            // Compare by ID for Identifiable items
            if
                let selectedIdentifiable = selectedItem as? any Identifiable,
                selectedIdentifiable.id as? Value.ID == value.id
            {
                return true
            }
            // Fallback to direct comparison
            return (selectedItem as? Value) == value
        }()

        HStack {
            AnyView(label())
            Spacer()
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(backgroundColor(isSelected: isSelected, isHovered: isHovered))
        )
        .foregroundStyle(controlActiveState == .key ? .primary : .secondary)
        .opacity(controlActiveState == .key ? 1.0 : 0.5)
        .contentShape(.rect)
        .onHover { hovering in
            if context?.showHoverEffect == true {
                withAnimation(.themeEaseInOutFast) {
                    isHovered = hovering
                }
            }
        }
        .onTapGesture {
            if context?.selectionEnabled == true {
                withAnimation(.themeEaseInOutFast) {
                    context?.onSelectionChange(value)
                }
            }
        }
        .id(value.id)
        .preference(
            key: NavigationItemsPreferenceKey.self,
            value: [NavigationItem(id: AnyHashable(value.id), value: value)]
        )
    }

    /// Returns the appropriate background color based on selection and hover state
    ///
    /// This method provides colors that match SwiftUI's List component behavior,
    /// including different colors for active/inactive windows and hover states.
    ///
    /// - Parameters:
    ///   - isSelected: Whether this item is currently selected
    ///   - isHovered: Whether this item is currently being hovered
    /// - Returns: The appropriate background color for the current state
    private func backgroundColor(isSelected: Bool, isHovered: Bool) -> Color {
        if isSelected {
            // Match List's selection color
            if controlActiveState == .key {
                Color(NSColor.selectedContentBackgroundColor)
            } else {
                // Gray selection for unfocused window (like List)
                Color(NSColor.unemphasizedSelectedContentBackgroundColor)
            }
        } else if isHovered, context?.showHoverEffect == true {
            Color(NSColor.controlBackgroundColor)
        } else {
            Color.clear
        }
    }
}

#Preview {
    // Mock enum for preview that mimics RootNavigationPage structure
    enum MockRootNavigationPage: Int, CaseIterable, Identifiable, Hashable, Sendable {
        case license, general, spaces, groups, advanced

        var id: Int { rawValue }
        var name: String {
            switch self {
            case .license: "License"
            case .general: "General"
            case .spaces: "Spaces"
            case .groups: "Groups"
            case .advanced: "Advanced"
            }
        }

        var symbolName: String {
            switch self {
            case .license: "key.fill"
            case .general: "gear"
            case .spaces: "square.3.layers.3d"
            case .groups: "rectangle.3.group"
            case .advanced: "star"
            }
        }

        var viewForSidebar: some View {
            HStack {
                Image(systemName: symbolName)
                Text(name)
                Spacer()
            }
        }
    }

    struct PreviewView: View {
        @State private var selectedPage: MockRootNavigationPage? = .license

        // Use mock enum cases
        private let mockRootPages: [MockRootNavigationPage] = [
            .license,
            .general,
            .spaces,
            .groups,
            .advanced
        ]

        var body: some View {
            NavigationSplitView {
                LazyVStackList(
                    selection: $selectedPage
                ) {
                    ForEach(mockRootPages) { rootPage in
                        LazyVStackNavigationLink(value: rootPage) {
                            rootPage.viewForSidebar
                        }

                        // Add spacing after license item
                        if rootPage == .license {
                            Section { }
                        }
                    }
                }
                .navigationSplitViewColumnWidth(min: 200, ideal: 250)
            } detail: {
                VStack {
                    Text(
                        """
                        Selected Page: \(selectedPage?.name ?? "None")
                        """
                    )
                    .padding()

                    Spacer()
                }
            }
            .frame(width: 600, height: 400)
        }
    }

    return PreviewView()
}

#Preview("Simple LazyVStackList") {
    LazyVStackList {
        ForEach(1 ... 20, id: \.self) { index in
            HStack {
                Image(systemName: "circle.fill")
                    .foregroundColor(.blue)
                Text("Item \(index)")
                Spacer()
                Text("Detail")
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
    }
    .frame(width: 300, height: 400)
}
