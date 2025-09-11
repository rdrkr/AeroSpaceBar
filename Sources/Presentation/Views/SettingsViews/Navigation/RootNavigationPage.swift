// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// An enumeration of navigation options for the settings interface.
enum RootNavigationPage: Int, CaseIterable, NavigationPage {
    /// A case that represents general application settings.
    case general
    /// A case that represents spaces settings.
    case spaces
    /// A case that represents groups settings.
    case groups
    /// A case that represents advanced settings.
    case advanced
    #if DEBUG
        /// A case that represents developer settings for feature flags and debugging.
        case developer
    #endif

    /// The ID of the navigation option.
    var id: Int { rawValue }

    /// The name of the navigation option.
    var name: LocalizedStringResource {
        switch self {
        case .general: LocalizedStringResource("General", comment: "Title for the General settings section.")
        case .spaces: LocalizedStringResource("Spaces", comment: "Title for the Spaces settings section.")
        case .groups: LocalizedStringResource("Groups", comment: "Title for the Groups settings section.")
        case .advanced: LocalizedStringResource("Advanced", comment: "Title for the Advanced settings section.")
        #if DEBUG
            case .developer: LocalizedStringResource("Developer", comment: "Title for the Developer settings section.")
        #endif
        }
    }

    /// The symbol name of the navigation option.
    var symbolName: String {
        switch self {
        case .general: "gear"
        case .spaces: "square.3.layers.3d"
        case .groups: "rectangle.3.group"
        case .advanced: "star"
        #if DEBUG
            case .developer: "hammer"
        #endif
        }
    }

    /// The parent page of the navigation option.
    var parentPage: (any NavigationPage)? { nil }

    /// A view builder that the split view uses to show a view for the selected navigation option.
    @MainActor
    var viewForPage: PageView {
        switch self {
        case .general:
            return PageView(GeneralSettingsView())
        case .spaces:
            return PageView(SpacesSettingsView())
        case .groups:
            return PageView(GroupsSettingsView())
        case .advanced:
            return PageView(AdvancedSettingsView())
        #if DEBUG
            case .developer:
                return PageView(DeveloperSettingsView())
        #endif
        }
    }
}
