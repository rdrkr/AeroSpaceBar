// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// An enumeration of navigation options for the settings interface.
enum SettingsNavigationOptions: Equatable, Hashable, Identifiable, CaseIterable {
    /// A case that represents general application settings.
    case general
    /// A case that represents appearance settings.
    case appearance
    /// A case that represents advanced settings.
    case advanced

    /// The ID of the navigation option.
    var id: String {
        switch self {
        case .general: "General"
        case .appearance: "Appearance"
        case .advanced: "Advanced"
        }
    }

    /// The name of the navigation option.
    var name: LocalizedStringResource {
        switch self {
        case .general: LocalizedStringResource("General", comment: "Title for the General settings section.")
        case .appearance: LocalizedStringResource("Appearance", comment: "Title for the Appearance settings section.")
        case .advanced: LocalizedStringResource("Advanced", comment: "Title for the Advanced settings section.")
        }
    }

    /// The symbol name of the navigation option.
    var symbolName: String {
        switch self {
        case .general: "gear"
        case .appearance: "paintbrush"
        case .advanced: "star"
        }
    }

    /// A view builder that the split view uses to show a view for the selected navigation option.
    @MainActor @ViewBuilder func viewForPage() -> some View {
        switch self {
        case .general: GeneralSettingsView()
        case .appearance: AppearanceSettingsView()
        case .advanced: AdvancedSettingsView()
        }
    }
}
