// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// A reusable toggle component for feature flags in developer settings.
///
/// This component provides a consistent interface for enabling/disabling feature flags
/// during development and testing. Only available in debug builds.
struct FeatureFlagToggle: View {
    /// The title text for the feature flag
    let title: String

    /// The description text explaining what the feature flag does
    let description: String

    /// The current enabled state
    let isEnabled: Bool

    /// Whether the toggle is disabled
    let isDisabled: Bool

    /// The action to perform when the toggle state changes
    let onToggle: (Bool) -> Void

    /// Creates a new feature flag toggle with a binding.
    /// - Parameters:
    ///   - title: The title text for the feature flag
    ///   - description: The description text explaining what the feature flag does
    ///   - isEnabled: A binding to the boolean value that controls the feature flag state
    init(
        title: String,
        description: String,
        isEnabled: Binding<Bool>,
        isDisabled: Bool = false
    ) {
        self.title = title
        self.description = description
        self.isEnabled = isEnabled.wrappedValue
        self.isDisabled = isDisabled
        onToggle = { newValue in
            isEnabled.wrappedValue = newValue
        }
    }

    /// Creates a new feature flag toggle with an action closure.
    /// - Parameters:
    ///   - title: The title text for the feature flag
    ///   - description: The description text explaining what the feature flag does
    ///   - isEnabled: The current enabled state
    ///   - onToggle: The action to perform when the toggle state changes
    init(
        title: String,
        description: String,
        isEnabled: Bool,
        isDisabled: Bool = false,
        onToggle: @escaping (Bool) -> Void
    ) {
        self.title = title
        self.description = description
        self.isEnabled = isEnabled
        self.isDisabled = isDisabled
        self.onToggle = onToggle
    }

    var body: some View {
        VStack(alignment: .leading) {
            Toggle(isOn: Binding(
                get: { isEnabled },
                set: { newValue in
                    if !isDisabled {
                        onToggle(newValue)
                    }
                }
            )) {
                Text(LocalizedStringResource(stringLiteral: title))
                    .font(.body)
                    .foregroundColor(isDisabled ? .secondary : .primary)
                    .tag("feature-flag-toggle-title")
            }
            .toggleStyle(.switch)
            .disabled(isDisabled)
            .tag("feature-flag-toggle-switch")

            Text(LocalizedStringResource(stringLiteral: description))
                .secondaryText()
                .fixedSize(horizontal: false, vertical: true)
                .tag("feature-flag-toggle-description")
        }
        .tag("feature-flag-toggle")
    }
}

#Preview {
    Form {
        Section {
            FeatureFlagToggle(
                title: "Enable Spaces",
                description: "Show/hide the Spaces feature in the menu bar and settings",
                isEnabled: .constant(true)
            )
        }
    }
    .settingsFormStyle()
}
