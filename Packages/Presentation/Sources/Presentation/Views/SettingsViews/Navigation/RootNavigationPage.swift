// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Domain
import SwiftUI

/// An enumeration of navigation options for the settings interface.
enum RootNavigationPage: Int, CaseIterable, NavigationPage {
    /// A case that represents license and subscription settings.
    case license
    /// A case that represents general application settings.
    case general
    /// A case that represents spaces settings.
    case spaces
    /// A case that represents groups settings.
    case groups
    /// A case that represents software update settings.
    case updates
    /// A case that represents advanced settings.
    case advanced
    #if DEBUG
        /// A case that represents developer settings for feature flags and debugging.
        case developer
    #endif

    /// The ID of the navigation option.
    var id: Int {
        rawValue
    }

    /// The name of the navigation option.
    var name: String {
        switch self {
        case .license: String(
                localized: LocalizedStringResource("License", comment: "Title for the License settings section.")
            )

        case .general: String(
                localized: LocalizedStringResource("General", comment: "Title for the General settings section.")
            )

        case .spaces: String(
                localized: LocalizedStringResource("Spaces", comment: "Title for the Spaces settings section.")
            )

        case .groups: String(
                localized: LocalizedStringResource("Groups", comment: "Title for the Groups settings section.")
            )

        case .updates: String(
                localized: LocalizedStringResource("Updates", comment: "Title for the Updates settings section.")
            )

        case .advanced: String(
                localized: LocalizedStringResource("Advanced", comment: "Title for the Advanced settings section.")
            )

        #if DEBUG
            case .developer: String(
                    localized: LocalizedStringResource(
                        "Developer",
                        comment: "Title for the Developer settings section."
                    )
                )
        #endif
        }
    }

    /// The symbol name of the navigation option.
    var symbolName: String {
        switch self {
        case .license: "key.fill"
        case .general: "gear"
        case .spaces: "square.3.layers.3d.top.filled"
        case .groups: "rectangle.3.group.fill"
        case .updates: "arrow.trianglehead.2.clockwise.rotate.90.circle.fill"
        case .advanced: "star.fill"

        #if DEBUG
            case .developer: "hammer.fill"
        #endif
        }
    }

    /// The description/subtitle text for this navigation page.
    var description: String {
        switch self {
        case .license: String(
                localized: LocalizedStringResource("Manage your license and subscription settings.")
            )

        case .general: String(
                localized: LocalizedStringResource(
                    """
                    Manage your overall setup and preferences for AeroSpaceBar, \
                    such as AeroSpace path and Appearance settings.
                    """
                )
            )

        case .spaces: String(
                localized: LocalizedStringResource(
                    "Fine-tune how spaces look and behave: opacity, blur, titles, and more."
                )
            )

        case .groups: String(
                localized: LocalizedStringResource(
                    """
                    Organize menu bar applications into groups for better visual organization,\
                    including background, border, opacity and more.
                    """
                )
            )

        case .updates: String(
                localized: LocalizedStringResource(
                    "Manage software update preferences and check for new versions of AeroSpaceBar."
                )
            )

        case .advanced: String(
                localized: LocalizedStringResource(
                    "Configure advanced behaviors, logging, performance metrics, and reset options."
                )
            )

        #if DEBUG
            case .developer: String(
                    localized: LocalizedStringResource(
                        "Developer settings for feature flags and debugging options."
                    )
                )
        #endif
        }
    }

    /// The icon for the navigation option.
    @MainActor
    var icon: AnyView {
        switch self {
        case .general:
            AnyView(defaultIcon.foregroundColor(Color.gray))

        case .updates:
            AnyView(defaultIcon.foregroundColor(Color.indigo))

        case .advanced:
            AnyView(defaultIcon.foregroundColor(Color.red))

        default:
            AnyView(defaultIcon.foregroundColor(Color.accentColor))
        }
    }

    /// The parent page of the navigation option.
    var parentPage: (any NavigationPage)? {
        nil
    }

    /// The view for the sidebar item.
    @MainActor
    var viewForSidebar: AnyView {
        AnyView(
            Group {
                switch self {
                case .license:
                    LicenseSettingsSidebarItemView()

                default:
                    defaultViewForSidebar(icon)
                }
            }
        )
    }

    /// A view builder that the split view uses to show a view for the selected navigation option.
    @MainActor
    var viewForPage: PageView {
        switch self {
        case .license:
            return PageView(LicenseSettingsView())

        case .general:
            return PageView(GeneralSettingsView())

        case .spaces:
            return PageView(SpacesSettingsView())

        case .groups:
            return PageView(GroupsSettingsView())

        case .updates:
            return PageView(UpdatesSettingsView())

        case .advanced:
            return PageView(AdvancedSettingsView())

        #if DEBUG

            case .developer:
                return PageView(DeveloperSettingsView())
        #endif
        }
    }
}
